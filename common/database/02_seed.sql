-- ====================================================================
-- Web-Based Boat Safari Trip Management System
-- Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
-- Realistic Seed Data (Sri Lankan Boat Safari Operations)
-- Inspired by Sail Lanka Charter (sail-lanka-charter.com)
-- ====================================================================

USE `boat_safari_db`;

-- --------------------------------------------------------------------
-- 1. USERS & STAKEHOLDERS (Passwords: all hashed for 'Password@123' or 'admin123')
-- SHA-256('admin123') = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
-- SHA-256('password123') = 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f'
-- --------------------------------------------------------------------
INSERT INTO `users` (`id`, `full_name`, `email`, `password_hash`, `phone`, `role`, `status`) VALUES
(1, 'System Administrator', 'admin@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 123 4567', 'ADMIN', 'ACTIVE'),
(2, 'Chief Reservation Officer', 'officer@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 234 5678', 'OFFICER', 'ACTIVE'),
(3, 'Safari Tour Operations Manager', 'tourmanager@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 345 6789', 'ADMIN', 'ACTIVE'),
(4, 'Capt. Shantha Perera (Master Mariner)', 'captain.perera@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 456 7890', 'CAPTAIN', 'ACTIVE'),
(5, 'Capt. Ruwan Kumara (Catamaran Skipper)', 'captain.kumara@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 567 8901', 'CAPTAIN', 'ACTIVE'),
(6, 'Kasun Fernando (Marine Naturalist Guide)', 'guide.kasun@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 678 9012', 'GUIDE', 'ACTIVE'),
(7, 'Dilshan Silva (Snorkeling Guide)', 'guide.dilshan@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 789 0123', 'GUIDE', 'ACTIVE'),
(8, 'Luxury Fleet Owner', 'owner@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 890 1234', 'OWNER', 'ACTIVE'),
(9, 'Chief Marine Engineer', 'maintenance@sail-safari.lk', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', '+94 77 901 2345', 'ADMIN', 'ACTIVE'),
(10, 'David Miller (Tourist / Customer)', 'david.miller@gmail.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '+44 7911 123456', 'CUSTOMER', 'ACTIVE'),
(11, 'Sarah Jenkins (Tourist / Customer)', 'sarah.j@outlook.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '+61 412 345 678', 'CUSTOMER', 'ACTIVE');

-- --------------------------------------------------------------------
-- 2. DESTINATIONS & HARBORS
-- --------------------------------------------------------------------
INSERT INTO `destinations` (`id`, `name`, `region`, `harbor_name`, `description`, `image_url`) VALUES
(1, 'Mirissa Bay & Deep Ocean Trench', 'SOUTH_COAST', 'Mirissa Fishery Harbour', 'Sri Lanka’s premier whale and dolphin watching capital. Continental shelf drops dramatically 6 miles offshore.', 'assets/img/destinations/mirissa.jpg'),
(2, 'Galle Fort Heritage Coast', 'SOUTH_COAST', 'Galle International Harbour', 'UNESCO world heritage ramparts viewed from the turquoise waters of the Indian Ocean.', 'assets/img/destinations/galle.jpg'),
(3, 'Trincomalee Natural Harbor & Pigeon Island', 'EAST_COAST', 'Trincomalee Cod Bay Pier', 'World-famous coral reefs, blacktip reef sharks, and calm blue summer sailing waters.', 'assets/img/destinations/trinco.jpg'),
(4, 'Bentota Lagoon & Sea Route', 'WEST_COAST', 'Bentota River Marina', 'Scenic blend of riverine mangrove safari and offshore open-sea cruising.', 'assets/img/destinations/bentota.jpg'),
(5, 'Passikudah Coral Bay', 'EAST_COAST', 'Passikudah Outer Pier', 'Shallow crystalline waters ideal for swimming, snorkeling, and luxury sunset champagne cruises.', 'assets/img/destinations/passikudah.jpg');

-- --------------------------------------------------------------------
-- 3. SAILING ROUTES
-- --------------------------------------------------------------------
INSERT INTO `routes` (`id`, `name`, `start_destination_id`, `end_destination_id`, `duration_hours`, `distance_nm`, `highlights`) VALUES
(1, 'Mirissa Pelagic Blue Whale Track', 1, 1, 4.5, 18.5, 'Blue Whale sightings, Spinner Dolphin pods, Flying Fish, Continental Shelf'),
(2, 'Galle Lighthouse & Coral Reef Sunset', 2, 2, 3.0, 10.0, 'Colonial Fort ramparts, Rumassala cliff, Jungle Beach, Sunset horizon'),
(3, 'Trincomalee Pigeon Island Reef Expedition', 3, 3, 5.0, 22.0, 'Coral reef snorkeling, Blacktip reef sharks, Sea turtles, Swami Rock cliff'),
(4, 'Bentota Mangrove & Ocean Breeze', 4, 4, 3.5, 12.0, 'River delta, Barberyn lighthouse offshore views, Warm coastal swimming'),
(5, 'Passikudah Bay & Coral Garden', 5, 5, 4.0, 15.0, 'Calm crystalline bay, Stand-up paddleboarding, Snorkeling safari');

-- --------------------------------------------------------------------
-- 4. BOAT FLEET (Vessels - Catamarans, Yachts, SpeedBoats)
-- --------------------------------------------------------------------
INSERT INTO `vessels` (`id`, `name`, `registration_no`, `vessel_type`, `capacity`, `cabins`, `engines`, `cruising_speed_knots`, `status`, `owner_id`, `image_url`, `safety_equipment_notes`) VALUES
(1, 'Ocean Pearl (Ceycat 55)', 'SLC-CAT-001', 'CATAMARAN', 30, 4, 'Twin 75HP Yanmar Marine Diesel', 9.5, 'AVAILABLE', 8, 'assets/img/fleet/ocean-pearl.jpg', 'SOLAS life jackets x35, Life rafts x2 (capacity 40), EPIRB, VHF Radio, First Aid Station'),
(2, 'Sapphire Blue (Topaz 48)', 'SLC-CAT-002', 'CATAMARAN', 25, 3, 'Twin 55HP Volvo Penta', 8.5, 'AVAILABLE', 8, 'assets/img/fleet/sapphire-blue.jpg', 'SOLAS life jackets x30, Life raft x1 (capacity 30), VHF Radio, Flares, Oxygen kit'),
(3, 'Ceylon Monarch (Majesty 62)', 'SLC-YACHT-003', 'YACHT', 15, 3, 'Twin 800HP MAN Marine Diesel', 18.0, 'AVAILABLE', 8, 'assets/img/fleet/ceylon-monarch.jpg', 'SOLAS life jackets x20, Life raft x1 (capacity 20), Radar, Sonar, Fire suppression system'),
(4, 'Wave Runner (SeaRay 32)', 'SLC-SPD-004', 'SPEEDBOAT', 12, 0, 'Twin 250HP Yamaha Outboards', 28.0, 'AVAILABLE', 8, 'assets/img/fleet/wave-runner.jpg', 'SOLAS life jackets x15, VHF Radio, Emergency Bilge Pump, Coastal First Aid Kit'),
(5, 'Mirissa Sun (Lagoon 42)', 'SLC-CAT-005', 'CATAMARAN', 20, 4, 'Twin 45HP Yanmar', 8.0, 'UNDER_MAINTENANCE', 8, 'assets/img/fleet/mirissa-sun.jpg', 'Full safety gear inspected March 2026; scheduled for starboard hull repainting');

-- --------------------------------------------------------------------
-- 5. SAFARI TOURS & PACKAGES
-- --------------------------------------------------------------------
INSERT INTO `tours` (`id`, `title`, `tour_type`, `route_id`, `description`, `duration_hours`, `base_price`, `max_passengers`, `inclusions`, `exclusions`, `image_url`, `is_active`) VALUES
(1, 'Mirissa Blue Whale & Dolphin Luxury Catamaran Safari', 'WHALE_WATCHING', 1, 'Sail into the deep southern Indian Ocean aboard our premier 55-foot luxury catamaran. Witness magnificent Blue Whales, Brydes Whales, and playful Spinner Dolphins with fresh gourmet breakfast and marine biologist commentary on board.', 4.5, 24500.00, 25, 'Gourmet breakfast, Tropical fruit platter, Ceylon tea & coffee, Marine naturalist guide, Binoculars, Life jackets', 'Alcoholic beverages, Hotel pickup', 'assets/img/tours/mirissa-whale.jpg', TRUE),
(2, 'Galle Fort Heritage & Sunset Champagne Sail', 'SUNSET_SAIL', 2, 'Glaze across the historic Galle coastline as the sun dips into the crimson ocean. Enjoy chilled beverages, canapés, and breathtaking vistas of the centuries-old Dutch Fort ramparts.', 3.0, 18500.00, 20, 'Welcome mocktail, Artisanal canapés, Chilled wine or beer, Snorkeling gear, Stand-up paddleboards', 'Personal gratuities', 'assets/img/tours/galle-sunset.jpg', TRUE),
(3, 'Trincomalee Pigeon Island Reef Snorkeling Safari', 'SNORKELING_SAFARI', 3, 'Discover the vibrant marine biodiversity of Sri Lanka’s east coast. Snorkel with colorful tropical fish, sea turtles, and harmless blacktip reef sharks in crystal-clear waters.', 5.0, 29000.00, 22, 'Seafood BBQ lunch, Fresh coconut water, Snorkeling masks & fins, Island marine park entry fee, Guide', 'Wetsuits, Towels', 'assets/img/tours/trinco-snorkeling.jpg', TRUE),
(4, 'Private Starlight Dine-at-Sea Yacht Experience', 'DINE_AT_SEA', 2, 'An exclusive 5-star culinary voyage anchored under the stars in a calm secluded bay. Complete with a private chef, 4-course seafood banquet, and romantic ambient lighting.', 4.0, 65000.00, 10, 'Private 4-course seafood dinner, Premium wine pairing, Dedicated steward and captain, Soft music system', 'Spirits and cocktails', 'assets/img/tours/dine-at-sea.jpg', TRUE);

-- --------------------------------------------------------------------
-- 6. TOUR SCHEDULES (Upcoming Departures)
-- --------------------------------------------------------------------
INSERT INTO `tour_schedules` (`id`, `tour_id`, `vessel_id`, `captain_id`, `guide_id`, `departure_time`, `return_time`, `available_seats`, `status`) VALUES
(1, 1, 1, 4, 6, '2026-09-20 06:30:00', '2026-09-20 11:00:00', 22, 'SCHEDULED'),
(2, 1, 1, 4, 6, '2026-09-21 06:30:00', '2026-09-21 11:00:00', 25, 'SCHEDULED'),
(3, 2, 2, 5, 7, '2026-09-20 15:30:00', '2026-09-20 18:30:00', 18, 'SCHEDULED'),
(4, 3, 2, 5, 7, '2026-09-22 08:00:00', '2026-09-22 13:00:00', 20, 'SCHEDULED'),
(5, 4, 3, 4, 6, '2026-09-22 18:00:00', '2026-09-22 22:00:00', 10, 'SCHEDULED');

-- --------------------------------------------------------------------
-- 7. PROMOTIONS & DISCOUNT STRATEGIES
-- --------------------------------------------------------------------
INSERT INTO `promotions` (`id`, `name`, `promo_code`, `discount_type`, `discount_value`, `min_spend`, `max_discount`, `max_redemptions`, `times_redeemed`, `start_date`, `end_date`, `is_active`) VALUES
(1, 'Sail Lanka Welcome Privilege', 'SAIL15', 'PERCENTAGE', 15.00, 15000.00, 10000.00, 100, 2, '2026-01-01', '2026-12-31', TRUE),
(2, 'Early Bird Safari Special', 'EARLYBIRD', 'FIXED_AMOUNT', 3500.00, 20000.00, 3500.00, 50, 1, '2026-06-01', '2026-12-31', TRUE),
(3, 'Monsoon Coastal Voyage Discount', 'MONSOON20', 'PERCENTAGE', 20.00, 25000.00, 15000.00, 30, 0, '2026-05-01', '2026-10-31', TRUE),
(4, 'Luxury Yacht Group Deal', 'LUXYACHT', 'FIXED_AMOUNT', 8000.00, 50000.00, 8000.00, 20, 0, '2026-01-01', '2026-12-31', TRUE);

-- --------------------------------------------------------------------
-- 8. SAMPLE RESERVATIONS & PASSENGERS
-- --------------------------------------------------------------------
INSERT INTO `reservations` (`id`, `booking_ref`, `schedule_id`, `customer_id`, `passenger_count`, `total_amount`, `discount_amount`, `final_amount`, `promo_id`, `status`, `special_notes`) VALUES
(1, 'SLC-2026-0901', 1, 10, 2, 49000.00, 7350.00, 41650.00, 1, 'CONFIRMED', 'Vegetarian breakfast requested for 1 guest'),
(2, 'SLC-2026-0902', 3, 11, 2, 37000.00, 3500.00, 33500.00, 2, 'CONFIRMED', 'Celebrating anniversary; requested special dessert');

INSERT INTO `passengers` (`id`, `reservation_id`, `full_name`, `id_or_passport`, `age`, `gender`, `nationality`, `emergency_contact`) VALUES
(1, 1, 'David Miller', 'GB44908123', 38, 'MALE', 'British', '+44 7911 123456'),
(2, 1, 'Emma Miller', 'GB44908124', 35, 'FEMALE', 'British', '+44 7911 123456'),
(3, 2, 'Sarah Jenkins', 'AU99201481', 29, 'FEMALE', 'Australian', '+61 412 345 678'),
(4, 2, 'Liam Evans', 'AU99201482', 31, 'MALE', 'Australian', '+61 412 345 678');

INSERT INTO `promo_redemptions` (`id`, `promo_id`, `customer_id`, `reservation_id`, `discount_applied`) VALUES
(1, 1, 10, 1, 7350.00),
(2, 2, 11, 2, 3500.00);

-- --------------------------------------------------------------------
-- 9. MAINTENANCE RECORDS & SERVICE REMINDERS
-- --------------------------------------------------------------------
INSERT INTO `maintenance_records` (`id`, `vessel_id`, `maintenance_type`, `description`, `scheduled_date`, `completed_date`, `cost`, `service_provider`, `status`) VALUES
(1, 1, 'ROUTINE_SERVICE', '500-hour engine service, oil filter replacement, fuel line purge', '2026-08-10', '2026-08-11', 85000.00, 'Colombo Marine Dockyard Eng.', 'COMPLETED'),
(2, 2, 'SAFETY_INSPECTION', 'Annual Merchant Shipping Secretariat survey and life raft recertification', '2026-08-25', '2026-08-26', 45000.00, 'Ceylon Maritime Surveyors', 'COMPLETED'),
(3, 5, 'HULL_CLEANING', 'Antifouling hull scrape and repaint, rudder bearing inspection', '2026-09-12', NULL, 125000.00, 'Galle Fishery Harbour Slipway', 'IN_PROGRESS');

INSERT INTO `service_reminders` (`id`, `vessel_id`, `reminder_title`, `interval_days`, `last_serviced_date`, `next_due_date`, `is_overdue`, `notes`) VALUES
(1, 1, 'Yanmar Port Engine Impeller Replacement', 120, '2026-06-01', '2026-09-29', FALSE, 'Inspect seawater cooling pumps'),
(2, 3, 'Majesty Yacht Generator 200hr Service', 90, '2026-05-15', '2026-08-15', TRUE, 'Overdue by 30 days! Urgent inspection required'),
(3, 4, 'Yamaha Outboard Gear Oil Change', 60, '2026-08-01', '2026-10-01', FALSE, 'Routine pre-season check');

-- --------------------------------------------------------------------
-- 10. EMERGENCY NOTICES & ADVISORIES
-- --------------------------------------------------------------------
INSERT INTO `emergency_notices` (`id`, `title`, `category`, `severity`, `affected_tour_id`, `affected_vessel_id`, `affected_region`, `message`, `broadcast_channels`, `status`, `created_by_id`, `created_at`) VALUES
(1, 'Department of Meteorology: Rough Seas Advisory for Southern Waters', 'BAD_WEATHER', 'HIGH', NULL, NULL, 'SOUTH_COAST', 'Gusty winds up to 55 km/h and wave swells reaching 2.8m expected along the Mirissa to Galle coastal belt. Morning whale watching cruises proceed under caution; afternoon sailing departures suspended.', 'PORTAL,SMS,EMAIL', 'ACTIVE', 1, NOW()),
(2, 'Technical Maintenance Delay Notice: Mirissa Sun (Lagoon 42)', 'TECHNICAL_DELAY', 'MEDIUM', NULL, 5, 'SOUTH_COAST', 'Vessel SLC-CAT-005 undergoing scheduled slipway maintenance. All existing reservations reassigned to Ocean Pearl (Ceycat 55) with zero schedule disruption.', 'PORTAL', 'ACTIVE', 3, NOW());

-- --------------------------------------------------------------------
-- 11. ACTIVITY LOGS
-- --------------------------------------------------------------------
INSERT INTO `activity_logs` (`id`, `user_id`, `action`, `module`, `details`, `ip_address`) VALUES
(1, 1, 'SYSTEM_INITIALIZATION', 'SYSTEM', 'Database seeded with default vessels, tours, users, and safety protocols', '127.0.0.1'),
(2, 2, 'BOOKING_CREATED', 'RESERVATIONS', 'Created reservation SLC-2026-0901 for David Miller with 2 passengers', '127.0.0.1'),
(3, 1, 'EMERGENCY_ALERT_POSTED', 'EMERGENCY', 'Broadcasted rough sea weather advisory for Southern Coast', '127.0.0.1');
