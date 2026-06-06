-- =============================================
-- QR ATTENDANCE SYSTEM — FULL DATABASE SCHEMA
-- College: CAIT
-- Run this entire file in MySQL Workbench once
-- =============================================

CREATE DATABASE IF NOT EXISTS attendance_db;
USE attendance_db;

-- 1. semesters
CREATE TABLE semesters (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    year        INT          NOT NULL,
    division    VARCHAR(10),
    is_current  BOOLEAN DEFAULT FALSE
);

-- 2. users (all roles: admin, faculty, staff, student)
CREATE TABLE users (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)  NOT NULL,
    email           VARCHAR(100)  UNIQUE NOT NULL,
    password_hash   VARCHAR(255)  NOT NULL,
    role            ENUM('admin','faculty','staff','student') NOT NULL,
    semester_id     INT,
    enrollment_no   VARCHAR(30) UNIQUE,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (semester_id) REFERENCES semesters(id)
);

-- 3. devices (registered devices per student — approved by admin)
CREATE TABLE devices (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NOT NULL,
    fingerprint_hash VARCHAR(255) NOT NULL,
    device_label    VARCHAR(100),
    registered_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active       BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 4. subjects (subject-faculty-semester assignments)
CREATE TABLE subjects (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    code            VARCHAR(20)  UNIQUE NOT NULL,
    semester_id     INT          NOT NULL,
    faculty_id      INT          NOT NULL,
    total_lectures  INT DEFAULT 0,
    FOREIGN KEY (semester_id) REFERENCES semesters(id),
    FOREIGN KEY (faculty_id)  REFERENCES users(id)
);

-- 5. college_entry_log (every gate QR scan attempt)
-- UNIQUE KEY prevents a student scanning twice in the same session
CREATE TABLE college_entry_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NOT NULL,
    session         ENUM('morning','afternoon') NOT NULL,
    entry_date      DATE         NOT NULL,
    scanned_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address      VARCHAR(45),
    fingerprint_hash VARCHAR(255),
    status          ENUM('valid','rejected_time','rejected_ip','rejected_device') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uq_entry (user_id, session, entry_date)
);

-- 6. classroom_attendance (faculty-marked class attendance)
-- UNIQUE KEY prevents marking the same student twice for same subject/date/session
CREATE TABLE classroom_attendance (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT          NOT NULL,
    subject_id  INT          NOT NULL,
    class_date  DATE         NOT NULL,
    session     ENUM('morning','afternoon') NOT NULL,
    status      ENUM('present','absent','late') NOT NULL DEFAULT 'absent',
    marked_by   INT          NOT NULL,
    mark_type   ENUM('manual','qr_auto') NOT NULL DEFAULT 'manual',
    marked_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note        VARCHAR(255),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (marked_by)  REFERENCES users(id),
    UNIQUE KEY uq_class (student_id, subject_id, class_date, session)
);

-- 7. manual_override_log (audit trail of every admin attendance change)
CREATE TABLE manual_override_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    attendance_id   INT          NOT NULL,
    overridden_by   INT          NOT NULL,
    reason          VARCHAR(255),
    overridden_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    prev_status     ENUM('present','absent','late') NOT NULL,
    new_status      ENUM('present','absent','late') NOT NULL,
    FOREIGN KEY (attendance_id)  REFERENCES classroom_attendance(id),
    FOREIGN KEY (overridden_by)  REFERENCES users(id)
);

-- 8. qr_settings (admin-controlled time windows and college IP)
CREATE TABLE qr_settings (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    session         ENUM('morning','afternoon') NOT NULL UNIQUE,
    window_start    TIME         NOT NULL,
    window_end      TIME         NOT NULL,
    grace_minutes   INT DEFAULT 5,
    college_ip      VARCHAR(45)  NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by      INT,
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- =============================================
-- SEED DATA — default admin + QR settings
-- Password for admin is: admin123
-- Change this immediately after first login
-- =============================================

-- Default QR time windows
INSERT INTO qr_settings (session, window_start, window_end, grace_minutes, college_ip) VALUES
('morning',   '08:30:00', '09:30:00', 5, '0.0.0.0'),
('afternoon', '13:30:00', '14:00:00', 5, '0.0.0.0');

-- Default semester
INSERT INTO semesters (name, year, division, is_current) VALUES
('Semester 4', 2024, 'SEC-II', TRUE);

-- Default admin user
-- bcrypt hash of 'admin123' (cost=10)
INSERT INTO users (name, email, password_hash, role) VALUES
('Principal Admin', 'admin@cait.edu.in', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');
