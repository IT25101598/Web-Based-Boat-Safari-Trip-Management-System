package com.boatsafari.member5.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.model.User;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.common.util.SessionHelper;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member3.service.BoatService;
import com.boatsafari.member5.model.EmergencyCategory;
import com.boatsafari.member5.model.EmergencyNotice;
import com.boatsafari.member5.model.EmergencySeverity;
import com.boatsafari.member5.service.EmergencyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Member 5: Emergency Management Controller (Member 5: Maritime Safety & Emergency Notice Management).
 */
@WebServlet(name = "EmergencyController", urlPatterns = {"/emergency", "/admin/emergency", "/admin/emergency/create", "/admin/emergency/edit", "/admin/emergency/resolve", "/admin/emergency/delete"})
public class EmergencyController extends BaseController {
    private final EmergencyService emergencyService = new EmergencyService();
    private final TourService tourService = new TourService();
    private final BoatService boatService = new BoatService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // ==========================================
        // Member 5: CREATE (Form)
        // ==========================================
        if ("/admin/emergency/create".equals(path)) {
            request.setAttribute("categories", EmergencyCategory.values());
            request.setAttribute("severities", EmergencySeverity.values());
            request.setAttribute("tours", tourService.getActiveTours());
            request.setAttribute("vessels", boatService.getAllVessels());
            render(request, response, "member5/emergency-form.jsp");
            return;
        }

        // ==========================================
        // Member 5: UPDATE (Form)
        // ==========================================
        if ("/admin/emergency/edit".equals(path)) {
            int id = getIntParam(request, "id", 0);
            var noticeOpt = emergencyService.getNoticeById(id);
            if (noticeOpt.isEmpty()) {
                flashError(request, "Emergency notice #" + id + " not found.");
                redirect(response, request.getContextPath() + "/admin/emergency");
                return;
            }
            request.setAttribute("notice", noticeOpt.get());
            request.setAttribute("categories", EmergencyCategory.values());
            request.setAttribute("severities", EmergencySeverity.values());
            request.setAttribute("tours", tourService.getActiveTours());
            request.setAttribute("vessels", boatService.getAllVessels());
            render(request, response, "member5/emergency-form.jsp");
            return;
        }

        // ==========================================
        // Member 5: READ (List)
        // ==========================================
        List<EmergencyNotice> notices = emergencyService.getAllNotices();
        request.setAttribute("notices", notices);
        request.setAttribute("activeCount", emergencyService.getActiveNotices().size());
        render(request, response, "member5/emergency-list.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/emergency");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 5: UPDATE (Resolve Alert)
        // ==========================================
        if ("/admin/emergency/resolve".equals(path)) {
            int noticeId = getIntParam(request, "id", 0);
            emergencyService.resolveAlert(noticeId);
            flashSuccess(request, "Emergency notice marked as RESOLVED (All-Clear).");
            redirect(response, request.getContextPath() + "/admin/emergency");
            return;
        }

        // ==========================================
        // Member 5: DELETE
        // ==========================================
        if ("/admin/emergency/delete".equals(path)) {
            int noticeId = getIntParam(request, "id", 0);
            emergencyService.deleteNotice(noticeId);
            flashSuccess(request, "Emergency notice archived and removed from broadcast list.");
            redirect(response, request.getContextPath() + "/admin/emergency");
            return;
        }

        // ==========================================
        // Member 5: UPDATE
        // ==========================================
        if ("/admin/emergency/edit".equals(path)) {
            int noticeId = getIntParam(request, "id", 0);
            var noticeOpt = emergencyService.getNoticeById(noticeId);
            if (noticeOpt.isEmpty()) {
                flashError(request, "Emergency notice #" + noticeId + " not found.");
                redirect(response, request.getContextPath() + "/admin/emergency");
                return;
            }

            EmergencyNotice notice = noticeOpt.get();
            notice.setTitle(getStringParam(request, "title", notice.getTitle()));
            try {
                notice.setCategory(EmergencyCategory.valueOf(getStringParam(request, "category", notice.getCategory().name())));
            } catch (Exception ignored) {}
            try {
                notice.setSeverity(EmergencySeverity.valueOf(getStringParam(request, "severity", notice.getSeverity().name())));
            } catch (Exception ignored) {}
            notice.setAffectedRegion(getStringParam(request, "affectedRegion", notice.getAffectedRegion()));
            int tourId = getIntParam(request, "affectedTourId", 0);
            notice.setAffectedTourId(tourId > 0 ? tourId : null);
            int vesselId = getIntParam(request, "affectedVesselId", 0);
            notice.setAffectedVesselId(vesselId > 0 ? vesselId : null);
            notice.setMessage(getStringParam(request, "message", notice.getMessage()));
            notice.setBroadcastChannels(getStringParam(request, "broadcastChannels", notice.getBroadcastChannels()));
            String statusStr = getStringParam(request, "status", "");
            if (!statusStr.isBlank()) {
                try {
                    notice.setStatus(com.boatsafari.member5.model.EmergencyStatus.valueOf(statusStr));
                } catch (Exception ignored) {}
            }

            try {
                emergencyService.updateNotice(notice);
                flashSuccess(request, "Emergency notice #" + noticeId + " updated successfully.");
                redirect(response, request.getContextPath() + "/admin/emergency");
            } catch (ValidationException e) {
                flashError(request, e.getMessage());
                redirect(response, request.getContextPath() + "/admin/emergency/edit?id=" + noticeId);
            }
            return;
        }

        // ==========================================
        // Member 5: CREATE
        // ==========================================
        // Broadcast New Emergency Notice
        String title = getStringParam(request, "title", "");
        String categoryStr = getStringParam(request, "category", "BAD_WEATHER");
        String severityStr = getStringParam(request, "severity", "HIGH");
        int tourId = getIntParam(request, "affectedTourId", 0);
        int vesselId = getIntParam(request, "affectedVesselId", 0);
        String region = getStringParam(request, "affectedRegion", "SOUTH_COAST");
        String message = getStringParam(request, "message", "");
        String channels = getStringParam(request, "broadcastChannels", "PORTAL,SMS,EMAIL");

        EmergencyNotice notice = new EmergencyNotice();
        notice.setTitle(title);
        try {
            notice.setCategory(EmergencyCategory.valueOf(categoryStr));
        } catch (Exception e) {
            notice.setCategory(EmergencyCategory.BAD_WEATHER);
        }
        try {
            notice.setSeverity(EmergencySeverity.valueOf(severityStr));
        } catch (Exception e) {
            notice.setSeverity(EmergencySeverity.HIGH);
        }
        if (tourId > 0) notice.setAffectedTourId(tourId);
        if (vesselId > 0) notice.setAffectedVesselId(vesselId);
        notice.setAffectedRegion(region);
        notice.setMessage(message);
        notice.setBroadcastChannels(channels);

        User current = SessionHelper.getCurrentUser(request);
        if (current != null) {
            notice.setCreatedById(current.getId());
            notice.setCreatedByName(current.getFullName());
        }

        try {
            emergencyService.broadcastAlert(notice);
            flashSuccess(request, "EMERGENCY ALERT BROADCASTED ACROSS ALL CHANNELS!");
            redirect(response, request.getContextPath() + "/admin/emergency");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + "/admin/emergency/create");
        }
    }
}
