-- ====================================================================
-- MOBILE-BASED ATTENDANCE SYSTEM - DATABASE SCHEMA v3
-- Fully Aligned with Hetvi Frontend
-- ====================================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS attendance_system_v3;
USE attendance_system_v3;

-- ====================================================================
-- 1. USERS TABLE (for login authentication)
-- ====================================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50),
    email VARCHAR(100),
    password_hash VARCHAR(255),
    role ENUM('student', 'parent', 'faculty', 'admin') NOT NULL,
    enrollment_number VARCHAR(20) UNIQUE,
    phone_number VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_enrollment (enrollment_number),
    INDEX idx_username (username),
    INDEX idx_role (role)
);

-- ====================================================================
-- 2. STUDENTS TABLE (detailed student information)
-- ====================================================================
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    enrollment_number VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(15),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    semester INT NOT NULL,
    section VARCHAR(10) NOT NULL,
    hosteler BOOLEAN DEFAULT FALSE,
    parent_reference_number VARCHAR(20),
    admission_year INT,
    department VARCHAR(50),
    cgpa DECIMAL(3, 2),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_enrollment (enrollment_number),
    INDEX idx_semester (semester),
    INDEX idx_section (section),
    INDEX idx_hosteler (hosteler)
);

-- ====================================================================
-- 3. FACULTY TABLE (faculty/teacher information)
-- ====================================================================
CREATE TABLE faculty (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(15),
    department VARCHAR(50) NOT NULL,
    designation VARCHAR(50),
    qualification VARCHAR(100),
    specialization VARCHAR(100),
    office_room VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_username (username),
    INDEX idx_department (department)
);

-- ====================================================================
-- 4. COURSES TABLE (course/subject information)
-- ====================================================================
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    section VARCHAR(10) NOT NULL,
    semester INT NOT NULL,
    credits INT DEFAULT 4,
    category VARCHAR(50),
    faculty_id INT,
    total_sessions INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (faculty_id) REFERENCES faculty(id) ON DELETE SET NULL,
    INDEX idx_course_code (course_code),
    INDEX idx_section (section),
    INDEX idx_semester (semester),
    INDEX idx_faculty (faculty_id)
);

-- ====================================================================
-- 5. STUDENT_COURSE ENROLLMENT TABLE
-- ====================================================================
CREATE TABLE student_course_enrollment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT CURDATE(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id),
    INDEX idx_student (student_id),
    INDEX idx_course (course_id)
);

-- ====================================================================
-- 6. ATTENDANCE TABLE (main attendance records)
-- ====================================================================
CREATE TABLE attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('present', 'absent', 'late', 'leave') DEFAULT 'absent',
    recorded_by INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by) REFERENCES faculty(id) ON DELETE SET NULL,
    UNIQUE KEY unique_attendance (student_id, course_id, attendance_date),
    INDEX idx_student (student_id),
    INDEX idx_course (course_id),
    INDEX idx_date (attendance_date),
    INDEX idx_status (status)
);

-- ====================================================================
-- 7. ATTENDANCE SUMMARY TABLE (cached statistics)
-- ====================================================================
CREATE TABLE attendance_summary (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    total_sessions INT DEFAULT 0,
    sessions_present INT DEFAULT 0,
    sessions_absent INT DEFAULT 0,
    sessions_late INT DEFAULT 0,
    sessions_leave INT DEFAULT 0,
    attendance_percentage DECIMAL(5, 2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_summary (student_id, course_id),
    INDEX idx_student (student_id),
    INDEX idx_course (course_id),
    INDEX idx_percentage (attendance_percentage)
);

-- ====================================================================
-- 8. PARENTS TABLE (parent/guardian information)
-- ====================================================================
CREATE TABLE parents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(15),
    parent_reference_number VARCHAR(20) UNIQUE NOT NULL,
    relationship VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reference (parent_reference_number)
);

-- ====================================================================
-- 9. STUDENT_PARENT MAPPING TABLE
-- ====================================================================
CREATE TABLE student_parent_mapping (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    parent_id INT NOT NULL,
    relationship VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES parents(id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_parent (parent_id)
);

-- ====================================================================
-- 10. ADMIN_AUDIT_LOG TABLE (for tracking admin actions)
-- ====================================================================
CREATE TABLE admin_audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    old_values JSON,
    new_values JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_admin (admin_id),
    INDEX idx_created (created_at)
);

-- ====================================================================
-- SAMPLE DATA INSERTION
-- ====================================================================

-- Insert Users
INSERT INTO users (name, username, email, password_hash, role, enrollment_number) VALUES
('Chauhan Aryan', 'aryan_chauhan', 'aryan@example.com', 'hash_password_123', 'admin', NULL),
('John Doe', NULL, 'john.doe@example.com', 'hash_password_123', 'student', '3060824001'),
('Jane Smith', NULL, 'jane.smith@example.com', 'hash_password_123', 'student', '3060824002'),
('Dr. Amit Sharma', 'dr_amit_sharma', 'amit.sharma@college.com', 'hash_password_123', 'faculty', NULL),
('Prof. V. Narayan', 'prof_v_narayan', 'v.narayan@college.com', 'hash_password_123', 'faculty', NULL),
('Mrs. Priya Patel', NULL, 'priya.patel@email.com', 'hash_password_123', 'parent', NULL);

-- Insert Students
INSERT INTO students (user_id, enrollment_number, name, email, semester, section, hosteler, admission_year, department, parent_reference_number) VALUES
(2, '3060824001', 'John Doe', 'john.doe@example.com', 4, 'SEC-II', TRUE, 2022, 'Computer Science', 'PAR001'),
(3, '3060824002', 'Jane Smith', 'jane.smith@example.com', 2, 'SEC-I', FALSE, 2023, 'Information Technology', 'PAR002');

-- Insert Faculty
INSERT INTO faculty (user_id, username, name, email, department, designation, specialization) VALUES
(4, 'dr_amit_sharma', 'Dr. Amit Sharma', 'amit.sharma@college.com', 'Computer Science', 'Associate Professor', 'Web Development'),
(5, 'prof_v_narayan', 'Prof. V. Narayan', 'v.narayan@college.com', 'Information Technology', 'Professor', 'Database Systems');

-- Insert Parents
INSERT INTO parents (user_id, name, email, phone_number, parent_reference_number, relationship) VALUES
(6, 'Mrs. Priya Patel', 'priya.patel@email.com', '9876543210', 'PAR001', 'Mother');

-- Insert Courses
INSERT INTO courses (course_code, name, section, semester, credits, category, faculty_id, total_sessions) VALUES
('CS401', 'Intro to Web Scripting', 'SEC-II', 4, 4, 'Theory Lectures', 1, 22),
('IT201', 'Database Management Systems', 'SEC-I', 2, 4, 'Practical Labs', 2, 12),
('CS402', 'Advanced Java Systems', 'SEC-I', 6, 4, 'Theory Lectures', 1, 20);

-- Insert Student Course Enrollment
INSERT INTO student_course_enrollment (student_id, course_id) VALUES
(1, 1), -- John Doe enrolled in CS401
(2, 2); -- Jane Smith enrolled in IT201

-- Insert Attendance Records
INSERT INTO attendance (student_id, course_id, attendance_date, status, recorded_by) VALUES
(1, 1, '2024-01-15', 'present', 1),
(1, 1, '2024-01-16', 'present', 1),
(1, 1, '2024-01-17', 'absent', 1),
(1, 1, '2024-01-18', 'present', 1),
(1, 1, '2024-01-19', 'present', 1),
(1, 1, '2024-01-22', 'present', 1),
(1, 1, '2024-01-23', 'late', 1),
(1, 1, '2024-01-24', 'present', 1),
(2, 2, '2024-01-15', 'present', 2),
(2, 2, '2024-01-16', 'present', 2),
(2, 2, '2024-01-17', 'present', 2),
(2, 2, '2024-01-18', 'absent', 2),
(2, 2, '2024-01-19', 'present', 2);

-- Update Attendance Summary
INSERT INTO attendance_summary (student_id, course_id, total_sessions, sessions_present, sessions_absent, sessions_late, attendance_percentage)
SELECT 
    a.student_id,
    a.course_id,
    COUNT(*) as total_sessions,
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as sessions_present,
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as sessions_absent,
    SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END) as sessions_late,
    ROUND((SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as attendance_percentage
FROM attendance a
GROUP BY a.student_id, a.course_id;

-- ====================================================================
-- CREATE VIEWS FOR EASY DATA RETRIEVAL
-- ====================================================================

-- View for Student Dashboard
CREATE VIEW student_attendance_view AS
SELECT 
    s.id,
    s.enrollment_number,
    s.name,
    c.id as course_id,
    c.name as course_name,
    c.section,
    c.category,
    asv.total_sessions,
    asv.sessions_present,
    asv.attendance_percentage
FROM students s
JOIN student_course_enrollment sce ON s.id = sce.student_id
JOIN courses c ON sce.course_id = c.id
LEFT JOIN attendance_summary asv ON s.id = asv.student_id AND c.id = asv.course_id;

-- View for Faculty Dashboard
CREATE VIEW faculty_courses_view AS
SELECT 
    f.id,
    f.username,
    f.name,
    f.department,
    c.id as course_id,
    c.name as course_name,
    c.section,
    c.semester,
    COUNT(DISTINCT sce.student_id) as student_count
FROM faculty f
LEFT JOIN courses c ON f.id = c.faculty_id
LEFT JOIN student_course_enrollment sce ON c.id = sce.course_id
GROUP BY f.id, c.id;

-- View for Admin Dashboard
CREATE VIEW admin_student_view AS
SELECT 
    s.id,
    s.enrollment_number,
    s.name,
    s.email,
    s.semester,
    s.section,
    s.hosteler,
    s.department,
    u.created_at
FROM students s
JOIN users u ON s.user_id = u.id;

-- View for Admin Faculty View
CREATE VIEW admin_faculty_view AS
SELECT 
    f.id,
    f.username,
    f.name,
    f.email,
    f.department,
    f.designation,
    u.created_at
FROM faculty f
JOIN users u ON f.user_id = u.id;

-- ====================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ====================================================================

CREATE INDEX idx_attendance_student_course ON attendance(student_id, course_id);
CREATE INDEX idx_attendance_summary_percentage ON attendance_summary(student_id, attendance_percentage);
CREATE INDEX idx_student_enrollment ON students(enrollment_number, semester);
CREATE INDEX idx_course_faculty_section ON courses(faculty_id, section);

-- ====================================================================
-- END OF SCHEMA
-- ====================================================================
