-- ====================================================================
-- Web-Based Boat Safari Trip Management System
-- Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
-- Luxury Catamaran & Yacht Safari Management Database Schema
-- Inspired by Sail Lanka Charter (sail-lanka-charter.com)
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `boat_safari_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `boat_safari_db`;

-- Disable FK checks during schema setup
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------------------
-- 1. COMMON: USERS & AUTHENTICATION (All 6 Roles)
-- --------------------------------------------------------------------
DROP TABLE IF EXISTS `activity_logs`;
DROP TABLE IF EXISTS `emergency_acknowledgments`;
DROP TABLE IF EXISTS `promo_redemptions`;
DROP TABLE IF EXISTS `promotions`;
DROP TABLE IF EXISTS `emergency_notices`;
DROP TABLE IF EXISTS `service_reminders`;
DROP TABLE IF EXISTS `maintenance_records`;
DROP TABLE IF EXISTS `passengers`;
DROP TABLE IF EXISTS `reservations`;
DROP TABLE IF EXISTS `tour_schedules`;
DROP TABLE IF EXISTS `vessels`;
DROP TABLE IF EXISTS `tours`;
DROP TABLE IF EXISTS `routes`;
DROP TABLE IF EXISTS `destinations`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(120) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(30),
    `role` ENUM('ADMIN', 'OFFICER', 'GUIDE', 'CAPTAIN', 'OWNER', 'CUSTOMER') NOT NULL DEFAULT 'CUSTOMER',
    `status` ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    `profile_image` VARCHAR(255) DEFAULT 'assets/img/default-avatar.png',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 2. MEMBER 1: SAFARI TOUR MANAGEMENT (Safari Tour Operations Manager)
-- --------------------------------------------------------------------
CREATE TABLE `destinations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `region` ENUM('SOUTH_COAST', 'EAST_COAST', 'WEST_COAST', 'NORTH_COAST') NOT NULL,
    `harbor_name` VARCHAR(120) NOT NULL,
    `description` TEXT,
    `image_url` VARCHAR(255),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `routes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL,
    `start_destination_id` INT NOT NULL,
    `end_destination_id` INT NOT NULL,
    `duration_hours` DECIMAL(4, 1) NOT NULL,
    `distance_nm` DECIMAL(5, 1) NOT NULL,
    `highlights` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`start_destination_id`) REFERENCES `destinations`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`end_destination_id`) REFERENCES `destinations`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `tours` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(200) NOT NULL,
    `tour_type` ENUM('WHALE_WATCHING', 'DAYLIGHT_CRUISE', 'SUNSET_SAIL', 'OVERNIGHT_CHARTER', 'SNORKELING_SAFARI', 'DINE_AT_SEA') NOT NULL,
    `route_id` INT NOT NULL,
    `description` TEXT NOT NULL,
    `duration_hours` DECIMAL(4, 1) NOT NULL,
    `base_price` DECIMAL(10, 2) NOT NULL,
    `max_passengers` INT NOT NULL DEFAULT 20,
    `inclusions` TEXT,
    `exclusions` TEXT,
    `special_instructions` TEXT,
    `image_url` VARCHAR(255),
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`route_id`) REFERENCES `routes`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 3. MEMBER 3: BOAT MANAGEMENT (Boat Fleet & Vessel Manager)
-- --------------------------------------------------------------------
CREATE TABLE `vessels` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(120) NOT NULL,
    `registration_no` VARCHAR(60) NOT NULL UNIQUE,
    `vessel_type` ENUM('CATAMARAN', 'YACHT', 'SPEEDBOAT') NOT NULL,
    `capacity` INT NOT NULL,
    `cabins` INT DEFAULT 0,
    `engines` VARCHAR(100),
    `cruising_speed_knots` DECIMAL(4, 1),
    `status` ENUM('AVAILABLE', 'ASSIGNED', 'UNDER_MAINTENANCE', 'INACTIVE') NOT NULL DEFAULT 'AVAILABLE',
    `owner_id` INT,
    `image_url` VARCHAR(255),
    `safety_equipment_notes` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 4. MEMBER 1 (CONTINUED): TOUR SCHEDULES
-- --------------------------------------------------------------------
CREATE TABLE `tour_schedules` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `tour_id` INT NOT NULL,
    `vessel_id` INT NOT NULL,
    `captain_id` INT,
    `guide_id` INT,
    `departure_time` DATETIME NOT NULL,
    `return_time` DATETIME NOT NULL,
    `available_seats` INT NOT NULL,
    `status` ENUM('SCHEDULED', 'BOARDING', 'DEPARTED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    `cancellation_reason` VARCHAR(255),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`tour_id`) REFERENCES `tours`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`vessel_id`) REFERENCES `vessels`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`captain_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`guide_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 5. MEMBER 6: PROMOTION & DISCOUNT MANAGEMENT (Promotion & Discount Strategy Manager)
-- --------------------------------------------------------------------
CREATE TABLE `promotions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(120) NOT NULL,
    `promo_code` VARCHAR(50) NOT NULL UNIQUE,
    `discount_type` ENUM('PERCENTAGE', 'FIXED_AMOUNT', 'SEASONAL') NOT NULL,
    `discount_value` DECIMAL(10, 2) NOT NULL,
    `min_spend` DECIMAL(10, 2) DEFAULT 0.00,
    `max_discount` DECIMAL(10, 2) DEFAULT 0.00,
    `max_redemptions` INT DEFAULT 100,
    `times_redeemed` INT DEFAULT 0,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 6. MEMBER 2: RESERVATION MANAGEMENT (Reservation & Guest Booking Manager)
-- --------------------------------------------------------------------
CREATE TABLE `reservations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `booking_ref` VARCHAR(30) NOT NULL UNIQUE,
    `schedule_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `passenger_count` INT NOT NULL DEFAULT 1,
    `total_amount` DECIMAL(10, 2) NOT NULL,
    `discount_amount` DECIMAL(10, 2) DEFAULT 0.00,
    `final_amount` DECIMAL(10, 2) NOT NULL,
    `promo_id` INT,
    `status` ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
    `special_notes` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`schedule_id`) REFERENCES `tour_schedules`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`promo_id`) REFERENCES `promotions`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `passengers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `reservation_id` INT NOT NULL,
    `full_name` VARCHAR(120) NOT NULL,
    `id_or_passport` VARCHAR(50) NOT NULL,
    `age` INT NOT NULL,
    `gender` ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    `nationality` VARCHAR(60) NOT NULL DEFAULT 'Sri Lankan',
    `emergency_contact` VARCHAR(30),
    FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `promo_redemptions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `promo_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `reservation_id` INT NOT NULL,
    `discount_applied` DECIMAL(10, 2) NOT NULL,
    `redeemed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`promo_id`) REFERENCES `promotions`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 7. MEMBER 4: MAINTENANCE MANAGEMENT (Boat Maintenance & Service Manager)
-- --------------------------------------------------------------------
CREATE TABLE `maintenance_records` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `vessel_id` INT NOT NULL,
    `maintenance_type` ENUM('ENGINE_OVERHAUL', 'HULL_CLEANING', 'SAFETY_INSPECTION', 'ELECTRICAL', 'ROUTINE_SERVICE') NOT NULL,
    `description` TEXT NOT NULL,
    `scheduled_date` DATE NOT NULL,
    `completed_date` DATE,
    `cost` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `service_provider` VARCHAR(120),
    `status` ENUM('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`vessel_id`) REFERENCES `vessels`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `service_reminders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `vessel_id` INT NOT NULL,
    `reminder_title` VARCHAR(150) NOT NULL,
    `interval_days` INT NOT NULL DEFAULT 90,
    `last_serviced_date` DATE NOT NULL,
    `next_due_date` DATE NOT NULL,
    `is_overdue` BOOLEAN DEFAULT FALSE,
    `notes` TEXT,
    FOREIGN KEY (`vessel_id`) REFERENCES `vessels`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `safety_check_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `schedule_id` INT NOT NULL,
    `vessel_id` INT NOT NULL,
    `captain_id` INT NOT NULL,
    `safety_items_verified` BOOLEAN NOT NULL DEFAULT TRUE,
    `life_jackets_count` INT NOT NULL DEFAULT 30,
    `fuel_level_percent` INT NOT NULL DEFAULT 100,
    `weather_conditions` VARCHAR(255) NOT NULL,
    `briefing_confirmed` BOOLEAN NOT NULL DEFAULT TRUE,
    `all_clear` BOOLEAN NOT NULL DEFAULT TRUE,
    `captain_signature` VARCHAR(120) NOT NULL,
    `status` VARCHAR(40) NOT NULL DEFAULT 'READY_FOR_DEPARTURE',
    `notes` TEXT,
    `logged_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`schedule_id`) REFERENCES `tour_schedules`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`vessel_id`) REFERENCES `vessels`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`captain_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 8. MEMBER 5: EMERGENCY MANAGEMENT (Maritime Safety & Emergency Notice Manager)
-- --------------------------------------------------------------------
CREATE TABLE `emergency_notices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(150) NOT NULL,
    `category` ENUM('BAD_WEATHER', 'HIGH_SWELL', 'TECHNICAL_DELAY', 'TOUR_CANCELLATION', 'SAFETY_ADVISORY') NOT NULL,
    `severity` ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL DEFAULT 'HIGH',
    `affected_tour_id` INT,
    `affected_vessel_id` INT,
    `affected_region` ENUM('ALL_REGIONS', 'SOUTH_COAST', 'EAST_COAST', 'WEST_COAST', 'NORTH_COAST') NOT NULL DEFAULT 'ALL_REGIONS',
    `message` TEXT NOT NULL,
    `broadcast_channels` VARCHAR(100) DEFAULT 'PORTAL,SMS,EMAIL',
    `status` ENUM('ACTIVE', 'RESOLVED', 'ARCHIVED') NOT NULL DEFAULT 'ACTIVE',
    `created_by_id` INT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `resolved_at` TIMESTAMP NULL,
    FOREIGN KEY (`affected_tour_id`) REFERENCES `tours`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`affected_vessel_id`) REFERENCES `vessels`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`created_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `emergency_acknowledgments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `notice_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `acknowledged_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `notes` VARCHAR(255),
    FOREIGN KEY (`notice_id`) REFERENCES `emergency_notices`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 9. COMMON: ACTIVITY AUDIT LOGGING
-- --------------------------------------------------------------------
CREATE TABLE `activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    `action` VARCHAR(100) NOT NULL,
    `module` VARCHAR(60) NOT NULL,
    `details` TEXT,
    `ip_address` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- --------------------------------------------------------------------
-- 10. COMMON: LOGIN DETAILS & AUTH AUDIT
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `login_details` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `full_name` VARCHAR(120),
    `email` VARCHAR(150) NOT NULL,
    `role` VARCHAR(50) NOT NULL,
    `ip_address` VARCHAR(50) DEFAULT '127.0.0.1',
    `status` VARCHAR(50) NOT NULL,
    `login_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `user_agent` VARCHAR(255) DEFAULT 'Browser / Web Client',
    `details` VARCHAR(255),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
