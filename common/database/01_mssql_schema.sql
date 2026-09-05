-- ====================================================================
-- SLIIT SE2030 - Web-Based Boat Safari Trip Management System
-- Group: Y2-S1-MLB-B8G1-09
-- Database Schema for Microsoft SQL Server / SQL Server Management Studio (SSMS)
-- Database Name: boat_safari_db
-- ====================================================================

-- 1. CREATE DATABASE
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'boat_safari_db')
BEGIN
    CREATE DATABASE [boat_safari_db];
END
GO

USE [boat_safari_db];
GO

-- 2. DROP TABLES IN REVERSE DEPENDENCY ORDER
IF OBJECT_ID('dbo.emergency_acknowledgments', 'U') IS NOT NULL DROP TABLE dbo.emergency_acknowledgments;
IF OBJECT_ID('dbo.emergency_notices', 'U') IS NOT NULL DROP TABLE dbo.emergency_notices;
IF OBJECT_ID('dbo.safety_check_logs', 'U') IS NOT NULL DROP TABLE dbo.safety_check_logs;
IF OBJECT_ID('dbo.service_reminders', 'U') IS NOT NULL DROP TABLE dbo.service_reminders;
IF OBJECT_ID('dbo.maintenance_records', 'U') IS NOT NULL DROP TABLE dbo.maintenance_records;
IF OBJECT_ID('dbo.promo_redemptions', 'U') IS NOT NULL DROP TABLE dbo.promo_redemptions;
IF OBJECT_ID('dbo.passengers', 'U') IS NOT NULL DROP TABLE dbo.passengers;
IF OBJECT_ID('dbo.reservations', 'U') IS NOT NULL DROP TABLE dbo.reservations;
IF OBJECT_ID('dbo.promotions', 'U') IS NOT NULL DROP TABLE dbo.promotions;
IF OBJECT_ID('dbo.tour_schedules', 'U') IS NOT NULL DROP TABLE dbo.tour_schedules;
IF OBJECT_ID('dbo.vessels', 'U') IS NOT NULL DROP TABLE dbo.vessels;
IF OBJECT_ID('dbo.tours', 'U') IS NOT NULL DROP TABLE dbo.tours;
IF OBJECT_ID('dbo.routes', 'U') IS NOT NULL DROP TABLE dbo.routes;
IF OBJECT_ID('dbo.destinations', 'U') IS NOT NULL DROP TABLE dbo.destinations;
IF OBJECT_ID('dbo.activity_logs', 'U') IS NOT NULL DROP TABLE dbo.activity_logs;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
GO

-- --------------------------------------------------------------------
-- 1. COMMON: USERS & ROLE-BASED ACCESS CONTROL (RBAC)
-- --------------------------------------------------------------------
CREATE TABLE dbo.users (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [full_name] NVARCHAR(120) NOT NULL,
    [email] NVARCHAR(150) NOT NULL UNIQUE,
    [password_hash] NVARCHAR(255) NOT NULL,
    [phone] NVARCHAR(30),
    [role] NVARCHAR(30) NOT NULL CHECK ([role] IN ('ADMIN', 'OFFICER', 'GUIDE', 'CAPTAIN', 'OWNER', 'CUSTOMER')),
    [status] NVARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK ([status] IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    [profile_image] NVARCHAR(255) DEFAULT 'assets/img/default-avatar.png',
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [updated_at] DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- --------------------------------------------------------------------
-- 2. MEMBER 1: DESTINATIONS, ROUTES, AND TOURS
-- --------------------------------------------------------------------
CREATE TABLE dbo.destinations (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL,
    [region] NVARCHAR(40) NOT NULL CHECK ([region] IN ('SOUTH_COAST', 'EAST_COAST', 'WEST_COAST', 'NORTH_COAST')),
    [harbor_name] NVARCHAR(120) NOT NULL,
    [description] NVARCHAR(MAX),
    [image_url] NVARCHAR(255),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.routes (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(150) NOT NULL,
    [start_destination_id] INT NOT NULL,
    [end_destination_id] INT NOT NULL,
    [duration_hours] DECIMAL(4, 1) NOT NULL,
    [distance_nm] DECIMAL(5, 1) NOT NULL,
    [highlights] NVARCHAR(MAX),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_routes_start FOREIGN KEY ([start_destination_id]) REFERENCES dbo.destinations([id]),
    CONSTRAINT FK_routes_end FOREIGN KEY ([end_destination_id]) REFERENCES dbo.destinations([id])
);
GO

CREATE TABLE dbo.tours (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [title] NVARCHAR(200) NOT NULL,
    [tour_type] NVARCHAR(50) NOT NULL CHECK ([tour_type] IN ('WHALE_WATCHING', 'DAYLIGHT_CRUISE', 'SUNSET_SAIL', 'OVERNIGHT_CHARTER', 'SNORKELING_SAFARI', 'DINE_AT_SEA')),
    [route_id] INT NOT NULL,
    [description] NVARCHAR(MAX) NOT NULL,
    [duration_hours] DECIMAL(4, 1) NOT NULL,
    [base_price] DECIMAL(10, 2) NOT NULL,
    [max_passengers] INT NOT NULL DEFAULT 20,
    [inclusions] NVARCHAR(MAX),
    [exclusions] NVARCHAR(MAX),
    [special_instructions] NVARCHAR(MAX),
    [image_url] NVARCHAR(255),
    [is_active] BIT DEFAULT 1,
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_tours_route FOREIGN KEY ([route_id]) REFERENCES dbo.routes([id])
);
GO

-- --------------------------------------------------------------------
-- 3. MEMBER 3: BOAT FLEET HIERARCHY
-- --------------------------------------------------------------------
CREATE TABLE dbo.vessels (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(120) NOT NULL,
    [registration_no] NVARCHAR(60) NOT NULL UNIQUE,
    [vessel_type] NVARCHAR(40) NOT NULL CHECK ([vessel_type] IN ('CATAMARAN', 'YACHT', 'SPEEDBOAT')),
    [capacity] INT NOT NULL,
    [cabins] INT DEFAULT 0,
    [engines] NVARCHAR(100),
    [cruising_speed_knots] DECIMAL(4, 1),
    [status] NVARCHAR(40) NOT NULL DEFAULT 'AVAILABLE' CHECK ([status] IN ('AVAILABLE', 'ASSIGNED', 'UNDER_MAINTENANCE', 'INACTIVE')),
    [owner_id] INT,
    [image_url] NVARCHAR(255),
    [safety_equipment_notes] NVARCHAR(MAX),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_vessels_owner FOREIGN KEY ([owner_id]) REFERENCES dbo.users([id]) ON DELETE SET NULL
);
GO

-- --------------------------------------------------------------------
-- 4. MEMBER 1 (CONT.): DEPARTURE TIMETABLE SCHEDULES
-- --------------------------------------------------------------------
CREATE TABLE dbo.tour_schedules (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [tour_id] INT NOT NULL,
    [vessel_id] INT NOT NULL,
    [captain_id] INT,
    [guide_id] INT,
    [departure_time] DATETIME2 NOT NULL,
    [return_time] DATETIME2 NOT NULL,
    [available_seats] INT NOT NULL,
    [status] NVARCHAR(40) NOT NULL DEFAULT 'SCHEDULED' CHECK ([status] IN ('SCHEDULED', 'BOARDING', 'DEPARTED', 'COMPLETED', 'CANCELLED')),
    [cancellation_reason] NVARCHAR(255),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_schedules_tour FOREIGN KEY ([tour_id]) REFERENCES dbo.tours([id]),
    CONSTRAINT FK_schedules_vessel FOREIGN KEY ([vessel_id]) REFERENCES dbo.vessels([id]),
    CONSTRAINT FK_schedules_captain FOREIGN KEY ([captain_id]) REFERENCES dbo.users([id]),
    CONSTRAINT FK_schedules_guide FOREIGN KEY ([guide_id]) REFERENCES dbo.users([id])
);
GO

-- --------------------------------------------------------------------
-- 5. MEMBER 6: PROMOTION & DISCOUNT CAMPAIGNS
-- --------------------------------------------------------------------
CREATE TABLE dbo.promotions (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [name] NVARCHAR(120) NOT NULL,
    [promo_code] NVARCHAR(50) NOT NULL UNIQUE,
    [discount_type] NVARCHAR(40) NOT NULL CHECK ([discount_type] IN ('PERCENTAGE', 'FIXED_AMOUNT', 'SEASONAL')),
    [discount_value] DECIMAL(10, 2) NOT NULL,
    [min_spend] DECIMAL(10, 2) DEFAULT 0.00,
    [max_discount] DECIMAL(10, 2) DEFAULT 0.00,
    [max_redemptions] INT DEFAULT 100,
    [times_redeemed] INT DEFAULT 0,
    [start_date] DATE NOT NULL,
    [end_date] DATE NOT NULL,
    [is_active] BIT DEFAULT 1,
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

-- --------------------------------------------------------------------
-- 6. MEMBER 2: RESERVATIONS & PASSENGER MANIFEST
-- --------------------------------------------------------------------
CREATE TABLE dbo.reservations (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [booking_ref] NVARCHAR(30) NOT NULL UNIQUE,
    [schedule_id] INT NOT NULL,
    [customer_id] INT NOT NULL,
    [passenger_count] INT NOT NULL DEFAULT 1,
    [total_amount] DECIMAL(10, 2) NOT NULL,
    [discount_amount] DECIMAL(10, 2) DEFAULT 0.00,
    [final_amount] DECIMAL(10, 2) NOT NULL,
    [promo_id] INT,
    [status] NVARCHAR(40) NOT NULL DEFAULT 'CONFIRMED' CHECK ([status] IN ('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CANCELLED')),
    [special_notes] NVARCHAR(MAX),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_res_schedule FOREIGN KEY ([schedule_id]) REFERENCES dbo.tour_schedules([id]),
    CONSTRAINT FK_res_customer FOREIGN KEY ([customer_id]) REFERENCES dbo.users([id]),
    CONSTRAINT FK_res_promo FOREIGN KEY ([promo_id]) REFERENCES dbo.promotions([id]) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.passengers (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [reservation_id] INT NOT NULL,
    [full_name] NVARCHAR(120) NOT NULL,
    [id_or_passport] NVARCHAR(50) NOT NULL,
    [age] INT NOT NULL,
    [gender] NVARCHAR(20) NOT NULL CHECK ([gender] IN ('MALE', 'FEMALE', 'OTHER')),
    [nationality] NVARCHAR(60) NOT NULL DEFAULT 'Sri Lankan',
    [emergency_contact] NVARCHAR(30),
    CONSTRAINT FK_passengers_res FOREIGN KEY ([reservation_id]) REFERENCES dbo.reservations([id]) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.promo_redemptions (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [promo_id] INT NOT NULL,
    [customer_id] INT NOT NULL,
    [reservation_id] INT NOT NULL,
    [discount_applied] DECIMAL(10, 2) NOT NULL,
    [redeemed_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_redemptions_promo FOREIGN KEY ([promo_id]) REFERENCES dbo.promotions([id]),
    CONSTRAINT FK_redemptions_cust FOREIGN KEY ([customer_id]) REFERENCES dbo.users([id]),
    CONSTRAINT FK_redemptions_res FOREIGN KEY ([reservation_id]) REFERENCES dbo.reservations([id]) ON DELETE CASCADE
);
GO

-- --------------------------------------------------------------------
-- 7. MEMBER 4: BOAT MAINTENANCE & SERVICE REMINDERS
-- --------------------------------------------------------------------
CREATE TABLE dbo.maintenance_records (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [vessel_id] INT NOT NULL,
    [maintenance_type] NVARCHAR(50) NOT NULL CHECK ([maintenance_type] IN ('ENGINE_OVERHAUL', 'HULL_CLEANING', 'SAFETY_INSPECTION', 'ELECTRICAL', 'ROUTINE_SERVICE')),
    [description] NVARCHAR(MAX) NOT NULL,
    [scheduled_date] DATE NOT NULL,
    [completed_date] DATE,
    [cost] DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    [service_provider] NVARCHAR(120),
    [status] NVARCHAR(40) NOT NULL DEFAULT 'SCHEDULED' CHECK ([status] IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_maintenance_vessel FOREIGN KEY ([vessel_id]) REFERENCES dbo.vessels([id]) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.service_reminders (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [vessel_id] INT NOT NULL,
    [reminder_title] NVARCHAR(150) NOT NULL,
    [interval_days] INT NOT NULL DEFAULT 90,
    [last_serviced_date] DATE NOT NULL,
    [next_due_date] DATE NOT NULL,
    [is_overdue] BIT DEFAULT 0,
    [notes] NVARCHAR(MAX),
    CONSTRAINT FK_reminders_vessel FOREIGN KEY ([vessel_id]) REFERENCES dbo.vessels([id]) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.safety_check_logs (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [schedule_id] INT NOT NULL,
    [vessel_id] INT NOT NULL,
    [captain_id] INT NOT NULL,
    [safety_items_verified] BIT NOT NULL DEFAULT 1,
    [life_jackets_count] INT NOT NULL DEFAULT 30,
    [fuel_level_percent] INT NOT NULL DEFAULT 100,
    [weather_conditions] NVARCHAR(255) NOT NULL,
    [briefing_confirmed] BIT NOT NULL DEFAULT 1,
    [all_clear] BIT NOT NULL DEFAULT 1,
    [captain_signature] NVARCHAR(120) NOT NULL,
    [status] NVARCHAR(40) NOT NULL DEFAULT 'READY_FOR_DEPARTURE' CHECK ([status] IN ('READY_FOR_DEPARTURE', 'PENDING_RECHECK', 'VOIDED')),
    [notes] NVARCHAR(MAX),
    [logged_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_safety_schedule FOREIGN KEY ([schedule_id]) REFERENCES dbo.tour_schedules([id]),
    CONSTRAINT FK_safety_vessel FOREIGN KEY ([vessel_id]) REFERENCES dbo.vessels([id]),
    CONSTRAINT FK_safety_captain FOREIGN KEY ([captain_id]) REFERENCES dbo.users([id])
);
GO

-- --------------------------------------------------------------------
-- 8. MEMBER 5: MARITIME SAFETY & EMERGENCY ADVISORIES
-- --------------------------------------------------------------------
CREATE TABLE dbo.emergency_notices (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [title] NVARCHAR(150) NOT NULL,
    [category] NVARCHAR(50) NOT NULL CHECK ([category] IN ('BAD_WEATHER', 'HIGH_SWELL', 'TECHNICAL_DELAY', 'TOUR_CANCELLATION', 'SAFETY_ADVISORY')),
    [severity] NVARCHAR(30) NOT NULL DEFAULT 'HIGH' CHECK ([severity] IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    [affected_tour_id] INT,
    [affected_vessel_id] INT,
    [affected_region] NVARCHAR(40) NOT NULL DEFAULT 'ALL_REGIONS' CHECK ([affected_region] IN ('ALL_REGIONS', 'SOUTH_COAST', 'EAST_COAST', 'WEST_COAST', 'NORTH_COAST')),
    [message] NVARCHAR(MAX) NOT NULL,
    [broadcast_channels] NVARCHAR(100) DEFAULT 'PORTAL,SMS,EMAIL',
    [status] NVARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK ([status] IN ('ACTIVE', 'RESOLVED', 'ARCHIVED')),
    [created_by_id] INT,
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [resolved_at] DATETIME2 NULL,
    CONSTRAINT FK_notices_tour FOREIGN KEY ([affected_tour_id]) REFERENCES dbo.tours([id]) ON DELETE SET NULL,
    CONSTRAINT FK_notices_vessel FOREIGN KEY ([affected_vessel_id]) REFERENCES dbo.vessels([id]) ON DELETE SET NULL,
    CONSTRAINT FK_notices_creator FOREIGN KEY ([created_by_id]) REFERENCES dbo.users([id]) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.emergency_acknowledgments (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [notice_id] INT NOT NULL,
    [user_id] INT NOT NULL,
    [acknowledged_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [notes] NVARCHAR(255),
    CONSTRAINT FK_ack_notice FOREIGN KEY ([notice_id]) REFERENCES dbo.emergency_notices([id]) ON DELETE CASCADE,
    CONSTRAINT FK_ack_user FOREIGN KEY ([user_id]) REFERENCES dbo.users([id]) ON DELETE CASCADE
);
GO

-- --------------------------------------------------------------------
-- 9. COMMON: ACTIVITY AUDIT LOGGING
-- --------------------------------------------------------------------
CREATE TABLE dbo.activity_logs (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT,
    [action] NVARCHAR(100) NOT NULL,
    [module] NVARCHAR(60) NOT NULL,
    [details] NVARCHAR(MAX),
    [ip_address] NVARCHAR(50),
    [created_at] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_logs_user FOREIGN KEY ([user_id]) REFERENCES dbo.users([id]) ON DELETE SET NULL
);
GO

-- --------------------------------------------------------------------
-- 10. COMMON: LOGIN DETAILS & AUTH AUDIT
-- --------------------------------------------------------------------
CREATE TABLE dbo.login_details (
    [id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NULL,
    [full_name] NVARCHAR(120),
    [email] NVARCHAR(150) NOT NULL,
    [role] NVARCHAR(50) NOT NULL,
    [ip_address] NVARCHAR(50) DEFAULT '127.0.0.1',
    [status] NVARCHAR(50) NOT NULL,
    [login_time] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [user_agent] NVARCHAR(255) DEFAULT 'Browser / Web Client',
    [details] NVARCHAR(255),
    CONSTRAINT FK_login_user FOREIGN KEY ([user_id]) REFERENCES dbo.users([id]) ON DELETE SET NULL
);
GO
