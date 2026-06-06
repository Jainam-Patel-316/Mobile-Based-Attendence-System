// routes/entry.js
// POST /api/entry/scan    — student scans QR at gate
// GET  /api/entry/log     — staff/admin views entry log

const express    = require('express');
const db         = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');
const ipCheck     = require('../middleware/ipCheck');
const { getSessionForTime } = require('../utils/timeWindow');

const router = express.Router();

// -------------------------------------------------------
// POST /api/entry/scan
// Auth: student JWT + college WiFi IP + registered device
// Body: { fingerprintHash }
// -------------------------------------------------------
router.post('/scan', verifyToken, roleCheck('student'), ipCheck, async (req, res) => {
    const { fingerprintHash } = req.body;
    const studentId = req.user.id;

    if (!fingerprintHash) {
        return res.status(400).json({ error: 'fingerprintHash is required.' });
    }

    try {
        // 1. Check time window — fetch both morning and afternoon settings
        const [settings] = await db.query(
            'SELECT session, window_start, window_end, grace_minutes FROM qr_settings WHERE is_active = TRUE'
        );

        if (!settings.length) {
            return res.status(500).json({ error: 'QR settings not configured. Contact admin.' });
        }

        const now = new Date();
        const session = getSessionForTime(now, settings);

        if (!session) {
            // Log the rejected attempt
            const today = new Date().toISOString().split('T')[0];
            const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;
            await db.query(
                `INSERT IGNORE INTO college_entry_log (user_id, session, entry_date, ip_address, fingerprint_hash, status)
                 VALUES (?, 'morning', ?, ?, ?, 'rejected_time')`,
                [studentId, today, clientIp, fingerprintHash]
            );
            return res.status(400).json({ error: 'Outside scan window. Gates are closed.', reason: 'rejected_time' });
        }

        // 2. Device fingerprint check — must be registered and approved by admin
        const [device] = await db.query(
            'SELECT id FROM devices WHERE user_id = ? AND fingerprint_hash = ? AND is_active = TRUE',
            [studentId, fingerprintHash]
        );

        if (!device.length) {
            const today = new Date().toISOString().split('T')[0];
            const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;
            await db.query(
                `INSERT IGNORE INTO college_entry_log (user_id, session, entry_date, ip_address, fingerprint_hash, status)
                 VALUES (?, ?, ?, ?, ?, 'rejected_device')`,
                [studentId, session, today, clientIp, fingerprintHash]
            );
            return res.status(403).json({ error: 'Device not registered. Ask admin to approve your device.', reason: 'rejected_device' });
        }

        // 3. All checks passed — insert valid entry (INSERT IGNORE prevents duplicate scans)
        const today = new Date().toISOString().split('T')[0];
        const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;

        const [result] = await db.query(
            `INSERT IGNORE INTO college_entry_log (user_id, session, entry_date, ip_address, fingerprint_hash, status)
             VALUES (?, ?, ?, ?, ?, 'valid')`,
            [studentId, session, today, clientIp, fingerprintHash]
        );

        // affectedRows = 0 means IGNORE triggered — student already scanned this session
        if (result.affectedRows === 0) {
            return res.status(200).json({
                success: true,
                alreadyScanned: true,
                message: `Already scanned for ${session} session today.`,
                session
            });
        }

        res.json({ success: true, session, scannedAt: now });

    } catch (err) {
        console.error('QR scan error:', err);
        res.status(500).json({ error: 'Server error during QR scan.' });
    }
});

// -------------------------------------------------------
// GET /api/entry/log
// Auth: staff or admin
// Query params: ?date=YYYY-MM-DD&session=morning|afternoon
// Returns: list of all gate entry records for that day
// -------------------------------------------------------
router.get('/log', verifyToken, roleCheck('staff', 'admin'), async (req, res) => {
    const { date, session } = req.query;
    const targetDate = date || new Date().toISOString().split('T')[0];

    try {
        let query = `
            SELECT 
                cel.id,
                u.name         AS student_name,
                u.enrollment_no,
                cel.session,
                cel.entry_date,
                cel.scanned_at,
                cel.ip_address,
                cel.status
            FROM college_entry_log cel
            JOIN users u ON u.id = cel.user_id
            WHERE cel.entry_date = ?
        `;
        const params = [targetDate];

        if (session) {
            query += ' AND cel.session = ?';
            params.push(session);
        }

        query += ' ORDER BY cel.scanned_at DESC';

        const [rows] = await db.query(query, params);
        res.json({ date: targetDate, session: session || 'all', entries: rows });

    } catch (err) {
        console.error('Entry log error:', err);
        res.status(500).json({ error: 'Server error fetching entry log.' });
    }
});

module.exports = router;
