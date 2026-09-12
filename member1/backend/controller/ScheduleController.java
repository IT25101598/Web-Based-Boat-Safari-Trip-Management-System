package com.boatsafari.member1.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.service.UserService;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.member1.model.TourSchedule;
import com.boatsafari.member1.service.TourService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Member 1: Tour Schedule & Departures Controller (Member 1: Safari Tour & Schedule Management).
 */
@WebServlet(name = "ScheduleController", urlPatterns = {"/schedules", "/admin/schedules", "/admin/schedules/create", "/admin/schedules/edit", "/admin/schedules/cancel", "/admin/schedules/delete", "/schedules/cancel"})
public class ScheduleController extends BaseController {
    private final TourService tourService = new TourService();
    private final UserService userService = new UserService();
    private final com.boatsafari.member3.service.BoatService boatService = new com.boatsafari.member3.service.BoatService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // ==========================================
        // Member 1: CREATE (Show Departure Schedule Form)
        // ==========================================
        if ("/admin/schedules/create".equals(path)) {
            request.setAttribute("tours", tourService.getActiveTours());
            request.setAttribute("boats", boatService.getAllVessels());
            request.setAttribute("captains", userService.getCaptains());
            request.setAttribute("guides", userService.getTourGuides());
            render(request, response, "member1/schedule-form.jsp");
            return;
        }

        // ==========================================
        // Member 1: UPDATE (Show Edit Departure Schedule Form)
        // ==========================================
        if ("/admin/schedules/edit".equals(path)) {
            int scheduleId = getIntParam(request, "id", 0);
            var schedOpt = tourService.getScheduleById(scheduleId);
            if (schedOpt.isEmpty()) {
                flashError(request, "Schedule #" + scheduleId + " not found.");
                redirect(response, request.getContextPath() + "/admin/schedules");
                return;
            }
            request.setAttribute("schedule", schedOpt.get());
            request.setAttribute("tours", tourService.getActiveTours());
            request.setAttribute("boats", boatService.getAllVessels());
            request.setAttribute("captains", userService.getCaptains());
            request.setAttribute("guides", userService.getTourGuides());
            render(request, response, "member1/schedule-form.jsp");
            return;
        }

        // ==========================================
        // Member 1: READ (List Departure Schedules)
        // ==========================================
        List<TourSchedule> schedules = tourService.getAllSchedules();
        request.setAttribute("schedules", schedules);
        render(request, response, "member1/schedule-list.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/schedules");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 1: DELETE / CANCEL (Cancel Departure Schedule)
        // ==========================================
        if ("/admin/schedules/cancel".equals(path) || "/admin/schedules/delete".equals(path) || "/schedules/cancel".equals(path)) {
            int scheduleId = getIntParam(request, "id", 0);
            String reason = getStringParam(request, "reason", "Operational adjustment");
            boolean ok = tourService.cancelSchedule(scheduleId, reason);
            if (ok) {
                flashSuccess(request, "Tour departure marked as cancelled.");
            } else {
                flashError(request, "Could not cancel schedule #" + scheduleId + ".");
            }
            redirect(response, request.getContextPath() + "/admin/schedules");
            return;
        }

        // ==========================================
        // Member 1: UPDATE (Update Departure Schedule Handler)
        // ==========================================
        if ("/admin/schedules/edit".equals(path)) {
            int scheduleId = getIntParam(request, "id", 0);
            var schedOpt = tourService.getScheduleById(scheduleId);
            if (schedOpt.isEmpty()) {
                flashError(request, "Schedule #" + scheduleId + " not found.");
                redirect(response, request.getContextPath() + "/admin/schedules");
                return;
            }

            int tourId = getIntParam(request, "tourId", 0);
            int vesselId = getIntParam(request, "vesselId", 1);
            int captainId = getIntParam(request, "captainId", 4);
            int guideId = getIntParam(request, "guideId", 6);
            String depTimeStr = getStringParam(request, "departureTime", "");
            String retTimeStr = getStringParam(request, "returnTime", "");
            int seats = getIntParam(request, "availableSeats", 20);
            String statusStr = getStringParam(request, "status", "SCHEDULED");

            try {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                Timestamp dep = Timestamp.valueOf(LocalDateTime.parse(depTimeStr, formatter));
                Timestamp ret = Timestamp.valueOf(LocalDateTime.parse(retTimeStr, formatter));

                TourSchedule schedule = schedOpt.get();
                schedule.setTourId(tourId);
                schedule.setVesselId(vesselId);
                schedule.setCaptainId(captainId);
                schedule.setGuideId(guideId);
                schedule.setDepartureTime(dep);
                schedule.setReturnTime(ret);
                schedule.setAvailableSeats(seats);
                try {
                    schedule.setStatus(com.boatsafari.member1.model.ScheduleStatus.valueOf(statusStr));
                } catch (Exception ignored) {}

                tourService.updateSchedule(schedule);
                flashSuccess(request, "Tour departure schedule #" + scheduleId + " updated successfully!");
                redirect(response, request.getContextPath() + "/admin/schedules");
            } catch (ValidationException e) {
                flashError(request, e.getMessage());
                redirect(response, request.getContextPath() + "/admin/schedules/edit?id=" + scheduleId);
            } catch (Exception e) {
                flashError(request, "Invalid date/time format: " + e.getMessage());
                redirect(response, request.getContextPath() + "/admin/schedules/edit?id=" + scheduleId);
            }
            return;
        }

        // ==========================================
        // Member 1: CREATE (Create Departure Schedule Handler)
        // ==========================================
        // Create new schedule
        int tourId = getIntParam(request, "tourId", 0);
        int vesselId = getIntParam(request, "vesselId", 1);
        int captainId = getIntParam(request, "captainId", 4);
        int guideId = getIntParam(request, "guideId", 6);
        String depTimeStr = getStringParam(request, "departureTime", "");
        String retTimeStr = getStringParam(request, "returnTime", "");
        int seats = getIntParam(request, "availableSeats", 20);

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            Timestamp dep = Timestamp.valueOf(LocalDateTime.parse(depTimeStr, formatter));
            Timestamp ret = Timestamp.valueOf(LocalDateTime.parse(retTimeStr, formatter));

            TourSchedule schedule = new TourSchedule();
            schedule.setTourId(tourId);
            schedule.setVesselId(vesselId);
            schedule.setCaptainId(captainId);
            schedule.setGuideId(guideId);
            schedule.setDepartureTime(dep);
            schedule.setReturnTime(ret);
            schedule.setAvailableSeats(seats);

            tourService.createSchedule(schedule);
            flashSuccess(request, "Tour departure successfully scheduled!");
            redirect(response, request.getContextPath() + "/admin/schedules");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + "/admin/schedules/create");
        } catch (Exception e) {
            flashError(request, "Invalid date/time format: " + e.getMessage());
            redirect(response, request.getContextPath() + "/admin/schedules/create");
        }
    }
}
