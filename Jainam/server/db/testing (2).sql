-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 18, 2026 at 05:50 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `testing`
--

-- --------------------------------------------------------

--
-- Table structure for table `classroom_attendance`
--

CREATE TABLE `classroom_attendance` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `class_date` date NOT NULL,
  `session` enum('morning','afternoon') NOT NULL,
  `status` enum('present','absent','late') NOT NULL DEFAULT 'absent',
  `marked_by` int(11) NOT NULL,
  `mark_type` enum('manual','qr_auto') NOT NULL DEFAULT 'manual',
  `marked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `college_entry_log`
--

CREATE TABLE `college_entry_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session` enum('morning','afternoon') NOT NULL,
  `entry_date` date NOT NULL,
  `scanned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL,
  `fingerprint_hash` varchar(255) DEFAULT NULL,
  `status` enum('valid','rejected_time','rejected_ip','rejected_device') NOT NULL,
  `geo_lat` decimal(10,7) DEFAULT NULL,
  `geo_lng` decimal(10,7) DEFAULT NULL,
  `geo_status` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `college_entry_log`
--

INSERT INTO `college_entry_log` (`id`, `user_id`, `session`, `entry_date`, `scanned_at`, `ip_address`, `fingerprint_hash`, `status`, `geo_lat`, `geo_lng`, `geo_status`) VALUES
(10, 15, 'morning', '2026-06-17', '2026-06-17 13:59:31', '2409:40c1:4021:18eb:5c7a:7dff:fe18:c59f', '304c25183a0212ac0be87213a734c0d7', 'valid', 22.5339115, 72.9809141, 'verified'),
(11, 21, 'morning', '2026-06-17', '2026-06-17 14:17:55', '2409:40c1:4037:5323:407d:d1ff:fea1:aee4', '0219b3e42ec42e0da0eace163c68a75a', 'valid', 22.5339099, 72.9809105, 'verified'),
(12, 15, 'morning', '2026-06-18', '2026-06-18 15:08:58', '2409:40c1:402e:ae21:7005:1bff:fe6b:8a99', '304c25183a0212ac0be87213a734c0d7', 'valid', 22.5339288, 72.9809171, 'verified');

-- --------------------------------------------------------

--
-- Table structure for table `devices`
--

CREATE TABLE `devices` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `fingerprint_hash` varchar(255) NOT NULL,
  `device_label` varchar(100) DEFAULT NULL,
  `registered_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `devices`
--

INSERT INTO `devices` (`id`, `user_id`, `fingerprint_hash`, `device_label`, `registered_at`, `is_active`) VALUES
(4, 16, '54d26decfbb088cc7731e464539f2b2b', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)', '2026-06-17 13:35:26', 1),
(5, 15, '304c25183a0212ac0be87213a734c0d7', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-17 13:58:30', 1),
(6, 21, '0219b3e42ec42e0da0eace163c68a75a', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-17 14:16:47', 1),
(7, 22, 'a44cfa317879579fa520f9043ae4befd', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-18 15:16:40', 1);

-- --------------------------------------------------------

--
-- Table structure for table `manual_override_log`
--

CREATE TABLE `manual_override_log` (
  `id` int(11) NOT NULL,
  `attendance_id` int(11) NOT NULL,
  `overridden_by` int(11) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `overridden_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `prev_status` enum('present','absent','late') NOT NULL,
  `new_status` enum('present','absent','late') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `qr_settings`
--

CREATE TABLE `qr_settings` (
  `id` int(11) NOT NULL,
  `session` enum('morning','afternoon') NOT NULL,
  `window_start` time NOT NULL,
  `window_end` time NOT NULL,
  `grace_minutes` int(11) DEFAULT 5,
  `college_ip` varchar(45) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `geo_lat` decimal(10,7) DEFAULT NULL,
  `geo_lng` decimal(10,7) DEFAULT NULL,
  `geo_radius_meters` int(11) DEFAULT 200
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `qr_settings`
--

INSERT INTO `qr_settings` (`id`, `session`, `window_start`, `window_end`, `grace_minutes`, `college_ip`, `is_active`, `updated_at`, `updated_by`, `geo_lat`, `geo_lng`, `geo_radius_meters`) VALUES
(1, 'morning', '08:30:00', '22:00:00', 5, '0.0.0.0', 1, '2026-06-18 15:19:15', NULL, 22.5337100, 72.9701670, 1105),
(2, 'afternoon', '13:30:00', '23:30:00', 5, '0.0.0.0', 1, '2026-06-15 17:01:09', NULL, 22.5337100, 72.9701670, 1105);

-- --------------------------------------------------------

--
-- Table structure for table `semesters`
--

CREATE TABLE `semesters` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `year` int(11) NOT NULL,
  `division` varchar(20) DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `semesters`
--

INSERT INTO `semesters` (`id`, `name`, `year`, `division`, `is_current`) VALUES
(1, 'Semester I', 2024, 'First Year', 0),
(2, 'Semester II', 2024, 'First Year', 0),
(3, 'Semester III', 2024, 'Second Year', 0),
(4, 'Semester IV', 2024, 'Second Year', 1),
(5, 'Semester V', 2025, 'Third Year', 0),
(6, 'Semester VI', 2025, 'Third Year', 0),
(7, 'Semester VII', 2025, 'Fourth Year', 0),
(8, 'Semester VIII', 2025, 'Fourth Year', 0);

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) NOT NULL,
  `semester_id` int(11) NOT NULL,
  `faculty_id` int(11) NOT NULL,
  `total_lectures` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`id`, `name`, `code`, `semester_id`, `faculty_id`, `total_lectures`) VALUES
(1, 'Deeksharambh (Induction cum Foundation course)', 'FC-I', 1, 1, 0),
(2, 'Fundamentals of Computers', 'SEC-I', 1, 1, 0),
(3, 'Introduction to Web Scripting', 'SEC-II', 1, 1, 0),
(4, 'Programming in C', 'AIT111', 1, 1, 0),
(5, 'Fundamentals of Agronomy', 'AGRI111', 1, 1, 0),
(6, 'Fundamentals of Horticulture', 'AGRI112', 1, 1, 0),
(7, 'Engineering Mathematics I', 'MATH111', 1, 1, 0),
(8, 'Farming Based Livelihood Systems', 'MDC-I', 1, 1, 0),
(9, 'Communication Skills', 'AEC-I', 1, 1, 0),
(10, 'National Service Scheme (NSS-I)', 'AEC-II', 1, 1, 0),
(11, 'National Cadet Corps (NCC-I)', 'AEC-III', 1, 1, 0),
(12, 'Software Workshop', 'SEC-III', 2, 1, 0),
(13, 'Web Development Workshop', 'SEC-IV', 2, 1, 0),
(14, 'Data Structure Through C', 'AIT121', 2, 1, 0),
(15, 'Fundamentals of Soil Science', 'AGRI121', 2, 1, 0),
(16, 'Fundamentals of Entomology', 'AGRI122', 2, 1, 0),
(17, 'Engineering Mathematics II', 'MATH121', 2, 1, 0),
(18, 'Environmental Studies and Disaster Management', 'VAC-I', 2, 1, 0),
(19, 'Personality Development', 'AEC-IV', 2, 1, 0),
(20, 'National Service Scheme (NSS-II)', 'AEC-V', 2, 1, 0),
(21, 'National Cadet Corps (NCC-II)', 'AEC-VI', 2, 1, 0),
(22, 'Website Development Using PHP', 'SEC-V', 3, 1, 0),
(23, 'Object Oriented Programming', 'AIT211', 3, 1, 0),
(24, 'Database Management Systems', 'AIT212', 3, 1, 0),
(25, 'Computer Organization and Architecture', 'AIT213', 3, 1, 0),
(26, 'Fundamentals of Plant Pathology', 'AGRI211', 3, 1, 0),
(27, 'Fundamentals of Extension Education', 'AGRI212', 3, 1, 0),
(28, 'Basic Electronics and Instrumentation for IoT', 'EI211', 3, 1, 0),
(29, 'Entrepreneurship Development and Business Management', 'MDC-II', 3, 1, 0),
(30, 'Physical Education, First Aid, Yoga and Meditation', 'AEC-VII', 3, 1, 0),
(31, 'National Service Scheme (NSS-III)', 'AEC-VIII', 3, 1, 0),
(32, 'National Cadet Corps (NCC-III)', 'AEC-IX', 3, 1, 0),
(33, 'Web Development in .NET', 'SEC-VI', 4, 1, 0),
(34, 'Computer Networks', 'AIT221', 4, 1, 0),
(35, 'Python Programming', 'AIT222', 4, 1, 0),
(36, 'Software Engineering Principles and Practices', 'AIT223', 4, 1, 0),
(37, 'Basic and Applied Agricultural Statistics', 'AGRI221', 4, 1, 0),
(38, 'Introduction to Agro-meteorology', 'AGRI222', 4, 1, 0),
(39, 'Principles of Agricultural Economics and Farm Management', 'AGRI223', 4, 1, 0),
(40, 'Embedded and IoT System', 'EI221', 4, 1, 0),
(41, 'National Service Scheme (NSS-IV)', 'AEC-X', 4, 1, 0),
(42, 'National Cadet Corps (NCC-IV)', 'AEC-XI', 4, 1, 0),
(43, 'Advanced Web Development in .NET', 'AIT311', 5, 1, 0),
(44, 'Operating Systems', 'AIT312', 5, 1, 0),
(45, 'Image Processing', 'AIT313', 5, 1, 0),
(46, 'Geoinformatics and Remote Sensing', 'AGRI311', 5, 1, 0),
(47, 'Fundamentals of Agricultural Biotechnology', 'AGRI312', 5, 1, 0),
(48, 'Agricultural Informatics and Artificial Intelligence', 'MDC-III', 5, 1, 0),
(49, 'Agricultural Marketing and Trade', 'MDC-IV', 5, 1, 0),
(50, 'Mini Project I', 'PRJT311', 5, 1, 0),
(51, 'Study Tour (10-14 Days)', 'ST311', 5, 1, 0),
(52, 'Digital Forensics', 'AIT321', 6, 1, 0),
(53, 'Advanced Artificial Intelligence', 'AIT322', 6, 1, 0),
(54, 'Application Development in Mobile Technology', 'AIT323', 6, 1, 0),
(55, 'Data Analysis with MATLAB/Open Source Platforms', 'AIT324', 6, 1, 0),
(56, 'Theory of Computation', 'AIT325', 6, 1, 0),
(57, 'Introductory Bioinformatics', 'AGRI321', 6, 1, 0),
(58, 'Agricultural Finance and Cooperation', 'AGRI322', 6, 1, 0),
(59, 'Principles and Practices of Natural Farming', 'AGRI323', 6, 1, 0),
(60, 'Mini Project II', 'PRJT321', 6, 1, 0),
(61, 'Elective Course I', 'AIT411', 7, 1, 0),
(62, 'Elective Course II', 'AIT412', 7, 1, 0),
(63, 'Elective Course III', 'AGRI411', 7, 1, 0),
(64, 'Elective Course IV', 'AGRI412', 7, 1, 0),
(65, 'In House Project III', 'PRJT411', 7, 1, 0),
(66, 'Seminar', 'SMNR411', 7, 1, 0),
(67, 'Project cum Internship', 'PRJT421', 8, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin','faculty','staff','student') NOT NULL,
  `semester_id` int(11) DEFAULT NULL,
  `enrollment_no` varchar(30) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `semester_id`, `enrollment_no`, `is_active`, `created_at`) VALUES
(1, 'Principal Admin', 'admin@cait.edu.in', '$2a$10$l4en9gmsIbiNnt8VRP9YJuxx10vx261qox77XEHdevrIT4ZY7.CWG', 'admin', NULL, NULL, 1, '2026-06-13 13:29:13'),
(15, 'Jainam Patel', '3060824033@student.aau.in', '$2a$10$ANmDDUI9GCqoyY.r40reY.0GCa46ZPBzP6pRkbqUNSxkLrOKgW.de', 'student', 4, '3060824033', 1, '2026-06-17 13:01:35'),
(16, 'Mukti Baria', '3060824001@student.aau.in', '$2a$10$ZPHmsHvWWVu9a3.8MoIXBeeozB2nctiHG64qqRMfBz2UF9qOMADqa', 'student', 4, '3060824001', 1, '2026-06-17 13:02:11'),
(17, 'Alinaqi bukhari', '3060824002@student.aau.in', '$2a$10$LYZ57lce9btc7S/Bw7SNRuvqOA3tppXuT3w0tKm9UOa3K8VVd6voC', 'student', 4, '3060824002', 1, '2026-06-17 13:56:15'),
(18, 'Kudarat Chaudhari', '3060824003@student.aau.in', '$2a$10$jB4g1XSSw.Z0S50gKvr63.ty/.IJ1sxJra1fYqi1HhHj3yNMTHZwm', 'student', 4, '3060824003', 1, '2026-06-17 13:56:47'),
(19, 'Hetvi Chaudhary', '3060824004@student.aau.in', '$2a$10$QxSTwH3UD6tQEQ0Z1BagMem92rhefbu7j8l.WUBZWoSmluKcEpUCy', 'student', 4, '3060824004', 1, '2026-06-17 14:14:34'),
(20, 'Manav Chaudhary', '3060824005@student.aau.in', '$2a$10$ZPQtg34wzHQwHbu3GuRRA.ACD92BRvq4JxzP3YzUNwkyhI.YtO9R.', 'student', 4, '3060824005', 1, '2026-06-17 14:14:56'),
(21, 'Pranav Ganvit', '3060824012@student.aau.in', '$2a$10$Z4JMALID9k..MOYXFkEKmeDhSm4/eATQU62cN4QVDcWC6KzGg/QM.', 'student', 4, '3060824012', 1, '2026-06-17 14:15:27'),
(22, 'Aryan Chauhan', '3060824006@student.aau.in', '$2a$10$WBfGF8WlcKPD8lNrxBxZVetTKXrNxG5iqsNDWLTDtmZ5m2qGsMNKe', 'student', 4, '3060824006', 1, '2026-06-18 15:13:53'),
(23, 'Priyanka Chauhan', '3060824007@student.aau.in', '$2a$10$cPbzhwraSKsFTXuMUetUoO7k7Z883KJdnQNhdTKLOzpd8VaaB3IEq', 'student', 4, '3060824007', 1, '2026-06-18 15:20:38'),
(24, 'Deval Der', '3060824008@student.aau.in', '$2a$10$JC9BGYYQbSTzoJu5QcEWFOQIEXtqMtycJGJfAnFxwBNmxtMO7aF1S', 'student', 4, '3060824008', 1, '2026-06-18 15:20:48'),
(25, 'Ram Der', '3060824009@student.aau.in', '$2a$10$.B8iTG1d3SFNWMY2O.XJSOacwSzk6O9ojAfEON8f3HqtRM7Mg2yrK', 'student', 4, '3060824009', 1, '2026-06-18 15:21:00'),
(26, 'Hemdip Dodiya', '3060824010@student.aau.in', '$2a$10$xZYqVcKDzmqPTz8rJQBn7.l3sw2oYRr02LvG2Q9M1iBXNNzL9xJba', 'student', 4, '3060824010', 1, '2026-06-18 15:21:22'),
(27, 'Mitrali Gohil', '3060824013@student.aau.in', '$2a$10$ncHuTJ6LNDzda3yNTJ9l0eFLjfzvVfRzphC2IL/Tmz.GRJzmvEJb.', 'student', 4, '3060824013', 1, '2026-06-18 15:22:00'),
(28, 'Vipul Gojiya', '3060824014@student.aau.in', '$2a$10$MdDX1/aOozpEkfVQQ83n..9ym11BvfzMoWwQmY1o2s0Z8qm1Dl/ca', 'student', 4, '3060824014', 1, '2026-06-18 15:22:17'),
(29, 'Jiya Gondalia', '3060824015@student.aau.in', '$2a$10$gfUsEM0nxnd4YiQYh0FPXeMtnBJhlxUPAMPC9pTjDKVrG2rUTvSy6', 'student', 4, '3060824015', 1, '2026-06-18 15:22:33'),
(30, 'Darshan Jadav', '3060824016@student.aau.in', '$2a$10$U23pKlm7sRT9uouWbl4DFuqS9rauxM0KD2eyliH1Wukre1QasoM1O', 'student', 4, '3060824016', 1, '2026-06-18 15:22:53'),
(31, 'Rushil Jadav', '3060824017@student.aau.in', '$2a$10$LLlO.E1/GtqJckW6tMEQfe1wY7n6kKTxJmdfnjYtHgPajdYsjY8Fq', 'student', 4, '3060824017', 1, '2026-06-18 15:23:07'),
(32, 'Shital Karangiya', '3060824018@student.aau.in', '$2a$10$LrGLeYvadajDUyHaD5hkY.exXY4YxGzoz1SIA9OUA6jjba4E/oDf6', 'student', 4, '3060824018', 1, '2026-06-18 15:23:27'),
(33, 'Jigar Modiya', '3060824020@student.aau.in', '$2a$10$cNr23hiYdtdPfU1D/wd6LOESQ.6YtLIovZThT1d/.zVVhrBXJ7tsC', 'student', 4, '3060824020', 1, '2026-06-18 15:23:46'),
(34, 'Mohit Nair', '3060824021@student.aau.in', '$2a$10$7AadQ4gr8VWE6MywHB/Lhu5vOHdJ/708elWNxem1IH3ZLoVVzNPKq', 'student', 4, '3060824021', 1, '2026-06-18 15:24:01'),
(35, 'Krupalee Paghdar', '3060824022@student.aau.in', '$2a$10$lVZJR1VDhuYUfKNZQnkDW.FaewwRi0Qq9OunucZODaXxsEMYDxvwO', 'student', 4, '3060824022', 1, '2026-06-18 15:24:30'),
(36, 'Jaldhi Pandya', '3060824023@student.aau.in', '$2a$10$wBOPjQeq73gHfjnEQwAnu.WNI1pb/f.mGXBdzfbl25xJxOXcS7RxO', 'student', 4, '3060824023', 1, '2026-06-18 15:24:46'),
(37, 'Bhavik Parmar', '3060824024@student.aau.in', '$2a$10$GcxqpEcvNBmjkSIGkpzlUO9BQKBzdutIrv.pQvMuNhvl23kUQkSPK', 'student', 4, '3060824024', 1, '2026-06-18 15:25:02'),
(38, 'Kashish Parmar', '3060824025@student.aau.in', '$2a$10$Ab74sx98CsoDITY5rYGepe8yACuZ6NMKH6hZDNJ5srhYkvMn/ap4S', 'student', 4, '3060824025', 1, '2026-06-18 15:25:16'),
(39, 'Krushal Parmar', '3060824026@student.aau.in', '$2a$10$k/5pAFkRkv/FbOpAG/V1euGVQY3COFGCOrupY.1oB9qfCBSRZMYfS', 'student', 4, '3060824026', 1, '2026-06-18 15:25:36'),
(40, 'Nikhil Parmar', '3060824027@student.aau.in', '$2a$10$qAfr5Bi5vjO43b2nozhGR.rlYHqQ7ejxWPYBugWLsBrP6T24eQhcy', 'student', 4, '3060824027', 1, '2026-06-18 15:25:51'),
(41, 'Vraj Parmar', '3060824028@student.aau.in', '$2a$10$dZnVPS72unx5IJyXWT.OZucRZLckOs7zIeNHe6vW1dYjSEGhNvTvi', 'student', 4, '3060824028', 1, '2026-06-18 15:26:06'),
(42, 'Dhrumil Patel', '3060824029@student.aau.in', '$2a$10$R9jFVs/3vqA78WDL001D1uotXxorQtA6CoN1syMfcsBO4qC9kXUJS', 'student', 4, '3060824029', 1, '2026-06-18 15:26:30'),
(43, 'Divya Patel', '3060824030@student.aau.in', '$2a$10$3xftMH6akPANUt8vpClIQOYsA9I6PYXB8ZEeImQ4Tjwrrk4EPT0KC', 'student', 4, '3060824030', 1, '2026-06-18 15:28:31'),
(44, 'Drashti Patel', '3060824031@student.aau.in', '$2a$10$YYxLRN7zZn5shMWoBaLpgOK3L3adTS5I2FuPm2DIsuuamBEfPX97.', 'student', 4, '3060824031', 1, '2026-06-18 15:28:48'),
(45, 'Hetvi Patel', '3060824032@student.aau.in', '$2a$10$1Yuk0wlLeKXx5XN/rlX5c.N83ABu2kYcAaAZ7/WmrkAIsUJdTcyK2', 'student', 4, '3060824032', 1, '2026-06-18 15:29:00'),
(46, 'Mahi Patel', '3060824034@student.aau.in', '$2a$10$1jmvzZD0pimNEOOJ5YqRh.88g4Kkjy9sg.jrPYz7Wer/ywu0VGXJS', 'student', 4, '3060824034', 1, '2026-06-18 15:29:15'),
(47, 'Nisha Patel', '3060824036@student.aau.in', '$2a$10$yqP/AmxpniCuNYaQP02YRunyNB0VMwyMXzq07MWmn48mDiyk8lrMe', 'student', 4, '3060824036', 1, '2026-06-18 15:29:33'),
(48, 'Nitiksha Patel', '3060824037@student.aau.in', '$2a$10$UaCVVfGeb67iqvszRCBgvO5TUduxp3Kgsxysk6JN/znZdWm86HqfG', 'student', 4, '3060824037', 1, '2026-06-18 15:29:49'),
(49, 'Shrey Patel', '3060824038@student.aau.in', '$2a$10$49JsgqmTHW5lq8cClt8QM.7NmfMIUeWfPEAfyFpUxExKq2ygT0u0O', 'student', 4, '3060824038', 1, '2026-06-18 15:30:00'),
(50, 'Soham Patel', '3060824039@student.aau.in', '$2a$10$vjAi/iqjo6UwF39OzezKbOTinDdivR4HtZRT6KKf8jC.l/SCndArO', 'student', 4, '3060824039', 1, '2026-06-18 15:30:11'),
(51, 'Vishwa Patel', '3060824040@student.aau.in', '$2a$10$oVX.66PxiolWaRW1Ncz6A.R4ZKs6UWXX6YDlNB6t23RK1iiyG0i5.', 'student', 4, '3060824040', 1, '2026-06-18 15:30:27'),
(52, 'Siya Prajapati', '3060824041@student.aau.in', '$2a$10$1YlbkrEroDqmsimB13VORuUdqXcXM.6uDOyRuBxevZ4Kk3zWEfJvG', 'student', 4, '3060824041', 1, '2026-06-18 15:30:42'),
(53, 'Harpal Puwar', '3060824042@student.aau.in', '$2a$10$zrC02mf3QGtyrLt4sAPmv.ZUholz0VHaSyeSnhmJZMrLN7iOZqRyK', 'student', 4, '3060824042', 1, '2026-06-18 15:31:04'),
(54, 'Dhruv Ranagola', '3060824043@student.aau.in', '$2a$10$fbVJ18BTEA3h1ZT3eEC2PeoslP6FXRDJAgyua4YAUDAykPGcL/IKi', 'student', 4, '3060824043', 1, '2026-06-18 15:31:18'),
(55, 'Hardik Rathod', '3060824044@student.aau.in', '$2a$10$B6yUP11nvBgUg4aflBhrju.KoaCXDwrW9Wsw4AD6oo/vXso25foCi', 'student', 4, '3060824044', 1, '2026-06-18 15:31:35'),
(56, 'Nidhi Rathod', '3060824045@student.aau.in', '$2a$10$WffSsitVGy69NHYtW9atXu9sMqpoc80whxUCDweBJLyZ0cc0rdU5m', 'student', 4, '3060824045', 1, '2026-06-18 15:31:50'),
(57, 'Shreya Rathod', '3060824046@student.aau.in', '$2a$10$JTePzJ2phA1gsqBjZDrZJO.GBtYizhYjr608BfqYv/DtpDyq4YTGO', 'student', 4, '3060824046', 1, '2026-06-18 15:32:06'),
(58, 'Shreya M Rathod', '3060824047@student.aau.in', '$2a$10$lxFQ9EtlFf2ERFm7cUECv.lPTVYzpW2bK7Yqxh52nErueg53EuJna', 'student', 4, '3060824047', 1, '2026-06-18 15:32:21'),
(59, 'Mamta Rathva', '3060824048@student.aau.in', '$2a$10$ejGdBtiO3vv7j81gOgCBheB32MVCHe5U4exva5s5TO9abX9QUqJ4.', 'student', 4, '3060824048', 1, '2026-06-18 15:32:40'),
(60, 'Mansi Raval', '3060824049@student.aau.in', '$2a$10$u.tbNE6FE37FpHjdlvOHOOZ.0zdrBvshQIsDxNd95ZYtbZjUev95O', 'student', 4, '3060824049', 1, '2026-06-18 15:32:56'),
(61, 'Harsh Rojasara', '3060824050@student.aau.in', '$2a$10$PFdL231vCcN4SKWTb0MZk.q57ch/T2N6enkq7BtxTiMqKPGgRz.YO', 'student', 4, '3060824050', 1, '2026-06-18 15:33:11'),
(62, 'Rehan Saiyed', '3060824051@student.aau.in', '$2a$10$0kdrrrWQk.opOi/8kfY8XOuGcmW4mkefVT0c9U013yBm4ZB5ew5ya', 'student', 4, '3060824051', 1, '2026-06-18 15:33:31'),
(63, 'Darshan Solanki', '3060824052@student.aau.in', '$2a$10$UhULfTBNOgrYJN0MC4jo0.RDFZIw1e63auaJ9k9pxmaofiMKlbOsO', 'student', 4, '3060824052', 1, '2026-06-18 15:33:47'),
(64, 'Vaibhavi Solanki', '3060824053@student.aau.in', '$2a$10$Gq.OQqAskdefTjKXz7SnIeF.VpKd.Urjoe0R9saslkjUN219D4skC', 'student', 4, '3060824053', 1, '2026-06-18 15:34:01'),
(65, 'Sanvi Suthar', '3060824054@student.aau.in', '$2a$10$b1RLJZZpfrGaeZBKLOTrLuq5Bbxi/Dmo4aJJvuuDTmOAhYsQeSlh6', 'student', 4, '3060824054', 1, '2026-06-18 15:34:12'),
(66, 'Pratha Thakor', '3060824055@student.aau.in', '$2a$10$6znEnB9hzjQ4H7ZqG6VrUuPbncaQ3b2QmguwLJ0G66DS.v8s4.rNS', 'student', 4, '3060824055', 1, '2026-06-18 15:34:29'),
(67, 'Sejal Thakor', '3060824056@student.aau.in', '$2a$10$ToBTPGdsJSJuCjOAyVkFQOuRj/DFQR7GqMzcxh/gAhHJRcMnkT5wq', 'student', 4, '3060824056', 1, '2026-06-18 15:34:44'),
(68, 'Unnati Thakor', '3060824057@student.aau.in', '$2a$10$HrpMeALPJcE2a.R4KyRZLe/EJPMVSNHfcTCKhtD.nF8bJZv1BUIUO', 'student', 4, '3060824057', 1, '2026-06-18 15:35:03'),
(69, 'Blessy Vaghela', '3060824058@student.aau.in', '$2a$10$B8Drt87xuCiuKsPoJ5PVxu2zPFqFdbpASdLrUh.G16C1pHaFy5CPW', 'student', 4, '3060824058', 1, '2026-06-18 15:35:26'),
(70, 'Alok Vasava', '3060824060@student.aau.in', '$2a$10$mdSaulWqCfkkV4CjN/Ewtue/g7fcna7YpPuYwVt3Zzjxlzun1wZu.', 'student', 4, '3060824060', 1, '2026-06-18 15:35:47');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `classroom_attendance`
--
ALTER TABLE `classroom_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_class` (`student_id`,`subject_id`,`class_date`,`session`),
  ADD KEY `subject_id` (`subject_id`),
  ADD KEY `marked_by` (`marked_by`);

--
-- Indexes for table `college_entry_log`
--
ALTER TABLE `college_entry_log`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_entry` (`user_id`,`session`,`entry_date`);

--
-- Indexes for table `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `manual_override_log`
--
ALTER TABLE `manual_override_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attendance_id` (`attendance_id`),
  ADD KEY `overridden_by` (`overridden_by`);

--
-- Indexes for table `qr_settings`
--
ALTER TABLE `qr_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session` (`session`),
  ADD KEY `updated_by` (`updated_by`);

--
-- Indexes for table `semesters`
--
ALTER TABLE `semesters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `semester_id` (`semester_id`),
  ADD KEY `faculty_id` (`faculty_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `enrollment_no` (`enrollment_no`),
  ADD KEY `semester_id` (`semester_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `classroom_attendance`
--
ALTER TABLE `classroom_attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `college_entry_log`
--
ALTER TABLE `college_entry_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `devices`
--
ALTER TABLE `devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `manual_override_log`
--
ALTER TABLE `manual_override_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `qr_settings`
--
ALTER TABLE `qr_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `semesters`
--
ALTER TABLE `semesters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `classroom_attendance`
--
ALTER TABLE `classroom_attendance`
  ADD CONSTRAINT `classroom_attendance_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `classroom_attendance_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  ADD CONSTRAINT `classroom_attendance_ibfk_3` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `college_entry_log`
--
ALTER TABLE `college_entry_log`
  ADD CONSTRAINT `college_entry_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `devices`
--
ALTER TABLE `devices`
  ADD CONSTRAINT `devices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `manual_override_log`
--
ALTER TABLE `manual_override_log`
  ADD CONSTRAINT `manual_override_log_ibfk_1` FOREIGN KEY (`attendance_id`) REFERENCES `classroom_attendance` (`id`),
  ADD CONSTRAINT `manual_override_log_ibfk_2` FOREIGN KEY (`overridden_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `qr_settings`
--
ALTER TABLE `qr_settings`
  ADD CONSTRAINT `qr_settings_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `subjects_ibfk_1` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`),
  ADD CONSTRAINT `subjects_ibfk_2` FOREIGN KEY (`faculty_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
