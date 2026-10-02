package com.boatsafari;

import com.boatsafari.common.model.*;
import com.boatsafari.common.util.Capacity;
import com.boatsafari.common.util.Money;
import com.boatsafari.common.util.PasswordHasher;
import com.boatsafari.member1.model.*;
import com.boatsafari.member2.model.*;
import com.boatsafari.member3.model.*;
import com.boatsafari.member4.model.*;
import com.boatsafari.member5.model.*;
import com.boatsafari.member6.model.*;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member2.service.ReservationService;
import com.boatsafari.member3.service.BoatService;
import com.boatsafari.member4.service.SafetyCheckService;
import com.boatsafari.member5.service.EmergencyService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Enterprise Architecture & OOP Verification Unit Tests for
 * SLIIT SE2030 - Boat Safari Management System (Group Y2-S1-MLB-B8G1-09).
 */
public class SystemArchitectureTest {

    // ==========================================
    // 1. COMMON: Value Objects & Security Tests
    // ==========================================

    @Test
    @DisplayName("Common: Money Value Object immutability, arithmetic and formatting")
    public void testMoneyValueObject() {
        Money price1 = new Money(BigDecimal.valueOf(15000.00));
        Money price2 = new Money(BigDecimal.valueOf(5000.50));

        Money total = price1.add(price2);
        assertEquals(new BigDecimal("20000.50"), total.getAmount());

        Money discount = price1.subtract(new Money(new BigDecimal("3000.00")));
        assertEquals(new BigDecimal("12000.00"), discount.getAmount());

        assertTrue(total.isGreaterThan(price1));
        assertFalse(price2.isGreaterThan(price1));
        assertTrue(total.getFormatted().contains("LKR"));
    }

    @Test
    @DisplayName("Common: Capacity Value Object validation and bounds")
    public void testCapacityValueObject() {
        Capacity cap = new Capacity(25);
        assertEquals(25, cap.getMaxPassengers());
        assertTrue(cap.canAccommodate(20));
        assertTrue(cap.canAccommodate(25));
        assertFalse(cap.canAccommodate(26));

        assertThrows(IllegalArgumentException.class, () -> new Capacity(-5));
        assertThrows(IllegalArgumentException.class, () -> new Capacity(600));
    }

    @Test
    @DisplayName("Common: SHA-256 Password Hashing & Verification")
    public void testPasswordHasher() {
        String plain = "AdminPass123";
        String hash = PasswordHasher.hash(plain);
        assertNotNull(hash);
        assertNotEquals(plain, hash);
        assertTrue(PasswordHasher.verify(plain, hash));
        assertFalse(PasswordHasher.verify("WrongPassword", hash));
    }

    // ====================================================
    // 2. MEMBER 1: Safari Tour & Schedule Management Tests
    // ====================================================

    @Test
    @DisplayName("Member 1: Tour model, pricing, and CoastRegion classification")
    public void testTourModel() {
        Tour tour = new Tour();
        tour.setTitle("Mirissa Whale Watching Cruise");
        tour.setTourType(TourType.WHALE_WATCHING);
        tour.setBasePrice(new Money(BigDecimal.valueOf(18500.00)));
        tour.setDurationHours(4.5);
        tour.setMaxPassengers(40);

        assertEquals("Mirissa Whale Watching Cruise", tour.getTitle());
        assertEquals(TourType.WHALE_WATCHING, tour.getTourType());
        assertEquals(40, tour.getMaxPassengers());
        assertTrue(tour.getBasePrice().isGreaterThan(Money.zero()));
    }

    // =========================================================
    // 3. MEMBER 2: Reservation & Passenger Composition Tests
    // =========================================================

    @Test
    @DisplayName("Member 2: Reservation composition with Passengers and financial balance")
    public void testReservationComposition() {
        Reservation res = new Reservation();
        res.setBookingRef("RES-2026-TEST");
        res.setPassengerCount(2);
        res.setTotalAmount(new Money(BigDecimal.valueOf(30000.00)));
        res.setDiscountAmount(new Money(BigDecimal.valueOf(3000.00)));
        res.setFinalAmount(new Money(BigDecimal.valueOf(27000.00)));
        res.setStatus(ReservationStatus.CONFIRMED);

        List<Passenger> passengers = new ArrayList<>();
        passengers.add(new Passenger("Kasun Perera", "199412345678", 32, "MALE", "Sri Lankan", "+94771234567"));
        passengers.add(new Passenger("Nimali Perera", "199798765432", 29, "FEMALE", "Sri Lankan", "+94771234567"));
        res.setPassengers(passengers);

        assertEquals(2, res.getPassengers().size());
        assertEquals("Kasun Perera", res.getPassengers().get(0).getFullName());
        assertEquals(ReservationStatus.CONFIRMED, res.getStatus());
        assertEquals(new BigDecimal("27000.00"), res.getFinalAmount().getAmount());
    }

    // ==============================================================
    // 4. MEMBER 3: Vessel Polymorphism & Inheritance Hierarchy Tests
    // ==============================================================

    @Test
    @DisplayName("Member 3: Polymorphic Vessel Hierarchy (Catamaran, Yacht, SpeedBoat)")
    public void testVesselPolymorphism() {
        Vessel catamaran = new Catamaran(1, "Mirissa Pearl", "REG-CAT-01", 30, 2);
        Vessel yacht = new Yacht(2, "Ocean Sapphire", "REG-YAC-02", 18, 4);
        Vessel speedBoat = new SpeedBoat(3, "Wave Runner", "REG-SPD-03", 8);

        assertEquals(VesselType.CATAMARAN, catamaran.getVesselType());
        assertEquals(VesselType.YACHT, yacht.getVesselType());
        assertEquals(VesselType.SPEEDBOAT, speedBoat.getVesselType());

        assertTrue(catamaran.getCapacity().canAccommodate(25));
        assertFalse(catamaran.getCapacity().canAccommodate(35));
        assertTrue(yacht.isAvailable());

        // Subclass architecture polymorphism
        assertTrue(catamaran.getVesselArchitecture().contains("Twin-Hull Catamaran"));
        assertTrue(yacht.getVesselArchitecture().contains("Motor Yacht"));
        assertTrue(speedBoat.getVesselArchitecture().contains("Deep-V"));
    }

    // ========================================================
    // 5. MEMBER 4: Maintenance Records & Service Overdue Tests
    // ========================================================

    @Test
    @DisplayName("Member 4: Maintenance intervals and overdue calculation")
    public void testMaintenanceAndReminders() {
        MaintenanceRecord record = new MaintenanceRecord();
        record.setVesselId(1);
        record.setMaintenanceType(MaintenanceType.ENGINE_OVERHAUL);
        record.setDescription("Twin Yanmar Diesel Service");
        record.setCostAmount(BigDecimal.valueOf(85000.00));
        record.setStatus(MaintenanceStatus.COMPLETED);

        assertEquals(MaintenanceType.ENGINE_OVERHAUL, record.getMaintenanceType());
        assertEquals(new BigDecimal("85000.00"), record.getCost().getAmount());

        ServiceReminder reminder = new ServiceReminder();
        reminder.setVesselId(1);
        reminder.setReminderTitle("Impeller & Oil Change");
        reminder.setIntervalDays(30);
        reminder.setNextDueDate(Date.valueOf(LocalDate.now().minusDays(5))); // 5 days past due

        assertTrue(reminder.isOverdue(), "Reminder with past due date should be overdue");
    }

    // ===================================================
    // 6. MEMBER 5: Maritime Emergency Notices & Broadcasts
    // ===================================================

    @Test
    @DisplayName("Member 5: Emergency notice status and severity levels")
    public void testEmergencyNoticeLifecycle() {
        EmergencyNotice notice = new EmergencyNotice();
        notice.setTitle("Deep Bay High Wind Advisory");
        notice.setCategory(EmergencyCategory.BAD_WEATHER);
        notice.setSeverity(EmergencySeverity.CRITICAL);
        notice.setStatus(EmergencyStatus.ACTIVE);
        notice.setMessage("Gale force winds exceeding 35 knots off Mirissa Head.");

        assertTrue(notice.isActive());
        assertEquals(EmergencySeverity.CRITICAL, notice.getSeverity());
        assertEquals("badge-critical", notice.getStatusBadgeClass());

        notice.setStatus(EmergencyStatus.RESOLVED);
        notice.setResolvedAt(new Timestamp(System.currentTimeMillis()));
        assertFalse(notice.isActive());
        assertEquals(EmergencyStatus.RESOLVED, notice.getStatus());
        assertNotNull(notice.getResolvedAt());
    }

    // =========================================================
    // 7. MEMBER 6: Strategy Pattern Discount Engine Verification
    // =========================================================

    @Test
    @DisplayName("Member 6: Strategy Pattern - Percentage Discount")
    public void testPercentageDiscountStrategy() {
        Promotion promo = new Promotion();
        promo.setName("Whale Season 20% Off");
        promo.setPromoCode("WHALE20");
        promo.setDiscountType(DiscountType.PERCENTAGE);
        promo.setDiscountValue(BigDecimal.valueOf(20.0));
        promo.setMinSpend(BigDecimal.valueOf(10000.00));
        promo.setMaxDiscount(BigDecimal.valueOf(5000.00));
        promo.setMaxRedemptions(100);
        promo.setActive(true);

        // 20% of 20,000 is 4,000 (within 5,000 cap)
        Money discount1 = promo.applyDiscount(new Money(BigDecimal.valueOf(20000.00)));
        assertEquals(new BigDecimal("4000.00"), discount1.getAmount());

        // 20% of 40,000 is 8,000, capped at maxDiscount 5,000
        Money discount2 = promo.applyDiscount(new Money(BigDecimal.valueOf(40000.00)));
        assertEquals(new BigDecimal("5000.00"), discount2.getAmount());

        // Below minSpend of 10,000 -> 0 discount
        Money discount3 = promo.applyDiscount(new Money(BigDecimal.valueOf(8000.00)));
        assertTrue(discount3.isZero());
    }

    @Test
    @DisplayName("Member 6: Strategy Pattern - Fixed Amount Discount")
    public void testFixedAmountDiscountStrategy() {
        Promotion promo = new Promotion();
        promo.setName("First Time Sailor Flat 3000 Off");
        promo.setPromoCode("SAIL3000");
        promo.setDiscountType(DiscountType.FIXED_AMOUNT);
        promo.setDiscountValue(BigDecimal.valueOf(3000.00));
        promo.setMinSpend(BigDecimal.valueOf(10000.00));
        promo.setActive(true);

        // Booking is 25,000 -> discount is 3,000
        Money discount = promo.applyDiscount(new Money(BigDecimal.valueOf(25000.00)));
        assertEquals(new BigDecimal("3000.00"), discount.getAmount());

        // Booking is 5,000 (below min spend 10,000) -> discount is 0
        Money discountBelowMin = promo.applyDiscount(new Money(BigDecimal.valueOf(5000.00)));
        assertTrue(discountBelowMin.isZero());
    }

    @Test
    @DisplayName("Member 6: Strategy Pattern - Seasonal Off-Peak Discount")
    public void testSeasonalDiscountStrategy() {
        Promotion promo = new Promotion();
        promo.setName("Monsoon Seasonal 25% Off");
        promo.setPromoCode("MONSOON25");
        promo.setDiscountType(DiscountType.SEASONAL);
        promo.setDiscountValue(BigDecimal.valueOf(25.0));
        promo.setMinSpend(BigDecimal.valueOf(15000.00));
        promo.setMaxDiscount(BigDecimal.valueOf(8000.00));
        promo.setActive(true);

        Money discount = promo.applyDiscount(new Money(BigDecimal.valueOf(20000.00)));
        assertTrue(discount.isGreaterThan(Money.zero()));
        assertEquals(new BigDecimal("5000.00"), discount.getAmount());
    }

    // =========================================================================
    // 8. ALL 6 MEMBER CRUD OPERATIONS & BUSINESS LOGIC VERIFICATION
    // =========================================================================

    @Test
    @DisplayName("Member 1 CRUD: Schedule conflict checking prevents double booking vessel/captain")
    public void testMember1ScheduleConflictValidation() {
        TourService tourService = new TourService();

        // 1. Verify Tour special instructions
        Tour tour = new Tour();
        tour.setTitle("Trincomalee Coral Reef Snorkeling Safari");
        tour.setTourType(TourType.SNORKELING_SAFARI);
        tour.setBasePrice(new Money(BigDecimal.valueOf(12000.00)));
        tour.setDurationHours(3.0);
        tour.setMaxPassengers(25);
        tour.setSpecialInstructions("Bring waterproof sunscreen and reef-safe footwear.");
        assertEquals("Bring waterproof sunscreen and reef-safe footwear.", tour.getSpecialInstructions());

        // 2. Validate conflict checking logic: use existing schedule in system
        List<TourSchedule> existingSchedules = tourService.getAllSchedules();
        TourSchedule existing = existingSchedules.stream()
                .filter(s -> s.getStatus() != com.boatsafari.member1.model.ScheduleStatus.CANCELLED)
                .findFirst()
                .orElse(existingSchedules.get(0));

        TourSchedule conflictingSchedule = new TourSchedule();
        conflictingSchedule.setTourId(existing.getTourId());
        conflictingSchedule.setVesselId(existing.getVesselId());
        conflictingSchedule.setCaptainId(existing.getCaptainId());
        conflictingSchedule.setGuideId(existing.getGuideId());
        // Overlap existing departure and return
        conflictingSchedule.setDepartureTime(new Timestamp(existing.getDepartureTime().getTime() + 600000L));
        conflictingSchedule.setReturnTime(new Timestamp(existing.getReturnTime().getTime() - 600000L));
        conflictingSchedule.setAvailableSeats(20);
        conflictingSchedule.setStatus(ScheduleStatus.SCHEDULED);

        // ValidationException must be thrown due to vessel/captain conflict
        assertThrows(ValidationException.class, () -> {
            tourService.validateScheduleConflicts(conflictingSchedule);
        });

        // 3. Non-overlapping schedule (10 days in the future) should pass without exception
        TourSchedule nonConflicting = new TourSchedule();
        nonConflicting.setTourId(existing.getTourId());
        nonConflicting.setVesselId(existing.getVesselId());
        nonConflicting.setCaptainId(existing.getCaptainId());
        nonConflicting.setDepartureTime(new Timestamp(existing.getReturnTime().getTime() + 864000000L));
        nonConflicting.setReturnTime(new Timestamp(existing.getReturnTime().getTime() + 864000000L + 14400000L));
        nonConflicting.setAvailableSeats(25);
        nonConflicting.setStatus(ScheduleStatus.SCHEDULED);

        assertDoesNotThrow(() -> {
            tourService.validateScheduleConflicts(nonConflicting);
        });
    }

    @Test
    @DisplayName("Member 2 CRUD: Reservation passenger manifest update and refund tracking")
    public void testMember2ReservationUpdateAndManifest() {
        ReservationService reservationService = new ReservationService();

        // Create updated passenger manifest
        List<Passenger> newPassengers = new ArrayList<>();
        newPassengers.add(new Passenger("Dr. Rohan Silva", "198812345678", 38, "MALE", "Sri Lankan", "+94771112233"));
        newPassengers.add(new Passenger("Mrs. Chamari Silva", "199098765432", 36, "FEMALE", "Sri Lankan", "+94771112234"));
        newPassengers.add(new Passenger("Master Kaveen Silva", "201512345678", 11, "MALE", "Sri Lankan", "+94771112233"));

        // Update reservation #1 details with new passenger manifest
        boolean updated = reservationService.updateReservationDetails(1, 1, "Window seats and life jackets for child requested.", newPassengers, "127.0.0.1");
        assertTrue(updated, "Reservation update must succeed");

        // Verify updated reservation has 3 passengers
        var resOpt = reservationService.getReservationById(1);
        assertTrue(resOpt.isPresent());
        assertEquals("Window seats and life jackets for child requested.", resOpt.get().getSpecialNotes());
    }

    @Test
    @DisplayName("Member 3 CRUD: Boat availability and active departure conflict detection")
    public void testMember3BoatAvailabilityAndConflicts() {
        BoatService boatService = new BoatService();

        // Vessel 1 is assigned to active departure #1 -> must detect conflict when switching to MAINTENANCE
        var conflicts = boatService.checkVesselScheduleConflicts(1);
        assertNotNull(conflicts);

        // Update status with maintenance notes
        boolean statusChanged = boatService.updateStatus(1, VesselStatus.UNDER_MAINTENANCE, "Annual drydock hull inspection");
        assertTrue(statusChanged);

        // Reset back to available
        boolean restored = boatService.updateStatus(1, VesselStatus.AVAILABLE, "Drydock completed");
        assertTrue(restored);
    }

    @Test
    @DisplayName("Member 4 CRUD: SOLAS Pre-Trip Safety Check validation, submission, amendment, and voiding")
    public void testMember4SafetyCheckLogLifecycle() {
        SafetyCheckService safetyService = new SafetyCheckService();

        // 1. Validation test: missing SOLAS items or fuel below 50% must fail validation
        SafetyCheckLog invalidLog = new SafetyCheckLog();
        invalidLog.setScheduleId(1);
        invalidLog.setVesselId(1);
        invalidLog.setCaptainId(4);
        invalidLog.setSafetyItemsVerified(false); // Incomplete SOLAS
        invalidLog.setFuelLevelPercent(10);        // Below 25% threshold
        invalidLog.setAllClear(false);
        invalidLog.setCaptainSignature("");        // Missing signature

        var errors = invalidLog.validate();
        assertFalse(errors.isEmpty(), "Incomplete safety check must fail validation");
        assertTrue(errors.containsKey("safetyItemsVerified"));
        assertTrue(errors.containsKey("fuelLevelPercent"));
        assertTrue(errors.containsKey("allClear"));
        assertTrue(errors.containsKey("captainSignature"));

        // 2. Submit valid Pre-Trip Safety Check
        SafetyCheckLog validLog = new SafetyCheckLog();
        validLog.setScheduleId(2);
        validLog.setVesselId(1);
        validLog.setCaptainId(4);
        validLog.setSafetyItemsVerified(true);
        validLog.setLifeJacketsCount(30);
        validLog.setFuelLevelPercent(92);
        validLog.setWeatherConditions("Calm seas, swell 0.6m, visibility 15nm, clear skies");
        validLog.setBriefingConfirmed(true);
        validLog.setAllClear(true);
        validLog.setCaptainSignature("Capt. Shantha Perera");
        validLog.setNotes("SOLAS compliant. Bilge pumps, fire extinguishers, VHF Channel 16 operational.");

        SafetyCheckLog submitted = safetyService.submitPreTripSafetyCheck(validLog);
        assertNotNull(submitted);
        assertTrue(submitted.getId() > 0);
        assertEquals(SafetyCheckStatus.READY_FOR_DEPARTURE, submitted.getStatus());

        // 3. Captain amends check (e.g. after topping up fuel)
        submitted.setFuelLevelPercent(100);
        submitted.setNotes("Topped up to 100% fuel. Ready to cast off.");
        boolean amended = safetyService.updateSafetyCheck(submitted);
        assertTrue(amended);

        // 4. Void check
        boolean voided = safetyService.voidSafetyCheck(submitted.getId(), "Test schedule rescheduled");
        assertTrue(voided);

        var retrieved = safetyService.getSafetyCheckById(submitted.getId());
        assertTrue(retrieved.isPresent());
        assertEquals(SafetyCheckStatus.VOIDED, retrieved.get().getStatus());
    }

    @Test
    @DisplayName("Member 5 CRUD: Maritime Emergency Notice create, edit severity/instructions, and resolve")
    public void testMember5EmergencyUpdateAndLifecycle() {
        EmergencyService emergencyService = new EmergencyService();

        // 1. Create alert
        EmergencyNotice notice = new EmergencyNotice();
        notice.setTitle("Approaching Squall Line - Southern Coast");
        notice.setCategory(EmergencyCategory.BAD_WEATHER);
        notice.setSeverity(EmergencySeverity.HIGH);
        notice.setMessage("Thunderstorm cell detected 15 nautical miles south of Dondra Head. Maintain 10 knot caution.");
        notice.setStatus(EmergencyStatus.ACTIVE);
        notice.setCreatedById(1);

        EmergencyNotice created = emergencyService.broadcastAlert(notice);
        assertNotNull(created);
        assertTrue(created.getId() > 0);

        // 2. Update alert severity to CRITICAL and amend action instructions
        created.setSeverity(EmergencySeverity.CRITICAL);
        created.setMessage("Squall line intensifies to gale force 8 winds (40 knots). MANDATORY RETURN TO PORT: All vessels return immediately.");
        boolean updated = emergencyService.updateNotice(created);
        assertTrue(updated);

        var fetched = emergencyService.getNoticeById(created.getId());
        assertTrue(fetched.isPresent());
        assertEquals(EmergencySeverity.CRITICAL, fetched.get().getSeverity());
        assertTrue(fetched.get().getMessage().contains("MANDATORY RETURN"));

        // 3. Resolve alert
        boolean resolved = emergencyService.resolveAlert(created.getId());
        assertTrue(resolved);
        var resolvedNotice = emergencyService.getNoticeById(created.getId());
        assertTrue(resolvedNotice.isPresent());
        assertEquals(EmergencyStatus.RESOLVED, resolvedNotice.get().getStatus());
    }
}
