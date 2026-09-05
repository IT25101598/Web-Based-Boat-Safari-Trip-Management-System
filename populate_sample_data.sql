USE [boat_safari_db]
GO

SET NOCOUNT ON;
GO

PRINT '==================================================';
PRINT 'Resetting and inserting sample data for boat_safari_db';
PRINT '==================================================';
GO

-- 1. Safely remove existing data in reverse foreign key order
DELETE FROM [dbo].[activity_logs];
DELETE FROM [dbo].[login_details];
DELETE FROM [dbo].[emergency_acknowledgments];
DELETE FROM [dbo].[emergency_notices];
DELETE FROM [dbo].[safety_check_logs];
DELETE FROM [dbo].[service_reminders];
DELETE FROM [dbo].[maintenance_records];
DELETE FROM [dbo].[promo_redemptions];
DELETE FROM [dbo].[passengers];
DELETE FROM [dbo].[reservations];
DELETE FROM [dbo].[tour_schedules];
DELETE FROM [dbo].[tours];
DELETE FROM [dbo].[vessels];
DELETE FROM [dbo].[routes];
DELETE FROM [dbo].[destinations];
DELETE FROM [dbo].[promotions];
DELETE FROM [dbo].[users];
GO

-- Reseed identity counters to start cleanly from 1
DBCC CHECKIDENT ('[dbo].[users]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[destinations]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[routes]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[vessels]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[tours]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[tour_schedules]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[promotions]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[reservations]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[passengers]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[promo_redemptions]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[maintenance_records]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[service_reminders]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[safety_check_logs]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[emergency_notices]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[emergency_acknowledgments]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[login_details]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[activity_logs]', RESEED, 0);
GO

-- ==================================================
-- TABLE 1: users (17 records across all roles)
-- Roles: 'ADMIN', 'OFFICER', 'CAPTAIN', 'GUIDE', 'OWNER', 'CUSTOMER'
-- Status: 'ACTIVE', 'INACTIVE', 'SUSPENDED'
-- ==================================================
SET IDENTITY_INSERT [dbo].[users] ON;
GO
INSERT INTO [dbo].[users] ([id], [full_name], [email], [password_hash], [phone], [role], [status], [profile_image], [created_at], [updated_at])
VALUES
(1, N'Kasun Jayawardena', N'admin@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94771234567', N'ADMIN', N'ACTIVE', N'assets/img/avatars/admin1.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(2, N'Dilani Perera', N'dilani.admin@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94772345678', N'ADMIN', N'ACTIVE', N'assets/img/avatars/admin2.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(3, N'Chaminda Fernando', N'chaminda.officer@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94773456789', N'OFFICER', N'ACTIVE', N'assets/img/avatars/officer1.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(4, N'Capt. Sunil Perera', N'sunil.captain@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94774567890', N'CAPTAIN', N'ACTIVE', N'assets/img/avatars/captain1.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(5, N'Capt. Ranjith Silva', N'ranjith.captain@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94775678901', N'CAPTAIN', N'ACTIVE', N'assets/img/avatars/captain2.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(6, N'Capt. Nimal Rajapakse', N'nimal.captain@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94776789012', N'CAPTAIN', N'ACTIVE', N'assets/img/avatars/captain3.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(7, N'Roshan Wickramasinghe', N'roshan.guide@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94777890123', N'GUIDE', N'ACTIVE', N'assets/img/avatars/guide1.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(8, N'Malith Gunasekara', N'malith.guide@boatsafari.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94778901234', N'GUIDE', N'ACTIVE', N'assets/img/avatars/guide2.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(9, N'Dinesh Mendis', N'dinesh.owner@southernmarina.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94779012345', N'OWNER', N'ACTIVE', N'assets/img/avatars/owner1.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(10, N'Lalith De Silva', N'lalith.owner@oceanlux.lk', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94770123456', N'OWNER', N'ACTIVE', N'assets/img/avatars/owner2.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(11, N'Johnathan Miller', N'john.miller@gmail.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+447911123456', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust1.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(12, N'Elena Rostova', N'elena.rostova@yandex.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+79031234567', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust2.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(13, N'Sarah Jenkins', N'sarah.jenkins@outlook.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+12025550143', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust3.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(14, N'Hans Schmidt', N'hans.schmidt@web.de', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+491512345678', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust4.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(15, N'Nadeesha Kumari', N'nadeesha.k@gmail.com', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+94714567890', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust5.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(16, N'Kenji Sato', N'kenji.sato@sony.jp', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+819012345678', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust6.jpg', SYSUTCDATETIME(), SYSUTCDATETIME()),
(17, N'Liam O''Connor', N'liam.oconnor@tcd.ie', N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'+353871234567', N'CUSTOMER', N'ACTIVE', N'assets/img/avatars/cust7.jpg', SYSUTCDATETIME(), SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[users] OFF;
GO

-- ==================================================
-- TABLE 2: destinations (8 records)
-- Regions: 'SOUTH_COAST', 'WEST_COAST', 'EAST_COAST', 'NORTH_COAST'
-- ==================================================
SET IDENTITY_INSERT [dbo].[destinations] ON;
GO
INSERT INTO [dbo].[destinations] ([id], [name], [region], [harbor_name], [description], [image_url], [created_at])
VALUES
(1, N'Mirissa Marine Bay', N'SOUTH_COAST', N'Mirissa Fishery & Tourist Harbor', N'World-renowned hotspot for witnessing Blue Whales, Sperm Whales, and spinner dolphins in crystal blue waters.', N'assets/img/destinations/mirissa.jpg', SYSUTCDATETIME()),
(2, N'Galle Fort Harbor', N'SOUTH_COAST', N'Galle International Marine Harbor', N'Scenic heritage port sheltered beneath historic Dutch fortress ramparts with calm yacht mooring.', N'assets/img/destinations/galle.jpg', SYSUTCDATETIME()),
(3, N'Trincomalee Deep Bay', N'EAST_COAST', N'Trincomalee Coral Harbor', N'One of the worlds finest natural deep-water harbors, legendary for seasonal whale migrations and Pigeon Island reefs.', N'assets/img/destinations/trincomalee.jpg', SYSUTCDATETIME()),
(4, N'Bentota Estuary & Lagoon', N'WEST_COAST', N'Bentota Marina Pier', N'Serene mangrove estuaries meeting ocean surf, ideal for river safaris, birdwatching, and sunset cruises.', N'assets/img/destinations/bentota.jpg', SYSUTCDATETIME()),
(5, N'Pasikudah Coral Coast', N'EAST_COAST', N'Pasikudah Bay Anchorage', N'Calm, crystal-shallow turquoise bay protected by barrier reefs, perfect for swimming and reef snorkeling.', N'assets/img/destinations/pasikudah.jpg', SYSUTCDATETIME()),
(6, N'Kalpitiya Dolphin Lagoon', N'WEST_COAST', N'Kalpitiya Lagoon Pier', N'Premier sanctuary for massive pods of spinner dolphins, reef diving, and mangrove eco-tours.', N'assets/img/destinations/kalpitiya.jpg', SYSUTCDATETIME()),
(7, N'Jaffna Karainagar Channel', N'NORTH_COAST', N'Karainagar Jetty', N'Northern gateway island waterways featuring shallow turquoise sandbanks and migratory flamingo habitats.', N'assets/img/destinations/jaffna.jpg', SYSUTCDATETIME()),
(8, N'Hikkaduwa Marine Sanctuary', N'SOUTH_COAST', N'Hikkaduwa Fishery Pier', N'Famous national marine park featuring shallow coral gardens, sea turtles, and vibrant tropical fish.', N'assets/img/destinations/hikkaduwa.jpg', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[destinations] OFF;
GO

-- ==================================================
-- TABLE 3: routes (8 records)
-- ==================================================
SET IDENTITY_INSERT [dbo].[routes] ON;
GO
INSERT INTO [dbo].[routes] ([id], [name], [start_destination_id], [end_destination_id], [duration_hours], [distance_nm], [highlights], [created_at])
VALUES
(1, N'Mirissa Pelagic Deep Oceanic Route', 1, 1, 4.5, 22.5, N'Deep shelf whale feeding grounds, spinner dolphin pods, flying fish sightings', SYSUTCDATETIME()),
(2, N'Galle Bay Sunset Coastline Cruise', 2, 2, 2.5, 8.0, N'Historic UNESCO lighthouse view, Galle Fort ramparts from sea, coastal golden hour', SYSUTCDATETIME()),
(3, N'Pigeon Island Snorkeling & Reef Expedition', 3, 3, 5.0, 16.0, N'Coral gardens, blacktip reef sharks, green sea turtles, crystal lagoons', SYSUTCDATETIME()),
(4, N'Bentota River & Coastal Estuary Tour', 4, 4, 3.0, 12.0, N'Mangrove biodiversity, bird nesting isles, river-ocean confluence, coconut toddy isles', SYSUTCDATETIME()),
(5, N'Pasikudah Coral Bay Leisure Cruise', 5, 5, 3.5, 10.5, N'Shallow clear reef lagoons, stand-up paddleboarding stop, open sea swim session', SYSUTCDATETIME()),
(6, N'Kalpitiya Megapod Dolphin Circuit', 6, 6, 4.0, 18.0, N'Over 500+ spinner dolphins, Bar Reef marine border, sea eagle sightings', SYSUTCDATETIME()),
(7, N'Hikkaduwa Coral Reef & Turtle Point', 8, 8, 2.5, 6.5, N'Giant sea turtle feeding point, glass-bottom viewing zone, shipwreck reef spot', SYSUTCDATETIME()),
(8, N'Galle to Mirissa Scenic Coastal Passage', 2, 1, 3.5, 19.5, N'Weligama stilt fishermen bay view, Taprobane island coast, open water sailing', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[routes] OFF;
GO

-- ==================================================
-- TABLE 4: vessels (8 records)
-- Types: 'SPEEDBOAT', 'YACHT', 'CATAMARAN'
-- Status: 'AVAILABLE', 'ASSIGNED', 'UNDER_MAINTENANCE', 'INACTIVE'
-- ==================================================
SET IDENTITY_INSERT [dbo].[vessels] ON;
GO
INSERT INTO [dbo].[vessels] ([id], [name], [registration_no], [vessel_type], [capacity], [cabins], [engines], [cruising_speed_knots], [status], [owner_id], [image_url], [safety_equipment_notes], [created_at])
VALUES
(1, N'Ocean Monarch', N'SRI-VES-001', N'CATAMARAN', 40, 2, N'Twin Yanmar 315HP Turbo Diesels', 18.5, N'AVAILABLE', 9, N'assets/img/vessels/catamaran1.jpg', N'45 Solas life jackets, twin 25-person liferafts, satellite EPIRB, VHF marine radio, flares, first aid kits', SYSUTCDATETIME()),
(2, N'Pearl of the South', N'SRI-VES-002', N'SPEEDBOAT', 15, 0, N'Dual Yamaha 250HP Four-Stroke Outboards', 28.0, N'AVAILABLE', 9, N'assets/img/vessels/speedboat1.jpg', N'20 adult lifejackets, 5 child lifejackets, EPIRB, marine radio, offshore fire extinguishers', SYSUTCDATETIME()),
(3, N'Serendib Odyssey', N'SRI-VES-003', N'YACHT', 25, 3, N'Twin Caterpillar 600HP Marine Diesels', 22.0, N'AVAILABLE', 10, N'assets/img/vessels/yacht1.jpg', N'30 Solas approved vests, automatic fire suppression in engine room, life raft, Garmin radar', SYSUTCDATETIME()),
(4, N'Blue Horizon', N'SRI-VES-004', N'CATAMARAN', 35, 2, N'Twin Cummins 380HP Marine Diesels', 17.0, N'ASSIGNED', 9, N'assets/img/vessels/catamaran2.jpg', N'40 lifejackets, 2 life buoys, emergency flares, oxygen resuscitator, satellite phone', SYSUTCDATETIME()),
(5, N'Ceylon Wave Raider', N'SRI-VES-005', N'SPEEDBOAT', 12, 0, N'Twin Suzuki 200HP Lean Burn Engines', 30.5, N'AVAILABLE', 10, N'assets/img/vessels/speedboat2.jpg', N'15 Solas lifejackets, portable VHF, handheld GPS, first aid kit, waterproof fire extinguisher', SYSUTCDATETIME()),
(6, N'Trinco Voyager', N'SRI-VES-006', N'CATAMARAN', 30, 2, N'Twin Volvo Penta 260HP Inboard', 16.5, N'AVAILABLE', 9, N'assets/img/vessels/catamaran3.jpg', N'35 lifejackets, liferaft for 35 persons, AIS transponder, depth sounder, smoke beacons', SYSUTCDATETIME()),
(7, N'Southern Star Yacht', N'SRI-VES-007', N'YACHT', 18, 2, N'Twin MAN 450HP High Performance', 24.0, N'UNDER_MAINTENANCE', 10, N'assets/img/vessels/yacht2.jpg', N'25 life jackets, EPIRB beacon, forward sonar, life raft, twin distress rocket kits', SYSUTCDATETIME()),
(8, N'Lanka Reef Explorer', N'SRI-VES-008', N'SPEEDBOAT', 14, 0, N'Yamaha 300HP V6 Offshore Outboard', 26.0, N'AVAILABLE', 9, N'assets/img/vessels/speedboat3.jpg', N'18 life jackets, complete snorkeling safety flags, throw lines, medical emergency kit', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[vessels] OFF;
GO

-- ==================================================
-- TABLE 5: tours (8 records)
-- Types: 'WHALE_WATCHING', 'SUNSET_SAIL', 'SNORKELING_SAFARI', 'DAYLIGHT_CRUISE', 'DINE_AT_SEA', 'OVERNIGHT_CHARTER'
-- ==================================================
SET IDENTITY_INSERT [dbo].[tours] ON;
GO
INSERT INTO [dbo].[tours] ([id], [title], [tour_type], [route_id], [description], [duration_hours], [base_price], [max_passengers], [inclusions], [exclusions], [special_instructions], [image_url], [is_active], [created_at])
VALUES
(1, N'Mirissa Premier Blue Whale Safari', N'WHALE_WATCHING', 1, N'Embark on an early morning deep-sea cruise to witness majestic blue whales and acrobatic dolphins in their natural migratory habitat.', 4.5, 95.00, 35, N'Buffet breakfast, fresh tropical fruits, coffee & tea, certified marine biologist guide, binoculars', N'Hotel transfers, alcoholic beverages, gratuities', N'Departure strictly at 6:30 AM. Motion sickness medication recommended 30 min before boarding.', N'assets/img/tours/whale-watching.jpg', 1, SYSUTCDATETIME()),
(2, N'Galle Fortress Sunset Wine & Dine Sail', N'SUNSET_SAIL', 2, N'Unwind along the golden historic coastline of Galle Fort with champagne, artisanal canapes, and soothing acoustic ocean vibes.', 2.5, 75.00, 20, N'Welcome sparkling wine, canapes platter, live saxophonist, non-alcoholic drinks, life jackets', N'Hard liquor, private photography package', N'Smart casual dress code. Arrive at Galle harbor 20 minutes prior to departure.', N'assets/img/tours/sunset-sail.jpg', 1, SYSUTCDATETIME()),
(3, N'Pigeon Island Coral & Turtle Snorkel Safari', N'SNORKELING_SAFARI', 3, N'Explore Eastern Sri Lankas most vibrant coral reef national park with crystal waters, harmless reef sharks, and sea turtles.', 5.0, 85.00, 25, N'Full snorkeling gear (mask, snorkel, fins), national park entry permits, certified lifeguard, lunch box & refreshments', N'Wetsuits, underwater GoPro rental (available at pier)', N'Sunscreen must be reef-safe. Respect wildlife - do not step on or touch live corals.', N'assets/img/tours/snorkeling.jpg', 1, SYSUTCDATETIME()),
(4, N'Bentota Mangrove & Lagoon Eco-Cruise', N'DAYLIGHT_CRUISE', 4, N'Glide through dense mangrove channels, visit cinnamon islands, witness monitor lizards and exotic aquatic birds in tranquility.', 3.0, 50.00, 15, N'Guided boat safari, king coconut refreshment, cinnamon peeling demonstration, bird field guide', N'Personal tipping, hotel pick-up', N'Great tour for families and young children. Wear light cotton clothing and a sun hat.', N'assets/img/tours/bentota-lagoon.jpg', 1, SYSUTCDATETIME()),
(5, N'Pasikudah Coral Lagoon Catamaran Cruise', N'DAYLIGHT_CRUISE', 5, N'Relax aboard a luxury twin-hull catamaran across calm turquoise bays with open-sea swimming stops and stand-up paddleboards.', 3.5, 65.00, 28, N'Paddleboards, floatation tubes, grilled seafood lunch snack, iced tropical fruit juices', N'Alcoholic cocktails (available on board cash bar)', N'Swimwear is recommended. Towels provided on board.', N'assets/img/tours/pasikudah-cruise.jpg', 1, SYSUTCDATETIME()),
(6, N'Kalpitiya Spinner Dolphin Super-Pod Voyage', N'WHALE_WATCHING', 6, N'Experience thousands of synchronized spinner dolphins jumping and spinning alongside our high-speed ocean vessel.', 4.0, 80.00, 12, N'Hot breakfast rolls, mineral water, specialized dolphin spotter guide, lifejackets', N'Underwater camera gear, hotel drop-off', N'High chance of ocean spray. Waterproof bags provided for electronics.', N'assets/img/tours/kalpitiya-dolphins.jpg', 1, SYSUTCDATETIME()),
(7, N'Hikkaduwa Marine Sanctuary Glass-Bottom Safari', N'SNORKELING_SAFARI', 7, N'Perfect for non-swimmers and kids: discover corals, clownfish, and sea turtles through clear hull viewports and surface dips.', 2.5, 45.00, 14, N'Glass bottom boat ride, coral reef guide, bottled water, safety vests, sanitized snorkel set', N'Underwater photo prints, hotel transfer', N'Easy boarding from sandy beach jetty. All ages welcome.', N'assets/img/tours/hikkaduwa-reef.jpg', 1, SYSUTCDATETIME()),
(8, N'Southern Coast Private Chef Yacht Dining', N'DINE_AT_SEA', 8, N'An exclusive 4-course seafood feast prepared live by a master chef aboard our luxury motor yacht anchored off scenic Weligama bay.', 3.5, 140.00, 16, N'4-course gourmet dinner, grilled jumbo prawns, wine pairing, private host, yacht fuel & crew', N'Custom vintage wines (available on request)', N'Please inform of any dietary restrictions or shellfish allergies 24 hours prior.', N'assets/img/tours/dine-at-sea.jpg', 1, SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[tours] OFF;
GO

-- ==================================================
-- TABLE 6: tour_schedules (8 records)
-- Status: 'SCHEDULED', 'BOARDING', 'DEPARTED', 'COMPLETED', 'CANCELLED'
-- ==================================================
SET IDENTITY_INSERT [dbo].[tour_schedules] ON;
GO
INSERT INTO [dbo].[tour_schedules] ([id], [tour_id], [vessel_id], [captain_id], [guide_id], [departure_time], [return_time], [available_seats], [status], [cancellation_reason], [created_at])
VALUES
(1, 1, 1, 4, 7, N'2026-10-10 06:30:00', N'2026-10-10 11:00:00', 31, N'SCHEDULED', NULL, SYSUTCDATETIME()),
(2, 2, 3, 5, 8, N'2026-10-10 16:30:00', N'2026-10-10 19:00:00', 17, N'SCHEDULED', NULL, SYSUTCDATETIME()),
(3, 3, 6, 6, 7, N'2026-10-11 07:30:00', N'2026-10-11 12:30:00', 24, N'SCHEDULED', NULL, SYSUTCDATETIME()),
(4, 4, 2, 4, 8, N'2026-10-11 09:00:00', N'2026-10-11 12:00:00', 11, N'SCHEDULED', NULL, SYSUTCDATETIME()),
(5, 5, 4, 5, 7, N'2026-10-12 10:00:00', N'2026-10-12 13:30:00', 26, N'SCHEDULED', NULL, SYSUTCDATETIME()),
(6, 6, 5, 6, 8, N'2026-10-12 06:45:00', N'2026-10-12 10:45:00', 10, N'SCHEDULED', NULL, SYSUTCDATETIME()),
(7, 7, 8, 4, 7, N'2026-10-02 09:30:00', N'2026-10-02 12:00:00', 13, N'COMPLETED', NULL, SYSUTCDATETIME()),
(8, 8, 3, 5, 8, N'2026-10-13 17:30:00', N'2026-10-13 21:00:00', 14, N'SCHEDULED', NULL, SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[tour_schedules] OFF;
GO

-- ==================================================
-- TABLE 7: promotions (8 records)
-- Discount Types: 'PERCENTAGE', 'FIXED_AMOUNT', 'SEASONAL'
-- ==================================================
SET IDENTITY_INSERT [dbo].[promotions] ON;
GO
INSERT INTO [dbo].[promotions] ([id], [name], [promo_code], [discount_type], [discount_value], [min_spend], [max_discount], [max_redemptions], [times_redeemed], [start_date], [end_date], [is_active], [created_at])
VALUES
(1, N'Early Whale Watchers Discount', N'WHALE2026', N'PERCENTAGE', 15.00, 150.00, 50.00, 100, 12, '2026-09-01', '2026-12-31', 1, SYSUTCDATETIME()),
(2, N'Romantic Sunset Couple Special', N'SUNSET20', N'PERCENTAGE', 20.00, 120.00, 40.00, 50, 8, '2026-09-15', '2026-11-30', 1, SYSUTCDATETIME()),
(3, N'Pigeon Island Coral Explorer Savings', N'REEF30', N'FIXED_AMOUNT', 30.00, 200.00, 30.00, 75, 14, '2026-08-01', '2026-10-31', 1, SYSUTCDATETIME()),
(4, N'Family Holiday Lagoon Voucher', N'FAMILY50', N'FIXED_AMOUNT', 50.00, 250.00, 50.00, 40, 5, '2026-09-01', '2026-12-15', 1, SYSUTCDATETIME()),
(5, N'East Coast Summer Season Deal', N'SUMMERSEA', N'SEASONAL', 25.00, 180.00, 60.00, 60, 19, '2026-06-01', '2026-10-31', 1, SYSUTCDATETIME()),
(6, N'Luxury Yacht Private Charter Promo', N'LUXYACHT100', N'FIXED_AMOUNT', 100.00, 500.00, 100.00, 20, 3, '2026-09-01', '2026-12-31', 1, SYSUTCDATETIME()),
(7, N'Dolphin Super-Pod Flash Promo', N'DOLPHIN10', N'PERCENTAGE', 10.00, 100.00, 30.00, 150, 22, '2026-08-15', '2026-11-15', 1, SYSUTCDATETIME()),
(8, N'Local Sri Lankan Resident Privilege', N'LANKA25', N'PERCENTAGE', 25.00, 80.00, 45.00, 200, 45, '2026-01-01', '2026-12-31', 1, SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[promotions] OFF;
GO

-- ==================================================
-- TABLE 8: reservations (8 records)
-- Status: 'CONFIRMED', 'CHECKED_IN', 'CANCELLED', 'PENDING'
-- ==================================================
SET IDENTITY_INSERT [dbo].[reservations] ON;
GO
INSERT INTO [dbo].[reservations] ([id], [booking_ref], [schedule_id], [customer_id], [passenger_count], [total_amount], [discount_amount], [final_amount], [promo_id], [status], [special_notes], [created_at])
VALUES
(1, N'BK-2026-1001', 1, 11, 2, 190.00, 28.50, 161.50, 1, N'CONFIRMED', N'Celebrating 10th wedding anniversary; requested upper deck forward seating.', SYSUTCDATETIME()),
(2, N'BK-2026-1002', 1, 12, 2, 190.00, 0.00, 190.00, NULL, N'CONFIRMED', N'One passenger requires vegetarian meal.', SYSUTCDATETIME()),
(3, N'BK-2026-1003', 2, 13, 2, 150.00, 30.00, 120.00, 2, N'CONFIRMED', N'Please prepare chilled champagne on boarding.', SYSUTCDATETIME()),
(4, N'BK-2026-1004', 3, 14, 1, 85.00, 0.00, 85.00, NULL, N'CONFIRMED', N'Experienced scuba diver, brings own specialized mask.', SYSUTCDATETIME()),
(5, N'BK-2026-1005', 4, 15, 4, 200.00, 50.00, 150.00, 4, N'CONFIRMED', N'Family with two children (ages 8 and 11).', SYSUTCDATETIME()),
(6, N'BK-2026-1006', 5, 16, 2, 130.00, 25.00, 105.00, 5, N'PENDING', N'Awaiting wire transfer confirmation from Japan bank.', SYSUTCDATETIME()),
(7, N'BK-2026-1007', 7, 17, 1, 45.00, 0.00, 45.00, NULL, N'CHECKED_IN', N'Guest checked in on pier at 09:15 AM.', SYSUTCDATETIME()),
(8, N'BK-2026-1008', 8, 11, 2, 280.00, 100.00, 180.00, 6, N'CONFIRMED', N'Private VIP yacht dinner. No shellfish for Mrs. Miller.', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[reservations] OFF;
GO

-- ==================================================
-- TABLE 9: passengers (16 records matching reservations)
-- Gender: 'MALE', 'FEMALE', 'OTHER'
-- ==================================================
SET IDENTITY_INSERT [dbo].[passengers] ON;
GO
INSERT INTO [dbo].[passengers] ([id], [reservation_id], [full_name], [id_or_passport], [age], [gender], [nationality], [emergency_contact])
VALUES
(1, 1, N'Johnathan Miller', N'GBR-94827104', 38, N'MALE', N'British', N'+447911123456'),
(2, 1, N'Claire Miller', N'GBR-94827105', 36, N'FEMALE', N'British', N'+447911123456'),
(3, 2, N'Elena Rostova', N'RUS-71029384', 31, N'FEMALE', N'Russian', N'+79031234567'),
(4, 2, N'Dmitri Rostov', N'RUS-71029385', 34, N'MALE', N'Russian', N'+79031234567'),
(5, 3, N'Sarah Jenkins', N'USA-55102948', 29, N'FEMALE', N'American', N'+12025550143'),
(6, 3, N'Mark Davis', N'USA-55102949', 32, N'MALE', N'American', N'+12025550143'),
(7, 4, N'Hans Schmidt', N'DEU-C1092837', 42, N'MALE', N'German', N'+491512345678'),
(8, 5, N'Nadeesha Kumari', N'918237465V', 35, N'FEMALE', N'Sri Lankan', N'+94714567890'),
(9, 5, N'Pradeep Jayasinghe', N'881293847V', 38, N'MALE', N'Sri Lankan', N'+94714567890'),
(10, 5, N'Kavindu Jayasinghe', N'CH-2015-9921', 11, N'MALE', N'Sri Lankan', N'+94714567890'),
(11, 5, N'Dinithi Jayasinghe', N'CH-2018-4412', 8, N'FEMALE', N'Sri Lankan', N'+94714567890'),
(12, 6, N'Kenji Sato', N'JPN-TZ881923', 45, N'MALE', N'Japanese', N'+819012345678'),
(13, 6, N'Aoi Sato', N'JPN-TZ881924', 42, N'FEMALE', N'Japanese', N'+819012345678'),
(14, 7, N'Liam O''Connor', N'IRL-P9012847', 27, N'MALE', N'Irish', N'+353871234567'),
(15, 8, N'Johnathan Miller', N'GBR-94827104', 38, N'MALE', N'British', N'+447911123456'),
(16, 8, N'Claire Miller', N'GBR-94827105', 36, N'FEMALE', N'British', N'+447911123456');
GO
SET IDENTITY_INSERT [dbo].[passengers] OFF;
GO

-- ==================================================
-- TABLE 10: promo_redemptions (5 records)
-- ==================================================
SET IDENTITY_INSERT [dbo].[promo_redemptions] ON;
GO
INSERT INTO [dbo].[promo_redemptions] ([id], [promo_id], [customer_id], [reservation_id], [discount_applied], [redeemed_at])
VALUES
(1, 1, 11, 1, 28.50, SYSUTCDATETIME()),
(2, 2, 13, 3, 30.00, SYSUTCDATETIME()),
(3, 4, 15, 5, 50.00, SYSUTCDATETIME()),
(4, 5, 16, 6, 25.00, SYSUTCDATETIME()),
(5, 6, 11, 8, 100.00, SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[promo_redemptions] OFF;
GO

-- ==================================================
-- TABLE 11: maintenance_records (8 records)
-- Types: 'ROUTINE_SERVICE', 'ELECTRICAL', 'SAFETY_INSPECTION', 'HULL_CLEANING', 'ENGINE_OVERHAUL'
-- Status: 'COMPLETED', 'IN_PROGRESS', 'SCHEDULED', 'CANCELLED'
-- ==================================================
SET IDENTITY_INSERT [dbo].[maintenance_records] ON;
GO
INSERT INTO [dbo].[maintenance_records] ([id], [vessel_id], [maintenance_type], [description], [scheduled_date], [completed_date], [cost], [service_provider], [status], [created_at])
VALUES
(1, 1, N'ROUTINE_SERVICE', N'200-hour scheduled diesel engine servicing, oil change, fuel and oil filter replacements, coolant top up.', '2026-09-10', '2026-09-11', 450.00, N'Southern Marine Engineering Ltd', N'COMPLETED', SYSUTCDATETIME()),
(2, 2, N'SAFETY_INSPECTION', N'Annual Merchant Shipping Secretariat safety inspection and hull integrity certification.', '2026-08-20', '2026-08-20', 250.00, N'Lanka Maritime Safety Bureau', N'COMPLETED', SYSUTCDATETIME()),
(3, 3, N'HULL_CLEANING', N'Dry dock haul-out, high pressure hull washing, marine barnacle removal and antifouling coat reapplication.', '2026-09-01', '2026-09-04', 1200.00, N'Galle Dockyard & Engineering', N'COMPLETED', SYSUTCDATETIME()),
(4, 7, N'ENGINE_OVERHAUL', N'Port side MAN diesel injector calibration, turbocharger rebuild, and sea water cooling pump replacement.', '2026-10-01', NULL, 3500.00, N'Colombo Marine Tech Services', N'IN_PROGRESS', SYSUTCDATETIME()),
(5, 4, N'ELECTRICAL', N'Navigation electronics overhaul: Furuno radar calibration, transducer replacement, new dual AGM marine battery bank.', '2026-10-15', NULL, 850.00, N'Oceanic Electrical Lanka', N'SCHEDULED', SYSUTCDATETIME()),
(6, 5, N'ROUTINE_SERVICE', N'Twin Suzuki 200HP gearbox oil replacement, spark plugs renewal, propeller hub inspection.', '2026-09-25', '2026-09-26', 380.00, N'Negombo Outboard Specialists', N'COMPLETED', SYSUTCDATETIME()),
(7, 6, N'SAFETY_INSPECTION', N'Inflatable life raft 3-year recertification, hydro-static release unit renewal, and flare pack replacement.', '2026-09-18', '2026-09-19', 620.00, N'Trinco Marine Safety Supplies', N'COMPLETED', SYSUTCDATETIME()),
(8, 8, N'ROUTINE_SERVICE', N'100-hour Yamaha outboard tune up, fuel line check, water separator replacement.', '2026-10-20', NULL, 280.00, N'Southern Marine Engineering Ltd', N'SCHEDULED', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[maintenance_records] OFF;
GO

-- ==================================================
-- TABLE 12: service_reminders (8 records)
-- ==================================================
SET IDENTITY_INSERT [dbo].[service_reminders] ON;
GO
INSERT INTO [dbo].[service_reminders] ([id], [vessel_id], [reminder_title], [interval_days], [last_serviced_date], [next_due_date], [is_overdue], [notes])
VALUES
(1, 1, N'Diesel Engine Oil & Filter Change', 90, '2026-09-10', '2026-12-10', 0, N'Use genuine Yanmar 15W-40 marine diesel oil and twin micro-filters.'),
(2, 2, N'Outboard Impeller & Water Pump Inspection', 120, '2026-07-15', '2026-11-15', 0, N'Check cooling water stream pressure and rubber vane flexibility.'),
(3, 3, N'Life Raft Hydrostatic Release Unit Check', 365, '2025-11-01', '2026-11-01', 0, N'Mandatory annual maritime inspection requirement.'),
(4, 4, N'Bilge Pumps & Float Switches Test', 30, '2026-09-15', '2026-10-15', 0, N'Test all 4 automatic submersible bilge pumps with float override.'),
(5, 5, N'Fuel Filter Water Separator Drain', 30, '2026-09-20', '2026-10-20', 0, N'Drain visual bowl and check for condensation water contamination.'),
(6, 6, N'Steering Hydraulic Fluid Flush', 180, '2026-05-10', '2026-11-10', 0, N'Bleed SeaStar dual helm hydraulic line and replenish ISO 15 oil.'),
(7, 7, N'Anode Cathodic Protection Replacement', 90, '2026-07-01', '2026-10-01', 1, N'Zinc sacrificial anodes are over 60% eroded. Overdue for renewal.'),
(8, 8, N'Emergency First Aid & Oxygen Kit Resupply', 90, '2026-08-01', '2026-11-01', 0, N'Check medical expiration dates on sterile bandages and burn gels.');
GO
SET IDENTITY_INSERT [dbo].[service_reminders] OFF;
GO

-- ==================================================
-- TABLE 13: safety_check_logs (8 records)
-- Status: 'READY_FOR_DEPARTURE', 'PENDING_RECHECK', 'VOIDED'
-- ==================================================
SET IDENTITY_INSERT [dbo].[safety_check_logs] ON;
GO
INSERT INTO [dbo].[safety_check_logs] ([id], [schedule_id], [vessel_id], [captain_id], [safety_items_verified], [life_jackets_count], [fuel_level_percent], [weather_conditions], [briefing_confirmed], [all_clear], [captain_signature], [status], [notes], [logged_at])
VALUES
(1, 1, 1, 4, 1, 45, 95, N'Calm seas, wave height 0.8m, wind 6 knots SSW, visibility 12nm. Perfect whale watching weather.', 1, 1, N'Capt. Sunil Perera', N'READY_FOR_DEPARTURE', N'All SOLAS equipment checked. Passenger manifest reconciled. Departure approved.', SYSUTCDATETIME()),
(2, 2, 3, 5, 1, 28, 100, N'Fair breeze, gentle swell 0.6m, sunset skies clear. Excellent cruising condition.', 1, 1, N'Capt. Ranjith Silva', N'READY_FOR_DEPARTURE', N'Catering and guest safety vests verified. Sound system and navigation lights tested OK.', SYSUTCDATETIME()),
(3, 3, 6, 6, 1, 35, 90, N'East coast clear, water clarity > 15m, light chop 0.5m. Reef conditions pristine.', 1, 1, N'Capt. Nimal Rajapakse', N'READY_FOR_DEPARTURE', N'Snorkel gear sanitized. Dive briefing and marine park preservation rules reiterated.', SYSUTCDATETIME()),
(4, 4, 2, 4, 1, 18, 85, N'Estuary waters calm, river flow steady, temperature 29C.', 1, 1, N'Capt. Sunil Perera', N'READY_FOR_DEPARTURE', N'Child life vests inspected and properly fitted before gangway boarding.', SYSUTCDATETIME()),
(5, 5, 4, 5, 1, 40, 95, N'Lagoon water smooth, sun bright, wind 8 knots from East.', 1, 1, N'Capt. Ranjith Silva', N'READY_FOR_DEPARTURE', N'Stand-up paddle boards and tow ropes verified secured to catamaran aft stanchions.', SYSUTCDATETIME()),
(6, 6, 5, 6, 1, 15, 100, N'Offshore swell 1.2m, wind 10 knots North, excellent visibility.', 1, 1, N'Capt. Nimal Rajapakse', N'READY_FOR_DEPARTURE', N'Twin high-performance engines warm-up complete. Marine VHF radio link to naval watch operational.', SYSUTCDATETIME()),
(7, 7, 8, 4, 1, 16, 90, N'Shallow lagoon waters clear, negligible tide variance.', 1, 1, N'Capt. Sunil Perera', N'READY_FOR_DEPARTURE', N'Completed voyage safely with zero incidents. Marine turtle sighting confirmed.', SYSUTCDATETIME()),
(8, 8, 3, 5, 1, 25, 95, N'Evening breeze mild, coastal lights clear, swell under 0.7m.', 1, 1, N'Capt. Ranjith Silva', N'READY_FOR_DEPARTURE', N'Chef galley fire extinguisher inspected. Emergency evacuation route explained to guests.', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[safety_check_logs] OFF;
GO

-- ==================================================
-- TABLE 14: emergency_notices (6 records)
-- Categories: 'HIGH_SWELL', 'BAD_WEATHER', 'SAFETY_ADVISORY', 'TOUR_CANCELLATION', 'TECHNICAL_DELAY'
-- Severities: 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
-- Regions: 'SOUTH_COAST', 'WEST_COAST', 'EAST_COAST', 'NORTH_COAST', 'ALL_REGIONS'
-- Status: 'ACTIVE', 'RESOLVED', 'ARCHIVED'
-- ==================================================
SET IDENTITY_INSERT [dbo].[emergency_notices] ON;
GO
INSERT INTO [dbo].[emergency_notices] ([id], [title], [category], [severity], [affected_tour_id], [affected_vessel_id], [affected_region], [message], [broadcast_channels], [status], [created_by_id], [created_at], [resolved_at])
VALUES
(1, N'Monsoon Surge High Swell Advisory', N'HIGH_SWELL', N'HIGH', 1, 1, N'SOUTH_COAST', N'Department of Meteorology warns of sudden 3.0m to 3.5m swells along Southern offshore waters between Dondra and Mirissa. All captains must maintain minimum 5nm distance from outer shallows.', N'PORTAL,SMS,EMAIL', N'ACTIVE', 1, SYSUTCDATETIME(), NULL),
(2, N'Navigational Buoy Displacement - Galle Fairway', N'SAFETY_ADVISORY', N'MEDIUM', 2, NULL, N'SOUTH_COAST', N'Harbor Master reports fairway marker buoy #3 drifted 150 meters northeast following storm surge. Navigate with extreme visual caution when entering harbor channel.', N'PORTAL,SMS', N'ACTIVE', 3, SYSUTCDATETIME(), NULL),
(3, N'Pigeon Island Marine Park Underwater Visibility Notice', N'SAFETY_ADVISORY', N'LOW', 3, NULL, N'EAST_COAST', N'Runoff from coastal streams reduced underwater visibility to 6m. Snorkel groups advised to remain close to certified guides and stay inside inner reef lagoon.', N'PORTAL', N'ACTIVE', 1, SYSUTCDATETIME(), NULL),
(4, N'Kalpitiya Squall Warning & Precautionary Return', N'BAD_WEATHER', N'HIGH', 6, 5, N'WEST_COAST', N'Sudden tropical squall detected on Doppler radar 14nm offshore. Wind gusts reaching 32 knots. All small craft instructed to return to lagoon sanctuary immediately.', N'PORTAL,SMS,EMAIL', N'RESOLVED', 3, DATEADD(DAY, -5, SYSUTCDATETIME()), DATEADD(DAY, -4, SYSUTCDATETIME())),
(5, N'Southern Star Scheduled Engine Overhaul Downtime', N'TECHNICAL_DELAY', N'LOW', 8, 7, N'SOUTH_COAST', N'Southern Star Yacht is undergoing scheduled turbocharger replacement in dockyard. Charters temporarily reassigned to Serendib Odyssey.', N'PORTAL', N'ACTIVE', 2, SYSUTCDATETIME(), NULL),
(6, N'Annual Coastal Life Safety System Drill', N'SAFETY_ADVISORY', N'MEDIUM', NULL, NULL, N'ALL_REGIONS', N'All captains, tour guides, and shore operations staff are mandated to participate in the joint maritime rescue drill with Sri Lanka Coast Guard this Saturday at 08:00 AM.', N'PORTAL,SMS,EMAIL', N'ACTIVE', 1, SYSUTCDATETIME(), NULL);
GO
SET IDENTITY_INSERT [dbo].[emergency_notices] OFF;
GO

-- ==================================================
-- TABLE 15: emergency_acknowledgments (6 records)
-- ==================================================
SET IDENTITY_INSERT [dbo].[emergency_acknowledgments] ON;
GO
INSERT INTO [dbo].[emergency_acknowledgments] ([id], [notice_id], [user_id], [acknowledged_at], [notes])
VALUES
(1, 1, 4, SYSUTCDATETIME(), N'Capt. Sunil Perera acknowledged. Revised course plotted 6.5nm offshore.'),
(2, 1, 5, SYSUTCDATETIME(), N'Capt. Ranjith Silva acknowledged. Life raft check double-verified.'),
(3, 2, 5, SYSUTCDATETIME(), N'Acknowledged. GPS waypoint offset entered into navigation console.'),
(4, 3, 6, SYSUTCDATETIME(), N'Briefed snorkel dive leaders on inner reef boundary restriction.'),
(5, 4, 6, DATEADD(DAY, -5, SYSUTCDATETIME()), N'Craft safely docked at Kalpitiya marina before wind picked up.'),
(6, 6, 4, SYSUTCDATETIME(), N'Capt. Sunil confirmed crew attendance for Saturday maritime safety drill.');
GO
SET IDENTITY_INSERT [dbo].[emergency_acknowledgments] OFF;
GO

-- ==================================================
-- TABLE 16: login_details (10 records)
-- ==================================================
SET IDENTITY_INSERT [dbo].[login_details] ON;
GO
INSERT INTO [dbo].[login_details] ([id], [user_id], [full_name], [email], [role], [ip_address], [status], [login_time], [user_agent], [details])
VALUES
(1, 1, N'Kasun Jayawardena', N'admin@boatsafari.lk', N'ADMIN', N'192.168.1.10', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/129.0.0.0 Safari/537.36', N'Admin portal session initiated with two-factor authentication.'),
(2, 3, N'Chaminda Fernando', N'chaminda.officer@boatsafari.lk', N'OFFICER', N'192.168.1.25', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/131.0', N'Harbor dispatch console accessed.'),
(3, 4, N'Capt. Sunil Perera', N'sunil.captain@boatsafari.lk', N'CAPTAIN', N'124.43.12.88', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (iPhone; CPU iPhone OS 17_6 like Mac OS X) AppleWebKit/605.1.15', N'Mobile captain safety checklist portal logged in.'),
(4, 5, N'Capt. Ranjith Silva', N'ranjith.captain@boatsafari.lk', N'CAPTAIN', N'124.43.14.92', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (iPad; CPU OS 17_5 like Mac OS X) AppleWebKit/605.1.15', N'Vessel safety checklist logged.'),
(5, 7, N'Roshan Wickramasinghe', N'roshan.guide@boatsafari.lk', N'GUIDE', N'112.134.88.14', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Linux; Android 14; SM-S928B) Chrome/128.0.0.0 Mobile', N'Guide passenger manifest check.'),
(6, 11, N'Johnathan Miller', N'john.miller@gmail.com', N'CUSTOMER', N'86.154.21.90', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15', N'Customer booking confirmation viewed.'),
(7, 12, N'Elena Rostova', N'elena.rostova@yandex.com', N'CUSTOMER', N'95.173.136.22', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/129.0.0.0', N'Browsing Mirissa whale watching schedules.'),
(8, 13, N'Sarah Jenkins', N'sarah.jenkins@outlook.com', N'CUSTOMER', N'68.183.45.102', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (iPhone; CPU iPhone OS 17_6) AppleWebKit/605.1.15', N'Sunset wine cruise payment processed.'),
(9, 9, N'Dinesh Mendis', N'dinesh.owner@southernmarina.lk', N'OWNER', N'124.43.99.10', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/129.0.0.0', N'Vessel revenue and maintenance analytics accessed.'),
(10, 2, N'Dilani Perera', N'dilani.admin@boatsafari.lk', N'ADMIN', N'192.168.1.15', N'SUCCESS', SYSUTCDATETIME(), N'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_6) Chrome/129.0.0.0', N'Promotion code campaign WHALE2026 configured.');
GO
SET IDENTITY_INSERT [dbo].[login_details] OFF;
GO

-- ==================================================
-- TABLE 17: activity_logs (10 records)
-- ==================================================
SET IDENTITY_INSERT [dbo].[activity_logs] ON;
GO
INSERT INTO [dbo].[activity_logs] ([id], [user_id], [action], [module], [details], [ip_address], [created_at])
VALUES
(1, 1, N'USER_CREATE', N'USER_MANAGEMENT', N'Created new guide user account for Roshan Wickramasinghe (ID: 7).', N'192.168.1.10', SYSUTCDATETIME()),
(2, 1, N'SCHEDULE_CREATE', N'TOUR_SCHEDULING', N'Scheduled Mirissa Premier Whale Safari on Ocean Monarch for 2026-10-10.', N'192.168.1.10', SYSUTCDATETIME()),
(3, 4, N'SAFETY_CHECK_SUBMIT', N'SAFETY_MODULE', N'Submitted departure safety inspection log for Schedule #1 on vessel Ocean Monarch with 45 life vests verified.', N'124.43.12.88', SYSUTCDATETIME()),
(4, 11, N'RESERVATION_CREATE', N'BOOKING_ENGINE', N'Customer completed online reservation BK-2026-1001 for 2 passengers with promo WHALE2026.', N'86.154.21.90', SYSUTCDATETIME()),
(5, 3, N'EMERGENCY_BROADCAST', N'EMERGENCY_CENTER', N'Issued HIGH severity advisory #1 for 3.5m southern swell conditions to all active captains.', N'192.168.1.25', SYSUTCDATETIME()),
(6, 4, N'EMERGENCY_ACKNOWLEDGE', N'EMERGENCY_CENTER', N'Captain Sunil Perera acknowledged emergency notice #1.', N'124.43.12.88', SYSUTCDATETIME()),
(7, 2, N'PROMOTION_CREATE', N'MARKETING', N'Launched new seasonal discount code SUMMERSEA offering 25% off.', N'192.168.1.15', SYSUTCDATETIME()),
(8, 9, N'MAINTENANCE_LOG', N'FLEET_MANAGEMENT', N'Recorded completion of 200-hour routine service on Ocean Monarch by Southern Marine Engineering.', N'124.43.99.10', SYSUTCDATETIME()),
(9, 3, N'STATUS_UPDATE', N'FLEET_MANAGEMENT', N'Updated Southern Star Yacht status to UNDER_MAINTENANCE for turbocharger overhaul.', N'192.168.1.25', SYSUTCDATETIME()),
(10, 1, N'SYSTEM_BACKUP', N'SYSTEM_SETTINGS', N'Manual full database backup executed prior to peak safari season launch.', N'192.168.1.10', SYSUTCDATETIME());
GO
SET IDENTITY_INSERT [dbo].[activity_logs] OFF;
GO

PRINT '==================================================';
PRINT 'Sample data insertion completed successfully!';
PRINT '==================================================';
GO

-- Display summary count of all 17 tables
SELECT t.name AS [Table_Name], i.rows AS [Row_Count]
FROM sys.tables t
JOIN sys.sysindexes i ON t.object_id = i.id AND i.indid < 2
ORDER BY t.name;
GO
