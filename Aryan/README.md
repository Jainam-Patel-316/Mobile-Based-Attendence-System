# Mobile-Based Attendance System - Database Module

This folder contains the complete MySQL database setup and backend API for the Mobile-Based Attendance System.

## 📁 Files Overview

### Core Database Files
- **db_config.js** - MySQL connection pool configuration
- **db_queries.js** - All database query functions (users, classes, attendance, sessions)
- **schema.sql** - Complete database schema with all tables and indexes

### Configuration & Setup
- **.env.example** - Environment variables template
- **package.json** - Node.js dependencies
- **DATABASE_SETUP.md** - Step-by-step setup guide

### Server & API
- **server.js** - Express.js REST API server
- **API_DOCUMENTATION.md** - Complete API endpoints documentation

### Documentation
- **README.md** - This file

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup Database
```bash
mysql -u root -p < schema.sql
```

### 3. Configure Environment
```bash
cp .env.example .env
# Edit .env with your MySQL credentials
```

### 4. Start Server
```bash
npm start
```

Server will run on `http://localhost:3000`

## 📊 Database Tables

### users
Stores all users (students, teachers, admins)

### classes
Stores class information and teacher assignments

### class_members
Maps students to classes (enrollment)

### attendance
Main attendance records with check-in/out times

### sessions
Tracks individual class sessions

### attendance_reports
Monthly attendance summaries and statistics

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/:id` | Get user by ID |
| POST | `/api/users` | Create new user |
| GET | `/api/classes` | Get all classes |
| POST | `/api/classes` | Create new class |
| POST | `/api/attendance/mark` | Mark attendance |
| GET | `/api/attendance/:classId/:studentId` | Get student attendance |
| GET | `/api/attendance/summary/:classId/:studentId` | Get attendance summary |

## 📝 Usage Examples

### Mark Attendance
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

### Get Attendance Summary
```bash
curl http://localhost:3000/api/attendance/summary/1/5
```

## 🔧 Configuration

### MySQL Connection (.env)
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=attendance_system
PORT=3000
NODE_ENV=development
```

## 📚 Documentation

- **DATABASE_SETUP.md** - Detailed setup instructions
- **API_DOCUMENTATION.md** - Complete API reference with examples

## 🛠️ Development

### Testing the API
Use Postman, Insomnia, or cURL to test endpoints

### Adding New Endpoints
1. Add query function in `db_queries.js`
2. Add route handler in `server.js`
3. Document in `API_DOCUMENTATION.md`

### Database Changes
1. Update schema in `schema.sql`
2. Drop and recreate database
3. Update query functions accordingly

## 🔐 Security Considerations

- [ ] Add JWT authentication
- [ ] Add input validation
- [ ] Add CORS configuration
- [ ] Use environment variables for secrets
- [ ] Implement rate limiting
- [ ] Add password hashing (bcrypt)
- [ ] Add SQL injection prevention

## 📦 Dependencies

- **mysql2** - MySQL driver with promise support
- **dotenv** - Environment variable management
- **express** - Web framework (in server.js)

## 📞 Support

For issues or questions, contact the development team or create an issue in the repository.

## 📄 License

MIT License