package com.boatsafari.member6.controller;

import com.boatsafari.common.util.Money;
import com.boatsafari.member6.model.Promotion;
import com.boatsafari.member6.service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Optional;

/**
 * Member 6: Live Promo Code Validation API endpoint (Member 6: Promotion & Discount Strategy Management).
 * Called asynchronously from the reservation booking wizard.
 */
@WebServlet(name = "PromoValidateController", urlPatterns = {"/api/promo/validate"})
public class PromoValidateController extends HttpServlet {
    private final PromotionService promoService = new PromotionService();

    // ==========================================
    // Member 6: READ (Validate Promo Code)
    // ==========================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String code = request.getParameter("code");
        String totalStr = request.getParameter("total");

        double total = 0.0;
        try {
            if (totalStr != null) total = Double.parseDouble(totalStr);
        } catch (NumberFormatException ignored) {}

        Money orderTotal = Money.of(total);
        Optional<Promotion> promoOpt = promoService.findValidPromo(code, orderTotal);

        try (PrintWriter out = response.getWriter()) {
            if (promoOpt.isPresent()) {
                Promotion promo = promoOpt.get();
                Money discount = promo.applyDiscount(orderTotal);
                Money finalPrice = orderTotal.subtract(discount);

                out.print("{"
                        + "\"valid\": true,"
                        + "\"promoId\": " + promo.getId() + ","
                        + "\"code\": \"" + promo.getPromoCode() + "\","
                        + "\"name\": \"" + promo.getName() + "\","
                        + "\"discountAmount\": " + discount.getAmount() + ","
                        + "\"discountFormatted\": \"" + discount.getFormatted() + "\","
                        + "\"finalAmount\": " + finalPrice.getAmount() + ","
                        + "\"finalFormatted\": \"" + finalPrice.getFormatted() + "\","
                        + "\"message\": \"Promo applied: " + promo.getName() + "\""
                        + "}");
            } else {
                out.print("{"
                        + "\"valid\": false,"
                        + "\"message\": \"Invalid, expired, or minimum spend not met for this promo code.\""
                        + "}");
            }
        }
    }
}
