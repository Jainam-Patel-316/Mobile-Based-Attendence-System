// middleware/roleCheck.js
// Factory function — returns a middleware that blocks anyone not in the allowed roles list
// Usage examples:
//   router.get('/admin-only', verifyToken, roleCheck('admin'), handler)
//   router.get('/faculty-or-admin', verifyToken, roleCheck('faculty', 'admin'), handler)

function roleCheck(...allowedRoles) {
    return function (req, res, next) {
        // verifyToken must run before this — req.user is set by it
        if (!req.user) {
            return res.status(401).json({ error: 'Not authenticated.' });
        }

        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                error: `Access denied. Required role: ${allowedRoles.join(' or ')}. Your role: ${req.user.role}`
            });
        }

        next();
    };
}

module.exports = roleCheck;
