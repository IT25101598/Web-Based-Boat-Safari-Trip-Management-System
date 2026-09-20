package com.boatsafari.member2.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member2.model.Passenger;
import com.boatsafari.member2.model.Reservation;
import com.boatsafari.member2.service.ReservationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Member 2: Reservation Management Controller (Member 2: Reservation & Guest Booking Management).
 */
@WebServlet(name = "ReservationController", urlPatterns = {"/reservations", "/admin/reservations", "/reservations/view", "/reservations/edit", "/reservations/cancel", "/reservations/confirm"})
public class ReservationController extends BaseController {
    private final ReservationService reservationService = new ReservationService();
    private final TourService tourService = new TourService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // ==========================================
        // Member 2: READ
        // ==========================================
        if ("/reservations/view".equals(path)) {
            String ref = getStringParam(request, "ref", "");
            int id = getIntParam(request, "id", 0);

            Optional<Reservation> resOpt = id > 0 ? reservationService.getReservationById(id) : reservationService.getReservationByRef(ref);
            if (resOpt.isPresent()) {
                request.setAttribute("reservation", resOpt.get());
                render(request, response, "member2/reservation-view.jsp");
            } else {
                flashError(request, "Reservation not found.");
                redirect(response, request.getContextPath() + "/reservations");
            }
            return;
        }

        // ==========================================
        // Member 2: UPDATE (Form)
        // ==========================================
        if ("/reservations/edit".equals(path)) {
            int id = getIntParam(request, "id", 0);
            Optional<Reservation> resOpt = reservationService.getReservationById(id);
            if (resOpt.isPresent()) {
                request.setAttribute("reservation", resOpt.get());
                request.setAttribute("schedules", tourService.getUpcomingSchedules());
                render(request, response, "member2/reservation-edit.jsp");
            } else {
                flashError(request, "Reservation not found for modification.");
                redirect(response, request.getContextPath() + "/reservations");
            }
            return;
        }

        // ==========================================
        // Member 2: READ
        // ==========================================
        // List reservations with search keyword
        String search = getStringParam(request, "search", "");
        List<Reservation> list = reservationService.getAllReservations();
        if (!search.isEmpty()) {
            list = list.stream().filter(r ->
                    r.getBookingRef().contains(search.toUpperCase()) ||
                    (r.getCustomerName() != null && r.getCustomerName().toLowerCase().contains(search.toLowerCase())) ||
                    (r.getTourTitle() != null && r.getTourTitle().toLowerCase().contains(search.toLowerCase()))
            ).toList();
        }

        request.setAttribute("reservations", list);
        request.setAttribute("search", search);
        render(request, response, "member2/reservation-list.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/reservations");
            return;
        }

        String path = request.getServletPath();
        int resId = getIntParam(request, "id", 0);

        // ==========================================
        // Member 2: DELETE / CANCEL
        // ==========================================
        if ("/reservations/cancel".equals(path)) {
            reservationService.cancelReservation(resId, getClientIp(request));
            flashSuccess(request, "Reservation has been cancelled, seats released, and refund process initiated.");
            redirect(response, request.getContextPath() + "/reservations");
            return;
        } 
        
        // ==========================================
        // Member 2: UPDATE
        // ==========================================
        if ("/reservations/confirm".equals(path)) {
            reservationService.confirmReservation(resId);
            flashSuccess(request, "Reservation status confirmed.");
            redirect(response, request.getContextPath() + "/reservations");
            return;
        }

        // ==========================================
        // Member 2: UPDATE
        // ==========================================
        if ("/reservations/edit".equals(path)) {
            int scheduleId = getIntParam(request, "scheduleId", 0);
            String specialNotes = getStringParam(request, "specialNotes", "");

            // Extract passenger rows
            String[] names = request.getParameterValues("passengerName");
            String[] passports = request.getParameterValues("idOrPassport");
            String[] ages = request.getParameterValues("age");
            String[] genders = request.getParameterValues("gender");
            String[] nationalities = request.getParameterValues("nationality");

            List<Passenger> updatedPassengers = new ArrayList<>();
            if (names != null) {
                for (int i = 0; i < names.length; i++) {
                    if (names[i] != null && !names[i].isBlank()) {
                        Passenger p = new Passenger();
                        p.setReservationId(resId);
                        p.setFullName(names[i]);
                        p.setIdOrPassport(passports != null && i < passports.length ? passports[i] : "N/A");
                        try {
                            p.setAge(ages != null && i < ages.length ? Integer.parseInt(ages[i]) : 30);
                        } catch (Exception e) {
                            p.setAge(30);
                        }
                        p.setGender(genders != null && i < genders.length ? genders[i] : "OTHER");
                        p.setNationality(nationalities != null && i < nationalities.length ? nationalities[i] : "Sri Lankan");
                        p.setEmergencyContact("+94 77 000 0000");
                        updatedPassengers.add(p);
                    }
                }
            }

            try {
                reservationService.updateReservationDetails(resId, scheduleId, specialNotes, updatedPassengers, getClientIp(request));
                flashSuccess(request, "Reservation details modified and confirmed successfully!");
                redirect(response, request.getContextPath() + "/reservations/view?id=" + resId);
            } catch (ValidationException e) {
                flashError(request, e.getMessage());
                redirect(response, request.getContextPath() + "/reservations/edit?id=" + resId);
            }
        }
    }
}
