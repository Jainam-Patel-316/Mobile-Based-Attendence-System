-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 21, 2026 at 10:07 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `attendance`
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
(11, 21, 'morning', '2026-06-17', '2026-06-17 14:17:55', '2409:40c1:4037:5323:407d:d1ff:fea1:aee4', '0219b3e42ec42e0da0eace163c68a75a', 'valid', 22.5339099, 72.9809105, 'verified'),
(15, 15, 'morning', '2026-06-19', '2026-06-19 13:19:58', '2409:40c1:4115:25da:7457:e5ff:fe7f:40bb', '304c25183a0212ac0be87213a734c0d7', 'valid', 22.5339265, 72.9809149, 'verified'),
(43, 15, 'afternoon', '2026-06-19', '2026-06-19 16:23:56', '2409:40c1:4115:25da:7457:e5ff:fe7f:40bb', '304c25183a0212ac0be87213a734c0d7', 'valid', 22.5339272, 72.9809157, 'verified'),
(45, 21, '', '2026-06-19', '2026-06-19 17:18:39', '2409:40c1:403f:b301:50ca:cfff:fe04:5e30', '0219b3e42ec42e0da0eace163c68a75a', '', 22.5339220, 72.9809204, 'outside_fence'),
(46, 21, 'morning', '2026-06-19', '2026-06-19 17:21:55', '2409:40c1:403f:b301:50ca:cfff:fe04:5e30', '0219b3e42ec42e0da0eace163c68a75a', 'valid', 22.5339264, 72.9809144, 'verified'),
(47, 15, 'morning', '2026-06-20', '2026-06-20 04:00:18', '2409:40c1:411c:33d3:381e:beff:fe26:b9ce', '304c25183a0212ac0be87213a734c0d7', 'rejected_time', 22.5338568, 72.9701321, 'verified'),
(48, 61, 'morning', '2026-06-20', '2026-06-20 04:52:26', '2409:40c1:403d:afb:98e7:25ff:feed:1a54', '5951fb70e9fdfc88568e62394974e2fb', 'valid', 22.5338604, 72.9701271, 'verified'),
(49, 16, 'morning', '2026-06-20', '2026-06-20 04:52:47', '2402:3a80:1b86:86ec:0:9:5085:d201', 'dabd792492b9425e55c5d5cff0623ba8', 'valid', 22.5338089, 72.9701854, 'verified'),
(50, 18, 'morning', '2026-06-20', '2026-06-20 04:52:58', '2409:40c1:4022:4c78:8000::', '4e08592c94ca9e5650b9dbadac2e9a5e', 'valid', 22.5338060, 72.9701863, 'verified'),
(51, 20, 'morning', '2026-06-20', '2026-06-20 04:53:20', '2409:40c1:402e:7a7f:8000::', '62e3490ccaad4b2eb4b42f2645b6ac4b', 'valid', 22.5337481, 72.9702397, 'verified'),
(52, 21, 'morning', '2026-06-20', '2026-06-20 04:53:22', '2409:40c1:415e:a2f2:404f:5dff:fe7c:e667', '0219b3e42ec42e0da0eace163c68a75a', 'valid', 22.5338450, 72.9701471, 'verified'),
(53, 54, '', '2026-06-20', '2026-06-20 04:53:33', '2409:40c1:4105:f59a:c98:e912:3f40:4624', 'a4a3bdb71afaaf9765be3c4a22654921', '', 22.5339208, 72.9700543, 'outside_fence'),
(54, 47, '', '2026-06-20', '2026-06-20 04:53:48', '2409:40c1:414f:5f1f:3cec:69ff:fe1b:f2f8', 'aed775ff5f08c688a1b9bf07ecf84bd5', '', 22.5339030, 72.9700794, 'outside_fence'),
(55, 30, 'morning', '2026-06-20', '2026-06-20 04:54:04', '2409:40c1:414f:eab4:8000::', 'f38e27edba344fddffa8d4cc81c0fe8a', 'valid', 22.5337966, 72.9701969, 'verified'),
(56, 44, 'morning', '2026-06-20', '2026-06-20 04:54:05', '2409:40c1:4002:184:8000::', '84c699c9af5c9a1244ef04cfd25f5231', 'valid', 22.5337947, 72.9702264, 'verified'),
(58, 50, '', '2026-06-20', '2026-06-20 04:54:07', '2409:40c1:4159:f69c:8000::', '7d07419cf1570cf5bd8e3accbf319062', '', 22.5338898, 72.9700930, 'outside_fence'),
(59, 62, '', '2026-06-20', '2026-06-20 04:54:14', '2409:40c1:4030:601a:8000::', 'b385b8834c68d5d28d7e90ea00f49da8', '', 22.5339146, 72.9700650, 'outside_fence'),
(60, 38, 'morning', '2026-06-20', '2026-06-20 04:54:16', '2409:4080:8499:f935:bceb:f624:b000:3175', 'd04bc3fb92c1f551d65f2544fe60b56b', 'valid', 22.5338533, 72.9700806, 'verified'),
(62, 69, '', '2026-06-20', '2026-06-20 04:54:24', '2409:4041:2e49:6993::c80b:ac0e', 'd959e2f3c9fea18f023e0cf1c7d0362c', '', 22.5405405, 72.9609844, 'outside_fence'),
(63, 31, 'morning', '2026-06-20', '2026-06-20 04:54:29', '2409:40c1:4039:5122:c5a:8e6f:89bf:bd52', 'b91ebfc976743aa3f1b914123112ec16', 'valid', 22.5337598, 72.9702368, 'verified'),
(64, 27, 'morning', '2026-06-20', '2026-06-20 04:54:31', '2409:40c1:4024:cb9c:8000::', '621dd6471d3c69a82a5b333486df5cf5', 'valid', 22.5337900, 72.9702077, 'verified'),
(66, 48, '', '2026-06-20', '2026-06-20 04:54:37', '2409:40c1:4028:da2d:c015:87ff:fedd:f16f', '334be5f5f12d050dd3e0073c58758589', '', 22.5338840, 72.9701226, 'outside_fence'),
(67, 28, '', '2026-06-20', '2026-06-20 04:54:40', '2409:40c1:4105:f59a:8000::', '8ff464dbefd7cd092a9fecceb5123f17', '', 22.5338831, 72.9701432, 'outside_fence'),
(69, 41, '', '2026-06-20', '2026-06-20 04:54:41', '2409:40c1:4004:6323:5826:bff:fe37:6455', '29cefcc547167362b742dc1f074a10f7', '', 22.5339071, 72.9700725, 'outside_fence'),
(71, 36, 'morning', '2026-06-20', '2026-06-20 04:54:43', '2402:3a80:4613:7bc7:0:1:52e3:7f01', '110d8b2c3b511b73a5a938389f02e6ae', 'valid', 22.5337995, 72.9701932, 'verified'),
(74, 51, 'morning', '2026-06-20', '2026-06-20 04:54:46', '2409:40c1:4154:7724:8ff4:d92c:54fd:3f7b', 'dc82fcbdad3b98f04e19836290d24fbf', 'valid', 22.5338127, 72.9701955, 'verified'),
(75, 24, 'morning', '2026-06-20', '2026-06-20 04:54:47', '2409:40c1:403d:f564:64a3:32ff:fe64:d267', '814da14ce127c87e174189a3625ea5c7', 'valid', 22.5337979, 72.9701591, 'verified'),
(77, 62, 'morning', '2026-06-20', '2026-06-20 04:54:48', '2409:40c1:4030:601a:8000::', 'b385b8834c68d5d28d7e90ea00f49da8', 'valid', 22.5338120, 72.9701906, 'verified'),
(79, 40, '', '2026-06-20', '2026-06-20 04:54:53', '2409:40c1:401b:f1fd:40ff:7bff:feb5:5891', '8a3e501ffbd7b01f4383353cf1827b1c', '', 22.5339250, 72.9700495, 'outside_fence'),
(80, 47, 'morning', '2026-06-20', '2026-06-20 04:54:54', '2409:40c1:414f:5f1f:3cec:69ff:fe1b:f2f8', 'aed775ff5f08c688a1b9bf07ecf84bd5', 'valid', 22.5338564, 72.9701288, 'verified'),
(81, 59, 'morning', '2026-06-20', '2026-06-20 04:54:55', '2405:204:828f:6029:6cf9:8eff:feeb:7c36', 'c993dad665c0c9ac30d4ddedd96704c8', 'valid', 22.5338147, 72.9701751, 'verified'),
(82, 28, 'morning', '2026-06-20', '2026-06-20 04:54:57', '2409:40c1:4105:f59a:8000::', '8ff464dbefd7cd092a9fecceb5123f17', 'valid', 22.5338831, 72.9701432, 'verified'),
(83, 23, 'morning', '2026-06-20', '2026-06-20 04:55:01', '2401:4900:576b:f196::1035:3ab9', 'ae5165d9f2c9f0e12d0a03e3e730b0a3', 'valid', 22.5338000, 72.9701431, 'verified'),
(84, 60, '', '2026-06-20', '2026-06-20 04:55:05', '2409:40c1:4012:9340:8000::', '1c7fcd27585f815391cf005c843c010a', '', 22.5339531, 72.9701333, 'outside_fence'),
(86, 58, 'morning', '2026-06-20', '2026-06-20 04:55:09', '2409:40c1:402f:7ad5:d4d3:11ff:fe38:5971', 'ac2cf8fd42fb049dfeffd32d9e13ad0d', 'valid', 22.5338095, 72.9701886, 'verified'),
(87, 48, 'morning', '2026-06-20', '2026-06-20 04:55:09', '2409:40c1:4028:da2d:c015:87ff:fedd:f16f', '334be5f5f12d050dd3e0073c58758589', 'valid', 22.5338021, 72.9701879, 'verified'),
(89, 50, 'morning', '2026-06-20', '2026-06-20 04:55:10', '2409:40c1:4159:f69c:8000::', '7d07419cf1570cf5bd8e3accbf319062', 'valid', 22.5338164, 72.9701850, 'verified'),
(91, 39, 'morning', '2026-06-20', '2026-06-20 04:55:14', '49.34.176.251', 'e5b53090cdba205d92cc905270eed6ab', 'valid', 22.5338065, 72.9701869, 'verified'),
(92, 54, 'morning', '2026-06-20', '2026-06-20 04:55:15', '2409:40c1:4105:f59a:c98:e912:3f40:4624', 'a4a3bdb71afaaf9765be3c4a22654921', 'valid', 22.5338279, 72.9701725, 'verified'),
(93, 45, 'morning', '2026-06-20', '2026-06-20 04:55:16', '2409:40c1:4154:7724:53ba:3541:624c:5995', '78a7ec5ab9bc713cb0ba56399d237816', 'valid', 22.5337527, 72.9702653, 'verified'),
(94, 17, 'morning', '2026-06-20', '2026-06-20 04:55:16', '2409:40c1:4000:71a0:2c27:ce72:19b:8775', 'e38d4481aa701dc5d2ff000accba1284', 'valid', 22.5338201, 72.9701736, 'verified'),
(98, 67, 'morning', '2026-06-20', '2026-06-20 04:55:30', '2405:205:c8e9:75ba::8a6:98a1', 'dafff3a1c3cffc3e543a36be74cf734c', 'valid', 22.5338107, 72.9701908, 'verified'),
(99, 34, 'morning', '2026-06-20', '2026-06-20 04:55:37', '2409:40c1:4142:1731:8000::', 'cd9ca25c11e19fa1bdaf5796dd161436', 'valid', 22.5337890, 72.9702049, 'verified'),
(100, 60, 'morning', '2026-06-20', '2026-06-20 04:55:38', '2409:40c1:4012:9340:8000::', '1c7fcd27585f815391cf005c843c010a', 'valid', 22.5338116, 72.9701908, 'verified'),
(101, 41, 'morning', '2026-06-20', '2026-06-20 04:55:38', '2409:40c1:4004:6323:5826:bff:fe37:6455', '29cefcc547167362b742dc1f074a10f7', 'valid', 22.5338098, 72.9701879, 'verified'),
(103, 40, 'morning', '2026-06-20', '2026-06-20 04:55:42', '2409:40c1:401b:f1fd:40ff:7bff:feb5:5891', '8a3e501ffbd7b01f4383353cf1827b1c', 'valid', 22.5338573, 72.9701393, 'verified'),
(106, 57, 'morning', '2026-06-20', '2026-06-20 04:55:54', '2409:4080:8311:70e1::25e3:58a0', '53b71f03acffe5745e08adb656ec68f3', 'valid', 22.5338166, 72.9701940, 'verified'),
(107, 64, 'morning', '2026-06-20', '2026-06-20 04:55:57', '2409:40c1:402e:13b3:8000::', 'd2069e26d965c4e7d1c39ceb51bb04b9', 'valid', 22.5337770, 72.9702187, 'verified'),
(108, 52, 'morning', '2026-06-20', '2026-06-20 04:55:57', '2409:40c1:4154:7724:5481:86c4:bef8:97c7', '578144726f097115312f72c1c9435ad6', 'valid', 22.5338581, 72.9701374, 'verified'),
(110, 68, 'morning', '2026-06-20', '2026-06-20 04:56:04', '2409:40c1:4039:3fe1:e0e7:8cff:feb7:5dd2', 'fe683da63025d79837b9d1a098e76b3b', 'valid', 22.5338102, 72.9701899, 'verified'),
(111, 55, 'morning', '2026-06-20', '2026-06-20 04:56:11', '2409:40c1:403d:afb:f4e4:672f:18f2:bcb2', '9e2b183c14c427fc638ad75352a57c2a', 'valid', 22.5336075, 72.9702759, 'verified'),
(113, 63, 'morning', '2026-06-20', '2026-06-20 04:56:22', '2409:40c1:4142:1731:71b5:363f:d472:c336', '785d7e406264e8abd1ac7f35a933c93f', 'valid', 22.5338112, 72.9701907, 'verified'),
(114, 70, 'morning', '2026-06-20', '2026-06-20 04:56:28', '2409:40c1:4017:e240:8000::', '34aa7327bf1cc848f283f6f04e3e116a', 'valid', 22.5338131, 72.9701769, 'verified'),
(116, 33, 'morning', '2026-06-20', '2026-06-20 04:56:38', '2402:3a80:1cf5:2562:0:24:baf5:5501', '385919c5dd7cdafdfd3b607cb0d8f94e', 'valid', 22.5338114, 72.9701930, 'verified'),
(117, 65, 'morning', '2026-06-20', '2026-06-20 04:56:43', '2409:40c1:4149:76e7:8000::', 'b7cc29c948df8a44cadb4ce218c26709', 'valid', 22.5338992, 72.9700779, 'verified'),
(121, 72, 'morning', '2026-06-20', '2026-06-20 04:58:09', '2409:40c1:4104:fa1e:b4ea:85ff:fe4e:798', '735523254e4c6899c35190f48f45a5be', 'valid', 22.5338042, 72.9701447, 'verified'),
(122, 26, '', '2026-06-20', '2026-06-20 04:58:16', '2401:4900:aaf1:f0ec::7fda:d3f3', '1706148ab6a229c1d06fa9d62c728b9f', '', 22.5339716, 72.9702355, 'outside_fence'),
(123, 32, '', '2026-06-20', '2026-06-20 04:58:52', '2409:40c1:4154:7724:1997:ee15:fb87:4f55', '95c32a29d66965dbbc3570fc575a4ab9', '', 22.5339241, 72.9700499, 'outside_fence'),
(124, 26, 'morning', '2026-06-20', '2026-06-20 04:59:01', '2401:4900:aaf1:f0ec::7fda:d3f3', '1706148ab6a229c1d06fa9d62c728b9f', 'valid', 22.5337850, 72.9701999, 'verified'),
(129, 32, 'morning', '2026-06-20', '2026-06-20 04:59:30', '2409:40c1:4154:7724:1997:ee15:fb87:4f55', '95c32a29d66965dbbc3570fc575a4ab9', 'valid', 22.5338704, 72.9701300, 'verified'),
(133, 35, 'morning', '2026-06-20', '2026-06-20 04:59:59', '2409:40c1:4154:7724:8000::', '96c4e9805c275881fe3867477d84b6b3', 'valid', 22.5338618, 72.9701612, 'verified'),
(146, 29, 'morning', '2026-06-20', '2026-06-20 05:01:52', '2402:3a80:4620:664b:0:47:c78a:2b01', 'aa2502e95bb46d97d3cc442a8e2a0a52', 'valid', 22.5338661, 72.9701656, 'verified'),
(153, 49, 'morning', '2026-06-20', '2026-06-20 05:04:29', '2409:40c1:414e:fc55:94c2:a3ff:fe54:b018', '4444dfed2544b2ef7903b4db1f9d576b', 'valid', 22.5338801, 72.9700986, 'verified'),
(155, 24, '', '2026-06-21', '2026-06-21 07:49:30', '117.254.228.12', '814da14ce127c87e174189a3625ea5c7', '', 22.5339091, 72.9809118, 'outside_fence'),
(156, 34, '', '2026-06-21', '2026-06-21 08:02:20', '2409:40c1:4140:1901:b2b9:bda4:7250:9475', 'cd9ca25c11e19fa1bdaf5796dd161436', '', 22.5339275, 72.9809136, 'outside_fence');

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
(6, 21, '0219b3e42ec42e0da0eace163c68a75a', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-17 14:16:47', 1),
(7, 22, 'a44cfa317879579fa520f9043ae4befd', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-18 15:16:40', 1),
(14, 15, '304c25183a0212ac0be87213a734c0d7', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-19 16:21:54', 1),
(17, 16, 'dabd792492b9425e55c5d5cff0623ba8', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:13:33', 1),
(18, 17, 'e38d4481aa701dc5d2ff000accba1284', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Samsun', '2026-06-20 04:14:37', 1),
(19, 18, '4e08592c94ca9e5650b9dbadac2e9a5e', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:15:13', 1),
(20, 20, '62e3490ccaad4b2eb4b42f2645b6ac4b', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:15:50', 1),
(21, 24, '814da14ce127c87e174189a3625ea5c7', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:16:46', 1),
(22, 23, 'ae5165d9f2c9f0e12d0a03e3e730b0a3', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:16:54', 1),
(23, 25, '814da14ce127c87e174189a3625ea5c7', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:17:32', 1),
(24, 26, '1706148ab6a229c1d06fa9d62c728b9f', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:17:51', 1),
(25, 28, '8ff464dbefd7cd092a9fecceb5123f17', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:18:39', 1),
(26, 27, '621dd6471d3c69a82a5b333486df5cf5', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:18:52', 1),
(28, 30, 'f38e27edba344fddffa8d4cc81c0fe8a', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:19:56', 1),
(29, 29, 'aa2502e95bb46d97d3cc442a8e2a0a52', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:20:16', 1),
(30, 31, 'b91ebfc976743aa3f1b914123112ec16', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/14', '2026-06-20 04:21:08', 1),
(31, 32, '95c32a29d66965dbbc3570fc575a4ab9', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:21:13', 1),
(32, 34, '', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:21:50', 1),
(33, 33, '385919c5dd7cdafdfd3b607cb0d8f94e', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:23:22', 1),
(34, 36, '110d8b2c3b511b73a5a938389f02e6ae', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:23:27', 1),
(35, 35, '96c4e9805c275881fe3867477d84b6b3', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:24:11', 1),
(36, 38, 'd04bc3fb92c1f551d65f2544fe60b56b', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:25:20', 1),
(37, 39, 'e5b53090cdba205d92cc905270eed6ab', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:26:46', 1),
(38, 40, '8a3e501ffbd7b01f4383353cf1827b1c', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:26:59', 1),
(39, 41, '29cefcc547167362b742dc1f074a10f7', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:27:44', 1),
(40, 44, '84c699c9af5c9a1244ef04cfd25f5231', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:28:52', 1),
(41, 45, '78a7ec5ab9bc713cb0ba56399d237816', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:29:55', 1),
(42, 47, 'aed775ff5f08c688a1b9bf07ecf84bd5', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:34:13', 1),
(43, 49, '4444dfed2544b2ef7903b4db1f9d576b', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:34:15', 1),
(44, 51, 'dc82fcbdad3b98f04e19836290d24fbf', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:37:30', 1),
(45, 50, '7d07419cf1570cf5bd8e3accbf319062', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:37:49', 1),
(46, 52, '578144726f097115312f72c1c9435ad6', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:38:36', 1),
(47, 54, 'a4a3bdb71afaaf9765be3c4a22654921', 'Mozilla/5.0 (Linux; Android 15; V2307) AppleWebKit/537.36 (KHTML, like Gecko) Ve', '2026-06-20 04:39:20', 1),
(48, 55, '9e2b183c14c427fc638ad75352a57c2a', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_7 like Mac OS X) AppleWebKit/605.1.15 (K', '2026-06-20 04:40:41', 1),
(49, 53, '9d20e64452864963cdf1b7a50e9ba7f6', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:40:57', 1),
(50, 56, '55adeaafcdc5ea86cf3fb670f2397b3f', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:41:49', 1),
(51, 57, '53b71f03acffe5745e08adb656ec68f3', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:41:50', 1),
(52, 58, 'ac2cf8fd42fb049dfeffd32d9e13ad0d', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:42:41', 1),
(53, 59, 'c993dad665c0c9ac30d4ddedd96704c8', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:42:50', 1),
(54, 60, '1c7fcd27585f815391cf005c843c010a', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:44:19', 1),
(55, 61, '5951fb70e9fdfc88568e62394974e2fb', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:44:50', 1),
(56, 62, '', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:45:40', 1),
(57, 63, '785d7e406264e8abd1ac7f35a933c93f', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Samsun', '2026-06-20 04:46:30', 1),
(58, 64, 'd2069e26d965c4e7d1c39ceb51bb04b9', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:46:34', 1),
(59, 65, 'b7cc29c948df8a44cadb4ce218c26709', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:47:20', 1),
(60, 67, 'dafff3a1c3cffc3e543a36be74cf734c', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Samsun', '2026-06-20 04:48:15', 1),
(61, 68, 'fe683da63025d79837b9d1a098e76b3b', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:49:32', 1),
(62, 69, 'd959e2f3c9fea18f023e0cf1c7d0362c', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:49:37', 1),
(63, 70, '34aa7327bf1cc848f283f6f04e3e116a', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:50:19', 1),
(64, 72, '735523254e4c6899c35190f48f45a5be', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:51:01', 1),
(65, 48, '334be5f5f12d050dd3e0073c58758589', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:52:42', 1),
(66, 44, 'cb50f3c184796d2d639626253deb9625', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-20 04:53:19', 1),
(67, 32, '1e951ce336d78dfc109ed9650fc5f361', 'Mozilla/5.0 (Linux; U; Android 13; en-gb; RMX3085 Build/SP1A.210812.016) AppleWe', '2026-06-20 04:57:38', 1),
(68, 34, 'cd9ca25c11e19fa1bdaf5796dd161436', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome', '2026-06-21 08:01:01', 1);

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
(1, 'morning', '08:40:00', '09:00:00', 5, '0.0.0.0', 1, '2026-06-21 07:58:53', 1, 22.5336940, 72.9701310, 25),
(2, 'afternoon', '13:30:00', '14:00:00', 5, '0.0.0.0', 1, '2026-06-20 04:55:00', 1, 22.5336940, 72.9701310, 25);

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
(70, 'Alok Vasava', '3060824060@student.aau.in', '$2a$10$mdSaulWqCfkkV4CjN/Ewtue/g7fcna7YpPuYwVt3Zzjxlzun1wZu.', 'student', 4, '3060824060', 1, '2026-06-18 15:35:47'),
(72, 'Het Rabari', '3060824061@student.aau.in', '$2a$10$gxTLmHldYiHiiE.PC4Hpo.S4J0Ra4foVe8czwux9mvl.b7b0lMqCO', 'student', 4, '3060824061', 1, '2026-06-20 04:50:35');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT for table `devices`
--
ALTER TABLE `devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

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
