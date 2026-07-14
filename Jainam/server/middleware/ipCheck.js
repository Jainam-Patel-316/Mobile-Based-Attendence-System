// middleware/ipCheck.js
// Validates that the request is coming from the college WiFi network
// Reads college_ip from qr_settings table (so admin can update it without redeploying)
// Only applied on the QR scan route — not on login or dashboard routes

const db = require('../db/connection');

async function ipCheck(req, res, next) {
    try {
        // Get client IP — handles proxies (Railway, Vercel, Nginx, etc.)
        const clientIp = req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip;

        // Fetch the stored college IP from DB (admin can update this anytime)
        const [rows] = await db.query(
            'SELECT college_ip FROM qr_settings WHERE is_active = TRUE LIMIT 1'
        );

        if (!rows.length) {
            return res.status(500).json({ error: 'QR settings not configured. Contact admin.' });
        }

        const collegeIp = rows[0].college_ip;

        // Special case: if college_ip is 0.0.0.0 it means "not configured yet" — allow all (dev mode)
        if (collegeIp === '0.0.0.0') {
            console.warn('⚠️  IP check is in dev mode (college_ip = 0.0.0.0). Update via admin panel.');
            return next();
        }

        if (clientIp !== collegeIp) {
            return res.status(403).json({
                error: 'QR scan rejected: Not on college WiFi network.',
                reason: 'rejected_ip'
            });
        }

        next();
    } catch (err) {
        console.error('ipCheck middleware error:', err);
        return res.status(500).json({ error: 'Internal server error during IP validation.' });
    }
}

module.exports = ipCheck;
