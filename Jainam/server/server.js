// server.js
// Entry point — starts the Express server
// Run with: node server.js
// Dev mode:  npm run dev  (uses nodemon for auto-restart)

require('dotenv').config();
const app  = require('./app');

// DB connection is initialized on require (logs success/failure to console)
require('./db/connection');

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`\n🚀 QR Attendance Server running on port ${PORT}`);
    console.log(`   Health check: http://localhost:${PORT}/api/health`);
    console.log(`   Environment : ${process.env.NODE_ENV || 'development'}\n`);
});
