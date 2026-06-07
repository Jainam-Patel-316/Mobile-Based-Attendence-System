-- ============================================================
-- COMPLETE REDESIGNED DATABASE SCHEMA FOR ATTENDANCE SYSTEM
-- Fully Compatible with Hetvi Frontend
-- ============================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS attendance_system;
USE attendance_system;

-- ============================================================
-- TABLE 1: USERS (Students, Faculty, Admin, Parents)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(15),
  username VARCHAR(50) UNIQUE,
  password_hash VARCHAR(255),
  
  -- Role: student, faculty, admin, parent
  role ENUM('student', 'faculty', 'admin', 'parent') NOT NULL DEFAULT 'student',
  
  -- Student Specific Fields
  enrollment VARCHAR(50) UNIQUE,
  roll_number VARCHAR(50) UNIQUE,
  parent_ref VARCHAR(50),
  semester VARCHAR(50),
  section VARCHAR(20),
  hosteler BOOLEAN DEFAULT FALSE,
  
  -- Faculty Specific Fields
  department VARCHAR(100),
  qualification VARCHAR(100),
  
  -- Common Fields
  profile_image LONGBLOB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Indexes for better performance
  INDEX idx_email (email),
  INDEX idx_username (username),
  INDEX idx_enrollment (enrollment),
  INDEX idx_roll_number (roll_number),
  INDEX idx_role (role),
  INDEX idx_parent_ref (parent_ref),
  INDEX idx_section (section)
);

-- ============================================================
-- TABLE 2: COURSES/SUBJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS courses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(50) UNIQUE,
  category ENUM('Theory Lectures', 'Practical Labs', 'Seminar', 'Project') DEFAULT 'Theory Lectures',
  section VARCHAR(20) NOT NULL,
  semester VARCHAR(50),
  teacher_id INT,
  description TEXT,
  credits INT DEFAULT 4,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_section (section),
  INDEX idx_semester (semester),
  INDEX idx_teacher_id (teacher_id),
  INDEX idx_code (code)
);

-- ============================================================
-- TABLE 3: COURSE ENROLLMENT (Student-Course Mapping)
-- ============================================================
CREATE TABLE IF NOT EXISTS course_enrollment (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  student_id INT NOT NULL,
  enrolled_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_sessions INT DEFAULT 0,
  attended_sessions INT DEFAULT 0,
  
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_enrollment (course_id, student_id),
  INDEX idx_student_id (student_id),
  INDEX idx_course_id (course_id)
);

-- ============================================================
-- TABLE 4: ATTENDANCE (Main Attendance Records)
-- ============================================================
CREATE TABLE IF NOT EXISTS attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  student_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  check_in_time TIME,
  check_out_time TIME,
  
  -- Status: present, absent, late, excused
  status ENUM('present', 'absent', 'late', 'excused') DEFAULT 'absent',
  remarks TEXT,
  recorded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE SET NULL,
  
  UNIQUE KEY unique_attendance (course_id, student_id, attendance_date),
  INDEX idx_attendance_date (attendance_date),
  INDEX idx_student_id (student_id),
  INDEX idx_course_id (course_id),
  INDEX idx_status (status)
);

-- ============================================================
-- TABLE 5: SESSIONS (Class Sessions)
-- ============================================================
CREATE TABLE IF NOT EXISTS sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  session_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INT,
  
  -- Status: scheduled, ongoing, completed, cancelled
  status ENUM('scheduled', 'ongoing', 'completed', 'cancelled') DEFAULT 'scheduled',
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_session_date (session_date),
  INDEX idx_course_id (course_id),
  INDEX idx_status (status)
);

-- ============================================================
-- TABLE 6: ATTENDANCE REPORTS (Monthly/Period Summaries)
-- ============================================================
CREATE TABLE IF NOT EXISTS attendance_reports (
  id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  student_id INT NOT NULL,
  report_month INT NOT NULL,
  report_year INT NOT NULL,
  
  total_days INT DEFAULT 0,
  present_days INT DEFAULT 0,
  absent_days INT DEFAULT 0,
  late_days INT DEFAULT 0,
  excused_days INT DEFAULT 0,
  attendance_percentage DECIMAL(5,2) DEFAULT 0.00,
  
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_report (course_id, student_id, report_month, report_year),
  INDEX idx_report_month_year (report_year, report_month),
  INDEX idx_student_id (student_id)
);

-- ============================================================
-- TABLE 7: PARENT-STUDENT RELATIONSHIP
-- ============================================================
CREATE TABLE IF NOT EXISTS parent_student_mapping (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT NOT NULL,
  student_id INT NOT NULL,
  relationship VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_parent_student (parent_id, student_id),
  INDEX idx_student_id (student_id),
  INDEX idx_parent_id (parent_id)
);

-- ============================================================
-- TABLE 8: ADMIN LOGS (Audit Trail)
-- ============================================================
CREATE TABLE IF NOT EXISTS admin_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admin_id INT NOT NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50),
  entity_id INT,
  old_value JSON,
  new_value JSON,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_action (action),
  INDEX idx_created_at (created_at)
);

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================
CREATE INDEX idx_attendance_course_date ON attendance(course_id, attendance_date);
CREATE INDEX idx_attendance_student_date ON attendance(student_id, attendance_date);
CREATE INDEX idx_course_enrollment_course ON course_enrollment(course_id, student_id);
CREATE INDEX idx_sessions_course_date ON sessions(course_id, session_date);

-- ============================================================
-- DEFAULT DATA (For Testing)
-- ============================================================

-- Insert Admin User
INSERT INTO users (name, email, username, password_hash, role, is_active) 
VALUES ('Admin User', 'admin@attendance.com', 'admin', 'adminpassword', 'admin', TRUE)
ON DUPLICATE KEY UPDATE id=id;

-- Insert Sample Faculty
INSERT INTO users (name, email, username, password_hash, role, department, is_active) 
VALUES 
('Dr. Amit Sharma', 'amit@college.com', 'dr_amit_sharma', 'password123', 'faculty', 'Computer Science', TRUE),
('Prof. V. Narayan', 'narayan@college.com', 'prof_v_narayan', 'password123', 'faculty', 'Information Technology', TRUE)
ON DUPLICATE KEY UPDATE id=id;

-- Insert Sample Students
INSERT INTO users (name, email, enrollment, roll_number, role, semester, section, hosteler, is_active) 
VALUES 
('John Doe', 'john@student.com', '3060821045', '3060821045', 'student', 'Semester 4', 'SEC-II', TRUE, TRUE),
('Jane Smith', 'jane@student.com', 'ENR3060824001', 'ENR3060824001', 'student', 'Semester 2', 'SEC-I', FALSE, TRUE),
('Mike Johnson', 'mike@student.com', 'ENR3060824002', 'ENR3060824002', 'student', 'Semester 2', 'SEC-I', TRUE, TRUE)
ON DUPLICATE KEY UPDATE id=id;

-- Insert Sample Courses
INSERT INTO courses (name, code, category, section, semester, teacher_id) 
VALUES 
('Intro to Web Scripting', 'CS-301', 'Theory Lectures', 'SEC-II', 'Semester 4', 1),
('Database Management Systems', 'CS-302', 'Practical Labs', 'SEC-I', 'Semester 2', 2),
('Advanced Java Systems', 'CS-401', 'Theory Lectures', 'SEC-I', 'Semester 6', 1)
ON DUPLICATE KEY UPDATE id=id;

-- ============================================================
-- END OF SCHEMA
-- ============================================================
