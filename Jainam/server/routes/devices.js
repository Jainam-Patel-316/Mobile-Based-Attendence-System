// routes/devices.js
// POST  /api/devices/register       — student submits their device fingerprint
// GET   /api/devices/pending        — admin views unapproved devices
// PATCH /api/devices/:id/approve    — admin approves a device
// PATCH /api/devices/:id/deactivate — admin deactivates a device (student changed phone)

const express     = require('express');
const db          = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');

const router = express.Router();

// -------------------------------------------------------
// POST /api/devices/register
// Auth: student
// Body: { fingerprintHash, deviceLabel? }
// Student submits their FingerprintJS hash — admin must approve before they can scan
// -------------------------------------------------------
router.post('/register', verifyToken, roleCheck('student'), async (req, res) => {
    const { fingerprintHash, deviceLabel } = req.body;
    const studentId = req.user.id;

    if (!fingerprintHash) {
        return res.status(400).json({ error: 'fingerprintHash is required.' });
    }

    try {
        // Check if this exact fingerprint already registered for this student
        const [existing] = await db.query(
            'SELECT id, is_active FROM devices WHERE user_id = ? AND fingerprint_hash = ?',
            [studentId, fingerprintHash]
        );

        if (existing.length) {
            if (existing[0].is_active) {
                return res.status(200).json({ message: 'Device already registered and active.' });
            } else {
                return res.status(200).json({ message: 'Device already submitted. Waiting for admin approval.' });
            }
        }

        // Insert as inactive — admin must approve
        await db.query(
            'INSERT INTO devices (user_id, fingerprint_hash, device_label, is_active) VALUES (?, ?, ?, FALSE)',
            [studentId, fingerprintHash, deviceLabel || 'Unnamed Device']
        );

        res.status(201).json({
            message: 'Device submitted for approval. You can scan QR once admin approves your device.'
        });

    } catch (err) {
        console.error('Device register error:', err);
        res.status(500).json({ error: 'Server error registering device.' });
    }
});

// -------------------------------------------------------
// GET /api/devices/pending
// Auth: admin
// Returns: all unapproved device requests
// -------------------------------------------------------
router.get('/pending', verifyToken, roleCheck('admin'), async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT 
                d.id,
                d.fingerprint_hash,
                d.device_label,
                d.registered_at,
                d.is_active,
                u.id   AS student_id,
                u.name AS student_name,
                u.enrollment_no
             FROM devices d
             JOIN users u ON u.id = d.user_id
             WHERE d.is_active = FALSE
             ORDER BY d.registered_at DESC`
        );

        res.json({ pendingDevices: rows });

    } catch (err) {
        console.error('Pending devices error:', err);
        res.status(500).json({ error: 'Server error fetching pending devices.' });
    }
});

// -------------------------------------------------------
// PATCH /api/devices/:id/approve
// Auth: admin
// -------------------------------------------------------
router.patch('/:id/approve', verifyToken, roleCheck('admin'), async (req, res) => {
    const { id } = req.params;

    try {
        const [device] = await db.query('SELECT id, user_id FROM devices WHERE id = ?', [id]);

        if (!device.length) {
            return res.status(404).json({ error: 'Device not found.' });
        }

        // Deactivate any other active devices for this student (one device per student policy)
        await db.query(
            'UPDATE devices SET is_active = FALSE WHERE user_id = ? AND id != ?',
            [device[0].user_id, id]
        );

        // Approve the requested device
        await db.query('UPDATE devices SET is_active = TRUE WHERE id = ?', [id]);

        res.json({ message: 'Device approved. Student can now scan QR.' });

    } catch (err) {
        console.error('Approve device error:', err);
        res.status(500).json({ error: 'Server error approving device.' });
    }
});

// -------------------------------------------------------
// PATCH /api/devices/:id/deactivate
// Auth: admin
// Use when a student changes their phone
// -------------------------------------------------------
router.patch('/:id/deactivate', verifyToken, roleCheck('admin'), async (req, res) => {
    const { id } = req.params;

    try {
        const [result] = await db.query(
            'UPDATE devices SET is_active = FALSE WHERE id = ?',
            [id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Device not found.' });
        }

        res.json({ message: 'Device deactivated.' });

    } catch (err) {
        console.error('Deactivate device error:', err);
        res.status(500).json({ error: 'Server error deactivating device.' });
    }
});

module.exports = router;
