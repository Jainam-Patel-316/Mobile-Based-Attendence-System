// routes/attendance.js
// GET  /api/attendance/subject/:subjectId    — all students + % for a subject
// POST /api/attendance/mark                  — faculty marks attendance
// PATCH /api/attendance/:id/override         — admin overrides a record
// GET  /api/attendance/student/:studentId    — student views own % per subject
// GET  /api/attendance/reports/bunkers       — the "who entered but skipped class" report

const express     = require('express');
const db          = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');

const router = express.Router();

// -------------------------------------------------------
// GET /api/attendance/subject/:subjectId
// Auth: faculty or admin
// Returns: all students in that subject with their attendance %
// -------------------------------------------------------
router.get('/subject/:subjectId', verifyToken, roleCheck('faculty', 'admin'), async (req, res) => {
    const { subjectId } = req.params;

    try {
        // Verify the subject exists and (if faculty) belongs to them
        const [subject] = await db.query(
            'SELECT id, name, code, total_lectures, faculty_id FROM subjects WHERE id = ?',
            [subjectId]
        );

        if (!subject.length) {
            return res.status(404).json({ error: 'Subject not found.' });
        }

        // Faculty can only see their own subjects
        if (req.user.role === 'faculty' && subject[0].faculty_id !== req.user.id) {
            return res.status(403).json({ error: 'This subject is not assigned to you.' });
        }

        // Get all students in the subject's semester
        const [students] = await db.query(
            `SELECT 
                u.id,
                u.name,
                u.enrollment_no,
                COUNT(ca.id)                                        AS total_marked,
                SUM(ca.status = 'present' OR ca.status = 'late')   AS present_count,
                ROUND(
                    SUM(ca.status = 'present' OR ca.status = 'late') / 
                    GREATEST(COUNT(ca.id), 1) * 100, 1
                )                                                   AS percentage
             FROM users u
             LEFT JOIN classroom_attendance ca 
                ON ca.student_id = u.id AND ca.subject_id = ?
             WHERE u.role = 'student' AND u.semester_id = ?
             GROUP BY u.id, u.name, u.enrollment_no
             ORDER BY u.enrollment_no`,
            [subjectId, subject[0].semester_id ?? null]
        );

        res.json({
            subject: subject[0],
            students
        });

    } catch (err) {
        console.error('Get subject attendance error:', err);
        res.status(500).json({ error: 'Server error fetching attendance.' });
    }
});

// -------------------------------------------------------
// POST /api/attendance/mark
// Auth: faculty or admin
// Body: { subjectId, classDate, session, records: [{ studentId, status }] }
// status: 'present' | 'absent' | 'late'
// -------------------------------------------------------
router.post('/mark', verifyToken, roleCheck('faculty', 'admin'), async (req, res) => {
    const { subjectId, classDate, session, records } = req.body;

    if (!subjectId || !classDate || !session || !records || !records.length) {
        return res.status(400).json({ error: 'subjectId, classDate, session, and records are required.' });
    }

    try {
        // Verify subject
        const [subject] = await db.query(
            'SELECT id, faculty_id FROM subjects WHERE id = ?',
            [subjectId]
        );

        if (!subject.length) {
            return res.status(404).json({ error: 'Subject not found.' });
        }

        if (req.user.role === 'faculty' && subject[0].faculty_id !== req.user.id) {
            return res.status(403).json({ error: 'This subject is not assigned to you.' });
        }

        // Insert or update each student record
        // ON DUPLICATE KEY UPDATE handles re-marking (faculty corrects a mistake same day)
        const insertPromises = records.map(({ studentId, status }) =>
            db.query(
                `INSERT INTO classroom_attendance 
                    (student_id, subject_id, class_date, session, status, marked_by, mark_type)
                 VALUES (?, ?, ?, ?, ?, ?, 'manual')
                 ON DUPLICATE KEY UPDATE 
                    status = VALUES(status),
                    marked_by = VALUES(marked_by),
                    marked_at = CURRENT_TIMESTAMP`,
                [studentId, subjectId, classDate, session, status, req.user.id]
            )
        );

        await Promise.all(insertPromises);

        res.json({ message: `Attendance saved for ${records.length} students.` });

    } catch (err) {
        console.error('Mark attendance error:', err);
        res.status(500).json({ error: 'Server error saving attendance.' });
    }
});

// -------------------------------------------------------
// PATCH /api/attendance/:id/override
// Auth: admin only
// Body: { newStatus, reason }
// Writes to manual_override_log for audit trail
// -------------------------------------------------------
router.patch('/:id/override', verifyToken, roleCheck('admin'), async (req, res) => {
    const { id } = req.params;
    const { newStatus, reason } = req.body;

    if (!newStatus || !reason) {
        return res.status(400).json({ error: 'newStatus and reason are required.' });
    }

    const validStatuses = ['present', 'absent', 'late'];
    if (!validStatuses.includes(newStatus)) {
        return res.status(400).json({ error: `newStatus must be: ${validStatuses.join(', ')}` });
    }

    try {
        // Get the current record
        const [record] = await db.query(
            'SELECT id, status FROM classroom_attendance WHERE id = ?',
            [id]
        );

        if (!record.length) {
            return res.status(404).json({ error: 'Attendance record not found.' });
        }

        const prevStatus = record[0].status;

        if (prevStatus === newStatus) {
            return res.status(400).json({ error: 'New status is same as current status. No change needed.' });
        }

        // Update the attendance record
        await db.query(
            'UPDATE classroom_attendance SET status = ?, note = ? WHERE id = ?',
            [newStatus, `Override: ${reason}`, id]
        );

        // Write audit trail
        await db.query(
            `INSERT INTO manual_override_log (attendance_id, overridden_by, reason, prev_status, new_status)
             VALUES (?, ?, ?, ?, ?)`,
            [id, req.user.id, reason, prevStatus, newStatus]
        );

        res.json({ message: 'Attendance overridden successfully.', prevStatus, newStatus });

    } catch (err) {
        console.error('Override error:', err);
        res.status(500).json({ error: 'Server error during override.' });
    }
});

// -------------------------------------------------------
// GET /api/attendance/student/:studentId
// Auth: student (own only) or admin
// Returns: attendance % per subject for a student
// -------------------------------------------------------
router.get('/student/:studentId', verifyToken, async (req, res) => {
    const { studentId } = req.params;

    // Students can only view their own data
    if (req.user.role === 'student' && req.user.id !== parseInt(studentId)) {
        return res.status(403).json({ error: 'You can only view your own attendance.' });
    }

    // Non-student roles (admin, faculty) can view anyone
    if (!['admin', 'faculty', 'student'].includes(req.user.role)) {
        return res.status(403).json({ error: 'Access denied.' });
    }

    try {
        const [rows] = await db.query(
            `SELECT
                s.id            AS subject_id,
                s.name          AS subject_name,
                s.code          AS subject_code,
                s.total_lectures,
                COUNT(ca.id)                                        AS classes_held,
                SUM(ca.status = 'present' OR ca.status = 'late')   AS classes_attended,
                ROUND(
                    SUM(ca.status = 'present' OR ca.status = 'late') /
                    GREATEST(COUNT(ca.id), 1) * 100, 1
                )                                                   AS percentage
             FROM subjects s
             LEFT JOIN classroom_attendance ca
                ON ca.subject_id = s.id AND ca.student_id = ?
             JOIN users u ON u.id = ? AND u.semester_id = s.semester_id
             GROUP BY s.id, s.name, s.code, s.total_lectures
             ORDER BY s.name`,
            [studentId, studentId]
        );

        res.json({ studentId: parseInt(studentId), subjects: rows });

    } catch (err) {
        console.error('Student attendance error:', err);
        res.status(500).json({ error: 'Server error fetching student attendance.' });
    }
});

// -------------------------------------------------------
// GET /api/attendance/reports/bunkers
// Auth: admin or faculty
// Query params: ?date=YYYY-MM-DD&session=morning|afternoon
// The key feature: students who entered college but are absent in class
// -------------------------------------------------------
router.get('/reports/bunkers', verifyToken, roleCheck('admin', 'faculty'), async (req, res) => {
    const { date, session } = req.query;
    const targetDate = date || new Date().toISOString().split('T')[0];

    try {
        let query = `
            SELECT 
                u.name              AS student_name,
                u.enrollment_no,
                cel.session,
                s.name              AS subject_name,
                s.code              AS subject_code,
                cel.scanned_at      AS gate_entry_time,
                COALESCE(ca.status, 'not marked') AS class_status
            FROM college_entry_log cel
            JOIN users u        ON u.id = cel.user_id
            JOIN subjects s     ON s.semester_id = u.semester_id
            LEFT JOIN classroom_attendance ca
                ON  ca.student_id = cel.user_id
                AND ca.subject_id = s.id
                AND ca.class_date = cel.entry_date
                AND ca.session    = cel.session
            WHERE cel.entry_date = ?
              AND cel.status     = 'valid'
              AND (ca.status IS NULL OR ca.status = 'absent')
        `;
        const params = [targetDate];

        if (session) {
            query += ' AND cel.session = ?';
            params.push(session);
        }

        // Faculty only see their own subjects
        if (req.user.role === 'faculty') {
            query += ' AND s.faculty_id = ?';
            params.push(req.user.id);
        }

        query += ' ORDER BY u.enrollment_no, s.name';

        const [rows] = await db.query(query, params);

        res.json({
            date: targetDate,
            session: session || 'all',
            bunkerCount: rows.length,
            records: rows
        });

    } catch (err) {
        console.error('Bunker report error:', err);
        res.status(500).json({ error: 'Server error generating bunker report.' });
    }
});

module.exports = router;
