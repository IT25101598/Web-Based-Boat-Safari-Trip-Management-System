package com.boatsafari.member5.controller;

import com.boatsafari.member5.model.EmergencyNotice;
import com.boatsafari.member5.service.EmergencyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Member 5: Live Emergency Notice JSON API endpoint (Member 5: Maritime Safety & Emergency Notice Management).
 * Feeds dynamic emergency tickers and notification badges on client web browsers.
 */
@WebServlet(name = "EmergencyFeedController", urlPatterns = {"/api/emergency/feed"})
public class EmergencyFeedController extends HttpServlet {
    private final EmergencyService emergencyService = new EmergencyService();

    // ==========================================
    // Member 5: READ (Live JSON Feed)
    // ==========================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        List<EmergencyNotice> active = emergencyService.getActiveNotices();

        try (PrintWriter out = response.getWriter()) {
            StringBuilder sb = new StringBuilder();
            sb.append("{\"count\":").append(active.size()).append(",\"alerts\":[");
            for (int i = 0; i < active.size(); i++) {
                EmergencyNotice n = active.get(i);
                if (i > 0) sb.append(",");
                sb.append("{")
                  .append("\"id\":").append(n.getId()).append(",")
                  .append("\"title\":\"").append(escape(n.getTitle())).append("\",")
                  .append("\"category\":\"").append(n.getCategory().name()).append("\",")
                  .append("\"severity\":\"").append(n.getSeverity().name()).append("\",")
                  .append("\"region\":\"").append(escape(n.getAffectedRegion())).append("\",")
                  .append("\"message\":\"").append(escape(n.getMessage())).append("\",")
                  .append("\"badgeClass\":\"").append(n.getSeverity().getBadgeClass()).append("\",")
                  .append("\"bannerClass\":\"").append(n.getSeverity().getBannerClass()).append("\"")
                  .append("}");
            }
            sb.append("]}");
            out.print(sb.toString());
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
