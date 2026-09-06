package com.boatsafari.common.util;

import com.boatsafari.common.model.User;
import com.boatsafari.common.model.UserRole;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Session management helper for authenticating web requests and flash messages.
 */
public final class SessionHelper {
    public static final String SESSION_USER_KEY = "currentUser";
    public static final String FLASH_SUCCESS_KEY = "flashSuccess";
    public static final String FLASH_ERROR_KEY = "flashError";

    private SessionHelper() {}

    public static void setCurrentUser(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute(SESSION_USER_KEY, user);
    }

    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(SESSION_USER_KEY);
        }
        return null;
    }

    public static boolean isLoggedIn(HttpServletRequest request) {
        return getCurrentUser(request) != null;
    }

    public static boolean hasRole(HttpServletRequest request, UserRole role) {
        User user = getCurrentUser(request);
        return user != null && user.getRole() == role;
    }

    public static boolean isAdmin(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && user.getRole() == UserRole.ADMIN;
    }

    public static boolean isStaff(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && user.getRole().isStaff();
    }

    public static void logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }

    public static void setFlashSuccess(HttpServletRequest request, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_SUCCESS_KEY, message);
    }

    public static void setFlashError(HttpServletRequest request, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute(FLASH_ERROR_KEY, message);
    }
}
