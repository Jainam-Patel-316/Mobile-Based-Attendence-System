// db/connection.js
// mysql2 connection pool — import this in every route file
// pool handles multiple simultaneous requests without opening a new connection each time

const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
    host:     process.env.DB_HOST,
    user:     process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test the connection on startup so you know immediately if credentials are wrong
pool.getConnection()
    .then(conn => {
        console.log('✅ MySQL connected successfully');
        conn.release();
    })
    .catch(err => {
        console.error('❌ MySQL connection failed:', err.message);
        console.error('   Check your .env file — DB_HOST, DB_USER, DB_PASS, DB_NAME');
    });

module.exports = pool;
