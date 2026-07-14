// app.js
// Express app setup — middleware, CORS, routes
// Kept separate from server.js so it's easier to test

const express = require('express');
const cors    = require('cors');
require('dotenv').config();

const app = express();

// -------------------------------------------------------
// CORS — allow requests from the frontend (Vite dev or Vercel)
// -------------------------------------------------------
app.use(cors({
    origin: [
        'http://localhost:5173',
        'http://127.0.0.1:5500',
        'http://localhost:5000',
		'http://10.112.74.68:5500'
        
		
    ],
}));

const path = require('path');
app.use(express.static(path.join(__dirname)));

// -------------------------------------------------------
// Body parser — parse JSON request bodies
// -------------------------------------------------------
app.use(express.json());

// -------------------------------------------------------
// Request logger — logs every incoming request in dev
// -------------------------------------------------------
if (process.env.NODE_ENV !== 'production') {
    app.use((req, res, next) => {
        console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
        next();
    });
}

// -------------------------------------------------------
// Routes
// -------------------------------------------------------
app.use('/api/auth',       require('./routes/auth'));
app.use('/api/entry',      require('./routes/entry'));
app.use('/api/attendance', require('./routes/attendance'));
app.use('/api/devices',    require('./routes/devices'));
app.use('/api/admin',      require('./routes/admin'));
app.use('/api/faculty',    require('./routes/faculty'));

// -------------------------------------------------------
// Health check — visit /api/health to confirm server is up
// -------------------------------------------------------
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// -------------------------------------------------------
// 404 handler — catch unknown routes
// -------------------------------------------------------
app.use((req, res) => {
    res.status(404).json({ error: `Route not found: ${req.method} ${req.path}` });
});

// -------------------------------------------------------
// Global error handler — catches any unhandled errors
// -------------------------------------------------------
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ error: 'Internal server error.' });
});

module.exports = app;
