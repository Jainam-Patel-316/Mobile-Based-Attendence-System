// routes/devices.js
// POST  /api/devices/register       — student submits their device fingerprint
// GET   /api/devices/pending        — admin views unapproved devices
// PATCH /api/devices/:id/approve    — admin approves a device
// PATCH /api/devices/:id/reject     — admin rejects a pending device request
// PATCH /api/devices/:id/deactivate — admin deactivates a device (student changed phone)

const express     = require('express');
const crypto       = require('crypto');
const db          = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');

const router = express.Router();

// Generates the per-device secret used to identify a student at scan time.
// This has real entropy (32 random bytes), unlike fingerprint_hash, so two
// identical phones can never end up with the same value.
function generateDeviceToken() {
    return crypto.randomBytes(32).toString('hex');
}

// -------------------------------------------------------
// POST /api/devices/register
// Auth: student
// Body: { fingerprintHash, deviceLabel? }
// Student submits their FingerprintJS hash — admin must approve before they can scan
// -------------------------------------------------------
router.post('/register', verifyToken, roleCheck('student'), async (req, res) => {
    const { fingerprintHash, deviceLabel } = req.body;
    const studentId = req.user.id;

    if (!fingerprintHash || !fingerprintHash.trim()) {
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

        // Warn the admin if this fingerprint is already used by a DIFFERENT
        // student's approved device. Same-hash devices are technically
        // legitimate (identical phone models), the admin just needs to
        // know so they don't assume it's a duplicate/fake registration.
        if (rows.length) {
            const hashes = [...new Set(rows.map(r => r.fingerprint_hash))];
            const [clashRows] = await db.query(
                `SELECT DISTINCT d.fingerprint_hash, d.user_id
                 FROM devices d
                 WHERE d.is_active = TRUE AND d.fingerprint_hash IN (?)`,
                [hashes]
            );
            const activeOwnersByHash = new Map();
            for (const r of clashRows) {
                if (!activeOwnersByHash.has(r.fingerprint_hash)) {
                    activeOwnersByHash.set(r.fingerprint_hash, []);
                }
                activeOwnersByHash.get(r.fingerprint_hash).push(r.user_id);
            }

            for (const row of rows) {
                const owners = (activeOwnersByHash.get(row.fingerprint_hash) || [])
                    .filter(id => id !== row.student_id);
                row.duplicate_fingerprint = owners.length > 0;
            }
        }

        res.json({ pendingDevices: rows });

    } catch (err) {
        console.error('Pending devices error:', err);
        res.status(500).json({ error: 'Server error fetching pending devices.' });
    }
});

// -------------------------------------------------------
// PATCH /api/devices/:id/approve
// Auth: admin
// BUG FIX: Old code was setting ALL other devices to is_active = FALSE,
// which knocked out already-approved devices and caused them to reappear
// in the pending list — making the UI look like nothing changed.
// Fix: DELETE the other pending (inactive) rows instead of deactivating active ones.
// -------------------------------------------------------
router.patch('/:id/approve', verifyToken, roleCheck('admin'), async (req, res) => {
    const { id } = req.params;

    try {
        const [device] = await db.query(
            'SELECT id, user_id, is_active FROM devices WHERE id = ?',
            [id]
        );

        if (!device.length) {
            return res.status(404).json({ error: 'Device not found.' });
        }

        // Guard: already approved
        if (device[0].is_active) {
            return res.status(400).json({ error: 'Device is already approved.' });
        }

        // Delete other PENDING (inactive) device requests for this student.
        // Do NOT touch already-active devices — that was the original bug.
        await db.query(
            'DELETE FROM devices WHERE user_id = ? AND id != ? AND is_active = FALSE',
            [device[0].user_id, id]
        );

        // Approve the requested device and issue it a unique token.
        // The scan endpoint identifies students by this token, not by
        // fingerprint_hash, so two identical phones can never collide.
        const deviceToken = generateDeviceToken();
        await db.query(
            'UPDATE devices SET is_active = TRUE, device_token = ? WHERE id = ?',
            [deviceToken, id]
        );

        res.json({ message: 'Device approved. Student can now scan QR.' });

    } catch (err) {
        console.error('Approve device error:', err);
        res.status(500).json({ error: 'Server error approving device.' });
    }
});

// -------------------------------------------------------
// PATCH /api/devices/:id/reject
// Auth: admin
// Rejects and removes a pending device request.
// Only works on inactive (pending) devices — cannot reject an approved device.
// -------------------------------------------------------
router.patch('/:id/reject', verifyToken, roleCheck('admin'), async (req, res) => {
    const { id } = req.params;

    try {
        const [result] = await db.query(
            'DELETE FROM devices WHERE id = ? AND is_active = FALSE',
            [id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Pending device not found or already approved.' });
        }

        res.json({ message: 'Device request rejected.' });

    } catch (err) {
        console.error('Reject device error:', err);
        res.status(500).json({ error: 'Server error rejecting device.' });
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
            'UPDATE devices SET is_active = FALSE, device_token = NULL WHERE id = ?',
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

// GET /api/devices/status
router.get('/status', verifyToken, roleCheck('student'), async (req, res) => {
    try {
        const studentId = req.user.id;

        const [rows] = await db.query(
            'SELECT is_active, device_token FROM devices WHERE user_id = ? LIMIT 1',
            [studentId]
        );

        if (!rows.length) {
            return res.json({
                approved: false,
                pending: false
            });
        }

        return res.json({
            approved: rows[0].is_active === 1,
            pending: rows[0].is_active === 0,
            deviceToken: rows[0].is_active === 1 ? rows[0].device_token : null
        });

    } catch (err) {
        console.error('Device status error:', err);
        res.status(500).json({ error: 'Server error.' });
    }
});

module.exports = router;
