// routes/admin.js
// All admin-only management routes
//
// GET  /api/admin/qr-settings          — get current time windows
// PUT  /api/admin/qr-settings          — update time windows + college IP
// GET  /api/admin/users                — list all users (filterable by role)
// DELETE /api/admin/users/:id          — deactivate a user
// GET  /api/admin/subjects             — list all subjects
// POST /api/admin/subjects             — create a subject
// PUT  /api/admin/subjects/:id         — update a subject
// GET  /api/admin/semesters            — list all semesters
// POST /api/admin/semesters            — create a semester

const express     = require('express');
const db          = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');

const router = express.Router();

// All routes in this file are admin-only
router.use(verifyToken, roleCheck('admin'));

// -------------------------------------------------------
// GET /api/admin/qr-settings
// -------------------------------------------------------
router.get('/qr-settings', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM qr_settings ORDER BY session');
        res.json({ settings: rows });
    } catch (err) {
        console.error('QR settings GET error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// PUT /api/admin/qr-settings
// Body: { session, window_start, window_end, grace_minutes, college_ip, is_active,
//         geo_lat, geo_lng, geo_radius_meters }
// geo_lat/geo_lng optional — set to null to disable geofencing
// -------------------------------------------------------
router.put('/qr-settings', async (req, res) => {
    const {
        session, window_start, window_end, grace_minutes,
        college_ip, is_active,
        geo_lat, geo_lng, geo_radius_meters
    } = req.body;

    if (!session || !window_start || !window_end || !college_ip) {
        return res.status(400).json({ error: 'session, window_start, window_end, college_ip are required.' });
    }

    if (geo_lat !== undefined && geo_lat !== null) {
        const lat = parseFloat(geo_lat);
        const lng = parseFloat(geo_lng);
        if (isNaN(lat) || lat < -90 || lat > 90)
            return res.status(400).json({ error: 'geo_lat must be between -90 and 90.' });
        if (isNaN(lng) || lng < -180 || lng > 180)
            return res.status(400).json({ error: 'geo_lng must be between -180 and 180.' });
    }

    try {
        // Fetch the existing row first. The admin UI's time-window form doesn't expose
        // geo_lat/geo_lng/geo_radius_meters, so those keys are simply absent from req.body
        // on a normal save — that must NOT be treated the same as "explicitly clear this field".
        const [existingRows] = await db.query(
            'SELECT geo_lat, geo_lng, geo_radius_meters FROM qr_settings WHERE session = ?',
            [session]
        );

        if (!existingRows.length) {
            return res.status(404).json({ error: `No QR settings found for ${session} session.` });
        }
        const existing = existingRows[0];

        // Only touch a geo field if the client actually included that key in the request body.
        // This preserves "set to null to disable geofencing" as a real, explicit action,
        // while requests that simply omit these fields keep the stored values untouched.
        const finalGeoLat    = ('geo_lat' in req.body)            ? geo_lat            : existing.geo_lat;
        const finalGeoLng    = ('geo_lng' in req.body)             ? geo_lng            : existing.geo_lng;
        const finalGeoRadius = ('geo_radius_meters' in req.body)   ? geo_radius_meters  : existing.geo_radius_meters;

        await db.query(
            `UPDATE qr_settings
             SET window_start = ?, window_end = ?, grace_minutes = ?,
                 college_ip = ?, is_active = ?, updated_by = ?,
                 geo_lat = ?, geo_lng = ?, geo_radius_meters = ?
             WHERE session = ?`,
            [
                window_start, window_end, grace_minutes ?? 5,
                college_ip, is_active ?? true, req.user.id,
                finalGeoLat, finalGeoLng, finalGeoRadius ?? 200,
                session
            ]
        );

        res.json({ message: `QR settings updated for ${session} session.` });

    } catch (err) {
        console.error('QR settings PUT error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// GET /api/admin/users?role=student|faculty|staff|admin
// -------------------------------------------------------
router.get('/users', async (req, res) => {
    const { role,semester_id } = req.query;

    try {
        let query = `
            SELECT u.id, u.name, u.email, u.role, u.enrollment_no, u.is_active, u.created_at,
                   s.name AS semester_name
            FROM users u
            LEFT JOIN semesters s ON s.id = u.semester_id
        `;
        const params = [];

        if (role && semester_id) {
    query += ' WHERE u.role = ? AND u.semester_id = ?';
    params.push(role, semester_id);

} else if (role) {
    query += ' WHERE u.role = ?';
    params.push(role);

} else if (semester_id) {
    query += ' WHERE u.semester_id = ?';
    params.push(semester_id);
}

        query += ' ORDER BY u.role, u.name';

        const [rows] = await db.query(query, params);
        res.json({ users: rows });

    } catch (err) {
        console.error('List users error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// DELETE /api/admin/users/:id (soft delete — sets is_active = FALSE)
// -------------------------------------------------------
router.delete('/users/:id', async (req, res) => {
    const { id } = req.params;

    // Prevent admin from deactivating themselves
    if (parseInt(id) === req.user.id) {
        return res.status(400).json({ error: 'You cannot deactivate your own account.' });
    }

    try {
        const [result] = await db.query(
            'UPDATE users SET is_active = FALSE WHERE id = ?',
            [id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'User not found.' });
        }

        res.json({ message: 'User deactivated successfully.' });

    } catch (err) {
        console.error('Deactivate user error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// GET /api/admin/subjects
// -------------------------------------------------------
router.get('/subjects', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT s.id, s.name, s.code, s.total_lectures,
                    sem.name AS semester_name,
                    u.name   AS faculty_name
             FROM subjects s
             JOIN semesters sem ON sem.id = s.semester_id
             JOIN users u       ON u.id   = s.faculty_id
             ORDER BY sem.name, s.name`
        );
        res.json({ subjects: rows });
    } catch (err) {
        console.error('List subjects error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// POST /api/admin/subjects
// Body: { name, code, semester_id, faculty_id, total_lectures }
// -------------------------------------------------------
router.post('/subjects', async (req, res) => {
    const { name, code, semester_id, faculty_id, total_lectures } = req.body;

    if (!name || !code || !semester_id || !faculty_id) {
        return res.status(400).json({ error: 'name, code, semester_id, faculty_id are required.' });
    }

    try {
        const [result] = await db.query(
            'INSERT INTO subjects (name, code, semester_id, faculty_id, total_lectures) VALUES (?, ?, ?, ?, ?)',
            [name, code, semester_id, faculty_id, total_lectures || 0]
        );

        res.status(201).json({ message: 'Subject created.', subjectId: result.insertId });

    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ error: 'Subject code already exists.' });
        }
        console.error('Create subject error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// PUT /api/admin/subjects/:id
// Body: { name?, code?, faculty_id?, total_lectures? }
// -------------------------------------------------------
router.put('/subjects/:id', async (req, res) => {
    const { id } = req.params;
    const { name, code, faculty_id, total_lectures } = req.body;

    try {
        await db.query(
            `UPDATE subjects
             SET name = COALESCE(?, name),
                 code = COALESCE(?, code),
                 faculty_id = COALESCE(?, faculty_id),
                 total_lectures = COALESCE(?, total_lectures)
             WHERE id = ?`,
            [name || null, code || null, faculty_id || null, total_lectures ?? null, id]
        );

        res.json({ message: 'Subject updated.' });

    } catch (err) {
        console.error('Update subject error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// GET /api/admin/semesters
// -------------------------------------------------------
router.get('/semesters', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM semesters ORDER BY year, name');
        res.json({ semesters: rows });
    } catch (err) {
        res.status(500).json({ error: 'Server error.' });
    }
});

// -------------------------------------------------------
// POST /api/admin/semesters
// Body: { name, year, division, is_current }
// -------------------------------------------------------
router.post('/semesters', async (req, res) => {
    const { name, year, division, is_current } = req.body;

    if (!name || !year) {
        return res.status(400).json({ error: 'name and year are required.' });
    }

    try {
        // If this is set as current, unset all others first
        if (is_current) {
            await db.query('UPDATE semesters SET is_current = FALSE');
        }

        const [result] = await db.query(
            'INSERT INTO semesters (name, year, division, is_current) VALUES (?, ?, ?, ?)',
            [name, year, division || null, is_current || false]
        );

        res.status(201).json({ message: 'Semester created.', semesterId: result.insertId });

    } catch (err) {
        console.error('Create semester error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

module.exports = router;
