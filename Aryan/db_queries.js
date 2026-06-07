const pool = require('./db_config');

// User Queries
const userQueries = {
  // Get all users
  getAllUsers: async () => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query('SELECT * FROM users');
      return rows;
    } finally {
      connection.release();
    }
  },

  // Get user by ID
  getUserById: async (userId) => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query('SELECT * FROM users WHERE id = ?', [userId]);
      return rows[0];
    } finally {
      connection.release();
    }
  },

  // Create new user
  createUser: async (userData) => {
    const connection = await pool.getConnection();
    try {
      const { name, email, phone, role, roll_number, password_hash } = userData;
      const [result] = await connection.query(
        'INSERT INTO users (name, email, phone, role, roll_number, password_hash) VALUES (?, ?, ?, ?, ?, ?)',
        [name, email, phone, role, roll_number, password_hash]
      );
      return result.insertId;
    } finally {
      connection.release();
    }
  }
};

// Class Queries
const classQueries = {
  // Get all classes
  getAllClasses: async () => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query('SELECT * FROM classes');
      return rows;
    } finally {
      connection.release();
    }
  },

  // Get class by ID with students
  getClassById: async (classId) => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(
        `SELECT c.*, u.name as teacher_name 
         FROM classes c 
         LEFT JOIN users u ON c.teacher_id = u.id 
         WHERE c.id = ?`,
        [classId]
      );
      return rows[0];
    } finally {
      connection.release();
    }
  },

  // Create new class
  createClass: async (classData) => {
    const connection = await pool.getConnection();
    try {
      const { class_name, description, teacher_id } = classData;
      const [result] = await connection.query(
        'INSERT INTO classes (class_name, description, teacher_id) VALUES (?, ?, ?)',
        [class_name, description, teacher_id]
      );
      return result.insertId;
    } finally {
      connection.release();
    }
  }
};

// Attendance Queries
const attendanceQueries = {
  // Mark attendance
  markAttendance: async (attendanceData) => {
    const connection = await pool.getConnection();
    try {
      const { class_id, student_id, attendance_date, status, check_in_time, check_out_time, recorded_by } = attendanceData;
      const [result] = await connection.query(
        `INSERT INTO attendance (class_id, student_id, attendance_date, status, check_in_time, check_out_time, recorded_by) 
         VALUES (?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE status = ?, check_in_time = ?, check_out_time = ?, updated_at = CURRENT_TIMESTAMP`,
        [class_id, student_id, attendance_date, status, check_in_time, check_out_time, recorded_by, status, check_in_time, check_out_time]
      );
      return result;
    } finally {
      connection.release();
    }
  },

  // Get attendance for a student in a class
  getStudentAttendance: async (classId, studentId, fromDate, toDate) => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(
        `SELECT * FROM attendance 
         WHERE class_id = ? AND student_id = ? AND attendance_date BETWEEN ? AND ?
         ORDER BY attendance_date DESC`,
        [classId, studentId, fromDate, toDate]
      );
      return rows;
    } finally {
      connection.release();
    }
  },

  // Get class attendance for a date
  getClassAttendanceByDate: async (classId, attendanceDate) => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(
        `SELECT a.*, u.name, u.roll_number 
         FROM attendance a
         JOIN users u ON a.student_id = u.id
         WHERE a.class_id = ? AND a.attendance_date = ?
         ORDER BY u.name`,
        [classId, attendanceDate]
      );
      return rows;
    } finally {
      connection.release();
    }
  },

  // Get attendance summary
  getAttendanceSummary: async (classId, studentId) => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(
        `SELECT 
          COUNT(*) as total_days,
          SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_days,
          SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) as absent_days,
          SUM(CASE WHEN status = 'late' THEN 1 ELSE 0 END) as late_days,
          ROUND(SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as attendance_percentage
         FROM attendance
         WHERE class_id = ? AND student_id = ?`,
        [classId, studentId]
      );
      return rows[0];
    } finally {
      connection.release();
    }
  }
};

// Session Queries
const sessionQueries = {
  // Create session
  createSession: async (sessionData) => {
    const connection = await pool.getConnection();
    try {
      const { class_id, session_date, start_time, end_time, duration_minutes, created_by } = sessionData;
      const [result] = await connection.query(
        `INSERT INTO sessions (class_id, session_date, start_time, end_time, duration_minutes, created_by) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [class_id, session_date, start_time, end_time, duration_minutes, created_by]
      );
      return result.insertId;
    } finally {
      connection.release();
    }
  },

  // Get sessions for a class
  getClassSessions: async (classId) => {
    const connection = await pool.getConnection();
    try {
      const [rows] = await connection.query(
        'SELECT * FROM sessions WHERE class_id = ? ORDER BY session_date DESC',
        [classId]
      );
      return rows;
    } finally {
      connection.release();
    }
  }
};

module.exports = {
  userQueries,
  classQueries,
  attendanceQueries,
  sessionQueries
};