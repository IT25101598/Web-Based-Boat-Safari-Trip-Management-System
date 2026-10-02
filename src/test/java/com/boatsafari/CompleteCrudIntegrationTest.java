package com.boatsafari;

import com.boatsafari.common.model.*;
import com.boatsafari.common.util.Money;
import com.boatsafari.member1.dao.TourDAO;
import com.boatsafari.member1.dao.TourScheduleDAO;
import com.boatsafari.member1.model.*;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member2.dao.PassengerDAO;
import com.boatsafari.member2.dao.ReservationDAO;
import com.boatsafari.member2.model.*;
import com.boatsafari.member2.service.ReservationService;
import com.boatsafari.member3.dao.BoatDAO;
import com.boatsafari.member3.model.*;
import com.boatsafari.member3.service.BoatService;
import com.boatsafari.member4.dao.MaintenanceDAO;
import com.boatsafari.member4.model.*;
import com.boatsafari.member5.dao.EmergencyDAO;
import com.boatsafari.member5.model.*;
import com.boatsafari.member6.dao.PromotionDAO;
import com.boatsafari.member6.model.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

/**
 * End-to-End Database Integration CRUD Verification Test for All 6 Modules.
 */
public class CompleteCrudIntegrationTest {

    @Test
    @DisplayName("Module 1: Tour & Schedule CRUD complete lifecycle")
    public void testModule1TourAndScheduleCrud() {
        TourDAO tourDAO = new TourDAO();
        TourScheduleDAO scheduleDAO = new TourScheduleDAO();
        TourService tourService = new TourService();

        // 1. CREATE Tour
        Tour tour = new Tour();
        tour.setTitle("Test CRUD Lagoon Adventure");
        tour.setTourType(TourType.WHALE_WATCHING);
        tour.setRouteId(1);
        tour.setDescription("Automated test river safari");
        tour.setDurationHours(2.5);
        tour.setBasePriceAmount(BigDecimal.valueOf(8500.00));
        tour.setMaxPassengers(15);
        tour.setInclusions("Binoculars, Life Jackets");
        tour.setExclusions("Alcoholic drinks");
        tour.setSpecialInstructions("Bring waterproof phone pouch");
        tour.setImageUrl("assets/img/tours/bentota-river.jpg");
        tour.setActive(true);

        Tour createdTour = tourDAO.create(tour);
        assertNotNull(createdTour.getId(), "Created tour must receive an ID");
        int tourId = createdTour.getId();

        // 2. READ Tour
        Optional<Tour> readTourOpt = tourDAO.findById(tourId);
        assertTrue(readTourOpt.isPresent(), "Tour must be found in DB");
        Tour readTour = readTourOpt.get();
        assertEquals("Test CRUD Lagoon Adventure", readTour.getTitle());
        assertEquals("Bring waterproof phone pouch", readTour.getSpecialInstructions());

        // 3. UPDATE Tour
        readTour.setTitle("Updated CRUD Lagoon Adventure");
        readTour.setBasePriceAmount(BigDecimal.valueOf(9500.00));
        readTour.setSpecialInstructions("Updated: Bring hat and sunblock");
        boolean updatedTour = tourDAO.update(readTour);
        assertTrue(updatedTour, "Tour update must succeed");

        Optional<Tour> updatedTourOpt = tourDAO.findById(tourId);
        assertTrue(updatedTourOpt.isPresent());
        assertEquals("Updated CRUD Lagoon Adventure", updatedTourOpt.get().getTitle());
        assertEquals(new BigDecimal("9500.00"), updatedTourOpt.get().getBasePrice().getAmount());
        assertEquals("Updated: Bring hat and sunblock", updatedTourOpt.get().getSpecialInstructions());

        // 4. CREATE Schedule for this tour
        TourSchedule schedule = new TourSchedule();
        schedule.setTourId(tourId);
        schedule.setVesselId(1);
        schedule.setCaptainId(4);
        schedule.setGuideId(6);
        schedule.setDepartureTime(Timestamp.valueOf("2026-10-01 09:00:00"));
        schedule.setReturnTime(Timestamp.valueOf("2026-10-01 11:30:00"));
        schedule.setAvailableSeats(15);
        schedule.setStatus(ScheduleStatus.SCHEDULED);

        TourSchedule createdSchedule = scheduleDAO.create(schedule);
        assertNotNull(createdSchedule.getId(), "Schedule must receive generated ID");
        int schedId = createdSchedule.getId();

        // 5. READ & UPDATE Schedule Seats (Deduct & Release)
        boolean deducted = scheduleDAO.updateAvailableSeats(schedId, 3);
        assertTrue(deducted, "Seats deduction must succeed");
        Optional<TourSchedule> schedAfterDeduct = scheduleDAO.findById(schedId);
        assertTrue(schedAfterDeduct.isPresent());
        assertEquals(12, schedAfterDeduct.get().getAvailableSeats());

        boolean released = tourService.releaseSeats(schedId, 3);
        assertTrue(released, "Seats release must succeed");
        Optional<TourSchedule> schedAfterRelease = scheduleDAO.findById(schedId);
        assertTrue(schedAfterRelease.isPresent());
        assertEquals(15, schedAfterRelease.get().getAvailableSeats());

        // 6. CANCEL Schedule
        boolean cancelled = scheduleDAO.cancelSchedule(schedId, "Test cancellation");
        assertTrue(cancelled);
        Optional<TourSchedule> schedAfterCancel = scheduleDAO.findById(schedId);
        assertTrue(schedAfterCancel.isPresent());
        assertEquals(ScheduleStatus.CANCELLED, schedAfterCancel.get().getStatus());

        // 7. DELETE Tour (cascading cleanup of schedules)
        boolean deleted = tourDAO.delete(tourId);
        assertTrue(deleted, "Tour deletion must succeed");
        assertTrue(tourDAO.findById(tourId).isEmpty(), "Tour must be gone from DB");
    }

    @Test
    @DisplayName("Module 2: Reservation & Passenger CRUD complete lifecycle")
    public void testModule2ReservationCrud() {
        ReservationDAO reservationDAO = new ReservationDAO();
        PassengerDAO passengerDAO = new PassengerDAO();
        ReservationService resService = new ReservationService();

        // 1. CREATE Reservation
        String bookingRef = "RES-TEST-" + System.currentTimeMillis();
        Reservation res = new Reservation();
        res.setBookingRef(bookingRef);
        res.setScheduleId(1);
        res.setCustomerId(1);
        res.setPassengerCount(2);
        res.setTotalAmount(new Money(BigDecimal.valueOf(20000.00)));
        res.setDiscountAmount(Money.zero());
        res.setFinalAmount(new Money(BigDecimal.valueOf(20000.00)));
        res.setStatus(ReservationStatus.PENDING);
        res.setSpecialNotes("Window side seats requested");

        Reservation created = reservationDAO.create(res);
        assertNotNull(created.getId(), "Reservation ID must be generated");
        int resId = created.getId();

        // Create passenger
        Passenger p1 = new Passenger("Test Passenger", "200012345678", 26, "MALE", "Sri Lankan", "+94771234567");
        p1.setReservationId(resId);
        passengerDAO.create(p1);

        // 2. READ Reservation
        Optional<Reservation> readRes = reservationDAO.findByBookingRef(bookingRef);
        assertTrue(readRes.isPresent(), "Reservation must be found by booking ref");
        assertEquals(1, readRes.get().getScheduleId());
        assertEquals("Window side seats requested", readRes.get().getSpecialNotes());

        List<Passenger> passengers = passengerDAO.findByReservationId(resId);
        assertFalse(passengers.isEmpty(), "Passenger list must not be empty");

        // 3. UPDATE Reservation (including schedule_id update!)
        readRes.get().setScheduleId(2);
        readRes.get().setSpecialNotes("Updated: Allergic to seafood");
        readRes.get().setStatus(ReservationStatus.CONFIRMED);
        boolean updated = reservationDAO.update(readRes.get());
        assertTrue(updated, "Reservation update must succeed");

        Optional<Reservation> updatedRes = reservationDAO.findById(resId);
        assertTrue(updatedRes.isPresent());
        assertEquals(2, updatedRes.get().getScheduleId(), "Schedule ID must be updated in DB");
        assertEquals("Updated: Allergic to seafood", updatedRes.get().getSpecialNotes());
        assertEquals(ReservationStatus.CONFIRMED, updatedRes.get().getStatus());

        // 4. CANCEL Reservation
        boolean cancelled = resService.cancelReservation(resId, "127.0.0.1");
        assertTrue(cancelled, "Cancellation must succeed");
        Optional<Reservation> cancelledRes = reservationDAO.findById(resId);
        assertTrue(cancelledRes.isPresent());
        assertEquals(ReservationStatus.CANCELLED, cancelledRes.get().getStatus());

        // Clean up
        passengerDAO.deleteByReservationId(resId);
        reservationDAO.delete(resId);
    }

    @Test
    @DisplayName("Module 3: Boat Fleet Management CRUD complete lifecycle")
    public void testModule3BoatFleetCrud() {
        BoatDAO boatDAO = new BoatDAO();
        BoatService boatService = new BoatService();

        // 1. CREATE Vessel
        SpeedBoat vessel = new SpeedBoat();
        vessel.setName("Test Coral Runner");
        vessel.setRegistrationNo("SL-BOAT-TEST-99");
        vessel.setCapacityValues(12, 1);
        vessel.setEngines("Mercury 250HP Twin Outboard");
        vessel.setCruisingSpeedKnots(28.0);
        vessel.setStatus(VesselStatus.AVAILABLE);
        vessel.setImageUrl("assets/img/fleet/coral-runner.jpg");
        vessel.setSafetyEquipmentNotes("12 life jackets, fire extinguisher, GPS");

        Vessel created = boatDAO.create(vessel);
        assertNotNull(created.getId(), "Vessel must receive generated ID");
        int vesselId = created.getId();

        // 2. READ Vessel
        Optional<Vessel> readOpt = boatDAO.findById(vesselId);
        assertTrue(readOpt.isPresent());
        assertEquals("Test Coral Runner", readOpt.get().getName());
        assertEquals("SL-BOAT-TEST-99", readOpt.get().getRegistrationNo());

        // 3. UPDATE Vessel
        readOpt.get().setName("Test Coral Runner Updated");
        readOpt.get().setCruisingSpeedKnots(30.0);
        boolean updated = boatDAO.update(readOpt.get());
        assertTrue(updated, "Vessel update must succeed");

        Optional<Vessel> updatedOpt = boatDAO.findById(vesselId);
        assertTrue(updatedOpt.isPresent());
        assertEquals("Test Coral Runner Updated", updatedOpt.get().getName());

        // UPDATE Status
        boolean statusUpdated = boatDAO.updateStatus(vesselId, VesselStatus.UNDER_MAINTENANCE, "Routine engine tune-up");
        assertTrue(statusUpdated);
        Optional<Vessel> statusOpt = boatDAO.findById(vesselId);
        assertTrue(statusOpt.isPresent());
        assertEquals(VesselStatus.UNDER_MAINTENANCE, statusOpt.get().getStatus());

        // 4. DELETE Vessel
        boolean deleted = boatService.deleteVessel(vesselId);
        assertTrue(deleted, "Vessel deletion must succeed");
        assertTrue(boatDAO.findById(vesselId).isEmpty(), "Vessel must be deleted from DB");
    }

    @Test
    @DisplayName("Module 4: Safety & Maintenance CRUD complete lifecycle")
    public void testModule4MaintenanceCrud() {
        MaintenanceDAO maintenanceDAO = new MaintenanceDAO();

        // 1. CREATE Maintenance Record
        MaintenanceRecord mr = new MaintenanceRecord();
        mr.setVesselId(1);
        mr.setMaintenanceType(MaintenanceType.ROUTINE_SERVICE);
        mr.setDescription("Test routine 100-hour engine oil replacement");
        mr.setScheduledDate(Date.valueOf(LocalDate.now()));
        mr.setCostAmount(BigDecimal.valueOf(45000.00));
        mr.setServiceProvider("Lanka Marine Engineering");
        mr.setStatus(MaintenanceStatus.SCHEDULED);

        MaintenanceRecord created = maintenanceDAO.create(mr);
        assertNotNull(created.getId(), "Maintenance record must receive ID");
        int mrId = created.getId();

        // 2. READ Maintenance Record
        Optional<MaintenanceRecord> readOpt = maintenanceDAO.findById(mrId);
        assertTrue(readOpt.isPresent());
        assertEquals(MaintenanceType.ROUTINE_SERVICE, readOpt.get().getMaintenanceType());

        // 3. UPDATE Maintenance Record
        readOpt.get().setStatus(MaintenanceStatus.COMPLETED);
        readOpt.get().setCompletedDate(Date.valueOf(LocalDate.now()));
        readOpt.get().setCostAmount(BigDecimal.valueOf(48000.00));
        boolean updated = maintenanceDAO.update(readOpt.get());
        assertTrue(updated, "Maintenance record update must succeed");

        Optional<MaintenanceRecord> updatedOpt = maintenanceDAO.findById(mrId);
        assertTrue(updatedOpt.isPresent());
        assertEquals(MaintenanceStatus.COMPLETED, updatedOpt.get().getStatus());

        // 4. DELETE Maintenance Record
        boolean deleted = maintenanceDAO.delete(mrId);
        assertTrue(deleted, "Maintenance record deletion must succeed");
        assertTrue(maintenanceDAO.findById(mrId).isEmpty(), "Record must be deleted from DB");
    }

    @Test
    @DisplayName("Module 5: Emergency Management CRUD complete lifecycle")
    public void testModule5EmergencyCrud() {
        EmergencyDAO emergencyDAO = new EmergencyDAO();

        // 1. CREATE Emergency Notice
        EmergencyNotice notice = new EmergencyNotice();
        notice.setTitle("Test High Swell Advisory");
        notice.setCategory(EmergencyCategory.BAD_WEATHER);
        notice.setSeverity(EmergencySeverity.MEDIUM);
        notice.setAffectedTourId(1);
        notice.setAffectedVesselId(1);
        notice.setAffectedRegion("SOUTH_COAST");
        notice.setMessage("Rough sea conditions anticipated between 10:00 and 14:00.");
        notice.setBroadcastChannels("SMS,WEB_BANNER");
        notice.setStatus(EmergencyStatus.ACTIVE);
        notice.setCreatedById(1);

        EmergencyNotice created = emergencyDAO.create(notice);
        assertNotNull(created.getId(), "Emergency notice must receive ID");
        int noticeId = created.getId();

        // 2. READ Emergency Notice
        Optional<EmergencyNotice> readOpt = emergencyDAO.findById(noticeId);
        assertTrue(readOpt.isPresent());
        assertEquals("Test High Swell Advisory", readOpt.get().getTitle());
        assertEquals(Integer.valueOf(1), readOpt.get().getAffectedTourId());
        assertEquals(Integer.valueOf(1), readOpt.get().getAffectedVesselId());

        // 3. UPDATE Emergency Notice (including affected_tour_id and affected_vessel_id)
        readOpt.get().setTitle("Updated High Swell Warning");
        readOpt.get().setSeverity(EmergencySeverity.CRITICAL);
        readOpt.get().setAffectedTourId(null);
        readOpt.get().setAffectedVesselId(null);
        boolean updated = emergencyDAO.update(readOpt.get());
        assertTrue(updated, "Emergency notice update must succeed");

        Optional<EmergencyNotice> updatedOpt = emergencyDAO.findById(noticeId);
        assertTrue(updatedOpt.isPresent());
        assertEquals("Updated High Swell Warning", updatedOpt.get().getTitle());
        assertEquals(EmergencySeverity.CRITICAL, updatedOpt.get().getSeverity());
        assertNull(updatedOpt.get().getAffectedTourId(), "affected_tour_id must be updated to NULL in DB");
        assertNull(updatedOpt.get().getAffectedVesselId(), "affected_vessel_id must be updated to NULL in DB");

        // Resolve Notice
        boolean resolved = emergencyDAO.resolveNotice(noticeId);
        assertTrue(resolved);
        Optional<EmergencyNotice> resolvedOpt = emergencyDAO.findById(noticeId);
        assertTrue(resolvedOpt.isPresent());
        assertEquals(EmergencyStatus.RESOLVED, resolvedOpt.get().getStatus());

        // 4. DELETE Emergency Notice
        boolean deleted = emergencyDAO.delete(noticeId);
        assertTrue(deleted, "Emergency notice deletion must succeed");
        assertTrue(emergencyDAO.findById(noticeId).isEmpty(), "Notice must be deleted from DB");
    }

    @Test
    @DisplayName("Module 6: Promotion Management CRUD complete lifecycle")
    public void testModule6PromotionCrud() {
        PromotionDAO promoDAO = new PromotionDAO();

        // 1. CREATE Promotion
        String promoCode = "TESTPROMO" + (int)(Math.random() * 9000 + 1000);
        Promotion promo = new Promotion();
        promo.setName("Test Seasonal Flash Sale");
        promo.setPromoCode(promoCode);
        promo.setDiscountType(DiscountType.PERCENTAGE);
        promo.setDiscountValue(BigDecimal.valueOf(15.00));
        promo.setMinSpend(BigDecimal.valueOf(10000.00));
        promo.setMaxDiscount(BigDecimal.valueOf(5000.00));
        promo.setMaxRedemptions(50);
        promo.setStartDate(Date.valueOf(LocalDate.now()));
        promo.setEndDate(Date.valueOf(LocalDate.now().plusMonths(1)));
        promo.setActive(true);

        Promotion created = promoDAO.create(promo);
        assertNotNull(created.getId(), "Promotion must receive generated ID");
        int promoId = created.getId();

        // 2. READ Promotion
        Optional<Promotion> readOpt = promoDAO.findByCode(promoCode);
        assertTrue(readOpt.isPresent());
        assertEquals("Test Seasonal Flash Sale", readOpt.get().getName());
        assertEquals(new BigDecimal("15.00"), readOpt.get().getDiscountValue());

        // 3. UPDATE Promotion
        readOpt.get().setName("Updated Flash Sale");
        readOpt.get().setDiscountValue(BigDecimal.valueOf(20.00));
        boolean updated = promoDAO.update(readOpt.get());
        assertTrue(updated, "Promotion update must succeed");

        Optional<Promotion> updatedOpt = promoDAO.findById(promoId);
        assertTrue(updatedOpt.isPresent());
        assertEquals("Updated Flash Sale", updatedOpt.get().getName());
        assertEquals(new BigDecimal("20.00"), updatedOpt.get().getDiscountValue());

        // Increment usage
        boolean incremented = promoDAO.incrementUsage(promoId);
        assertTrue(incremented);
        Optional<Promotion> incOpt = promoDAO.findById(promoId);
        assertTrue(incOpt.isPresent());
        assertEquals(1, incOpt.get().getTimesRedeemed());

        // 4. DELETE Promotion
        boolean deleted = promoDAO.delete(promoId);
        assertTrue(deleted, "Promotion deletion must succeed");
        assertTrue(promoDAO.findById(promoId).isEmpty(), "Promotion must be deleted from DB");
    }
}
