-- ====================================================================
-- SLIIT SE2030 - Web-Based Boat Safari Trip Management System
-- Group: Y2-S1-MLB-B8G1-09
-- Realistic Seed Data for Microsoft SQL Server (SSMS)
-- Database: boat_safari_db
-- ====================================================================

USE [boat_safari_db];
GO

-- --------------------------------------------------------------------
-- 1. USERS & STAKEHOLDERS
-- Passwords: SHA-256('admin123') = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
--            SHA-256('password123') = 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f'
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.users ON;
INSERT INTO dbo.users ([id], [full_name], [email], [password_hash], [phone], [role], [status]) VALUES
(1, N'System Administrator', N'admin@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 123 4567', N'ADMIN', N'ACTIVE'),
(2, N'Chief Reservation Officer', N'officer@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 234 5678', N'OFFICER', N'ACTIVE'),
(3, N'Safari Tour Operations Manager', N'tourmanager@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 345 6789', N'ADMIN', N'ACTIVE'),
(4, N'Capt. Shantha Perera (Master Mariner)', N'captain.perera@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 456 7890', N'CAPTAIN', N'ACTIVE'),
(5, N'Capt. Ruwan Kumara (Catamaran Skipper)', N'captain.kumara@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 567 8901', N'CAPTAIN', N'ACTIVE'),
(6, N'Kasun Fernando (Marine Naturalist Guide)', N'guide.kasun@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 678 9012', N'GUIDE', N'ACTIVE'),
(7, N'Dilshan Silva (Snorkeling Guide)', N'guide.dilshan@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 789 0123', N'GUIDE', N'ACTIVE'),
(8, N'Luxury Fleet Owner', N'owner@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 890 1234', N'OWNER', N'ACTIVE'),
(9, N'Chief Marine Engineer', N'maintenance@sail-safari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94 77 901 2345', N'ADMIN', N'ACTIVE'),
(10, N'David Miller (Tourist / Customer)', N'david.miller@gmail.com', N'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', N'+44 7911 123456', N'CUSTOMER', N'ACTIVE'),
(11, N'Sarah Jenkins (Tourist / Customer)', N'sarah.j@outlook.com', N'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', N'+61 412 345 678', N'CUSTOMER', N'ACTIVE');
SET IDENTITY_INSERT dbo.users OFF;
GO

-- --------------------------------------------------------------------
-- 2. DESTINATIONS & HARBORS
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.destinations ON;
INSERT INTO dbo.destinations ([id], [name], [region], [harbor_name], [description], [image_url]) VALUES
(1, N'Mirissa Bay & Deep Ocean Trench', N'SOUTH_COAST', N'Mirissa Fishery Harbour', N'Sri Lanka’s premier whale and dolphin watching capital. Continental shelf drops dramatically 6 miles offshore.', N'assets/img/destinations/mirissa.jpg'),
(2, N'Galle Fort Heritage Coast', N'SOUTH_COAST', N'Galle International Harbour', N'UNESCO world heritage ramparts viewed from the turquoise waters of the Indian Ocean.', N'assets/img/destinations/galle.jpg'),
(3, N'Trincomalee Natural Harbor & Pigeon Island', N'EAST_COAST', N'Trincomalee Cod Bay Pier', N'World-famous coral reefs, blacktip reef sharks, and calm blue summer sailing waters.', N'assets/img/destinations/trinco.jpg'),
(4, N'Bentota Lagoon & Sea Route', N'WEST_COAST', N'Bentota River Marina', N'Scenic blend of riverine mangrove safari and offshore open-sea cruising.', N'assets/img/destinations/bentota.jpg'),
(5, N'Passikudah Coral Bay', N'EAST_COAST', N'Passikudah Outer Pier', N'Shallow crystalline waters ideal for swimming, snorkeling, and luxury sunset champagne cruises.', N'assets/img/destinations/passikudah.jpg');
SET IDENTITY_INSERT dbo.destinations OFF;
GO

-- --------------------------------------------------------------------
-- 3. SAILING ROUTES
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.routes ON;
INSERT INTO dbo.routes ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights]) VALUES
(1, N'Mirissa Pelagic Blue Whale Track', 1, 1, 4.5, 18.5, N'Blue Whale sightings, Spinner Dolphin pods, Flying Fish, Continental Shelf'),
(2, N'Galle Lighthouse & Coral Reef Sunset', 2, 2, 3.0, 10.0, N'Colonial Fort ramparts, Rumassala cliff, Jungle Beach, Sunset horizon'),
(3, N'Trincomalee Pigeon Island Reef Expedition', 3, 3, 5.0, 22.0, N'Coral reef snorkeling, Blacktip reef sharks, Sea turtles, Swami Rock cliff'),
(4, N'Bentota Mangrove & Ocean Breeze', 4, 4, 3.5, 12.0, N'River delta, Barberyn lighthouse offshore views, Warm coastal swimming'),
(5, N'Passikudah Bay & Coral Garden', 5, 5, 4.0, 15.0, N'Calm crystalline bay, Stand-up paddleboarding, Snorkeling safari');
SET IDENTITY_INSERT dbo.routes OFF;
GO

-- --------------------------------------------------------------------
-- 4. BOAT FLEET (Vessels - Catamarans, Yachts, SpeedBoats)
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.vessels ON;
INSERT INTO dbo.vessels ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes]) VALUES
(1, N'Ocean Pearl (Ceycat 55)', N'SLC-CAT-001', N'CATAMARAN', 30, 4, N'Twin 75HP Yanmar Marine Diesel', 9.5, N'AVAILABLE', 8, N'assets/img/fleet/ocean-pearl.jpg', N'SOLAS life jackets x35, Life rafts x2 (capacity 40), EPIRB, VHF Radio, First Aid Station'),
(2, N'Sapphire Blue (Topaz 48)', N'SLC-CAT-002', N'CATAMARAN', 25, 3, N'Twin 55HP Volvo Penta', 8.5, N'AVAILABLE', 8, N'assets/img/fleet/sapphire-blue.jpg', N'SOLAS life jackets x30, Life raft x1 (capacity 30), VHF Radio, Flares, Oxygen kit'),
(3, N'Ceylon Monarch (Majesty 62)', N'SLC-YACHT-003', N'YACHT', 15, 3, N'Twin 800HP MAN Marine Diesel', 18.0, N'AVAILABLE', 8, N'assets/img/fleet/ceylon-monarch.jpg', N'SOLAS life jackets x20, Life raft x1 (capacity 20), Radar, Sonar, Fire suppression system'),
(4, N'Wave Runner (SeaRay 32)', N'SLC-SPD-004', N'SPEEDBOAT', 12, 0, N'Twin 250HP Yamaha Outboards', 28.0, N'AVAILABLE', 8, N'assets/img/fleet/wave-runner.jpg', N'SOLAS life jackets x15, VHF Radio, Emergency Bilge Pump, Coastal First Aid Kit'),
(5, N'Mirissa Sun (Lagoon 42)', N'SLC-CAT-005', N'CATAMARAN', 20, 4, N'Twin 45HP Yanmar', 8.0, N'UNDER_MAINTENANCE', 8, N'assets/img/fleet/mirissa-sun.jpg', N'Full safety gear inspected March 2026; scheduled for starboard hull repainting');
SET IDENTITY_INSERT dbo.vessels OFF;
GO

-- --------------------------------------------------------------------
-- 5. SAFARI TOURS & PACKAGES
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.tours ON;
INSERT INTO dbo.tours ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [image_url], [is_active]) VALUES
(1, N'Mirissa Blue Whale & Dolphin Luxury Catamaran Safari', N'WHALE_WATCHING', 1, N'Sail into the deep southern Indian Ocean aboard our premier 55-foot luxury catamaran. Witness magnificent Blue Whales, Brydes Whales, and playful Spinner Dolphins with fresh gourmet breakfast and marine biologist commentary on board.', 4.5, 24500.00, 25, N'Gourmet breakfast, Tropical fruit platter, Ceylon tea & coffee, Marine naturalist guide, Binoculars, Life jackets', N'Alcoholic beverages, Hotel pickup', N'assets/img/tours/mirissa-whale.jpg', 1),
(2, N'Galle Fort Heritage & Sunset Champagne Sail', N'SUNSET_SAIL', 2, N'Glaze across the historic Galle coastline as the sun dips into the crimson ocean. Enjoy chilled beverages, canapés, and breathtaking vistas of the centuries-old Dutch Fort ramparts.', 3.0, 18500.00, 20, N'Welcome mocktail, Artisanal canapés, Chilled wine or beer, Snorkeling gear, Stand-up paddleboards', N'Personal gratuities', N'assets/img/tours/galle-sunset.jpg', 1),
(3, N'Trincomalee Pigeon Island Reef Snorkeling Safari', N'SNORKELING_SAFARI', 3, N'Discover the vibrant marine biodiversity of Sri Lanka’s east coast. Snorkel with colorful tropical fish, sea turtles, and harmless blacktip reef sharks in crystal-clear waters.', 5.0, 29000.00, 22, N'Seafood BBQ lunch, Fresh coconut water, Snorkeling masks & fins, Island marine park entry fee, Guide', N'Wetsuits, Towels', N'assets/img/tours/trinco-snorkeling.jpg', 1),
(4, N'Private Starlight Dine-at-Sea Yacht Experience', N'DINE_AT_SEA', 2, N'An exclusive 5-star culinary voyage anchored under the stars in a calm secluded bay. Complete with a private chef, 4-course seafood banquet, and romantic ambient lighting.', 4.0, 65000.00, 10, N'Private 4-course seafood dinner, Premium wine pairing, Dedicated steward and captain, Soft music system', N'Spirits and cocktails', N'assets/img/tours/dine-at-sea.jpg', 1);
SET IDENTITY_INSERT dbo.tours OFF;
GO

-- --------------------------------------------------------------------
-- 6. TOUR SCHEDULES (Upcoming Departures)
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.tour_schedules ON;
INSERT INTO dbo.tour_schedules ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status]) VALUES
(1, 1, 1, 4, 6, '2026-09-20 06:30:00', '2026-09-20 11:00:00', 22, N'SCHEDULED'),
(2, 1, 1, 4, 6, '2026-09-21 06:30:00', '2026-09-21 11:00:00', 25, N'SCHEDULED'),
(3, 2, 2, 5, 7, '2026-09-20 15:30:00', '2026-09-20 18:30:00', 18, N'SCHEDULED'),
(4, 3, 2, 5, 7, '2026-09-22 08:00:00', '2026-09-22 13:00:00', 20, N'SCHEDULED'),
(5, 4, 3, 4, 6, '2026-09-22 18:00:00', '2026-09-22 22:00:00', 10, N'SCHEDULED');
SET IDENTITY_INSERT dbo.tour_schedules OFF;
GO

-- --------------------------------------------------------------------
-- 7. PROMOTIONS & DISCOUNT STRATEGIES
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.promotions ON;
INSERT INTO dbo.promotions ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active]) VALUES
(1, N'Sail Lanka Welcome Privilege', N'SAIL15', N'PERCENTAGE', 15.00, 15000.00, 10000.00, 100, 2, '2026-01-01', '2026-12-31', 1),
(2, N'Early Bird Safari Special', N'EARLYBIRD', N'FIXED_AMOUNT', 3500.00, 20000.00, 3500.00, 50, 1, '2026-06-01', '2026-12-31', 1),
(3, N'Monsoon Coastal Voyage Discount', N'MONSOON20', N'PERCENTAGE', 20.00, 25000.00, 15000.00, 30, 0, '2026-05-01', '2026-10-31', 1),
(4, N'Luxury Yacht Group Deal', N'LUXYACHT', N'FIXED_AMOUNT', 8000.00, 50000.00, 8000.00, 20, 0, '2026-01-01', '2026-12-31', 1);
SET IDENTITY_INSERT dbo.promotions OFF;
GO

-- --------------------------------------------------------------------
-- 8. SAMPLE RESERVATIONS & PASSENGERS
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.reservations ON;
INSERT INTO dbo.reservations ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes]) VALUES
(1, N'SLC-2026-0901', 1, 10, 2, 49000.00, 7350.00, 41650.00, 1, N'CONFIRMED', N'Vegetarian breakfast requested for 1 guest'),
(2, N'SLC-2026-0902', 3, 11, 2, 37000.00, 3500.00, 33500.00, 2, N'CONFIRMED', N'Celebrating anniversary; requested special dessert');
SET IDENTITY_INSERT dbo.reservations OFF;
GO

SET IDENTITY_INSERT dbo.passengers ON;
INSERT INTO dbo.passengers ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact]) VALUES
(1, 1, N'David Miller', N'GB44908123', 38, N'MALE', N'British', N'+44 7911 123456'),
(2, 1, N'Emma Miller', N'GB44908124', 35, N'FEMALE', N'British', N'+44 7911 123456'),
(3, 2, N'Sarah Jenkins', N'AU99201481', 29, N'FEMALE', N'Australian', N'+61 412 345 678'),
(4, 2, N'Liam Evans', N'AU99201482', 31, N'MALE', N'Australian', N'+61 412 345 678');
SET IDENTITY_INSERT dbo.passengers OFF;
GO

SET IDENTITY_INSERT dbo.promo_redemptions ON;
INSERT INTO dbo.promo_redemptions ([id], [promo_id], [customer_id], [reservation_id], [discount_applied]) VALUES
(1, 1, 10, 1, 7350.00),
(2, 2, 11, 2, 3500.00);
SET IDENTITY_INSERT dbo.promo_redemptions OFF;
GO

-- --------------------------------------------------------------------
-- 9. MAINTENANCE RECORDS & SERVICE REMINDERS
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.maintenance_records ON;
INSERT INTO dbo.maintenance_records ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status]) VALUES
(1, 1, N'ROUTINE_SERVICE', N'500-hour engine service, oil filter replacement, fuel line purge', '2026-08-10', '2026-08-11', 85000.00, N'Colombo Marine Dockyard Eng.', N'COMPLETED'),
(2, 2, N'SAFETY_INSPECTION', N'Annual Merchant Shipping Secretariat survey and life raft recertification', '2026-08-25', '2026-08-26', 45000.00, N'Ceylon Maritime Surveyors', N'COMPLETED'),
(3, 5, N'HULL_CLEANING', N'Antifouling hull scrape and repaint, rudder bearing inspection', '2026-09-12', NULL, 125000.00, N'Galle Fishery Harbour Slipway', N'IN_PROGRESS');
SET IDENTITY_INSERT dbo.maintenance_records OFF;
GO

SET IDENTITY_INSERT dbo.service_reminders ON;
INSERT INTO dbo.service_reminders ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes]) VALUES
(1, 1, N'Yanmar Port Engine Impeller Replacement', 120, '2026-06-01', '2026-09-29', 0, N'Inspect seawater cooling pumps'),
(2, 3, N'Majesty Yacht Generator 200hr Service', 90, '2026-05-15', '2026-08-15', 1, N'Overdue by 30 days! Urgent inspection required'),
(3, 4, N'Yamaha Outboard Gear Oil Change', 60, '2026-08-01', '2026-10-01', 0, N'Routine pre-season check');
SET IDENTITY_INSERT dbo.service_reminders OFF;
GO

SET IDENTITY_INSERT dbo.safety_check_logs ON;
INSERT INTO dbo.safety_check_logs ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at]) VALUES
(1, 1, 1, 4, 1, 35, 95, N'Calm seas, wave swell 0.8m, wind 10 knots SW, visibility 12nm', 1, 1, N'Capt. Shantha Perera (Master Mariner)', N'READY_FOR_DEPARTURE', N'All SOLAS life vests inspected, bilge pumps operational, marine radio tested on Channel 16.', GETDATE()),
(2, 3, 2, 5, 1, 30, 90, N'Gentle breeze, sea state 2, horizon clear for sunset cruise', 1, 1, N'Capt. Ruwan Kumara (Catamaran Skipper)', N'READY_FOR_DEPARTURE', N'Safety briefings completed for all boarding guests; navigation lights tested.', GETDATE());
SET IDENTITY_INSERT dbo.safety_check_logs OFF;
GO

-- --------------------------------------------------------------------
-- 10. EMERGENCY NOTICES & ADVISORIES
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.emergency_notices ON;
INSERT INTO dbo.emergency_notices ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at]) VALUES
(1, N'Department of Meteorology: Rough Seas Advisory for Southern Waters', N'BAD_WEATHER', N'HIGH', NULL, NULL, N'SOUTH_COAST', N'Gusty winds up to 55 km/h and wave swells reaching 2.8m expected along the Mirissa to Galle coastal belt. Morning whale watching cruises proceed under caution; afternoon sailing departures suspended.', N'PORTAL,SMS,EMAIL', N'ACTIVE', 1, GETDATE()),
(2, N'Technical Maintenance Delay Notice: Mirissa Sun (Lagoon 42)', N'TECHNICAL_DELAY', N'MEDIUM', NULL, 5, N'SOUTH_COAST', N'Vessel SLC-CAT-005 undergoing scheduled slipway maintenance. All existing reservations reassigned to Ocean Pearl (Ceycat 55) with zero schedule disruption.', N'PORTAL', N'ACTIVE', 3, GETDATE());
SET IDENTITY_INSERT dbo.emergency_notices OFF;
GO

-- --------------------------------------------------------------------
-- 11. ACTIVITY LOGS
-- --------------------------------------------------------------------
SET IDENTITY_INSERT dbo.activity_logs ON;
INSERT INTO dbo.activity_logs ([id], [user_id], [action], [module], [details], [ip_address], [created_at]) VALUES
(1, 1, N'SYSTEM_INITIALIZATION', N'SYSTEM', N'Database seeded with default vessels, tours, users, and safety protocols', N'127.0.0.1', GETDATE()),
(2, 2, N'BOOKING_CREATED', N'RESERVATIONS', N'Created reservation SLC-2026-0901 for David Miller with 2 passengers', N'127.0.0.1', GETDATE()),
(3, 1, N'EMERGENCY_ALERT_POSTED', N'EMERGENCY', N'Broadcasted rough sea weather advisory for Southern Coast', N'127.0.0.1', GETDATE());
SET IDENTITY_INSERT dbo.activity_logs OFF;
GO
