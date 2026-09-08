package com.boatsafari.common.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.model.ActivityLog;
import com.boatsafari.common.model.User;
import com.boatsafari.common.model.UserRole;
import com.boatsafari.common.service.UserService;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.common.util.SessionHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Administrative User Management Controller (Common Function).
 * Manages RBAC user accounts, activity audit logs, and account activation/deactivation.
 */
@WebServlet(name = "UserAdminController", urlPatterns = {"/admin/users", "/admin/users/toggle-status", "/admin/activity-logs"})
public class UserAdminController extends BaseController {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/admin/activity-logs".equals(path)) {
            List<ActivityLog> logs = userService.getRecentActivityLogs(50);
            request.setAttribute("logs", logs);
            render(request, response, "common/activity-logs.jsp");
            return;
        }

        // List users with optional role filter
        String roleFilter = getStringParam(request, "role", "");
        List<User> users = userService.getAllUsers();
        if (!roleFilter.isEmpty()) {
            try {
                UserRole role = UserRole.valueOf(roleFilter);
                users = users.stream().filter(u -> u.getRole() == role).toList();
            } catch (IllegalArgumentException ignored) {}
        }

        request.setAttribute("users", users);
        request.setAttribute("roles", UserRole.values());
        request.setAttribute("selectedRole", roleFilter);
        render(request, response, "common/user-management.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/users");
            return;
        }

        String path = request.getServletPath();
        if ("/admin/users/toggle-status".equals(path)) {
            int userId = getIntParam(request, "userId", 0);
            Optional<User> userOpt = userService.getUserById(userId);
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                // Prevent admin from disabling own account
                User current = SessionHelper.getCurrentUser(request);
                if (current != null && current.getId().equals(user.getId())) {
                    flashError(request, "You cannot deactivate your own administrative account.");
                } else {
                    String newStatus = "ACTIVE".equalsIgnoreCase(user.getStatus()) ? "INACTIVE" : "ACTIVE";
                    user.setStatus(newStatus);
                    userService.updateProfile(user, getClientIp(request));
                    flashSuccess(request, "User status updated to: " + newStatus);
                }
            }
        }

        redirect(response, request.getContextPath() + "/admin/users");
    }
}
