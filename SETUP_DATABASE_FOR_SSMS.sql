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


-- ====================================================================
-- SEED DATA INSERTION (ALL 17 TABLES WITH LKR PRICES & ORIGINAL DATA)
-- ====================================================================

-- ====================================================================
-- SLIIT SE2030 - Web-Based Boat Safari Trip Management System
-- Group: Y2-S1-MLB-B8G1-09
-- COMPLETE 1-CLICK DATABASE SETUP FOR MICROSOFT SQL SERVER (SSMS)
-- Generated: 2026-10-03
-- ====================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'boat_safari_db')
BEGIN
    CREATE DATABASE [boat_safari_db];
    PRINT 'Database boat_safari_db created successfully.';
END
GO

USE [boat_safari_db];
GO

-- --------------------------------------------------------------------
-- Optional: Ensure application user 'boat_safari_user' has access
-- --------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'boat_safari_user')
BEGIN
    CREATE LOGIN [boat_safari_user] WITH PASSWORD = N'BoatSafari@2026', CHECK_POLICY = OFF;
END
GO
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'boat_safari_user')
BEGIN
    CREATE USER [boat_safari_user] FOR LOGIN [boat_safari_user];
    ALTER ROLE [db_owner] ADD MEMBER [boat_safari_user];
END
GO

-- ====================================================================
-- TABLE: destinations
-- ====================================================================
SET IDENTITY_INSERT [dbo].[destinations] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (1, N'Mirissa Bay & Deep Ocean Trench', N'SOUTH_COAST', N'Mirissa Fishery Harbour', N'Sri Lanka premier whale and dolphin watching capital. Continental shelf drops dramatically 6 miles offshore.', N'assets/img/destinations/mirissa.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (2, N'Galle Fort Heritage Coast', N'SOUTH_COAST', N'Galle International Harbour', N'UNESCO world heritage ramparts viewed from the turquoise waters of the Indian Ocean.', N'assets/img/destinations/galle.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (3, N'Trincomalee Natural Harbor & Pigeon Island', N'EAST_COAST', N'Trincomalee Cod Bay Pier', N'World-famous coral reefs, blacktip reef sharks, and calm blue summer sailing waters.', N'assets/img/destinations/trinco.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (4, N'Bentota Lagoon & Sea Route', N'WEST_COAST', N'Bentota River Marina', N'Scenic blend of riverine mangrove safari and offshore open-sea cruising.', N'assets/img/destinations/bentota.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (5, N'Passikudah Coral Bay', N'EAST_COAST', N'Passikudah Outer Pier', N'Shallow crystalline waters ideal for swimming, snorkeling, and luxury sunset champagne cruises.', N'assets/img/destinations/passikudah.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (6, N'Kalpitiya Lagoon & Dolphin Sanctuary', N'WEST_COAST', N'Kalpitiya Fishery Harbour', N'Renowned for mega-pods of spinner dolphins, scenic bar reefs, and kite surfing lagoons.', N'assets/img/destinations/kalpitiya.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (7, N'Jaffna Islands & Delft Channel', N'NORTH_COAST', N'Kurikadduwan Jetty', N'Historic northern waterways featuring the wild horses of Delft, coral ruins, and Dutch maritime forts.', N'assets/img/destinations/jaffna.jpg', N'2026-10-03 04:02:53.8700864');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[destinations] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at]) VALUES (8, N'Tangalle Coastal Coves & Turtle Coast', N'SOUTH_COAST', N'Tangalle Natural Harbour', N'Secluded rocky bays, palm-fringed coastlines, and pristine marine turtle nesting sanctuaries.', N'assets/img/destinations/tangalle.jpg', N'2026-10-03 04:02:53.8700864');
END
SET IDENTITY_INSERT [dbo].[destinations] OFF;
GO

-- ====================================================================
-- TABLE: routes
-- ====================================================================
SET IDENTITY_INSERT [dbo].[routes] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (1, N'Mirissa Pelagic Blue Whale Track', 1, 1, 4.5, 18.5, N'Blue Whale sightings, Spinner Dolphin pods, Flying Fish, Continental Shelf', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (2, N'Galle Lighthouse & Coral Reef Sunset', 2, 2, 3.0, 10.0, N'Colonial Fort ramparts, Rumassala cliff, Jungle Beach, Sunset horizon', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (3, N'Trincomalee Pigeon Island Reef Expedition', 3, 3, 5.0, 22.0, N'Coral reef snorkeling, Blacktip reef sharks, Sea turtles, Swami Rock cliff', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (4, N'Bentota Mangrove & Ocean Breeze', 4, 4, 3.5, 12.0, N'River delta, Barberyn lighthouse offshore views, Warm coastal swimming', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (5, N'Passikudah Bay & Coral Garden', 5, 5, 4.0, 15.0, N'Calm crystalline bay, Stand-up paddleboarding, Snorkeling safari', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (6, N'Kalpitiya Spinner Dolphin & Coral Track', 6, 6, 4.0, 16.0, N'Large spinner dolphin super-pods, Bar Reef coral gardens, dugong spotting zone', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (7, N'Jaffna Delft Island Historical Maritime Passage', 7, 7, 5.5, 24.0, N'Wild horses of Delft, ancient baobab trees, Chola kingdom ruins, northern waters', N'2026-10-03 04:02:53.8793291');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[routes] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at]) VALUES (8, N'Tangalle Blue Lagoon & Turtle Cove Cruise', 8, 8, 3.5, 11.5, N'Rekawa marine turtle sanctuary, secluded palm-fringed bays, bioluminescence', N'2026-10-03 04:02:53.8793291');
END
SET IDENTITY_INSERT [dbo].[routes] OFF;
GO

-- ====================================================================
-- TABLE: users
-- ====================================================================
SET IDENTITY_INSERT [dbo].[users] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (1, N'Kasun Jayawardena', N'admin@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94771234567', N'ADMIN', N'ACTIVE', N'assets/img/avatars/admin1.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (2, N'Dilani Perera', N'dilani.admin@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94772345678', N'ADMIN', N'ACTIVE', N'assets/img/avatars/admin2.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (3, N'Chaminda Fernando', N'chaminda.officer@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94773456789', N'OFFICER', N'ACTIVE', N'assets/img/avatars/officer1.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (4, N'Capt. Sunil Perera', N'sunil.captain@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94774567890', N'CAPTAIN', N'ACTIVE', N'assets/img/avatars/captain1.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (5, N'Capt. Ranjith Silva', N'ranjith.captain@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94775678901', N'CAPTAIN', N'ACTIVE', N'assets/img/avatars/captain2.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (6, N'Capt. Nimal Rajapakse', N'nimal.captain@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94776789012', N'CAPTAIN', N'ACTIVE', N'assets/img/avatars/captain3.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (7, N'Roshan Wickramasinghe', N'roshan.guide@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94777890123', N'GUIDE', N'ACTIVE', N'assets/img/avatars/guide1.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (8, N'Malith Gunasekara', N'malith.guide@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94778901234', N'GUIDE', N'ACTIVE', N'assets/img/avatars/guide2.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 9)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (9, N'Dinesh Mendis', N'dinesh.owner@southernmarina.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94779012345', N'OWNER', N'ACTIVE', N'assets/img/avatars/owner1.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (10, N'Lalith De Silva', N'lalith.owner@oceanlux.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94770123456', N'OWNER', N'ACTIVE', N'assets/img/avatars/owner2.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (11, N'Johnathan Miller', N'john.miller@gmail.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+447911123456', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust1.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 12)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (12, N'Elena Rostova', N'elena.rostova@yandex.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+79031234567', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust2.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 13)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (13, N'Sarah Jenkins', N'sarah.jenkins@outlook.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+12025550143', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust3.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 14)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (14, N'Hans Schmidt', N'hans.schmidt@web.de', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+491512345678', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust4.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (15, N'Nadeesha Kumari', N'nadeesha.k@gmail.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94714567890', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust5.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 16)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (16, N'Kenji Sato', N'kenji.sato@sony.jp', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+819012345678', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust6.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 17)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (17, N'Liam O''Connor', N'liam.oconnor@tcd.ie', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+353871234567', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust7.jpg', N'2026-10-03 04:02:53.862474', N'2026-10-03 04:02:53.862474');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 18)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (18, N'Kasun Rajapaksha (Updated)', N'guest.48654@example.com', N'34434ec0f5e1ef4332139668bfbdfd09a9aa5cabff11df74923fa4e75fba6654', N'+94710009988', N'CUSTOMER', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 16:26:15.9233333', N'2026-10-03 16:26:15.9233333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 19)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (19, N'Kasun Rajapaksha (Updated)', N'guest.86161@example.com', N'34434ec0f5e1ef4332139668bfbdfd09a9aa5cabff11df74923fa4e75fba6654', N'+94710009988', N'CUSTOMER', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 16:30:56.0566667', N'2026-10-03 16:30:56.0566667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 20)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (20, N'System Administrator', N'admin@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 123 4567', N'ADMIN', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 17:05:31.45', N'2026-10-03 17:05:31.45');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 21)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (21, N'Tourist Guest', N'tourist@sail-safari.lk', N'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', N'+94 71 234 5678', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust1.jpg', N'2026-10-03 17:05:31.4566667', N'2026-10-03 17:05:31.4566667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 22)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (22, N'Chief Reservation Officer', N'officer@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 234 5678', N'OFFICER', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.6066667', N'2026-10-03 18:16:09.6066667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 23)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (23, N'Safari Tour Operations Manager', N'tourmanager@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 345 6789', N'ADMIN', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.62', N'2026-10-03 18:16:09.62');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 24)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (24, N'Capt. Shantha Perera (Master Mariner)', N'captain.perera@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 456 7890', N'CAPTAIN', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.6333333', N'2026-10-03 18:16:09.6333333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 25)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (25, N'Capt. Ruwan Kumara (Catamaran Skipper)', N'captain.kumara@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 567 8901', N'CAPTAIN', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.6433333', N'2026-10-03 18:16:09.6433333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 26)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (26, N'Kasun Fernando (Marine Naturalist Guide)', N'guide.kasun@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 678 9012', N'GUIDE', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.65', N'2026-10-03 18:16:09.65');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 27)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (27, N'Dilshan Silva (Snorkeling Guide)', N'guide.dilshan@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 789 0123', N'GUIDE', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.65', N'2026-10-03 18:16:09.65');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 28)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (28, N'Luxury Fleet Owner', N'owner@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 890 1234', N'OWNER', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.6533333', N'2026-10-03 18:16:09.6533333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 29)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (29, N'Chief Marine Engineer', N'maintenance@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 901 2345', N'ADMIN', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:16:09.6566667', N'2026-10-03 18:16:09.6566667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[users] WHERE id = 30)
BEGIN
    INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at]) VALUES (30, N'Kasun Rajapaksha (Updated)', N'guest.44079@example.com', N'34434ec0f5e1ef4332139668bfbdfd09a9aa5cabff11df74923fa4e75fba6654', N'+94710009988', N'CUSTOMER', N'ACTIVE', N'assets/img/default-avatar.png', N'2026-10-03 18:20:50.48', N'2026-10-03 18:20:50.48');
END
SET IDENTITY_INSERT [dbo].[users] OFF;
GO

-- ====================================================================
-- TABLE: vessels
-- ====================================================================
SET IDENTITY_INSERT [dbo].[vessels] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (1, N'Ocean Pearl (Ceycat 55)', N'SLC-CAT-001', N'CATAMARAN', 30, 2, N'Twin Yanmar 315HP Turbo Diesels', 18.5, N'AVAILABLE', 9, N'assets/img/fleet/ocean-pearl.jpg', N'Drydock completed', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (2, N'Sapphire Blue (Topaz 48)', N'SLC-CAT-002', N'CATAMARAN', 25, 0, N'Dual Yamaha 250HP Four-Stroke Outboards', 28.0, N'AVAILABLE', 9, N'assets/img/fleet/sapphire-blue.jpg', N'20 adult lifejackets, 5 child lifejackets, EPIRB, marine radio, offshore fire extinguishers', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (3, N'Ceylon Monarch (Majesty 62)', N'SLC-YACHT-003', N'YACHT', 15, 3, N'Twin Caterpillar 600HP Marine Diesels', 22.0, N'AVAILABLE', 10, N'assets/img/fleet/ceylon-monarch.jpg', N'30 Solas approved vests, automatic fire suppression in engine room, life raft, Garmin radar', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (4, N'Wave Runner (SeaRay 32)', N'SLC-SPD-004', N'SPEEDBOAT', 12, 2, N'Twin Cummins 380HP Marine Diesels', 17.0, N'ASSIGNED', 9, N'assets/img/fleet/wave-runner.jpg', N'40 lifejackets, 2 life buoys, emergency flares, oxygen resuscitator, satellite phone', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (5, N'Mirissa Sun (Lagoon 42)', N'SLC-CAT-005', N'CATAMARAN', 20, 0, N'Twin Suzuki 200HP Lean Burn Engines', 30.5, N'AVAILABLE', 10, N'assets/img/fleet/mirissa-sun.jpg', N'15 Solas lifejackets, portable VHF, handheld GPS, first aid kit, waterproof fire extinguisher', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (6, N'Indian Ocean Queen (Sunreef 60)', N'SLC-CAT-006', N'CATAMARAN', 35, 2, N'Twin Volvo Penta 260HP Inboard', 16.5, N'AVAILABLE', 9, N'assets/img/fleet/ocean-queen.jpg', N'35 lifejackets, liferaft for 35 persons, AIS transponder, depth sounder, smoke beacons', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (7, N'Southern Star Express (Axopar 37)', N'SLC-SPD-007', N'SPEEDBOAT', 10, 2, N'Twin MAN 450HP High Performance', 24.0, N'UNDER_MAINTENANCE', 10, N'assets/img/fleet/southern-star.jpg', N'25 life jackets, EPIRB beacon, forward sonar, life raft, twin distress rocket kits', N'2026-10-03 04:02:53.8919333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[vessels] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at]) VALUES (8, N'Serendib Explorer (Princess 55)', N'SLC-YACHT-008', N'YACHT', 18, 0, N'Yamaha 300HP V6 Offshore Outboard', 26.0, N'AVAILABLE', 9, N'assets/img/fleet/serendib-explorer.jpg', N'18 life jackets, complete snorkeling safety flags, throw lines, medical emergency kit', N'2026-10-03 04:02:53.8919333');
END
SET IDENTITY_INSERT [dbo].[vessels] OFF;
GO

-- ====================================================================
-- TABLE: tours
-- ====================================================================
SET IDENTITY_INSERT [dbo].[tours] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (1, N'Mirissa Blue Whale & Dolphin Luxury Catamaran Safari', N'WHALE_WATCHING', 1, N'Sail into the deep southern Indian Ocean aboard our premier 55-foot luxury catamaran. Witness magnificent Blue Whales, Brydes Whales, and playful Spinner Dolphins with fresh gourmet breakfast and marine biologist commentary on board.', 4.5, 24500.00, 25, N'Gourmet breakfast, Tropical fruit platter, Ceylon tea & coffee, Marine naturalist guide, Binoculars, Life jackets', N'Alcoholic beverages, Hotel pickup', N'Departure strictly at 6:30 AM. Motion sickness medication recommended 30 min before boarding.', N'assets/img/tours/mirissa-whale.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (2, N'Galle Fort Heritage & Sunset Champagne Sail', N'SUNSET_SAIL', 2, N'Glaze across the historic Galle coastline as the sun dips into the crimson ocean. Enjoy chilled beverages, canapes, and breathtaking vistas of the centuries-old Dutch Fort ramparts.', 3.0, 18500.00, 20, N'Welcome mocktail, Artisanal canapes, Chilled wine or beer, Snorkeling gear, Stand-up paddleboards', N'Personal gratuities', N'Smart casual dress code. Arrive at Galle harbor 20 minutes prior to departure.', N'assets/img/tours/galle-sunset.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (3, N'Trincomalee Pigeon Island Reef Snorkeling Safari', N'SNORKELING_SAFARI', 3, N'Discover the vibrant marine biodiversity of Sri Lanka east coast. Snorkel with colorful tropical fish, sea turtles, and harmless blacktip reef sharks in crystal-clear waters.', 5.0, 29000.00, 22, N'Seafood BBQ lunch, Fresh coconut water, Snorkeling masks & fins, Island marine park entry fee, Guide', N'Wetsuits, Towels', N'Sunscreen must be reef-safe. Respect wildlife - do not step on or touch live corals.', N'assets/img/tours/trinco-snorkeling.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (4, N'Private Starlight Dine-at-Sea Yacht Experience', N'DINE_AT_SEA', 2, N'An exclusive 5-star culinary voyage anchored under the stars in a calm secluded bay. Complete with a private chef, 4-course seafood banquet, and romantic ambient lighting.', 4.0, 65000.00, 10, N'Private 4-course seafood dinner, Premium wine pairing, Dedicated steward and captain, Soft music system', N'Spirits and cocktails', N'Great tour for families and young children. Wear light cotton clothing and a sun hat.', N'assets/img/tours/dine-at-sea.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (5, N'Bentota Mangrove Estuary & River Delta Cruise', N'DAYLIGHT_CRUISE', 4, N'Explore tranquil mangrove tunnels, birdwatching sanctuaries, and cinnamon cultivation islands before cruising out into the ocean surf.', 3.5, 16000.00, 16, N'Chilled king coconut water, Local snack assortment, Life jackets, Certified naturalist commentary', N'Hotel transfers', N'Swimwear is recommended. Towels provided on board.', N'assets/img/tours/bentota-mangrove.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (6, N'Passikudah Coral Garden & Water Sports Cruise', N'DAYLIGHT_CRUISE', 5, N'Sail across the turquoise waters of Passikudah Bay. Enjoy swimming in the safe outer reef lagoon and stand-up paddleboarding in mirror-calm shallows.', 4.0, 21000.00, 20, N'Fresh fruit skewers, Iced beverages, Paddleboards, Snorkeling sets, Swimming vests', N'Motorized water sports', N'High chance of ocean spray. Waterproof bags provided for electronics.', N'assets/img/tours/passikudah-coral.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (7, N'Kalpitiya Spinner Dolphin Super-Pod Safari', N'DAYLIGHT_CRUISE', 6, N'Embark on an exhilarating speedboat and catamaran voyage into the Bar Reef marine sanctuary. Encounter hundreds of leaping spinner dolphins in their natural playground.', 4.0, 26000.00, 14, N'Continental snack basket, Fresh fruit juices, Expert dolphin spotter guide, Safety harnesses', N'Personal insurance', N'Easy boarding from sandy beach jetty. All ages welcome.', N'assets/img/tours/kalpitiya-dolphin.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tours] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at]) VALUES (8, N'Tangalle Secluded Coves & Sunset Twilight Cruise', N'SUNSET_SAIL', 8, N'Witness the rugged beauty of the deep south coast with secluded coves, blowholes, and sunset cocktail service along the tranquil waters of Tangalle.', 3.5, 22000.00, 18, N'Evening tapas board, Signature mocktails, High-powered binoculars, Ambient lounge audio', N'Hard liquor', N'Please inform of any dietary restrictions or shellfish allergies 24 hours prior.', N'assets/img/tours/tangalle-sunset.jpg', 1, N'2026-10-03 04:02:53.9061708');
END
SET IDENTITY_INSERT [dbo].[tours] OFF;
GO

-- ====================================================================
-- TABLE: tour_schedules
-- ====================================================================
SET IDENTITY_INSERT [dbo].[tour_schedules] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (1, 2, 2, 4, 6, N'2026-10-19 18:19:00.0', N'2026-10-19 22:19:00.0', 14, N'CANCELLED', N'Automated test cancellation', N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (2, 2, 3, 5, 8, N'2026-10-10 16:30:00.0', N'2026-10-10 19:00:00.0', 21, N'SCHEDULED', NULL, N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (3, 3, 6, 6, 7, N'2026-10-11 07:30:00.0', N'2026-10-11 12:30:00.0', 24, N'SCHEDULED', NULL, N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (4, 4, 2, 4, 8, N'2026-10-11 09:00:00.0', N'2026-10-11 12:00:00.0', 11, N'SCHEDULED', NULL, N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (5, 5, 4, 5, 7, N'2026-10-12 10:00:00.0', N'2026-10-12 13:30:00.0', 26, N'SCHEDULED', NULL, N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (6, 6, 5, 6, 8, N'2026-10-12 06:45:00.0', N'2026-10-12 10:45:00.0', 10, N'SCHEDULED', NULL, N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (7, 2, 2, 4, 6, N'2026-10-19 16:29:00.0', N'2026-10-19 20:29:00.0', 14, N'CANCELLED', N'Automated test cancellation', N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (8, 8, 3, 5, 8, N'2026-10-13 17:30:00.0', N'2026-10-13 21:00:00.0', 14, N'SCHEDULED', NULL, N'2026-10-03 04:02:53.9201706');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[tour_schedules] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at]) VALUES (11, 2, 2, 4, 6, N'2026-10-18 16:29:00.0', N'2026-10-18 19:29:00.0', 16, N'SCHEDULED', NULL, N'2026-10-03 16:29:28.2133333');
END
SET IDENTITY_INSERT [dbo].[tour_schedules] OFF;
GO

-- ====================================================================
-- TABLE: promotions
-- ====================================================================
SET IDENTITY_INSERT [dbo].[promotions] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (1, N'Early Whale Watchers Discount', N'WHALE2026', N'PERCENTAGE', 15.00, 150.00, 50.00, 100, 12, N'2026-09-01', N'2026-12-31', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (2, N'Early Bird Safari Special', N'EARLYBIRD', N'FIXED_AMOUNT', 3500.00, 20000.00, 3500.00, 50, 2, N'2026-06-01', N'2026-12-31', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (3, N'Monsoon Coastal Voyage Discount', N'MONSOON20', N'PERCENTAGE', 20.00, 25000.00, 15000.00, 30, 1, N'2026-05-01', N'2026-10-31', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (4, N'Luxury Yacht Group Deal', N'LUXYACHT', N'FIXED_AMOUNT', 8000.00, 50000.00, 8000.00, 20, 1, N'2026-01-01', N'2026-12-31', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (5, N'Family Safari Holiday Package', N'FAMILYFUN', N'PERCENTAGE', 12.00, 30000.00, 6000.00, 40, 1, N'2026-07-01', N'2026-12-31', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (6, N'Snorkelers Paradise East Coast', N'REEFEXPLORE', N'FIXED_AMOUNT', 4000.00, 28000.00, 4000.00, 60, 1, N'2026-05-01', N'2026-11-30', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (7, N'Romantic Dine-at-Sea Couples Promo', N'ROMANCE50', N'FIXED_AMOUNT', 5000.00, 60000.00, 5000.00, 25, 0, N'2026-01-01', N'2026-12-31', 1, N'2026-10-03 04:02:53.9291686');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promotions] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at]) VALUES (8, N'Local Sri Lankan Resident Privilege', N'LANKA25', N'PERCENTAGE', 25.00, 80.00, 45.00, 200, 45, N'2026-01-01', N'2026-12-31', 1, N'2026-10-03 04:02:53.9291686');
END
SET IDENTITY_INSERT [dbo].[promotions] OFF;
GO

-- ====================================================================
-- TABLE: reservations
-- ====================================================================
SET IDENTITY_INSERT [dbo].[reservations] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (1, N'SLC-2026-0901', 1, 11, 3, 49000.00, 7350.00, 41650.00, 1, N'CONFIRMED', N'Window seats and life jackets for child requested.', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (2, N'SLC-2026-0902', 1, 12, 2, 37000.00, 3500.00, 33500.00, NULL, N'CONFIRMED', N'Celebrating anniversary; requested special dessert', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (3, N'SLC-2026-0903', 2, 13, 2, 58000.00, 4000.00, 54000.00, 2, N'CONFIRMED', N'Need snorkeling gear size 38 and 42', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (4, N'SLC-2026-0904', 3, 14, 1, 130000.00, 8000.00, 122000.00, NULL, N'CONFIRMED', N'Honeymoon couple, romantic table arrangement', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (5, N'SLC-2026-0905', 4, 15, 4, 98000.00, 6000.00, 92000.00, 4, N'CONFIRMED', N'Family with two young teenagers, binoculars requested', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (6, N'SLC-2026-0906', 5, 16, 2, 32000.00, 4800.00, 27200.00, 5, N'PENDING', N'Interested in wildlife photography', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (7, N'SLC-2026-0907', 7, 17, 1, 26000.00, 3500.00, 22500.00, NULL, N'CHECKED_IN', N'Front-row observation deck seat', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (8, N'SLC-2026-0908', 8, 11, 2, 44000.00, 8800.00, 35200.00, 6, N'CONFIRMED', N'German translation requested if guide is available', N'2026-10-03 04:02:53.9433156');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (11, N'SLC-2026-9139', 2, 10, 2, 37000.00, 0.00, 37000.00, NULL, N'CONFIRMED', N'Celebrating wedding anniversary', N'2026-10-03 16:26:10.18');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 12)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (12, N'SLC-2026-9257', 2, 1, 2, 37000.00, 0.00, 37000.00, NULL, N'CONFIRMED', N'Celebrating wedding anniversary', N'2026-10-03 16:29:51.16');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[reservations] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at]) VALUES (15, N'SLC-2026-8577', 2, 20, 2, 37000.00, 0.00, 37000.00, NULL, N'CONFIRMED', N'Celebrating wedding anniversary', N'2026-10-03 18:19:49.8033333');
END
SET IDENTITY_INSERT [dbo].[reservations] OFF;
GO

-- ====================================================================
-- TABLE: passengers
-- ====================================================================
SET IDENTITY_INSERT [dbo].[passengers] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (3, 2, N'Elena Rostova', N'RUS-71029384', 31, N'FEMALE', N'Russian', N'+79031234567');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (4, 2, N'Dmitri Rostov', N'RUS-71029385', 34, N'MALE', N'Russian', N'+79031234567');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (5, 3, N'Sarah Jenkins', N'USA-55102948', 29, N'FEMALE', N'American', N'+12025550143');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (6, 3, N'Mark Davis', N'USA-55102949', 32, N'MALE', N'American', N'+12025550143');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (7, 4, N'Hans Schmidt', N'DEU-C1092837', 42, N'MALE', N'German', N'+491512345678');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (8, 5, N'Nadeesha Kumari', N'918237465V', 35, N'FEMALE', N'Sri Lankan', N'+94714567890');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 9)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (9, 5, N'Pradeep Jayasinghe', N'881293847V', 38, N'MALE', N'Sri Lankan', N'+94714567890');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (10, 5, N'Kavindu Jayasinghe', N'CH-2015-9921', 11, N'MALE', N'Sri Lankan', N'+94714567890');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (11, 5, N'Dinithi Jayasinghe', N'CH-2018-4412', 8, N'FEMALE', N'Sri Lankan', N'+94714567890');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 12)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (12, 6, N'Kenji Sato', N'JPN-TZ881923', 45, N'MALE', N'Japanese', N'+819012345678');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 13)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (13, 6, N'Aoi Sato', N'JPN-TZ881924', 42, N'FEMALE', N'Japanese', N'+819012345678');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 14)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (14, 7, N'Liam O''Connor', N'IRL-P9012847', 27, N'MALE', N'Irish', N'+353871234567');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (15, 8, N'Johnathan Miller', N'GBR-94827104', 38, N'MALE', N'British', N'+447911123456');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 16)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (16, 8, N'Claire Miller', N'GBR-94827105', 36, N'FEMALE', N'British', N'+447911123456');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 25)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (25, 11, N'Nimal Jayawardena 603', N'198512345678', 40, N'MALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 26)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (26, 11, N'Kusum Jayawardena', N'198812345678', 37, N'FEMALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 27)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (27, 12, N'Nimal Jayawardena 636', N'198512345678', 40, N'MALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 28)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (28, 12, N'Kusum Jayawardena', N'198812345678', 37, N'FEMALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 37)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (37, 15, N'Nimal Jayawardena 588', N'198512345678', 40, N'MALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 38)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (38, 15, N'Kusum Jayawardena', N'198812345678', 37, N'FEMALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 40)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (40, 1, N'Dr. Rohan Silva', N'198812345678', 38, N'MALE', N'Sri Lankan', N'+94771112233');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 41)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (41, 1, N'Mrs. Chamari Silva', N'199098765432', 36, N'FEMALE', N'Sri Lankan', N'+94771112234');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[passengers] WHERE id = 42)
BEGIN
    INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES (42, 1, N'Master Kaveen Silva', N'201512345678', 11, N'MALE', N'Sri Lankan', N'+94771112233');
END
SET IDENTITY_INSERT [dbo].[passengers] OFF;
GO

-- ====================================================================
-- TABLE: promo_redemptions
-- ====================================================================
SET IDENTITY_INSERT [dbo].[promo_redemptions] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[promo_redemptions] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[promo_redemptions] ([id], [promo_id], [customer_id], [reservation_id], [discount_applied], [redeemed_at]) VALUES (1, 1, 11, 1, 28.50, N'2026-10-03 04:02:53.9642155');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promo_redemptions] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[promo_redemptions] ([id], [promo_id], [customer_id], [reservation_id], [discount_applied], [redeemed_at]) VALUES (2, 2, 13, 3, 3500.00, N'2026-10-03 04:02:53.9642155');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promo_redemptions] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[promo_redemptions] ([id], [promo_id], [customer_id], [reservation_id], [discount_applied], [redeemed_at]) VALUES (3, 4, 15, 5, 4000.00, N'2026-10-03 04:02:53.9642155');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promo_redemptions] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[promo_redemptions] ([id], [promo_id], [customer_id], [reservation_id], [discount_applied], [redeemed_at]) VALUES (4, 5, 16, 6, 8000.00, N'2026-10-03 04:02:53.9642155');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[promo_redemptions] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[promo_redemptions] ([id], [promo_id], [customer_id], [reservation_id], [discount_applied], [redeemed_at]) VALUES (5, 6, 11, 8, 6000.00, N'2026-10-03 04:02:53.9642155');
END
SET IDENTITY_INSERT [dbo].[promo_redemptions] OFF;
GO

-- ====================================================================
-- TABLE: maintenance_records
-- ====================================================================
SET IDENTITY_INSERT [dbo].[maintenance_records] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (1, 1, N'ROUTINE_SERVICE', N'500-hour engine service, oil filter replacement, fuel line purge', N'2026-09-10', N'2026-09-11', 85000.00, N'Southern Marine Engineering Ltd', N'COMPLETED', N'2026-10-03 04:02:53.9765774');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (2, 2, N'SAFETY_INSPECTION', N'Annual Merchant Shipping Secretariat survey and life raft recertification', N'2026-08-20', N'2026-08-20', 45000.00, N'Lanka Maritime Safety Bureau', N'COMPLETED', N'2026-10-03 04:02:53.9765774');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (3, 3, N'HULL_CLEANING', N'Antifouling hull scrape and repaint, rudder bearing inspection', N'2026-09-01', N'2026-09-04', 125000.00, N'Galle Dockyard & Engineering', N'COMPLETED', N'2026-10-03 04:02:53.9765774');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (4, 7, N'ENGINE_OVERHAUL', N'Port side MAN diesel injector calibration, turbocharger rebuild, and sea water cooling pump replacement.', N'2026-10-01', NULL, 350000.00, N'Colombo Marine Tech Services', N'IN_PROGRESS', N'2026-10-03 04:02:53.9765774');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (6, 5, N'ROUTINE_SERVICE', N'Pre-season offshore survey, fire suppression testing, EPIRB hydrostatic release test', N'2026-09-25', N'2026-09-26', 55000.00, N'Negombo Outboard Specialists', N'COMPLETED', N'2026-10-03 04:02:53.9765774');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (7, 6, N'SAFETY_INSPECTION', N'100-hour outboard engine gear oil change, spark plug replacement, fuel filter check', N'2026-09-18', N'2026-09-19', 32000.00, N'Trinco Marine Safety Supplies', N'COMPLETED', N'2026-10-03 04:02:53.9765774');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (11, 1, N'HULL_CLEANING', N'Auto Test Hull Cleaning 9680', N'2026-10-03', NULL, 35000.00, N'Ceylon Marine Dockyard', N'SCHEDULED', N'2026-10-03 16:29:59.6333333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[maintenance_records] WHERE id = 14)
BEGIN
    INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at]) VALUES (14, 1, N'HULL_CLEANING', N'Auto Test Hull Cleaning 7167', N'2026-10-03', NULL, 35000.00, N'Ceylon Marine Dockyard', N'SCHEDULED', N'2026-10-03 18:19:57.7633333');
END
SET IDENTITY_INSERT [dbo].[maintenance_records] OFF;
GO

-- ====================================================================
-- TABLE: service_reminders
-- ====================================================================
SET IDENTITY_INSERT [dbo].[service_reminders] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (1, 1, N'Diesel Engine Oil & Filter Change', 90, N'2026-09-10', N'2026-12-10', 0, N'Use genuine Yanmar 15W-40 marine diesel oil and twin micro-filters.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (2, 2, N'Outboard Impeller & Water Pump Inspection', 120, N'2026-07-15', N'2026-11-15', 0, N'Check cooling water stream pressure and rubber vane flexibility.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (3, 3, N'Life Raft Hydrostatic Release Unit Check', 365, N'2025-11-01', N'2026-11-01', 0, N'Mandatory annual maritime inspection requirement.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (4, 4, N'Bilge Pumps & Float Switches Test', 30, N'2026-09-15', N'2026-10-15', 0, N'Test all 4 automatic submersible bilge pumps with float override.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (5, 5, N'Fuel Filter Water Separator Drain', 30, N'2026-09-20', N'2026-10-20', 0, N'Drain visual bowl and check for condensation water contamination.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (6, 6, N'Steering Hydraulic Fluid Flush', 180, N'2026-05-10', N'2026-11-10', 0, N'Bleed SeaStar dual helm hydraulic line and replenish ISO 15 oil.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (7, 7, N'Anode Cathodic Protection Replacement', 90, N'2026-07-01', N'2026-10-01', 1, N'Zinc sacrificial anodes are over 60% eroded. Overdue for renewal.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (8, 8, N'Emergency First Aid & Oxygen Kit Resupply', 90, N'2026-08-01', N'2026-11-01', 0, N'Check medical expiration dates on sterile bandages and burn gels.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 9)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (9, 1, N'Automated Test Bi-Monthly Engine Service', 60, N'2026-10-03', N'2026-12-02', 0, N'Inspect spark plugs and impellers');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[service_reminders] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES (10, 1, N'Automated Test Bi-Monthly Engine Service', 60, N'2026-10-03', N'2026-12-02', 0, N'Inspect spark plugs and impellers');
END
SET IDENTITY_INSERT [dbo].[service_reminders] OFF;
GO

-- ====================================================================
-- TABLE: safety_check_logs
-- ====================================================================
SET IDENTITY_INSERT [dbo].[safety_check_logs] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (1, 1, 1, 4, 1, 45, 95, N'Calm seas, wave height 0.8m, wind 6 knots SSW, visibility 12nm. Perfect whale watching weather.', 1, 1, N'Capt. Sunil Perera', N'READY_FOR_DEPARTURE', N'All SOLAS equipment checked. Passenger manifest reconciled. Departure approved.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (2, 2, 3, 5, 1, 28, 100, N'Fair breeze, gentle swell 0.6m, sunset skies clear. Excellent cruising condition.', 1, 1, N'Capt. Ranjith Silva', N'READY_FOR_DEPARTURE', N'Catering and guest safety vests verified. Sound system and navigation lights tested OK.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (3, 3, 6, 6, 1, 35, 90, N'East coast clear, water clarity > 15m, light chop 0.5m. Reef conditions pristine.', 1, 1, N'Capt. Nimal Rajapakse', N'READY_FOR_DEPARTURE', N'Snorkel gear sanitized. Dive briefing and marine park preservation rules reiterated.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (4, 4, 2, 4, 1, 18, 85, N'Estuary waters calm, river flow steady, temperature 29C.', 1, 1, N'Capt. Sunil Perera', N'READY_FOR_DEPARTURE', N'Child life vests inspected and properly fitted before gangway boarding.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (5, 5, 4, 5, 1, 40, 95, N'Lagoon water smooth, sun bright, wind 8 knots from East.', 1, 1, N'Capt. Ranjith Silva', N'READY_FOR_DEPARTURE', N'Stand-up paddle boards and tow ropes verified secured to catamaran aft stanchions.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (6, 6, 5, 6, 1, 15, 100, N'Offshore swell 1.2m, wind 10 knots North, excellent visibility.', 1, 1, N'Capt. Nimal Rajapakse', N'READY_FOR_DEPARTURE', N'Twin high-performance engines warm-up complete. Marine VHF radio link to naval watch operational.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (7, 7, 8, 4, 1, 16, 90, N'Shallow lagoon waters clear, negligible tide variance.', 1, 1, N'Capt. Sunil Perera', N'READY_FOR_DEPARTURE', N'Completed voyage safely with zero incidents. Marine turtle sighting confirmed.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (8, 8, 3, 5, 1, 25, 95, N'Evening breeze mild, coastal lights clear, swell under 0.7m.', 1, 1, N'Capt. Ranjith Silva', N'READY_FOR_DEPARTURE', N'Chef galley fire extinguisher inspected. Emergency evacuation route explained to guests.', N'2026-10-03 04:02:53.999255');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 9)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (9, 2, 1, 4, 1, 30, 100, N'Calm seas, swell 0.6m, visibility 15nm, clear skies', 1, 1, N'Capt. Shantha Perera', N'VOIDED', N'Topped up to 100% fuel. Ready to cast off. [VOIDED: Test schedule rescheduled]', N'2026-10-03 16:23:33.455');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (10, 2, 1, 4, 1, 30, 100, N'Calm seas, swell 0.6m, visibility 15nm, clear skies', 1, 1, N'Capt. Shantha Perera', N'VOIDED', N'Topped up to 100% fuel. Ready to cast off. [VOIDED: Test schedule rescheduled]', N'2026-10-03 16:24:53.543');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (11, 2, 1, 4, 1, 28, 100, N'Calm sea 0.3m swell test 4119 [UPDATED OBSERVATION]', 1, 1, N'Capt. S. Perera', N'VOIDED', N'Amended briefing notes [VOIDED: Automated test voiding]', N'2026-10-03 16:30:12.269');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 12)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (12, 2, 1, 4, 1, 30, 100, N'Calm seas, swell 0.6m, visibility 15nm, clear skies', 1, 1, N'Capt. Shantha Perera', N'VOIDED', N'Topped up to 100% fuel. Ready to cast off. [VOIDED: Test schedule rescheduled]', N'2026-10-03 18:17:00.838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 13)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (13, 2, 1, 4, 1, 30, 100, N'Calm seas, swell 0.6m, visibility 15nm, clear skies', 1, 1, N'Capt. Shantha Perera', N'VOIDED', N'Topped up to 100% fuel. Ready to cast off. [VOIDED: Test schedule rescheduled]', N'2026-10-03 18:18:49.84');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 14)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (14, 2, 1, 4, 1, 28, 100, N'Calm sea 0.3m swell test 5556 [UPDATED OBSERVATION]', 1, 1, N'Capt. S. Perera', N'VOIDED', N'Amended briefing notes [VOIDED: Automated test voiding]', N'2026-10-03 18:20:09.789');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[safety_check_logs] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES (15, 2, 1, 4, 1, 30, 100, N'Calm seas, swell 0.6m, visibility 15nm, clear skies', 1, 1, N'Capt. Shantha Perera', N'VOIDED', N'Topped up to 100% fuel. Ready to cast off. [VOIDED: Test schedule rescheduled]', N'2026-10-03 18:22:21.329');
END
SET IDENTITY_INSERT [dbo].[safety_check_logs] OFF;
GO

-- ====================================================================
-- TABLE: emergency_notices
-- ====================================================================
SET IDENTITY_INSERT [dbo].[emergency_notices] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (1, N'Monsoon Surge High Swell Advisory', N'HIGH_SWELL', N'HIGH', 1, 1, N'SOUTH_COAST', N'Department of Meteorology warns of sudden 3.0m to 3.5m swells along Southern offshore waters between Dondra and Mirissa. All captains must maintain minimum 5nm distance from outer shallows.', N'PORTAL,SMS,EMAIL', N'ACTIVE', 1, N'2026-10-03 04:02:54.0137855', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (2, N'Navigational Buoy Displacement - Galle Fairway', N'SAFETY_ADVISORY', N'MEDIUM', 2, NULL, N'SOUTH_COAST', N'Harbor Master reports fairway marker buoy #3 drifted 150 meters northeast following storm surge. Navigate with extreme visual caution when entering harbor channel.', N'PORTAL,SMS', N'ACTIVE', 3, N'2026-10-03 04:02:54.0137855', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (3, N'Pigeon Island Marine Park Underwater Visibility Notice', N'SAFETY_ADVISORY', N'LOW', 3, NULL, N'EAST_COAST', N'Runoff from coastal streams reduced underwater visibility to 6m. Snorkel groups advised to remain close to certified guides and stay inside inner reef lagoon.', N'PORTAL', N'ACTIVE', 1, N'2026-10-03 04:02:54.0137855', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (4, N'Kalpitiya Squall Warning & Precautionary Return', N'BAD_WEATHER', N'HIGH', 6, 5, N'WEST_COAST', N'Sudden tropical squall detected on Doppler radar 14nm offshore. Wind gusts reaching 32 knots. All small craft instructed to return to lagoon sanctuary immediately.', N'PORTAL,SMS,EMAIL', N'RESOLVED', 3, N'2026-09-28 04:02:54.0137855', N'2026-09-29 04:02:54.0137855');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (5, N'Southern Star Scheduled Engine Overhaul Downtime', N'TECHNICAL_DELAY', N'LOW', 8, 7, N'SOUTH_COAST', N'Southern Star Yacht is undergoing scheduled turbocharger replacement in dockyard. Charters temporarily reassigned to Serendib Odyssey.', N'PORTAL', N'ACTIVE', 2, N'2026-10-03 04:02:54.0137855', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (6, N'Annual Coastal Life Safety System Drill', N'SAFETY_ADVISORY', N'MEDIUM', NULL, NULL, N'ALL_REGIONS', N'All captains, tour guides, and shore operations staff are mandated to participate in the joint maritime rescue drill with Sri Lanka Coast Guard this Saturday at 08:00 AM.', N'PORTAL,SMS,EMAIL', N'ACTIVE', 1, N'2026-10-03 04:02:54.0137855', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (7, N'Updated High Swell Warning', N'BAD_WEATHER', N'CRITICAL', NULL, NULL, N'SOUTH_COAST', N'Rough sea conditions anticipated between 10:00 and 14:00.', N'SMS,WEB_BANNER', N'ACTIVE', 1, N'2026-10-03 16:23:09.7033333', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (8, N'Approaching Squall Line - Southern Coast', N'BAD_WEATHER', N'CRITICAL', NULL, NULL, N'SOUTH_COAST', N'Squall line intensifies to gale force 8 winds (40 knots). MANDATORY RETURN TO PORT: All vessels return immediately.', N'PORTAL,SMS,EMAIL', N'ACTIVE', 1, N'2026-10-03 16:23:32.66', NULL);
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (10, N'Approaching Squall Line - Southern Coast', N'BAD_WEATHER', N'CRITICAL', NULL, NULL, N'SOUTH_COAST', N'Squall line intensifies to gale force 8 winds (40 knots). MANDATORY RETURN TO PORT: All vessels return immediately.', N'PORTAL,SMS,EMAIL', N'RESOLVED', 1, N'2026-10-03 16:24:52.69', N'2026-10-03 16:24:53.32');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 13)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (13, N'Approaching Squall Line - Southern Coast', N'BAD_WEATHER', N'CRITICAL', NULL, NULL, N'SOUTH_COAST', N'Squall line intensifies to gale force 8 winds (40 knots). MANDATORY RETURN TO PORT: All vessels return immediately.', N'PORTAL,SMS,EMAIL', N'RESOLVED', 1, N'2026-10-03 18:16:59.95', N'2026-10-03 18:17:00.6166667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (15, N'Approaching Squall Line - Southern Coast', N'BAD_WEATHER', N'CRITICAL', NULL, NULL, N'SOUTH_COAST', N'Squall line intensifies to gale force 8 winds (40 knots). MANDATORY RETURN TO PORT: All vessels return immediately.', N'PORTAL,SMS,EMAIL', N'RESOLVED', 1, N'2026-10-03 18:18:49.0133333', N'2026-10-03 18:18:49.6266667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_notices] WHERE id = 18)
BEGIN
    INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at]) VALUES (18, N'Approaching Squall Line - Southern Coast', N'BAD_WEATHER', N'CRITICAL', NULL, NULL, N'SOUTH_COAST', N'Squall line intensifies to gale force 8 winds (40 knots). MANDATORY RETURN TO PORT: All vessels return immediately.', N'PORTAL,SMS,EMAIL', N'RESOLVED', 1, N'2026-10-03 18:22:20.4466667', N'2026-10-03 18:22:21.0966667');
END
SET IDENTITY_INSERT [dbo].[emergency_notices] OFF;
GO

-- ====================================================================
-- TABLE: emergency_acknowledgments
-- ====================================================================
SET IDENTITY_INSERT [dbo].[emergency_acknowledgments] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_acknowledgments] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes]) VALUES (1, 1, 4, N'2026-10-03 04:02:54.0207861', N'Capt. Sunil Perera acknowledged. Revised course plotted 6.5nm offshore.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_acknowledgments] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes]) VALUES (2, 1, 5, N'2026-10-03 04:02:54.0207861', N'Capt. Ranjith Silva acknowledged. Life raft check double-verified.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_acknowledgments] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes]) VALUES (3, 2, 5, N'2026-10-03 04:02:54.0207861', N'Acknowledged. GPS waypoint offset entered into navigation console.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_acknowledgments] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes]) VALUES (4, 3, 6, N'2026-10-03 04:02:54.0207861', N'Briefed snorkel dive leaders on inner reef boundary restriction.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_acknowledgments] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes]) VALUES (5, 4, 6, N'2026-09-28 04:02:54.0207861', N'Craft safely docked at Kalpitiya marina before wind picked up.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[emergency_acknowledgments] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes]) VALUES (6, 6, 4, N'2026-10-03 04:02:54.0207861', N'Capt. Sunil confirmed crew attendance for Saturday maritime safety drill.');
END
SET IDENTITY_INSERT [dbo].[emergency_acknowledgments] OFF;
GO

-- ====================================================================
-- TABLE: login_details
-- ====================================================================
SET IDENTITY_INSERT [dbo].[login_details] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (1, 1, N'Kasun Jayawardena', N'admin@boatsafari.lk', N'ADMIN', N'192.168.1.10', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/129.0.0.0 Safari/537.36', N'Admin portal session initiated with two-factor authentication.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (2, 3, N'Chaminda Fernando', N'chaminda.officer@boatsafari.lk', N'OFFICER', N'192.168.1.25', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/131.0', N'Harbor dispatch console accessed.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (3, 4, N'Capt. Sunil Perera', N'sunil.captain@boatsafari.lk', N'CAPTAIN', N'124.43.12.88', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (iPhone; CPU iPhone OS 17_6 like Mac OS X) AppleWebKit/605.1.15', N'Mobile captain safety checklist portal logged in.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (4, 5, N'Capt. Ranjith Silva', N'ranjith.captain@boatsafari.lk', N'CAPTAIN', N'124.43.14.92', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (iPad; CPU OS 17_5 like Mac OS X) AppleWebKit/605.1.15', N'Vessel safety checklist logged.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (5, 7, N'Roshan Wickramasinghe', N'roshan.guide@boatsafari.lk', N'GUIDE', N'112.134.88.14', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Linux; Android 14; SM-S928B) Chrome/128.0.0.0 Mobile', N'Guide passenger manifest check.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (6, 11, N'Johnathan Miller', N'john.miller@gmail.com', N'CUSTOMER', N'86.154.21.90', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15', N'Customer booking confirmation viewed.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (7, 12, N'Elena Rostova', N'elena.rostova@yandex.com', N'CUSTOMER', N'95.173.136.22', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/129.0.0.0', N'Browsing Mirissa whale watching schedules.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (8, 13, N'Sarah Jenkins', N'sarah.jenkins@outlook.com', N'CUSTOMER', N'68.183.45.102', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (iPhone; CPU iPhone OS 17_6) AppleWebKit/605.1.15', N'Sunset wine cruise payment processed.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 9)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (9, 9, N'Dinesh Mendis', N'dinesh.owner@southernmarina.lk', N'OWNER', N'124.43.99.10', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/129.0.0.0', N'Vessel revenue and maintenance analytics accessed.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (10, 2, N'Dilani Perera', N'dilani.admin@boatsafari.lk', N'ADMIN', N'192.168.1.15', N'SUCCESS', N'2026-10-03 04:02:54.0319897', N'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_6) Chrome/129.0.0.0', N'Promotion code campaign WHALE2026 configured.');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (11, NULL, N'Unknown Guest', N'admin@sail-safari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 16:25:58.563', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 12)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (12, 18, N'Kasun Rajapaksha', N'guest.48654@example.com', N'CUSTOMER', N'0:0:0:0:0:0:0:1', N'SUCCESS - NEW ACCOUNT', N'2026-10-03 16:26:16.331', N'Browser / Web Client', N'CUSTOMER_REGISTERED - SUCCESS - NEW ACCOUNT');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 13)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (13, 18, N'Kasun Rajapaksha', N'guest.48654@example.com', N'CUSTOMER', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 16:26:22.712', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 14)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (14, NULL, N'Unknown Guest', N'admin@sail-safari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 16:26:39.216', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (15, NULL, N'Unknown Guest', N'admin@sail-safari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 16:26:47.099', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 16)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (16, NULL, N'Unknown Guest', N'admin@boatsafari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 16:27:31.269', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 17)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (17, 1, N'Kasun Jayawardena', N'admin@boatsafari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 16:28:47.534', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 18)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (18, 1, N'Kasun Jayawardena', N'admin@boatsafari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 16:29:00.695', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 19)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (19, 19, N'Kasun Rajapaksha', N'guest.86161@example.com', N'CUSTOMER', N'0:0:0:0:0:0:0:1', N'SUCCESS - NEW ACCOUNT', N'2026-10-03 16:30:59.121', N'Browser / Web Client', N'CUSTOMER_REGISTERED - SUCCESS - NEW ACCOUNT');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 20)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (20, 19, N'Kasun Rajapaksha', N'guest.86161@example.com', N'CUSTOMER', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 16:31:01.968', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 21)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (21, NULL, N'Unknown Guest', N'admin@sail-safari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 17:02:49.569', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 22)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (22, NULL, N'Unknown Guest', N'admin@sail-safari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 17:02:51.764', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 23)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (23, NULL, N'Unknown Guest', N'admin@sail-safari.lk', N'GUEST', N'0:0:0:0:0:0:0:1', N'FAILED - INVALID CREDENTIALS', N'2026-10-03 17:03:18.713', N'Browser / Web Client', N'LOGIN_FAILED - FAILED - INVALID CREDENTIALS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 24)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (24, 20, N'System Administrator', N'admin@sail-safari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 17:05:41.163', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 25)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (25, 20, N'System Administrator', N'admin@sail-safari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 17:07:34.489', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 26)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (26, 20, N'System Administrator', N'admin@sail-safari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 17:07:36.374', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 27)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (27, 20, N'System Administrator', N'admin@sail-safari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 18:19:04.182', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 28)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (28, 30, N'Kasun Rajapaksha', N'guest.44079@example.com', N'CUSTOMER', N'0:0:0:0:0:0:0:1', N'SUCCESS - NEW ACCOUNT', N'2026-10-03 18:20:50.891', N'Browser / Web Client', N'CUSTOMER_REGISTERED - SUCCESS - NEW ACCOUNT');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 29)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (29, 30, N'Kasun Rajapaksha', N'guest.44079@example.com', N'CUSTOMER', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 18:20:53.845', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[login_details] WHERE id = 30)
BEGIN
    INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details]) VALUES (30, 20, N'System Administrator', N'admin@sail-safari.lk', N'ADMIN', N'0:0:0:0:0:0:0:1', N'SUCCESS', N'2026-10-03 18:22:32.816', N'Browser / Web Client', N'LOGIN_SUCCESS - SUCCESS');
END
SET IDENTITY_INSERT [dbo].[login_details] OFF;
GO

-- ====================================================================
-- TABLE: activity_logs
-- ====================================================================
SET IDENTITY_INSERT [dbo].[activity_logs] ON;
GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 1)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (1, 1, N'USER_CREATE', N'USER_MANAGEMENT', N'Created new guide user account for Roshan Wickramasinghe (ID: 7).', N'192.168.1.10', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 2)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (2, 1, N'SCHEDULE_CREATE', N'TOUR_SCHEDULING', N'Scheduled Mirissa Premier Whale Safari on Ocean Monarch for 2026-10-10.', N'192.168.1.10', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 3)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (3, 4, N'SAFETY_CHECK_SUBMIT', N'SAFETY_MODULE', N'Submitted departure safety inspection log for Schedule #1 on vessel Ocean Monarch with 45 life vests verified.', N'124.43.12.88', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 4)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (4, 11, N'RESERVATION_CREATE', N'BOOKING_ENGINE', N'Customer completed online reservation BK-2026-1001 for 2 passengers with promo WHALE2026.', N'86.154.21.90', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 5)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (5, 3, N'EMERGENCY_BROADCAST', N'EMERGENCY_CENTER', N'Issued HIGH severity advisory #1 for 3.5m southern swell conditions to all active captains.', N'192.168.1.25', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 6)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (6, 4, N'EMERGENCY_ACKNOWLEDGE', N'EMERGENCY_CENTER', N'Captain Sunil Perera acknowledged emergency notice #1.', N'124.43.12.88', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 7)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (7, 2, N'PROMOTION_CREATE', N'MARKETING', N'Launched new seasonal discount code SUMMERSEA offering 25% off.', N'192.168.1.15', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 8)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (8, 9, N'MAINTENANCE_LOG', N'FLEET_MANAGEMENT', N'Recorded completion of 200-hour routine service on Ocean Monarch by Southern Marine Engineering.', N'124.43.99.10', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 9)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (9, 3, N'STATUS_UPDATE', N'FLEET_MANAGEMENT', N'Updated Southern Star Yacht status to UNDER_MAINTENANCE for turbocharger overhaul.', N'192.168.1.25', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 10)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (10, 1, N'SYSTEM_BACKUP', N'SYSTEM_SETTINGS', N'Manual full database backup executed prior to peak safari season launch.', N'192.168.1.10', N'2026-10-03 04:02:54.0410838');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 11)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (11, 1, N'RESERVATION_CANCELLED', N'RESERVATIONS', N'Cancelled booking RES-TEST-1791024794799', N'127.0.0.1', N'2026-10-03 16:23:16.81');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 12)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (12, 11, N'RESERVATION_UPDATED', N'RESERVATIONS', N'Updated booking BK-2026-1001 details before departure.', N'127.0.0.1', N'2026-10-03 16:23:30.3066667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 13)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (13, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 16:23:34.0433333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 14)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (14, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #9 re-verified and updated by Captain Capt. Shantha Perera', N'127.0.0.1', N'2026-10-03 16:23:34.6533333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 15)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (15, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #9 marked as VOIDED. Reason: Test schedule rescheduled', N'127.0.0.1', N'2026-10-03 16:23:35.4566667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 16)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (16, 1, N'RESERVATION_CANCELLED', N'RESERVATIONS', N'Cancelled booking RES-TEST-1791024872086', N'127.0.0.1', N'2026-10-03 16:24:34.23');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 17)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (17, 11, N'RESERVATION_UPDATED', N'RESERVATIONS', N'Updated booking BK-2026-1001 details before departure.', N'127.0.0.1', N'2026-10-03 16:24:51.4066667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 18)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (18, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 16:24:54.1933333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 19)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (19, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #10 re-verified and updated by Captain Capt. Shantha Perera', N'127.0.0.1', N'2026-10-03 16:24:56.2933333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 20)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (20, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #10 marked as VOIDED. Reason: Test schedule rescheduled', N'127.0.0.1', N'2026-10-03 16:24:57.1233333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 21)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (21, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@sail-safari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:25:50.73');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 22)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (22, 10, N'RESERVATION_CREATED', N'RESERVATIONS', N'Created booking SLC-2026-9139 for 2 guests.', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:26:11.06');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 23)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (23, 18, N'CUSTOMER_REGISTERED', N'AUTH', N'New tourist registered: guest.48654@example.com', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:26:16.1266667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 24)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (24, 18, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:26:22.51');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 25)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (25, 18, N'PROFILE_UPDATED', N'USER', N'User updated profile details', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:26:25.2');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 26)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (26, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@sail-safari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:26:39.02');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 27)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (27, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@sail-safari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:26:45.92');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 28)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (28, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@boatsafari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:27:31.06');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 29)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (29, 1, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:28:45.25');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 30)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (30, 1, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:29:00.4866667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 31)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (31, 1, N'RESERVATION_CREATED', N'RESERVATIONS', N'Created booking SLC-2026-9257 for 2 guests.', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:29:51.9433333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 32)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (32, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 16:30:12.9');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 33)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (33, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #11 re-verified and updated by Captain Capt. S. Perera', N'127.0.0.1', N'2026-10-03 16:30:22.94');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 34)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (34, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #11 marked as VOIDED. Reason: Automated test voiding', N'127.0.0.1', N'2026-10-03 16:30:29.34');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 35)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (35, 19, N'CUSTOMER_REGISTERED', N'AUTH', N'New tourist registered: guest.86161@example.com', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:30:56.2733333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 36)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (36, 19, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:31:01.7633333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 37)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (37, 19, N'PROFILE_UPDATED', N'USER', N'User updated profile details', N'0:0:0:0:0:0:0:1', N'2026-10-03 16:31:04.58');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 38)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (38, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@sail-safari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 17:02:49.3633333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 39)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (39, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@sail-safari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 17:02:51.26');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 40)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (40, NULL, N'LOGIN_FAILED', N'AUTH', N'Failed login attempt for: admin@sail-safari.lk', N'0:0:0:0:0:0:0:1', N'2026-10-03 17:03:18.51');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 41)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (41, 20, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 17:05:37.8866667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 42)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (42, 20, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 17:07:30.8933333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 43)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (43, 20, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 17:07:32.2466667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 44)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (44, 1, N'RESERVATION_CANCELLED', N'RESERVATIONS', N'Cancelled booking RES-TEST-1791031595107', N'127.0.0.1', N'2026-10-03 18:16:37.3966667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 45)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (45, 11, N'RESERVATION_UPDATED', N'RESERVATIONS', N'Updated booking BK-2026-1001 details before departure.', N'127.0.0.1', N'2026-10-03 18:16:55.33');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 46)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (46, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 18:17:01.5066667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 47)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (47, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #12 re-verified and updated by Captain Capt. Shantha Perera', N'127.0.0.1', N'2026-10-03 18:17:02.1666667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 48)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (48, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #12 marked as VOIDED. Reason: Test schedule rescheduled', N'127.0.0.1', N'2026-10-03 18:17:03.0533333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 49)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (49, 1, N'RESERVATION_CANCELLED', N'RESERVATIONS', N'Cancelled booking RES-TEST-1791031703900', N'127.0.0.1', N'2026-10-03 18:18:26.06');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 50)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (50, 11, N'RESERVATION_UPDATED', N'RESERVATIONS', N'Updated booking BK-2026-1001 details before departure.', N'127.0.0.1', N'2026-10-03 18:18:44.4166667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 51)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (51, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 18:18:50.4333333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 52)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (52, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #13 re-verified and updated by Captain Capt. Shantha Perera', N'127.0.0.1', N'2026-10-03 18:18:51.0466667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 53)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (53, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #13 marked as VOIDED. Reason: Test schedule rescheduled', N'127.0.0.1', N'2026-10-03 18:18:51.8633333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 54)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (54, 20, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 18:19:01.7066667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 55)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (55, 20, N'RESERVATION_CREATED', N'RESERVATIONS', N'Created booking SLC-2026-8577 for 2 guests.', N'0:0:0:0:0:0:0:1', N'2026-10-03 18:19:50.5766667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 56)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (56, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 18:20:10.44');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 57)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (57, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #14 re-verified and updated by Captain Capt. S. Perera', N'127.0.0.1', N'2026-10-03 18:20:19.9866667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 58)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (58, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #14 marked as VOIDED. Reason: Automated test voiding', N'127.0.0.1', N'2026-10-03 18:20:27.04');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 59)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (59, 30, N'CUSTOMER_REGISTERED', N'AUTH', N'New tourist registered: guest.44079@example.com', N'0:0:0:0:0:0:0:1', N'2026-10-03 18:20:50.6866667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 60)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (60, 30, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 18:20:53.64');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 61)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (61, 30, N'PROFILE_UPDATED', N'USER', N'User updated profile details', N'0:0:0:0:0:0:0:1', N'2026-10-03 18:21:00.13');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 62)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (62, 1, N'RESERVATION_CANCELLED', N'RESERVATIONS', N'Cancelled booking RES-TEST-1791031915685', N'127.0.0.1', N'2026-10-03 18:21:57.8033333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 63)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (63, 11, N'RESERVATION_UPDATED', N'RESERVATIONS', N'Updated booking SLC-2026-0901 details before departure.', N'127.0.0.1', N'2026-10-03 18:22:15.95');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 64)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (64, 4, N'PRE_TRIP_SAFETY_CHECK_SUBMITTED', N'SAFETY', N'Captain submitted ''All Clear'' pre-trip safety check for schedule #2 (Vessel #1)', N'127.0.0.1', N'2026-10-03 18:22:21.9666667');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 65)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (65, 4, N'SAFETY_CHECK_AMENDED', N'SAFETY', N'Safety check #15 re-verified and updated by Captain Capt. Shantha Perera', N'127.0.0.1', N'2026-10-03 18:22:22.5833333');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 66)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (66, 1, N'SAFETY_CHECK_VOIDED', N'SAFETY', N'Safety check log #15 marked as VOIDED. Reason: Test schedule rescheduled', N'127.0.0.1', N'2026-10-03 18:22:23.38');
END
IF NOT EXISTS (SELECT 1 FROM [dbo].[activity_logs] WHERE id = 67)
BEGIN
    INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES (67, 20, N'LOGIN_SUCCESS', N'AUTH', N'User logged in successfully', N'0:0:0:0:0:0:0:1', N'2026-10-03 18:22:32.6233333');
END
SET IDENTITY_INSERT [dbo].[activity_logs] OFF;
GO

