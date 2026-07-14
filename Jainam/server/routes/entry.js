// routes/entry.js
// POST /api/entry/scan    — student scans QR at gate (IP + device + geofence)
// GET  /api/entry/log     — staff/admin views entry log

const express     = require('express');
const db          = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');
const ipCheck     = require('../middleware/ipCheck');
const { getSessionForTime } = require('../utils/timeWindow');

const router = express.Router();

// -------------------------------------------------------
// Haversine formula — returns distance in meters between
// two lat/lng coordinate pairs.
// -------------------------------------------------------
function haversineDistance(lat1, lng1, lat2, lng2) {
    const R = 6371000; // Earth radius in meters
    const toRad = (deg) => (deg * Math.PI) / 180;

    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
        Math.sin(dLng / 2) * Math.sin(dLng / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // meters
}

// -------------------------------------------------------
// POST /api/entry/scan
// Auth: NONE (kiosk page) — college WiFi IP + registered device fingerprint + geofence
// Body: { fingerprintHash, geo: { lat, lng } }
//
// geo is optional at the server level — if the admin hasn't configured
// geo_lat/geo_lng in qr_settings, the geofence check is skipped.
// If geo IS configured, the client MUST send coordinates or the scan is rejected.
// -------------------------------------------------------
router.post('/scan', async (req, res) => {
    const { deviceToken, fingerprintHash, geo } = req.body;

    if (!deviceToken) {
        return res.status(400).json({
            error: 'Device not synced. Open the app once while logged in, then try scanning again.',
            reason: 'rejected_device'
        });
    }

    try {
        // 0. Identify the student from the device token issued at approval time.
        // We do NOT identify by fingerprintHash any more: two phones of the
        // same model/OS/browser version can produce an identical fingerprint,
        // which used to make the scan silently attribute to the wrong student.
        // device_token is server-generated randomness, so it can't collide.
        const [device] = await db.query(
            `SELECT d.user_id, u.role
             FROM devices d
             JOIN users u ON u.id = d.user_id
             WHERE d.device_token = ? AND d.is_active = TRUE`,
            [deviceToken]
        );

        if (!device.length || device[0].role !== 'student') {
            return res.status(403).json({
                error: 'Device Not Registered For College Entry',
                reason: 'rejected_device'
            });
        }

        const studentId = device[0].user_id;

        // 1. Fetch QR settings — includes time windows AND geofence config
        const [settings] = await db.query(
            `SELECT session, window_start, window_end, grace_minutes,
                    geo_lat, geo_lng, geo_radius_meters
             FROM qr_settings WHERE is_active = TRUE`
        );

        if (!settings.length) {
            return res.status(500).json({ error: 'QR settings not configured. Contact admin.' });
        }

        // 2. Geofence check — only runs if admin has set geo_lat and geo_lng
        const geoConfig = settings[0]; // geo_lat/lng is same across sessions
        const geoEnabled = geoConfig.geo_lat !== null && geoConfig.geo_lng !== null;

        let geoStatus = 'not_configured'; // default when geofencing is off

        if (geoEnabled) {
            // Geofencing is ON — client must have sent coordinates
            if (!geo || geo.lat === undefined || geo.lng === undefined) {
                return res.status(400).json({
                    error: 'Location is required for QR scan. Please allow location access and try again.',
                    reason: 'geo_not_sent'
                });
            }

            const clientLat = parseFloat(geo.lat);
            const clientLng = parseFloat(geo.lng);

            // Basic sanity check — valid lat/lng ranges
            if (isNaN(clientLat) || isNaN(clientLng) ||
                clientLat < -90 || clientLat > 90 ||
                clientLng < -180 || clientLng > 180) {
                return res.status(400).json({
                    error: 'Invalid location coordinates received.',
                    reason: 'geo_invalid'
                });
            }

            const radiusMeters = geoConfig.geo_radius_meters || 200;
            const distance = haversineDistance(
                geoConfig.geo_lat, geoConfig.geo_lng,
                clientLat, clientLng
            );

            if (distance > radiusMeters) {
                geoStatus = 'outside_fence';

                // Log the rejected attempt with location data
                const today = new Date().toISOString().split('T')[0];
                const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;
                await db.query(
                    `INSERT IGNORE INTO college_entry_log
                        (user_id, session, entry_date, ip_address, fingerprint_hash, status, geo_lat, geo_lng, geo_status)
                     VALUES (?, 'unknown', ?, ?, ?, 'rejected_geo', ?, ?, ?)`,
                    [studentId, today, clientIp, fingerprintHash, clientLat, clientLng, geoStatus]
                );

                return res.status(403).json({
                    error: `You are ${Math.round(distance)}m away from college. Must be within ${radiusMeters}m to scan.`,
                    reason: 'rejected_geo',
                    distanceMeters: Math.round(distance),
                    allowedRadiusMeters: radiusMeters
                });
            }

            geoStatus = 'verified';
        }

        // 3. Check time window — is it within morning/afternoon scan window?
        const now = new Date();
        const session = getSessionForTime(now, settings);

        if (!session) {
            const today = new Date().toISOString().split('T')[0];
            const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;
            await db.query(
                `INSERT IGNORE INTO college_entry_log
                    (user_id, session, entry_date, ip_address, fingerprint_hash, status, geo_lat, geo_lng, geo_status)
                 VALUES (?, 'morning', ?, ?, ?, 'rejected_time', ?, ?, ?)`,
                [studentId, today, clientIp, fingerprintHash,
                 geo?.lat ?? null, geo?.lng ?? null, geoStatus]
            );
            const windows = settings.map(s => ({
                 session: s.session,
                 window_start: s.window_start,
                 window_end: s.window_end
            }));

            return res.status(400).json({
                 error: 'Outside scan window. Gates are closed.',
                 reason: 'rejected_time',
                 windows
            });
        }

        // 4. All checks passed — check for existing entry before inserting
        const today = new Date().toISOString().split('T')[0];
        const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;

        // Check if a row already exists for this student/session/date (valid OR rejected)
        const [existing] = await db.query(
            `SELECT id, status FROM college_entry_log
             WHERE user_id = ? AND session = ? AND entry_date = ? LIMIT 1`,
            [studentId, session, today]
        );

        if (existing.length > 0) {
            if (existing[0].status === 'valid') {
                // Already successfully scanned — friendly duplicate message
                return res.status(200).json({
                    success: true,
                    alreadyScanned: true,
                    message: `Already scanned for ${session} session today.`,
                    session
                });
            } else {
                // Previous attempt was rejected (time/ip/geo) — UPDATE it to valid now
                await db.query(
                    `UPDATE college_entry_log
                     SET status = 'valid', ip_address = ?, scanned_at = NOW(),
                         geo_lat = ?, geo_lng = ?, geo_status = ?
                     WHERE id = ?`,
                    [clientIp, geo?.lat ?? null, geo?.lng ?? null, geoStatus, existing[0].id]
                );
                return res.json({ success: true, session, scannedAt: now });
            }
        }

        // No existing row — safe to insert
        await db.query(
            `INSERT INTO college_entry_log
                (user_id, session, entry_date, ip_address, fingerprint_hash, status, geo_lat, geo_lng, geo_status)
             VALUES (?, ?, ?, ?, ?, 'valid', ?, ?, ?)`,
            [studentId, session, today, clientIp, fingerprintHash,
             geo?.lat ?? null, geo?.lng ?? null, geoStatus]
        );

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
// -------------------------------------------------------
router.get('/log', verifyToken, roleCheck('staff', 'admin'), async (req, res) => {
    const { date, session } = req.query;
    const targetDate = date || new Date().toISOString().split('T')[0];

    try {
        let query = `
            SELECT 
                cel.id,
                cel.user_id,
                u.name           AS student_name,
                u.enrollment_no,
                cel.session,
                cel.entry_date,
                cel.scanned_at,
                cel.ip_address,
                cel.status,
                cel.geo_lat,
                cel.geo_lng,
                cel.geo_status
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
