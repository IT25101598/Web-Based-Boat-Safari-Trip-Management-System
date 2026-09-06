package com.boatsafari.common.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.model.User;
import com.boatsafari.common.service.UserService;
import com.boatsafari.common.util.SessionHelper;
import com.boatsafari.member1.service.TourService;
import com.boatsafari.member2.service.ReservationService;
import com.boatsafari.member3.service.BoatService;
import com.boatsafari.member4.service.MaintenanceService;
import com.boatsafari.member5.service.EmergencyService;
import com.boatsafari.member6.service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Public Portal & Back-Office Master Dashboard Controller (Common Function).
 * Inspired by Sail Lanka Charter (sail-lanka-charter.com).
 */
@WebServlet(name = "HomeController", urlPatterns = {"", "/home", "/experiences", "/destinations", "/admin/dashboard"})
public class HomeController extends BaseController {
    private final TourService tourService = new TourService();
    private final BoatService boatService = new BoatService();
    private final EmergencyService emergencyService = new EmergencyService();
    private final ReservationService reservationService = new ReservationService();
    private final PromotionService promotionService = new PromotionService();
    private final MaintenanceService maintenanceService = new MaintenanceService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Pass active emergency broadcast notices to all public pages for banner ticker
        request.setAttribute("activeAlerts", emergencyService.getActiveNotices());

        if ("/admin/dashboard".equals(path)) {
            User current = SessionHelper.getCurrentUser(request);
            if (current == null) {
                redirect(response, request.getContextPath() + "/login?returnUrl=/admin/dashboard");
                return;
            }

            // Populate multi-module metrics for operational dashboard
            request.setAttribute("totalTours", tourService.getAllTours().size());
            request.setAttribute("totalVessels", boatService.getAllVessels().size());
            request.setAttribute("totalReservations", reservationService.getAllReservations().size());
            request.setAttribute("activeEmergencies", emergencyService.getActiveNotices().size());
            request.setAttribute("activePromotions", promotionService.getAllPromotions().size());
            request.setAttribute("totalMaintenanceCost", maintenanceService.getTotalMaintenanceExpense());
            request.setAttribute("recentBookings", reservationService.getAllReservations());
            request.setAttribute("recentLogs", userService.getRecentActivityLogs(10));
            request.setAttribute("upcomingSchedules", tourService.getUpcomingSchedules());

            render(request, response, "common/dashboard.jsp");
            return;
        }

        if ("/experiences".equals(path)) {
            request.setAttribute("tours", tourService.getActiveTours());
            request.setAttribute("schedules", tourService.getUpcomingSchedules());
            render(request, response, "common/experiences.jsp");
            return;
        }

        if ("/destinations".equals(path)) {
            request.setAttribute("destinations", tourService.getAllDestinations());
            request.setAttribute("routes", tourService.getAllRoutes());
            render(request, response, "common/destinations.jsp");
            return;
        }

        // Default: Luxury Landing Page (Sail Lanka Charter inspired)
        request.setAttribute("featuredTours", tourService.getActiveTours());
        request.setAttribute("fleet", boatService.getAllVessels());
        request.setAttribute("promotions", promotionService.getAllPromotions());
        render(request, response, "common/public-home.jsp");
    }
}
