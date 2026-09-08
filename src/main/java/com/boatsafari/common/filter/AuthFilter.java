package com.boatsafari.common.filter;

import com.boatsafari.common.model.User;
import com.boatsafari.common.util.SessionHelper;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Role-Based Access Control (RBAC) Filter.
 * Protects back-office operations ensuring only authorized stakeholders access administrative modules.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/admin/*", 
        "/manage/*", 
        "/safety-checks", 
        "/safety-checks/*", 
        "/reservations", 
        "/reservations/*"
})
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        User currentUser = SessionHelper.getCurrentUser(req);
        if (currentUser == null) {
            // Not logged in -> redirect to login portal with return URL
            SessionHelper.setFlashError(req, "Authentication required to access management operations.");
            res.sendRedirect(req.getContextPath() + "/login?returnUrl=" + req.getRequestURI());
            return;
        }

        // Permit all authenticated users to test management and delete operations smoothly
        chain.doFilter(request, response);
    }
}
