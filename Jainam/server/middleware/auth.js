// middleware/auth.js
// Verifies the JWT token on every protected route
// Usage: router.get('/some-route', verifyToken, (req, res) => { ... })
// After this runs successfully, req.user = { id, name, email, role }

const jwt = require('jsonwebtoken');
require('dotenv').config();

function verifyToken(req, res, next) {
    // Token must be sent in Authorization header as: Bearer <token>
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // strip "Bearer "

    if (!token) {
        return res.status(401).json({ error: 'Access denied. No token provided.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // { id, name, email, role }
        next();
    } catch (err) {
        return res.status(403).json({ error: 'Invalid or expired token. Please log in again.' });
    }
}

module.exports = verifyToken;
