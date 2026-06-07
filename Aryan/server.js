const express = require('express');
const dotenv = require('dotenv');
const { attendanceQueries, userQueries, classQueries, sessionQueries } = require('./db_queries');

// Load environment variables
dotenv.config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// ==================== USER ROUTES ====================

// Get all users
app.get('/api/users', async (req, res) => {
  try {
    const users = await userQueries.getAllUsers();
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get user by ID
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await userQueries.getUserById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User not found' });
    }
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create new user
app.post('/api/users', async (req, res) => {
  try {
    const userId = await userQueries.createUser(req.body);
    res.json({ success: true, data: { id: userId, ...req.body } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== CLASS ROUTES ====================

// Get all classes
app.get('/api/classes', async (req, res) => {
  try {
    const classes = await classQueries.getAllClasses();
    res.json({ success: true, data: classes });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get class by ID
app.get('/api/classes/:id', async (req, res) => {
  try {
    const classData = await classQueries.getClassById(req.params.id);
    if (!classData) {
      return res.status(404).json({ success: false, error: 'Class not found' });
    }
    res.json({ success: true, data: classData });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create new class
app.post('/api/classes', async (req, res) => {
  try {
    const classId = await classQueries.createClass(req.body);
    res.json({ success: true, data: { id: classId, ...req.body } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== ATTENDANCE ROUTES ====================

// Mark attendance
app.post('/api/attendance/mark', async (req, res) => {
  try {
    const result = await attendanceQueries.markAttendance(req.body);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get student attendance
app.get('/api/attendance/:classId/:studentId', async (req, res) => {
  try {
    const { classId, studentId } = req.params;
    const { fromDate, toDate } = req.query;
    
    if (!fromDate || !toDate) {
      return res.status(400).json({ success: false, error: 'fromDate and toDate are required' });
    }
    
    const attendance = await attendanceQueries.getStudentAttendance(
      classId, studentId, fromDate, toDate
    );
    res.json({ success: true, data: attendance });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get class attendance for a date
app.get('/api/attendance/class/:classId/date/:date', async (req, res) => {
  try {
    const { classId, date } = req.params;
    const attendance = await attendanceQueries.getClassAttendanceByDate(classId, date);
    res.json({ success: true, data: attendance });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get attendance summary
app.get('/api/attendance/summary/:classId/:studentId', async (req, res) => {
  try {
    const { classId, studentId } = req.params;
    const summary = await attendanceQueries.getAttendanceSummary(classId, studentId);
    res.json({ success: true, data: summary });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== SESSION ROUTES ====================

// Create session
app.post('/api/sessions', async (req, res) => {
  try {
    const sessionId = await sessionQueries.createSession(req.body);
    res.json({ success: true, data: { id: sessionId, ...req.body } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get class sessions
app.get('/api/sessions/:classId', async (req, res) => {
  try {
    const sessions = await sessionQueries.getClassSessions(req.params.classId);
    res.json({ success: true, data: sessions });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ==================== HEALTH CHECK ====================

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Server is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
  console.log(`Database: ${process.env.DB_NAME}`);
});
