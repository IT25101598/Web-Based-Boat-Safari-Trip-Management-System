-- ====================================================================
-- SLIIT SE2030 - Web-Based Boat Safari Trip Management System
-- Schema Fix & Alignment Script for MySQL and Microsoft SQL Server
-- ====================================================================

-- 1. Ensure `special_instructions` column exists on `tours` table
-- For MySQL:
ALTER TABLE `tours` ADD COLUMN IF NOT EXISTS `special_instructions` TEXT NULL AFTER `exclusions`;

-- 2. Ensure `activity_logs` table has proper structure if recreated
CREATE TABLE IF NOT EXISTS `activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    `action` VARCHAR(100) NOT NULL,
    `module` VARCHAR(60) NOT NULL,
    `details` TEXT,
    `ip_address` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
