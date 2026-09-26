package com.boatsafari.member6.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.member6.model.DiscountType;
import com.boatsafari.member6.model.Promotion;
import com.boatsafari.member6.service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import java.util.Optional;

/**
 * Member 6: Promotion and Discount Controller (Member 6: Promotion & Discount Strategy Management).
 */
@WebServlet(name = "PromotionController", urlPatterns = {"/promotions", "/promotions/delete", "/admin/promotions", "/admin/promotions/create", "/admin/promotions/edit", "/admin/promotions/delete", "/admin/promotions/redemptions"})
public class PromotionController extends BaseController {
    private final PromotionService promoService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // ==========================================
        // Member 6: READ (Redemption Analytics)
        // ==========================================
        if ("/admin/promotions/redemptions".equals(path)) {
            request.setAttribute("redemptions", promoService.getAllRedemptions());
            render(request, response, "member6/promo-analytics.jsp");
            return;
        }

        // ==========================================
        // Member 6: CREATE (Form)
        // ==========================================
        if ("/admin/promotions/create".equals(path)) {
            request.setAttribute("promotion", new Promotion());
            request.setAttribute("discountTypes", DiscountType.values());
            render(request, response, "member6/promo-form.jsp");
            return;
        }

        // ==========================================
        // Member 6: UPDATE (Form)
        // ==========================================
        if ("/admin/promotions/edit".equals(path)) {
            int editId = getIntParam(request, "id", 0);
            Optional<Promotion> opt = promoService.getPromotionById(editId);
            if (opt.isPresent()) {
                request.setAttribute("promotion", opt.get());
                request.setAttribute("discountTypes", DiscountType.values());
                render(request, response, "member6/promo-form.jsp");
            } else {
                flashError(request, "Promotion not found.");
                redirect(response, request.getContextPath() + "/admin/promotions");
            }
            return;
        }

        // ==========================================
        // Member 6: READ (List)
        // ==========================================
        List<Promotion> promotions = promoService.getAllPromotions();
        request.setAttribute("promotions", promotions);
        render(request, response, "member6/promo-list.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/promotions");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 6: DELETE
        // ==========================================
        if ("/admin/promotions/delete".equals(path) || "/promotions/delete".equals(path)) {
            int deleteId = getIntParam(request, "id", 0);
            boolean ok = promoService.deletePromotion(deleteId);
            if (ok) {
                flashSuccess(request, "Promotion campaign deleted.");
            } else {
                flashError(request, "Could not delete promotion campaign #" + deleteId + ".");
            }
            redirect(response, request.getContextPath() + (path.startsWith("/admin") ? "/admin/promotions" : "/promotions"));
            return;
        }

        // ==========================================
        // Member 6: CREATE & UPDATE (Save Campaign)
        // ==========================================
        // Save
        int id = getIntParam(request, "id", 0);
        String name = getStringParam(request, "name", "");
        String code = getStringParam(request, "promoCode", "");
        String typeStr = getStringParam(request, "discountType", "PERCENTAGE");
        double val = getDoubleParam(request, "discountValue", 10.0);
        double minSpend = getDoubleParam(request, "minSpend", 0.0);
        double maxDisc = getDoubleParam(request, "maxDiscount", 0.0);
        int maxRedemptions = getIntParam(request, "maxRedemptions", 100);
        String startStr = getStringParam(request, "startDate", "");
        String endStr = getStringParam(request, "endDate", "");
        boolean active = "on".equalsIgnoreCase(request.getParameter("active")) || "true".equalsIgnoreCase(request.getParameter("active"));

        Promotion promo = new Promotion();
        if (id > 0) promo.setId(id);
        promo.setName(name);
        promo.setPromoCode(code);
        try {
            promo.setDiscountType(DiscountType.valueOf(typeStr));
        } catch (Exception e) {
            promo.setDiscountType(DiscountType.PERCENTAGE);
        }
        promo.setDiscountValue(BigDecimal.valueOf(val));
        promo.setMinSpend(BigDecimal.valueOf(minSpend));
        promo.setMaxDiscount(BigDecimal.valueOf(maxDisc));
        promo.setMaxRedemptions(maxRedemptions);
        try {
            if (!startStr.isBlank()) promo.setStartDate(Date.valueOf(startStr));
            if (!endStr.isBlank()) promo.setEndDate(Date.valueOf(endStr));
        } catch (Exception ignored) {}
        promo.setActive(active);

        try {
            promoService.savePromotion(promo);
            flashSuccess(request, "Promotion campaign saved successfully!");
            redirect(response, request.getContextPath() + "/admin/promotions");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + (id > 0 ? "/admin/promotions/edit?id=" + id : "/admin/promotions/create"));
        }
    }
}
