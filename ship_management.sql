/*
 Navicat Premium Dump SQL

 Source Server         : a
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : 127.0.0.1:3306
 Source Schema         : ship_management

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 27/06/2025 00:07:50
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for attachment
-- ----------------------------
DROP TABLE IF EXISTS `attachment`;
CREATE TABLE `attachment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file_url` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime(6) DEFAULT NULL,
  `checklist_item_id` bigint DEFAULT NULL,
  `uploaded_by` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK687m28gfpcqtpmmlv05iwsn96` (`checklist_item_id`),
  KEY `FKa8c24dxad2utn3021054iqpo9` (`uploaded_by`),
  CONSTRAINT `FK687m28gfpcqtpmmlv05iwsn96` FOREIGN KEY (`checklist_item_id`) REFERENCES `checklist` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FKa8c24dxad2utn3021054iqpo9` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of attachment
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for checklist
-- ----------------------------
DROP TABLE IF EXISTS `checklist`;
CREATE TABLE `checklist` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `com_remark` varchar(255) DEFAULT NULL,
  `com_result` varchar(255) DEFAULT NULL,
  `com_review_at` datetime(6) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `guide` varchar(255) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `order_no` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `vessel_remark` varchar(255) DEFAULT NULL,
  `vessel_result` varchar(255) DEFAULT NULL,
  `vessel_review_at` datetime(6) DEFAULT NULL,
  `assigned_to` bigint DEFAULT NULL,
  `checklist_template_id` bigint DEFAULT NULL,
  `com_assigned_to` bigint DEFAULT NULL,
  `vessel_assigned_to` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK1xl6glhgijl3wrfuibustaw6r` (`com_assigned_to`),
  KEY `FK5uwjxccmetb3ekilr6kkalsxa` (`vessel_assigned_to`),
  KEY `FK6nqbyjjsjxpqo1ehiqfhgjivf` (`checklist_template_id`),
  KEY `FKawy952pex2b657v1fwulembos` (`assigned_to`),
  CONSTRAINT `FK1xl6glhgijl3wrfuibustaw6r` FOREIGN KEY (`com_assigned_to`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK5uwjxccmetb3ekilr6kkalsxa` FOREIGN KEY (`vessel_assigned_to`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FK6nqbyjjsjxpqo1ehiqfhgjivf` FOREIGN KEY (`checklist_template_id`) REFERENCES `checklist_template` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `FKawy952pex2b657v1fwulembos` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of checklist
-- ----------------------------
BEGIN;
INSERT INTO `checklist` (`id`, `com_remark`, `com_result`, `com_review_at`, `content`, `guide`, `note`, `order_no`, `status`, `vessel_remark`, `vessel_result`, `vessel_review_at`, `assigned_to`, `checklist_template_id`, `com_assigned_to`, `vessel_assigned_to`) VALUES (1, NULL, 'YES', '2025-06-26 14:23:33.213731', 'adasd', '2132', NULL, 2, NULL, NULL, NULL, NULL, 7, 1, 2, 4);
INSERT INTO `checklist` (`id`, `com_remark`, `com_result`, `com_review_at`, `content`, `guide`, `note`, `order_no`, `status`, `vessel_remark`, `vessel_result`, `vessel_review_at`, `assigned_to`, `checklist_template_id`, `com_assigned_to`, `vessel_assigned_to`) VALUES (2, NULL, 'YES', '2025-06-26 14:35:01.778384', '12321123', '213213', NULL, 1, NULL, NULL, 'YES', '2025-06-26 14:23:27.602911', 5, 1, 6, 2);
INSERT INTO `checklist` (`id`, `com_remark`, `com_result`, `com_review_at`, `content`, `guide`, `note`, `order_no`, `status`, `vessel_remark`, `vessel_result`, `vessel_review_at`, `assigned_to`, `checklist_template_id`, `com_assigned_to`, `vessel_assigned_to`) VALUES (3, NULL, NULL, NULL, '1313', '1313', NULL, 3, NULL, NULL, 'YES', '2025-06-26 14:32:50.329379', 7, 1, 2, 6);
INSERT INTO `checklist` (`id`, `com_remark`, `com_result`, `com_review_at`, `content`, `guide`, `note`, `order_no`, `status`, `vessel_remark`, `vessel_result`, `vessel_review_at`, `assigned_to`, `checklist_template_id`, `com_assigned_to`, `vessel_assigned_to`) VALUES (4, NULL, NULL, NULL, 'qqqqqq', 'qqqqq', NULL, 4, NULL, NULL, 'YES', '2025-06-26 14:34:51.364796', 5, 1, 2, 6);
COMMIT;

-- ----------------------------
-- Table structure for checklist_template
-- ----------------------------
DROP TABLE IF EXISTS `checklist_template`;
CREATE TABLE `checklist_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` int NOT NULL,
  `section` varchar(255) DEFAULT NULL,
  `company_id` bigint NOT NULL,
  `review_plan_id` bigint DEFAULT NULL,
  `ship_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKe2134ne6foyh3ku5moh90ghqe` (`company_id`),
  KEY `FKogaesmkixq09pmp8jyy1qk8jp` (`ship_id`),
  KEY `FKt0wpu9qw5q78afema0dy0qr0` (`review_plan_id`),
  CONSTRAINT `FKe2134ne6foyh3ku5moh90ghqe` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKogaesmkixq09pmp8jyy1qk8jp` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKt0wpu9qw5q78afema0dy0qr0` FOREIGN KEY (`review_plan_id`) REFERENCES `review_plan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of checklist_template
-- ----------------------------
BEGIN;
INSERT INTO `checklist_template` (`id`, `order_no`, `section`, `company_id`, `review_plan_id`, `ship_id`) VALUES (1, 0, 'adadad', 1, NULL, 1);
COMMIT;

-- ----------------------------
-- Table structure for companies
-- ----------------------------
DROP TABLE IF EXISTS `companies`;
CREATE TABLE `companies` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of companies
-- ----------------------------
BEGIN;
INSERT INTO `companies` (`id`, `address`, `email`, `name`, `phone`) VALUES (1, 'Hồng Kông / Toàn cầu', 'fml@gmail.com', 'Fleet Management Limited (FML)', '0909090909');
INSERT INTO `companies` (`id`, `address`, `email`, `name`, `phone`) VALUES (2, 'Đức / Toàn cầu', 'csm@gmail.com', 'Columbia Shipmanagement (CSM)', '0909090909');
INSERT INTO `companies` (`id`, `address`, `email`, `name`, `phone`) VALUES (3, 'Việt Nam', 'vimc@gmail.com', 'VIMC (Tổng công ty Hàng hải Việt Nam)', '0909090909');
INSERT INTO `companies` (`id`, `address`, `email`, `name`, `phone`) VALUES (4, 'Việt Nam', 'gemadept@gmail.com', 'Gemadept Shipping', '0909090909');
COMMIT;

-- ----------------------------
-- Table structure for review_plan
-- ----------------------------
DROP TABLE IF EXISTS `review_plan`;
CREATE TABLE `review_plan` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `company_id` bigint NOT NULL,
  `created_by` bigint DEFAULT NULL,
  `ship_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK4rihvyb0km1bk7jrdlnopdqgt` (`company_id`),
  KEY `FK94rjm533vbo83g66g6es1very` (`created_by`),
  KEY `FKf8pjabm0cqbpfyodq9p2649xy` (`ship_id`),
  CONSTRAINT `FK4rihvyb0km1bk7jrdlnopdqgt` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK94rjm533vbo83g66g6es1very` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKf8pjabm0cqbpfyodq9p2649xy` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of review_plan
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for role_permission
-- ----------------------------
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `permission` enum('COMPANY_MANAGEMENT','REVIEW_MANAGEMENT','ROLE_MANAGEMENT','SHIP_MANAGEMENT','USER_MANAGEMENT') DEFAULT NULL,
  `role_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKtfgq8q9blrp0pt1pvggyli3v9` (`role_id`),
  CONSTRAINT `FKtfgq8q9blrp0pt1pvggyli3v9` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of role_permission
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `root_role` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of roles
-- ----------------------------
BEGIN;
INSERT INTO `roles` (`id`, `description`, `name`, `root_role`) VALUES (1, 'Administrator', 'ADMIN', 0);
INSERT INTO `roles` (`id`, `description`, `name`, `root_role`) VALUES (2, 'Captain', 'CAP', 1);
INSERT INTO `roles` (`id`, `description`, `name`, `root_role`) VALUES (3, 'Technical', 'TEC', 2);
INSERT INTO `roles` (`id`, `description`, `name`, `root_role`) VALUES (4, 'Communication', 'COM', 1);
INSERT INTO `roles` (`id`, `description`, `name`, `root_role`) VALUES (5, 'C/O', 'C/O', 2);
INSERT INTO `roles` (`id`, `description`, `name`, `root_role`) VALUES (6, 'Chief Engineer', 'C/E', 2);
COMMIT;

-- ----------------------------
-- Table structure for ships
-- ----------------------------
DROP TABLE IF EXISTS `ships`;
CREATE TABLE `ships` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `company_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKbcew7tg6phr79nacxwas39e98` (`company_id`),
  CONSTRAINT `FKbcew7tg6phr79nacxwas39e98` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of ships
-- ----------------------------
BEGIN;
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (1, 'Ratione dolorum at.', 'Barb Dwyer', 1);
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (2, 'Inventore libero fugit sit explicabo sunt.', 'Moe DeLawn', 2);
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (3, 'Eveniet dolorum et deleniti molestias.', 'Rita Story', 2);
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (4, 'Rem vero voluptatem est quia odit quae architecto.', 'Rob Banks', 3);
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (5, 'Tempora ipsam consectetur ut hic corrupti.', 'Cody Pendant', 3);
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (6, 'Quisquam nihil ut voluptate qui atque.', 'Neve Adda', 4);
INSERT INTO `ships` (`id`, `description`, `name`, `company_id`) VALUES (7, 'Autem ratione voluptas minus fugit.', 'Barb E. Cue', 4);
COMMIT;

-- ----------------------------
-- Table structure for user_ship
-- ----------------------------
DROP TABLE IF EXISTS `user_ship`;
CREATE TABLE `user_ship` (
  `ship_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  KEY `FK834fd34ic2boy2xd0f4kbsyql` (`ship_id`),
  KEY `FKja3yu4jor8nk083uxwp6rbykb` (`user_id`),
  CONSTRAINT `FK834fd34ic2boy2xd0f4kbsyql` FOREIGN KEY (`ship_id`) REFERENCES `ships` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKja3yu4jor8nk083uxwp6rbykb` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user_ship
-- ----------------------------
BEGIN;
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (2, 13);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (2, 14);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (2, 14);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (2, 11);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (2, 14);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (3, 13);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (3, 15);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (3, 14);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (4, 21);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (4, 19);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (4, 21);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (4, 21);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (4, 21);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (5, 21);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (5, 23);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (5, 22);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (6, 27);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (6, 31);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (7, 28);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (7, 26);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (7, 28);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 7);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 5);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 2);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 3);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 4);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 6);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 8);
INSERT INTO `user_ship` (`ship_id`, `user_id`) VALUES (1, 9);
COMMIT;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `hashed_password` varchar(255) DEFAULT NULL,
  `company_id` bigint DEFAULT NULL,
  `role_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKin8gn4o1hpiwe6qe4ey7ykwq7` (`company_id`),
  KEY `FKp56c1712k691lhsyewcssf40f` (`role_id`),
  CONSTRAINT `FKin8gn4o1hpiwe6qe4ey7ykwq7` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKp56c1712k691lhsyewcssf40f` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of users
-- ----------------------------
BEGIN;
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (1, 'admin@gmail.com', 'Admin', '$2a$10$kj2krYgLE4Lw74Hc1v700eUd4HHQogIfaieMchBfVJXRxsQnRTYn2', NULL, 1);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (2, 'shani.hodkiewicz@gmail.com', 'Leif Mante', '$2a$10$RDWSpRXTL57iZ.FcfPkO7udOZKevqqzhHmJ5Wa2lgORaUy0rjlELu', 1, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (3, 'wilbur.von@gmail.com', 'Julee Price', '$2a$10$lrAXQ6LEIzUShY1LoDn2CuDP6DV/wZ6R2/PP5fKSv8loyr10AeMOG', 1, 2);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (4, 'lawerence.mcdermott@hotmail.com', 'Jeannette Reilly', '$2a$10$pkyRzbQOiHNHgPyHQfMe0eFpBEWHSxjs8bomGvZmpN5tlwRrmFSCS', 1, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (5, 'annamaria.little@yahoo.com', 'Mrs. Brant Feest', '$2a$10$vMNQXAcB/3Zolr/J.yOsDO06gDavk5Tb9NDYIQBvEHGTdUFSHvIBe', 1, 4);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (6, 'yen.grimes@yahoo.com', 'Rory Farrell', '$2a$10$Vb4fijT8q9rKBi.pl/FRse67ApypPBZlpNaUXyyjLwMtaT47OqGEe', 1, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (7, 'jackeline.bruen@yahoo.com', 'Thomas Hettinger', '$2a$10$KT7QVvfvpvzOvliOufZUBetVdc5FP7lFFxCYoxGc/koNcBwx40XT.', 1, 2);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (8, 'austin.orn@gmail.com', 'Dr. Nicolette Schumm', '$2a$10$tN0OroMd0BZlqfsMVYPfUOrY/g1Q4lvntlDBK/qITXYSJWgt3ajVS', 1, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (9, 'anthony.kerluke@gmail.com', 'Laverne Orn', '$2a$10$EgQB8cPzFmwRb9G8nDERHuIBW931Re9A.Br8HUsIpmWQgArrNyZvS', 1, 4);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (10, 'eunice.franecki@gmail.com', 'Ms. Hosea Hane', '$2a$10$PBbr1M1TRWjTGnBRhzvk.u9WfynAqRK7UktgCPMGCWliOy57xr4Hq', 2, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (11, 'lamont.batz@hotmail.com', 'Miquel Prohaska DDS', '$2a$10$W8Nh9i/A2CcU/CbGYUbIGu8dk4T1qCNGp3fT7AjqajP7DKHdlRa9C', 2, 4);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (12, 'efrain.nicolas@hotmail.com', 'Simona Torphy', '$2a$10$hY8vf2WatjJjK5KfwoxyuOWuvoQazcj9q3sWj3zVzkwqUMCyih8La', 2, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (13, 'dell.rippin@yahoo.com', 'Tenesha Barton', '$2a$10$kJufe6uPs6FrjcIlQDeur.tEM.sb.FGMCTTURjXGSQjBqICikOXJC', 2, 4);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (14, 'lanny.weber@gmail.com', 'Gus Bashirian Jr.', '$2a$10$YZ8osznQEmMGrvnKcxzb.O2iCcwzPMaXY1csB7Qb5I4yNvNop68Du', 2, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (15, 'david.little@hotmail.com', 'Sharilyn Ruecker', '$2a$10$o5nDJTJvXV4UIa0UPpTQWuxY3T.lfX3hnWFUH3FakAKQ0ckyzN62K', 2, 2);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (16, 'wilford.swift@yahoo.com', 'Kris Wiegand', '$2a$10$KyQ.eTPpbMOQnNzZszFLl.qZue4/pL0OWy8HDYbQr6zb0pUko54T2', 2, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (17, 'ezra.beahan@yahoo.com', 'Racheal Hilll', '$2a$10$drWnSCzS10v.RBEOgqjF3ODUWGVWQXjiIzOAUHrC27bX0OCop0czm', 2, 4);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (18, 'juliet.ratke@yahoo.com', 'Ryan Zemlak', '$2a$10$dmHod1f6uDgWyxYG9mjQFu5HF./0YTna3HzWhYqMmz5EwBQv9LzBe', 3, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (19, 'maurice.dare@hotmail.com', 'Laronda Oberbrunner', '$2a$10$OZ/KTg1C8w6TMUyMMSAoaOKtI/zfV468feN8/m548WXBE8xfeUogi', 3, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (20, 'erminia.rippin@hotmail.com', 'Caroyln Bednar', '$2a$10$6Q1wwlKD46xoUWuJwnMm8uLrcEPcKg7xUYeQidmJnGASOZCXQgWle', 3, 4);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (21, 'armida.armstrong@yahoo.com', 'Alex Zboncak V', '$2a$10$wlHRXm7xEGDCV.WHxBjs..pL0QR9LBgiNGv6W/S9GREp7XPQnMGdG', 3, 2);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (22, 'art.altenwerth@yahoo.com', 'Alexandra Schaefer DVM', '$2a$10$yRV0jnWMOj1im8n8hmLbO.9sQ3HObuvTPvIm9hCFkgHPRi1DJQHy2', 3, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (23, 'maynard.feest@yahoo.com', 'Vannessa Hudson', '$2a$10$XVrUWmh9UuVqUt5xZIR3TO63lLA2BorsuLGnwQKqTD0AwHfyMlPqO', 3, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (24, 'barbera.gulgowski@yahoo.com', 'Ines Casper II', '$2a$10$0s3ZWZJm29Ix0wbUhUgE0.hzJfMPBLHscFGRwp7kOsKZ2dT01j4mS', 3, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (25, 'aida.jakubowski@gmail.com', 'Darrel Bartell', '$2a$10$MfqzGxW0mnMqvKPOaHEiy.Sn9qirRmiF4Bj3Slqebr1SHtvxVkV.m', 3, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (26, 'lanny.haley@hotmail.com', 'Jewell Jones', '$2a$10$rDIak8LQExdMbJPPb3eCOutmy/AU5/9xuUj624hczyx1fRN54OheW', 4, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (27, 'maria.mertz@yahoo.com', 'Sirena Monahan II', '$2a$10$WrAlLeV22F9EyfXUrxJWxucGx5LVeF2I3B9BsgbMv3STbmHl0sFgy', 4, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (28, 'gary.swift@yahoo.com', 'Shavon Graham', '$2a$10$wiDrdmjoc6NIO/9je2z6HeYe7AdHMNyDGJul646usEvrYKnUtlyD2', 4, 2);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (29, 'dante.kemmer@gmail.com', 'Madaline Kiehn', '$2a$10$TYyMt0NO8dGtwPGE5XtScuwOWFyaEoPiGZKNq6uRFHL04pHXdyXfC', 4, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (30, 'santo.kerluke@hotmail.com', 'Dan Koch', '$2a$10$inHJpBbwgkUSHz7dScsAm.DKhgmuMuS3oz9/1w/6Cv1kilN.sGyOi', 4, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (31, 'lynetta.torp@hotmail.com', 'Joy Von DVM', '$2a$10$6HOcDA937cbRpOziP5dQ1OG9m5G0A0ufhbV01uO8EelE1b6lB5MZ.', 4, 5);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (32, 'fannie.armstrong@hotmail.com', 'Toya Bahringer', '$2a$10$LaQUPL3uIsVvhkUlfekbP.N8MmBIWVn2pYzKSurNYVTy1Au4kHLjK', 4, 2);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (33, 'ralph.kuvalis@hotmail.com', 'Latosha Osinski', '$2a$10$7SRTbWgL1bMuaryZjCAOgujqFPSXyTtJyneeHZAfyzPY2SDvckKCW', 4, 3);
INSERT INTO `users` (`id`, `email`, `full_name`, `hashed_password`, `company_id`, `role_id`) VALUES (34, 'normand.stanton@gmail.com', 'Sal Abshire', '$2a$10$4XIyyMIL05OZyhiNYa4JxOxJ7OI09ZJNvgaUyL/AZmTsHnVFRuPM6', 4, 4);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
