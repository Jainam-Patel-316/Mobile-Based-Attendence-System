// routes/faculty.js
// GET /api/faculty/subjects   — faculty views their assigned subjects
// GET /api/faculty/students/:subjectId — students enrolled in a subject

const express     = require('express');
const db          = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');

const router = express.Router();

// -------------------------------------------------------
// GET /api/faculty/subjects
// Auth: faculty
// Returns subjects assigned to the logged-in faculty member
// -------------------------------------------------------
router.get('/subjects', verifyToken, roleCheck('faculty'), async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT s.id, s.name, s.code, s.total_lectures,
                    sem.name     AS semester_name,
                    sem.division AS section
             FROM subjects s
             JOIN semesters sem ON sem.id = s.semester_id
             WHERE s.faculty_id = ?
             ORDER BY sem.name, s.name`,
            [req.user.id]
        );

        res.json({ subjects: rows });

    } catch (err) {
        console.error('Faculty subjects error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// GET /api/faculty/students/:subjectId
// Auth: faculty
// Returns student list for a specific subject (for roll call)
// -------------------------------------------------------
router.get('/students/:subjectId', verifyToken, roleCheck('faculty'), async (req, res) => {
    const { subjectId } = req.params;

    try {
        // Verify the subject belongs to this faculty
        const [subject] = await db.query(
            'SELECT id, semester_id, faculty_id FROM subjects WHERE id = ?',
            [subjectId]
        );

        if (!subject.length) {
            return res.status(404).json({ error: 'Subject not found.' });
        }

        if (subject[0].faculty_id !== req.user.id) {
            return res.status(403).json({ error: 'This subject is not assigned to you.' });
        }

        // Get all students in the subject's semester
        const [students] = await db.query(
            `SELECT id, name, enrollment_no
             FROM users
             WHERE role = 'student' AND semester_id = ? AND is_active = TRUE
             ORDER BY enrollment_no`,
            [subject[0].semester_id]
        );

        res.json({ subjectId: parseInt(subjectId), students });

    } catch (err) {
        console.error('Faculty students error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

module.exports = router;
