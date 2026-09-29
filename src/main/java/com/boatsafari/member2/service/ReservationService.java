package com.boatsafari.member2.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.dao.ActivityLogDAO;
import com.boatsafari.common.model.ActivityLog;
import com.boatsafari.common.util.Money;
import com.boatsafari.member1.model.TourSchedule;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member2.dao.PassengerDAO;
import com.boatsafari.member2.dao.ReservationDAO;
import com.boatsafari.member2.model.Passenger;
import com.boatsafari.member2.model.Reservation;
import com.boatsafari.member2.model.ReservationStatus;
import com.boatsafari.member6.service.PromotionService;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 2: Reservation Management Service Facade (Member 2: Reservation & Guest Booking Management).
 * Coordinates atomic booking processing, seat availability enforcement, and passenger manifest.
 */
public class ReservationService {
    private static final SecureRandom RANDOM = new SecureRandom();

    private final ReservationDAO reservationDAO;
    private final PassengerDAO passengerDAO;
    private final TourService tourService;
    private final PromotionService promotionService;
    private final ActivityLogDAO logDAO;

    public ReservationService() {
        this.reservationDAO = new ReservationDAO();
        this.passengerDAO = new PassengerDAO();
        this.tourService = new TourService();
        this.promotionService = new PromotionService();
        this.logDAO = new ActivityLogDAO();
    }

    public static String generateBookingReference() {
        int year = LocalDate.now().getYear();
        int seq = 1000 + RANDOM.nextInt(9000);
        return "SLC-" + year + "-" + seq;
    }

    // ==========================================
    // Member 2: CREATE
    // ==========================================
    public Reservation createBooking(Reservation reservation, List<Passenger> passengers, String ipAddress) {
        if (passengers == null || passengers.isEmpty()) {
            throw new ValidationException("At least one passenger must be registered in the manifest.");
        }

        // 1. Verify seat availability on the selected schedule
        Optional<TourSchedule> scheduleOpt = tourService.getScheduleById(reservation.getScheduleId());
        if (scheduleOpt.isEmpty()) {
            throw new ValidationException("Selected tour schedule does not exist.");
        }

        TourSchedule schedule = scheduleOpt.get();
        if (schedule.getAvailableSeats() < passengers.size()) {
            throw new ValidationException("Insufficient seats remaining on this departure (Available: " + schedule.getAvailableSeats() + ").");
        }

        // 2. Set booking reference and passenger count
        if (reservation.getBookingRef() == null || reservation.getBookingRef().isBlank()) {
            reservation.setBookingRef(generateBookingReference());
        }
        reservation.setPassengerCount(passengers.size());

        Map<String, String> errors = reservation.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Reservation data invalid", errors);
        }

        // 3. Persist reservation
        Reservation created = reservationDAO.create(reservation);

        // 4. Persist passenger manifest
        for (Passenger p : passengers) {
            p.setReservationId(created.getId());
            passengerDAO.create(p);
            created.addPassenger(p);
        }

        // 5. Deduct seats from departure schedule
        tourService.deductSeats(schedule.getId(), passengers.size());

        // 6. Record promo redemption if promo was applied
        if (created.getPromoId() != null && created.getPromoId() > 0) {
            promotionService.recordRedemption(created.getPromoId(), created.getCustomerId(), created.getId(), created.getDiscountAmount());
        }

        // 7. Audit log
        logDAO.create(new ActivityLog(created.getCustomerId(), "RESERVATION_CREATED", "RESERVATIONS", "Created booking " + created.getBookingRef() + " for " + passengers.size() + " guests.", ipAddress));

        return created;
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public List<Reservation> getAllReservations() {
        return reservationDAO.findAll();
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public List<Reservation> getReservationsByCustomer(int customerId) {
        return reservationDAO.findByCustomerId(customerId);
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public Optional<Reservation> getReservationByRef(String ref) {
        Optional<Reservation> resOpt = reservationDAO.findByBookingRef(ref);
        resOpt.ifPresent(r -> {
            r.setPassengers(passengerDAO.findByReservationId(r.getId()));
            tourService.getScheduleById(r.getScheduleId()).ifPresent(r::setSchedule);
        });
        return resOpt;
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public Optional<Reservation> getReservationById(int id) {
        Optional<Reservation> resOpt = reservationDAO.findById(id);
        resOpt.ifPresent(r -> {
            r.setPassengers(passengerDAO.findByReservationId(r.getId()));
            tourService.getScheduleById(r.getScheduleId()).ifPresent(r::setSchedule);
        });
        return resOpt;
    }

    // ==========================================
    // Member 2: DELETE / CANCEL
    // ==========================================
    public boolean cancelReservation(int reservationId, String ipAddress) {
        Optional<Reservation> resOpt = reservationDAO.findById(reservationId);
        if (resOpt.isPresent()) {
            Reservation r = resOpt.get();
            boolean ok = reservationDAO.updateStatus(reservationId, ReservationStatus.CANCELLED);
            if (ok) {
                // Restore seats to schedule
                tourService.releaseSeats(r.getScheduleId(), r.getPassengerCount());
                logDAO.create(new ActivityLog(r.getCustomerId(), "RESERVATION_CANCELLED", "RESERVATIONS", "Cancelled booking " + r.getBookingRef(), ipAddress));
            }
            return ok;
        }
        return false;
    }

    // ==========================================
    // Member 2: UPDATE
    // ==========================================
    public boolean confirmReservation(int reservationId) {
        return reservationDAO.updateStatus(reservationId, ReservationStatus.CONFIRMED);
    }

    /**
     * Customer or Reservation Officer modifies booking details (schedule, passengers, special notes) before departure.
     * System re-validates availability and updates booking.
     */
    // ==========================================
    // Member 2: UPDATE
    // ==========================================
    public boolean updateReservationDetails(int reservationId, int newScheduleId, String specialNotes, List<Passenger> updatedPassengers, String ipAddress) {
        Optional<Reservation> resOpt = reservationDAO.findById(reservationId);
        if (resOpt.isEmpty()) {
            throw new ValidationException("Reservation not found.");
        }
        Reservation r = resOpt.get();
        if (r.getStatus() == ReservationStatus.CANCELLED) {
            throw new ValidationException("Cannot modify a cancelled booking.");
        }

        // If schedule changed, verify and adjust seat availability
        if (newScheduleId > 0 && newScheduleId != r.getScheduleId()) {
            Optional<TourSchedule> newSchedOpt = tourService.getScheduleById(newScheduleId);
            if (newSchedOpt.isEmpty()) {
                throw new ValidationException("Target departure schedule not found.");
            }
            TourSchedule newSched = newSchedOpt.get();
            int paxCount = updatedPassengers != null && !updatedPassengers.isEmpty() ? updatedPassengers.size() : r.getPassengerCount();
            if (newSched.getAvailableSeats() < paxCount) {
                throw new ValidationException("Insufficient seats on the selected new departure (Available: " + newSched.getAvailableSeats() + ").");
            }

            // Release seats on old schedule, deduct from new schedule
            tourService.releaseSeats(r.getScheduleId(), r.getPassengerCount());
            tourService.deductSeats(newScheduleId, paxCount);

            r.setScheduleId(newScheduleId);
        }

        if (specialNotes != null) {
            r.setSpecialNotes(specialNotes);
        }

        // Update passengers if provided
        if (updatedPassengers != null && !updatedPassengers.isEmpty()) {
            r.setPassengerCount(updatedPassengers.size());
            passengerDAO.deleteByReservationId(r.getId());
            for (Passenger p : updatedPassengers) {
                p.setReservationId(r.getId());
                passengerDAO.create(p);
            }
            r.setPassengers(updatedPassengers);
        }

        boolean ok = reservationDAO.update(r);
        if (ok) {
            logDAO.create(new ActivityLog(r.getCustomerId(), "RESERVATION_UPDATED", "RESERVATIONS", "Updated booking " + r.getBookingRef() + " details before departure.", ipAddress));
        }
        return ok;
    }
}
