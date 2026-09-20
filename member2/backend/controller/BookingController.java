package com.boatsafari.member2.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.model.User;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.common.util.Money;
import com.boatsafari.common.util.SessionHelper;
import com.boatsafari.member1.model.Tour;
import com.boatsafari.member1.model.TourSchedule;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member2.model.Passenger;
import com.boatsafari.member2.model.Reservation;
import com.boatsafari.member2.model.ReservationStatus;
import com.boatsafari.member2.service.ReservationService;
import com.boatsafari.member6.model.Promotion;
import com.boatsafari.member6.service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Member 2: Customer Public Booking Wizard & Passenger Manifest Controller (Member 2: Reservation & Guest Booking Management).
 */
@WebServlet(name = "BookingController", urlPatterns = {"/booking", "/book", "/booking/submit", "/book/submit", "/booking/confirmation", "/book/confirmation", "/my-bookings"})
public class BookingController extends BaseController {
    private final TourService tourService = new TourService();
    private final ReservationService reservationService = new ReservationService();
    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // ==========================================
        // Member 2: READ (Customer Booking Manifest)
        // ==========================================
        if ("/my-bookings".equals(path)) {
            User current = SessionHelper.getCurrentUser(request);
            if (current == null) {
                redirect(response, request.getContextPath() + "/login?returnUrl=/my-bookings");
                return;
            }
            List<Reservation> customerBookings = reservationService.getReservationsByCustomer(current.getId());
            request.setAttribute("bookings", customerBookings);
            render(request, response, "member2/my-bookings.jsp");
            return;
        }

        // ==========================================
        // Member 2: READ (Booking Confirmation)
        // ==========================================
        if ("/booking/confirmation".equals(path)) {
            String ref = getStringParam(request, "ref", "");
            Optional<Reservation> resOpt = reservationService.getReservationByRef(ref);
            if (resOpt.isPresent()) {
                request.setAttribute("reservation", resOpt.get());
                render(request, response, "member2/booking-confirmation.jsp");
            } else {
                flashError(request, "Booking confirmation not found.");
                redirect(response, request.getContextPath() + "/home");
            }
            return;
        }

        // ==========================================
        // Member 2: CREATE (Booking Wizard Form)
        // ==========================================
        // Booking Wizard Form
        int preselectedTourId = getIntParam(request, "tourId", 0);
        int preselectedScheduleId = getIntParam(request, "scheduleId", 0);

        request.setAttribute("tours", tourService.getActiveTours());
        request.setAttribute("schedules", tourService.getUpcomingSchedules());
        request.setAttribute("selectedTourId", preselectedTourId);
        request.setAttribute("selectedScheduleId", preselectedScheduleId);
        render(request, response, "member2/booking-wizard.jsp");
    }

    // ==========================================
    // Member 2: CREATE (Submit Reservation)
    // ==========================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/booking");
            return;
        }

        int scheduleId = getIntParam(request, "scheduleId", 0);
        String promoCode = getStringParam(request, "promoCode", "");
        String notes = getStringParam(request, "specialNotes", "");
        int guestCount = getIntParam(request, "guestCount", 1);

        Optional<TourSchedule> schedOpt = tourService.getScheduleById(scheduleId);
        if (schedOpt.isEmpty()) {
            flashError(request, "Please select a valid scheduled safari departure.");
            redirect(response, request.getContextPath() + "/booking");
            return;
        }

        TourSchedule sched = schedOpt.get();
        Optional<Tour> tourOpt = tourService.getTourById(sched.getTourId());
        if (tourOpt.isEmpty()) {
            flashError(request, "Associated safari tour could not be loaded.");
            redirect(response, request.getContextPath() + "/booking");
            return;
        }

        Tour tour = tourOpt.get();
        User currentUser = SessionHelper.getCurrentUser(request);
        int customerId = currentUser != null ? currentUser.getId() : 10; // Default to guest/demo customer if not logged in

        // Parse passenger manifest list
        List<Passenger> manifest = new ArrayList<>();
        for (int i = 1; i <= guestCount; i++) {
            String pName = getStringParam(request, "passengerName_" + i, "Guest " + i);
            String pId = getStringParam(request, "passengerId_" + i, "DOC-" + i);
            int pAge = getIntParam(request, "passengerAge_" + i, 28);
            String pGender = getStringParam(request, "passengerGender_" + i, "MALE");
            String pNat = getStringParam(request, "passengerNat_" + i, "Sri Lankan");
            String pContact = getStringParam(request, "passengerContact_" + i, "");

            manifest.add(new Passenger(pName, pId, pAge, pGender, pNat, pContact));
        }

        // Calculate Pricing
        Money baseUnitPrice = tour.getBasePrice();
        Money total = baseUnitPrice.multiply(guestCount);
        Money discount = Money.zero();
        Integer appliedPromoId = null;

        if (!promoCode.isBlank()) {
            Optional<Promotion> promoOpt = promotionService.findValidPromo(promoCode, total);
            if (promoOpt.isPresent()) {
                Promotion promo = promoOpt.get();
                discount = promo.applyDiscount(total);
                appliedPromoId = promo.getId();
            }
        }

        Money finalPrice = total.subtract(discount);

        Reservation res = new Reservation();
        res.setScheduleId(scheduleId);
        res.setCustomerId(customerId);
        res.setPassengerCount(guestCount);
        res.setTotalAmount(total);
        res.setDiscountAmount(discount);
        res.setFinalAmount(finalPrice);
        res.setPromoId(appliedPromoId);
        res.setPromoCode(promoCode);
        res.setSpecialNotes(notes);
        res.setStatus(ReservationStatus.CONFIRMED);

        try {
            Reservation created = reservationService.createBooking(res, manifest, getClientIp(request));
            flashSuccess(request, "Your luxury boat safari booking has been successfully confirmed!");
            redirect(response, request.getContextPath() + "/booking/confirmation?ref=" + created.getBookingRef());
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + "/booking");
        }
    }
}
