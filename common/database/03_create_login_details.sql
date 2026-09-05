USE boat_safari_db;

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

INSERT INTO `login_details` (`user_id`, `full_name`, `email`, `role`, `ip_address`, `status`, `login_time`, `details`)
VALUES 
(10, 'David Miller (Tourist / Customer)', 'david.miller@gmail.com', 'CUSTOMER', '127.0.0.1', 'SUCCESS', '2026-09-15 17:54:44', 'Customer Login Success'),
(12, 'Chamath Pereira', 'chamath.pereira@gmail.com', 'CUSTOMER', '127.0.0.1', 'SUCCESS - NEW REGISTRATION', '2026-09-15 17:58:36', 'New Customer Account Created'),
(12, 'Chamath Pereira', 'chamath.pereira@gmail.com', 'CUSTOMER', '127.0.0.1', 'SUCCESS', '2026-09-15 17:59:30', 'Customer Login Success'),
(13, 'Amara Fernando', 'amara.tourist@example.com', 'CUSTOMER', '127.0.0.1', 'SUCCESS - NEW REGISTRATION', '2026-09-15 18:10:25', 'New Customer Account Created'),
(13, 'Amara Fernando', 'amara.tourist@example.com', 'CUSTOMER', '127.0.0.1', 'SUCCESS', '2026-09-15 18:10:30', 'Customer Login Success'),
(1, 'System Administrator', 'admin@sail-safari.lk', 'ADMIN', '127.0.0.1', 'SUCCESS', '2026-09-15 18:11:33', 'Administrator Dashboard Access'),
(1, 'System Administrator', 'admin@sail-safari.lk', 'ADMIN', '127.0.0.1', 'SUCCESS', '2026-09-15 18:27:47', 'Administrator Session Refresh');
