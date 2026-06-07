# MySQL Database Setup for Mobile-Based Attendance System

## Prerequisites
- MySQL Server installed and running
- Node.js and npm installed
- Basic knowledge of SQL and JavaScript

## Installation Steps

### 1. Install MySQL Dependencies
```bash
npm install
```

### 2. Create Database and Tables
```bash
mysql -u root -p < schema.sql
```

Or manually:
1. Open MySQL Command Line or MySQL Workbench
2. Run the commands from `schema.sql`

### 3. Configure Environment Variables
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your MySQL credentials:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=attendance_system
   ```

## Database Schema Overview

### Tables

#### **users**
- Stores student, teacher, and admin information
- Fields: id, name, email, phone, role, roll_number, password_hash, profile_image, is_active
- Indexes on: email, roll_number, role

#### **classes**
- Stores class information
- Fields: id, class_name, description, teacher_id
- Linked to: users (teacher)

#### **class_members**
- Student enrollment in classes
- Stores relationship between students and classes
- Many-to-many relationship

#### **attendance**
- Main attendance records
- Fields: id, class_id, student_id, attendance_date, check_in_time, check_out_time, status, remarks
- Status: present, absent, late, excused
- Unique constraint on (class_id, student_id, attendance_date)

#### **sessions**
- Tracks class sessions
- Fields: id, class_id, session_date, start_time, end_time, duration_minutes, status

#### **attendance_reports**
- Monthly attendance summary reports
- Auto-calculated statistics for performance tracking

## Usage Examples

### Example 1: Create a New User (Student)
```javascript
const { userQueries } = require('./db_queries');

const newStudent = {
  name: 'John Doe',
  email: 'john@example.com',
  phone: '1234567890',
  role: 'student',
  roll_number: 'STU001',
  password_hash: 'hashed_password_here'
};

const userId = await userQueries.createUser(newStudent);
console.log('New user created with ID:', userId);
```

### Example 2: Mark Attendance
```javascript
const { attendanceQueries } = require('./db_queries');

const attendanceRecord = {
  class_id: 1,
  student_id: 5,
  attendance_date: '2026-06-07',
  status: 'present',
  check_in_time: '09:00:00',
  check_out_time: '12:00:00',
  recorded_by: 2
};

await attendanceQueries.markAttendance(attendanceRecord);
console.log('Attendance marked successfully');
```

### Example 3: Get Attendance Summary
```javascript
const { attendanceQueries } = require('./db_queries');

const summary = await attendanceQueries.getAttendanceSummary(1, 5);
console.log('Attendance Summary:', summary);
// Output: { total_days: 20, present_days: 19, absent_days: 1, late_days: 0, attendance_percentage: 95.00 }
```

### Example 4: Get Class Attendance for a Date
```javascript
const { attendanceQueries } = require('./db_queries');

const classAttendance = await attendanceQueries.getClassAttendanceByDate(1, '2026-06-07');
console.log('Class attendance:', classAttendance);
```

## Frontend Integration

### Using with Express.js

```javascript
const express = require('express');
const { attendanceQueries, userQueries, classQueries } = require('./db_queries');

const app = express();
app.use(express.json());

// Mark attendance endpoint
app.post('/api/attendance/mark', async (req, res) => {
  try {
    const result = await attendanceQueries.markAttendance(req.body);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get student attendance endpoint
app.get('/api/attendance/:classId/:studentId', async (req, res) => {
  try {
    const { classId, studentId } = req.params;
    const { fromDate, toDate } = req.query;
    
    const attendance = await attendanceQueries.getStudentAttendance(
      classId, studentId, fromDate, toDate
    );
    res.json({ success: true, data: attendance });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get attendance summary endpoint
app.get('/api/attendance/summary/:classId/:studentId', async (req, res) => {
  try {
    const { classId, studentId } = req.params;
    const summary = await attendanceQueries.getAttendanceSummary(classId, studentId);
    res.json({ success: true, data: summary });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

## Query Performance Tips

1. **Indexes**: The schema includes indexes on frequently queried columns
2. **Date Queries**: Use date range queries efficiently
3. **Connection Pooling**: Uses connection pooling for better performance
4. **Batch Operations**: For bulk attendance marking, consider using transactions

## Troubleshooting

### Connection Error
```
Error: connect ECONNREFUSED 127.0.0.1:3306
```
**Solution**: Ensure MySQL server is running

### Authentication Error
```
Error: Access denied for user 'root'@'localhost'
```
**Solution**: Check DB_USER and DB_PASSWORD in .env file

### Table Already Exists
```
Error: Table 'attendance_system.users' already exists
```
**Solution**: This is normal if running schema.sql multiple times; it uses CREATE TABLE IF NOT EXISTS

## Next Steps

1. Create API endpoints using Express.js ✅
2. Add authentication and authorization
3. Build frontend UI to interact with these APIs
4. Implement data validation and error handling
5. Add backup and recovery procedures
