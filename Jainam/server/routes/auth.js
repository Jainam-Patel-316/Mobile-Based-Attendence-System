// routes/auth.js
// POST /api/auth/login   — all roles login here, returns JWT
// POST /api/auth/register — admin creates new users (students, faculty, staff)

const express  = require('express');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const db       = require('../db/connection');
const verifyToken = require('../middleware/auth');
const roleCheck   = require('../middleware/roleCheck');

const router = express.Router();
require('dotenv').config();

// -------------------------------------------------------
// POST /api/auth/login
// Body: { email, password }
// Returns: { token, user: { id, name, email, role } }
// -------------------------------------------------------
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required.' });
    }

    try {
        const [rows] = await db.query(
            'SELECT id, name, email, password_hash, role, is_active FROM users WHERE email = ?',
            [email]
        );

        if (!rows.length) {
            return res.status(401).json({ error: 'Invalid credentials.' });
        }

        const user = rows[0];

        if (!user.is_active) {
            return res.status(403).json({ error: 'Account is deactivated. Contact admin.' });
        }

        const passwordMatch = await bcrypt.compare(password, user.password_hash);
        if (!passwordMatch) {
            return res.status(401).json({ error: 'Invalid credentials.' });
        }

        // Sign JWT — expires in 8 hours (one college day)
        const token = jwt.sign(
            { id: user.id, name: user.name, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '8h' }
        );

        res.json({
            token,
            user: { id: user.id, name: user.name, email: user.email, role: user.role }
        });

    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Server error during login.' });
    }
});

// -------------------------------------------------------
// POST /api/auth/register
// Admin-only: creates a new user (student, faculty, staff)
// Body: { name, email, password, role, semester_id?, enrollment_no? }
// -------------------------------------------------------
router.post('/register', verifyToken, roleCheck('admin'), async (req, res) => {
    const { name, email, password, role, semester_id, enrollment_no } = req.body;

    if (!name || !email || !password || !role) {
        return res.status(400).json({ error: 'name, email, password, and role are required.' });
    }

    const validRoles = ['admin', 'faculty', 'staff', 'student'];
    if (!validRoles.includes(role)) {
        return res.status(400).json({ error: `Invalid role. Must be one of: ${validRoles.join(', ')}` });
    }

    try {
        // Check if email already exists
        const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length) {
            return res.status(409).json({ error: 'Email already registered.' });
        }

        const password_hash = await bcrypt.hash(password, 10);

        const [result] = await db.query(
            `INSERT INTO users (name, email, password_hash, role, semester_id, enrollment_no)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [name, email, password_hash, role, semester_id || null, enrollment_no || null]
        );

        res.status(201).json({
            message: 'User created successfully.',
            userId: result.insertId
        });

    } catch (err) {
        console.error('Register error:', err);
        res.status(500).json({ error: 'Server error during registration.' });
    }
});

module.exports = router;
