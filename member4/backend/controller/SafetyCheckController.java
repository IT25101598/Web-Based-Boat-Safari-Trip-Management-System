package com.boatsafari.member4.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.model.User;
import com.boatsafari.common.service.UserService;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.common.util.SessionHelper;
import com.boatsafari.member1.model.TourSchedule;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member3.service.BoatService;
import com.boatsafari.member4.model.SafetyCheckLog;
import com.boatsafari.member4.model.SafetyCheckStatus;
import com.boatsafari.member4.service.SafetyCheckService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Member 4: Pre-Trip Safety Check Controller.
 * Manages the Boat Captain's maritime pre-trip inspection checklist CRUD workflow.
 * 
 * Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
 */
@WebServlet(name = "SafetyCheckController", urlPatterns = {
        "/safety-checks", 
        "/admin/safety-checks", 
        "/safety-checks/create", 
        "/safety-checks/view", 
        "/safety-checks/edit", 
        "/safety-checks/void",
        "/admin/safety-checks/void",
        "/safety-checks/delete",
        "/admin/safety-checks/delete"
})
public class SafetyCheckController extends BaseController {
    private final SafetyCheckService safetyCheckService = new SafetyCheckService();
    private final TourService tourService = new TourService();
    private final BoatService boatService = new BoatService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            // ==========================================
            // Member 4: CREATE (Form)
            // ==========================================
            case "/safety-checks/create":
                int preScheduleId = getIntParam(request, "scheduleId", 0);
                List<TourSchedule> upcoming = tourService.getUpcomingSchedules();
                request.setAttribute("schedules", upcoming);
                request.setAttribute("vessels", boatService.getAllVessels());
                request.setAttribute("selectedScheduleId", preScheduleId);

                User user = SessionHelper.getCurrentUser(request);
                request.setAttribute("currentCaptain", user != null ? user.getFullName() : "Capt. Shantha Perera (Master Mariner)");
                request.setAttribute("currentCaptainId", user != null ? user.getId() : 4);
                render(request, response, "member4/safety-check-form.jsp");
                break;

            // ==========================================
            // Member 4: READ
            // ==========================================
            case "/safety-checks/view":
                int viewId = getIntParam(request, "id", 0);
                Optional<SafetyCheckLog> viewOpt = safetyCheckService.getSafetyCheckById(viewId);
                if (viewOpt.isPresent()) {
                    request.setAttribute("log", viewOpt.get());
                    render(request, response, "member4/safety-check-view.jsp");
                } else {
                    flashError(request, "Safety check record not found.");
                    redirect(response, request.getContextPath() + "/safety-checks");
                }
                break;

            // ==========================================
            // Member 4: UPDATE (Form)
            // ==========================================
            case "/safety-checks/edit":
                int editId = getIntParam(request, "id", 0);
                Optional<SafetyCheckLog> editOpt = safetyCheckService.getSafetyCheckById(editId);
                if (editOpt.isPresent()) {
                    request.setAttribute("log", editOpt.get());
                    request.setAttribute("schedules", tourService.getUpcomingSchedules());
                    request.setAttribute("vessels", boatService.getAllVessels());
                    render(request, response, "member4/safety-check-form.jsp");
                } else {
                    flashError(request, "Safety check record not found for amendment.");
                    redirect(response, request.getContextPath() + "/safety-checks");
                }
                break;

            // ==========================================
            // Member 4: READ (List)
            // ==========================================
            case "/safety-checks":
            case "/admin/safety-checks":
            default:
                List<SafetyCheckLog> logs = safetyCheckService.getAllSafetyChecks();
                request.setAttribute("logs", logs);
                request.setAttribute("schedules", tourService.getUpcomingSchedules());
                render(request, response, "member4/safety-check-list.jsp");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/safety-checks");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 4: DELETE / VOID
        // ==========================================
        // 1. Void / Delete Check
        if ("/safety-checks/void".equals(path) || "/admin/safety-checks/void".equals(path) || "/safety-checks/delete".equals(path) || "/admin/safety-checks/delete".equals(path)) {
            int id = getIntParam(request, "id", 0);
            String reason = getStringParam(request, "reason", "Entered in error");
            boolean ok = safetyCheckService.voidSafetyCheck(id, reason);
            if (ok) {
                flashSuccess(request, "Safety check record #" + id + " has been marked as VOIDED.");
            } else {
                flashError(request, "Could not void safety check #" + id + ".");
            }
            redirect(response, request.getContextPath() + (path.startsWith("/admin") ? "/admin/safety-checks" : "/safety-checks"));
            return;
        }

        // 2. Create or Update Safety Check Log
        int id = getIntParam(request, "id", 0);
        int scheduleId = getIntParam(request, "scheduleId", 0);
        int vesselId = getIntParam(request, "vesselId", 0);
        int captainId = getIntParam(request, "captainId", 4);
        boolean safetyVerified = "on".equalsIgnoreCase(request.getParameter("safetyItemsVerified")) || "true".equalsIgnoreCase(request.getParameter("safetyItemsVerified"));
        int lifeJackets = getIntParam(request, "lifeJacketsCount", 30);
        int fuelPercent = getIntParam(request, "fuelLevelPercent", 100);
        String weather = getStringParam(request, "weatherConditions", "");
        boolean briefing = "on".equalsIgnoreCase(request.getParameter("briefingConfirmed")) || "true".equalsIgnoreCase(request.getParameter("briefingConfirmed"));
        boolean allClear = "on".equalsIgnoreCase(request.getParameter("allClear")) || "true".equalsIgnoreCase(request.getParameter("allClear"));
        String signature = getStringParam(request, "captainSignature", "");
        String notes = getStringParam(request, "notes", "");

        SafetyCheckLog log = new SafetyCheckLog();
        if (id > 0) log.setId(id);
        log.setScheduleId(scheduleId);
        log.setVesselId(vesselId);
        log.setCaptainId(captainId);
        log.setSafetyItemsVerified(safetyVerified);
        log.setLifeJacketsCount(lifeJackets);
        log.setFuelLevelPercent(fuelPercent);
        log.setWeatherConditions(weather);
        log.setBriefingConfirmed(briefing);
        log.setAllClear(allClear);
        log.setCaptainSignature(signature);
        log.setStatus(SafetyCheckStatus.READY_FOR_DEPARTURE);
        log.setNotes(notes);

        try {
            if (id > 0) {
                // ==========================================
                // Member 4: UPDATE
                // ==========================================
                safetyCheckService.updateSafetyCheck(log);
                flashSuccess(request, "Pre-trip safety check amended successfully! Vessel clearance confirmed.");
            } else {
                // ==========================================
                // Member 4: CREATE
                // ==========================================
                safetyCheckService.submitPreTripSafetyCheck(log);
                flashSuccess(request, "ALL CLEAR! Pre-trip safety check logged. Vessel is marked READY FOR DEPARTURE!");
            }
            redirect(response, request.getContextPath() + "/safety-checks");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + (id > 0 ? "/safety-checks/edit?id=" + id : "/safety-checks/create?scheduleId=" + scheduleId));
        }
    }
}
