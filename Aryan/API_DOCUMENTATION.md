# API Documentation - Mobile-Based Attendance System

## Base URL
```
http://localhost:3000/api
```

## Authentication
Currently no authentication required. In production, add JWT tokens.

---

## USER ENDPOINTS

### Get All Users
```
GET /users
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "1234567890",
      "role": "student",
      "roll_number": "STU001",
      "is_active": true,
      "created_at": "2026-06-07T10:00:00.000Z"
    }
  ]
}
```

### Get User by ID
```
GET /users/:id
```
**Parameters:**
- `id` (integer): User ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "role": "student",
    "roll_number": "STU001",
    "is_active": true
  }
}
```

### Create New User
```
POST /users
```
**Request Body:**
```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "phone": "9876543210",
  "role": "student",
  "roll_number": "STU002",
  "password_hash": "hashed_password_here"
}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "Jane Doe",
    "email": "jane@example.com",
    "role": "student"
  }
}
```

---

## CLASS ENDPOINTS

### Get All Classes
```
GET /classes
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "class_name": "Class A",
      "description": "First year class",
      "teacher_id": 3,
      "created_at": "2026-06-07T10:00:00.000Z"
    }
  ]
}
```

### Get Class by ID
```
GET /classes/:id
```
**Parameters:**
- `id` (integer): Class ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "class_name": "Class A",
    "description": "First year class",
    "teacher_id": 3,
    "teacher_name": "Mr. Smith"
  }
}
```

### Create New Class
```
POST /classes
```
**Request Body:**
```json
{
  "class_name": "Class B",
  "description": "Second year class",
  "teacher_id": 4
}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "class_name": "Class B",
    "description": "Second year class",
    "teacher_id": 4
  }
}
```

---

## ATTENDANCE ENDPOINTS

### Mark Attendance
```
POST /attendance/mark
```
**Request Body:**
```json
{
  "class_id": 1,
  "student_id": 5,
  "attendance_date": "2026-06-07",
  "status": "present",
  "check_in_time": "09:00:00",
  "check_out_time": "12:00:00",
  "recorded_by": 3,
  "remarks": "On time"
}
```
**Status Values:** `present`, `absent`, `late`, `excused`

**Response:**
```json
{
  "success": true,
  "data": {
    "affectedRows": 1
  }
}
```

### Get Student Attendance (Date Range)
```
GET /attendance/:classId/:studentId?fromDate=2026-06-01&toDate=2026-06-30
```
**Parameters:**
- `classId` (integer): Class ID
- `studentId` (integer): Student ID
- `fromDate` (string, required): Start date (YYYY-MM-DD)
- `toDate` (string, required): End date (YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "class_id": 1,
      "student_id": 5,
      "attendance_date": "2026-06-07",
      "check_in_time": "09:00:00",
      "check_out_time": "12:00:00",
      "status": "present",
      "remarks": "On time",
      "recorded_by": 3,
      "created_at": "2026-06-07T10:00:00.000Z"
    }
  ]
}
```

### Get Class Attendance for a Date
```
GET /attendance/class/:classId/date/:date
```
**Parameters:**
- `classId` (integer): Class ID
- `date` (string): Attendance date (YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "class_id": 1,
      "student_id": 5,
      "student_name": "John Doe",
      "roll_number": "STU001",
      "attendance_date": "2026-06-07",
      "status": "present",
      "check_in_time": "09:00:00",
      "check_out_time": "12:00:00"
    },
    {
      "id": 2,
      "class_id": 1,
      "student_id": 6,
      "student_name": "Jane Doe",
      "roll_number": "STU002",
      "attendance_date": "2026-06-07",
      "status": "absent"
    }
  ]
}
```

### Get Attendance Summary
```
GET /attendance/summary/:classId/:studentId
```
**Parameters:**
- `classId` (integer): Class ID
- `studentId` (integer): Student ID

**Response:**
```json
{
  "success": true,
  "data": {
    "total_days": 20,
    "present_days": 18,
    "absent_days": 2,
    "late_days": 0,
    "attendance_percentage": 90.00
  }
}
```

---

## SESSION ENDPOINTS

### Create Session
```
POST /sessions
```
**Request Body:**
```json
{
  "class_id": 1,
  "session_date": "2026-06-08",
  "start_time": "09:00:00",
  "end_time": "12:00:00",
  "duration_minutes": 180,
  "created_by": 3
}
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "class_id": 1,
    "session_date": "2026-06-08",
    "status": "scheduled"
  }
}
```

### Get Class Sessions
```
GET /sessions/:classId
```
**Parameters:**
- `classId` (integer): Class ID

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "class_id": 1,
      "session_date": "2026-06-08",
      "start_time": "09:00:00",
      "end_time": "12:00:00",
      "duration_minutes": 180,
      "status": "scheduled",
      "created_by": 3,
      "created_at": "2026-06-07T10:00:00.000Z"
    }
  ]
}
```

---

## ERROR RESPONSES

### 400 Bad Request
```json
{
  "success": false,
  "error": "fromDate and toDate are required"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "User not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Error message describing the issue"
}
```

---

## USAGE EXAMPLES

### cURL Examples

**Create a Student:**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "role": "student",
    "roll_number": "STU001",
    "password_hash": "hashed_password"
  }'
```

**Mark Attendance:**
```bash
curl -X POST http://localhost:3000/api/attendance/mark \
  -H "Content-Type: application/json" \
  -d '{
    "class_id": 1,
    "student_id": 5,
    "attendance_date": "2026-06-07",
    "status": "present",
    "check_in_time": "09:00:00",
    "check_out_time": "12:00:00",
    "recorded_by": 3
  }'
```

**Get Attendance Summary:**
```bash
curl http://localhost:3000/api/attendance/summary/1/5
```

### JavaScript (Fetch API) Examples

**Create User:**
```javascript
const response = await fetch('http://localhost:3000/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
    role: 'student',
    roll_number: 'STU001',
    password_hash: 'hashed_password'
  })
});
const data = await response.json();
```

**Get Attendance Summary:**
```javascript
const response = await fetch('http://localhost:3000/api/attendance/summary/1/5');
const data = await response.json();
console.log(data.data); // { total_days: 20, present_days: 18, ... }
```

---

## Rate Limiting
No rate limiting currently implemented. Add in production.

## Security Notes
- Add JWT authentication
- Validate all inputs
- Use HTTPS in production
- Implement CORS properly
- Add input sanitization