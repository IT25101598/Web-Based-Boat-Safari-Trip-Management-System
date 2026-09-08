package com.boatsafari.common.core;

import com.boatsafari.common.util.Csrf;
import com.boatsafari.common.util.SessionHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.logging.Logger;

/**
 * Base Front-Controller Servlet providing uniform view rendering, redirecting,
 * parameter parsing, security, and flash messaging across all 6 member modules.
 */
public abstract class BaseController extends HttpServlet {
    protected final Logger logger = Logger.getLogger(getClass().getName());

    protected void render(HttpServletRequest request, HttpServletResponse response, String viewPath)
            throws ServletException, IOException {
        // Inject CSRF token into request scope for form templates
        request.setAttribute("csrfToken", Csrf.getToken(request));
        request.setAttribute("currentUser", SessionHelper.getCurrentUser(request));

        // Forward to the JSP view inside WEB-INF/views/
        String fullPath = "/WEB-INF/views/" + viewPath;
        request.getRequestDispatcher(fullPath).forward(request, response);
    }

    protected void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }

    protected void flashSuccess(HttpServletRequest request, String message) {
        SessionHelper.setFlashSuccess(request, message);
    }

    protected void flashError(HttpServletRequest request, String message) {
        SessionHelper.setFlashError(request, message);
    }

    protected int getIntParam(HttpServletRequest request, String paramName, int defaultValue) {
        String val = request.getParameter(paramName);
        if (val != null && !val.trim().isEmpty()) {
            try {
                return Integer.parseInt(val.trim());
            } catch (NumberFormatException ignored) {}
        }
        return defaultValue;
    }

    protected double getDoubleParam(HttpServletRequest request, String paramName, double defaultValue) {
        String val = request.getParameter(paramName);
        if (val != null && !val.trim().isEmpty()) {
            try {
                return Double.parseDouble(val.trim());
            } catch (NumberFormatException ignored) {}
        }
        return defaultValue;
    }

    protected String getStringParam(HttpServletRequest request, String paramName, String defaultValue) {
        String val = request.getParameter(paramName);
        return (val != null && !val.trim().isEmpty()) ? val.trim() : defaultValue;
    }

    protected String getClientIp(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader == null) {
            return request.getRemoteAddr();
        }
        return xfHeader.split(",")[0].trim();
    }
}
