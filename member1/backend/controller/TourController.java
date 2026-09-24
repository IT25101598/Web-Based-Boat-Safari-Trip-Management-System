package com.boatsafari.member1.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.member1.model.Tour;
import com.boatsafari.member1.model.TourType;
import com.boatsafari.member1.service.TourService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Member 1: Safari Tour Controller (Member 1: Safari Tour & Schedule Management).
 * Manages Tour catalog viewing, creation, updates, and deletion.
 */
@WebServlet(name = "TourController", urlPatterns = {"/tours", "/tours/view", "/tours/delete", "/admin/tours", "/admin/tours/create", "/admin/tours/edit", "/admin/tours/delete"})
public class TourController extends BaseController {
    private final TourService tourService = new TourService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            // ==========================================
            // Member 1: READ (List Tours)
            // ==========================================
            case "/tours":
            case "/admin/tours":
                List<Tour> tours = tourService.getAllTours();
                String searchQuery = getStringParam(request, "q", "").toLowerCase().trim();
                String typeFilter = getStringParam(request, "type", "").trim();
                if (!searchQuery.isEmpty()) {
                    tours = tours.stream().filter(t ->
                        (t.getTitle() != null && t.getTitle().toLowerCase().contains(searchQuery)) ||
                        (t.getDescription() != null && t.getDescription().toLowerCase().contains(searchQuery))
                    ).toList();
                }
                if (!typeFilter.isEmpty()) {
                    tours = tours.stream().filter(t -> t.getTourType() != null && t.getTourType().name().equalsIgnoreCase(typeFilter)).toList();
                }
                request.setAttribute("tours", tours);
                request.setAttribute("tourTypes", TourType.values());
                request.setAttribute("searchQuery", searchQuery);
                request.setAttribute("typeFilter", typeFilter);
                render(request, response, "member1/tour-list.jsp");
                break;

            // ==========================================
            // Member 1: READ (View Tour Details)
            // ==========================================
            case "/tours/view":
                int tourId = getIntParam(request, "id", 0);
                Optional<Tour> tourOpt = tourService.getTourById(tourId);
                if (tourOpt.isPresent()) {
                    request.setAttribute("tour", tourOpt.get());
                    request.setAttribute("schedules", tourService.getSchedulesForTour(tourId));
                    render(request, response, "member1/tour-view.jsp");
                } else {
                    flashError(request, "Requested safari tour not found.");
                    redirect(response, request.getContextPath() + "/tours");
                }
                break;

            // ==========================================
            // Member 1: CREATE (Show Create Tour Form)
            // ==========================================
            case "/admin/tours/create":
                request.setAttribute("tour", new Tour());
                request.setAttribute("routes", tourService.getAllRoutes());
                request.setAttribute("tourTypes", TourType.values());
                render(request, response, "member1/tour-form.jsp");
                break;

            // ==========================================
            // Member 1: UPDATE (Show Edit Tour Form)
            // ==========================================
            case "/admin/tours/edit":
                int editId = getIntParam(request, "id", 0);
                Optional<Tour> editOpt = tourService.getTourById(editId);
                if (editOpt.isPresent()) {
                    request.setAttribute("tour", editOpt.get());
                    request.setAttribute("routes", tourService.getAllRoutes());
                    request.setAttribute("tourTypes", TourType.values());
                    render(request, response, "member1/tour-form.jsp");
                } else {
                    flashError(request, "Tour not found for editing.");
                    redirect(response, request.getContextPath() + "/admin/tours");
                }
                break;

            default:
                redirect(response, request.getContextPath() + "/tours");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/tours");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 1: DELETE (Delete Tour)
        // ==========================================
        if ("/admin/tours/delete".equals(path) || "/tours/delete".equals(path)) {
            int deleteId = getIntParam(request, "id", 0);
            boolean ok = tourService.deleteTour(deleteId);
            if (ok) {
                flashSuccess(request, "Tour successfully deleted.");
            } else {
                flashError(request, "Could not delete tour #" + deleteId + ".");
            }
            redirect(response, request.getContextPath() + (path.startsWith("/admin") ? "/admin/tours" : "/tours"));
            return;
        }

        // ==========================================
        // Member 1: CREATE & UPDATE (Save Tour)
        // ==========================================
        // Create or Edit
        int id = getIntParam(request, "id", 0);
        String title = getStringParam(request, "title", "");
        String tourTypeStr = getStringParam(request, "tourType", "WHALE_WATCHING");
        int routeId = getIntParam(request, "routeId", 0);
        String description = getStringParam(request, "description", "");
        double duration = getDoubleParam(request, "durationHours", 3.0);
        double price = getDoubleParam(request, "basePrice", 15000.0);
        int maxPax = getIntParam(request, "maxPassengers", 20);
        String inclusions = getStringParam(request, "inclusions", "");
        String exclusions = getStringParam(request, "exclusions", "");
        String imageUrl = getStringParam(request, "imageUrl", "assets/img/tours/mirissa-whale.jpg");
        String specialInstructions = getStringParam(request, "specialInstructions", "");

        Tour tour = new Tour();
        if (id > 0) tour.setId(id);
        tour.setTitle(title);
        try {
            tour.setTourType(TourType.valueOf(tourTypeStr));
        } catch (Exception e) {
            tour.setTourType(TourType.WHALE_WATCHING);
        }
        tour.setRouteId(routeId);
        tour.setDescription(description);
        tour.setDurationHours(duration);
        tour.setBasePriceAmount(BigDecimal.valueOf(price));
        tour.setMaxPassengers(maxPax);
        tour.setInclusions(inclusions);
        tour.setExclusions(exclusions);
        tour.setImageUrl(imageUrl);
        tour.setSpecialInstructions(specialInstructions);

        try {
            tourService.saveTour(tour);
            flashSuccess(request, "Safari Tour saved successfully!");
            redirect(response, request.getContextPath() + "/admin/tours");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + (id > 0 ? "/admin/tours/edit?id=" + id : "/admin/tours/create"));
        }
    }
}
