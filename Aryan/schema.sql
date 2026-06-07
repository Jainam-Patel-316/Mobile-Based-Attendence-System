-- Create Database
CREATE DATABASE IF NOT EXISTS attendance_system;
USE attendance_system;

-- Users Table (Students/Staff)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(15),
  role ENUM('student', 'teacher', 'admin') DEFAULT 'student',
  roll_number VARCHAR(50) UNIQUE,
  password_hash VARCHAR(255),
  profile_image LONGBLOB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_roll_number (roll_number),
  INDEX idx_role (role)
);

-- Classes Table
CREATE TABLE IF NOT EXISTS classes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  teacher_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_teacher_id (teacher_id)
);

-- Class Members (Student Enrollment)
CREATE TABLE IF NOT EXISTS class_members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_id INT NOT NULL,
  student_id INT NOT NULL,
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_enrollment (class_id, student_id),
  INDEX idx_student_id (student_id)
);

-- Attendance Table
CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_id INT NOT NULL,
  student_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  check_in_time TIME,
  check_out_time TIME,
  status ENUM('present', 'absent', 'late', 'excused') DEFAULT 'absent',
  remarks TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY unique_attendance (class_id, student_id, attendance_date),
  INDEX idx_attendance_date (attendance_date),
  INDEX idx_student_id (student_id),
  INDEX idx_class_id (class_id)
);

-- Sessions Table (For tracking session/class sessions)
CREATE TABLE IF NOT EXISTS sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_id INT NOT NULL,
  session_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INT,
  status ENUM('scheduled', 'ongoing', 'completed', 'cancelled') DEFAULT 'scheduled',
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_session_date (session_date),
  INDEX idx_class_id (class_id)
);

-- Attendance Reports Table (For storing generated reports)
CREATE TABLE IF NOT EXISTS attendance_reports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_id INT NOT NULL,
  student_id INT NOT NULL,
  report_month INT NOT NULL,
  report_year INT NOT NULL,
  total_days INT DEFAULT 0,
  present_days INT DEFAULT 0,
  absent_days INT DEFAULT 0,
  late_days INT DEFAULT 0,
  attendance_percentage DECIMAL(5,2) DEFAULT 0.00,
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_report (class_id, student_id, report_month, report_year),
  INDEX idx_report_month_year (report_year, report_month)
);

-- Create indexes for better performance
CREATE INDEX idx_attendance_class_date ON attendance(class_id, attendance_date);
CREATE INDEX idx_attendance_student_date ON attendance(student_id, attendance_date);