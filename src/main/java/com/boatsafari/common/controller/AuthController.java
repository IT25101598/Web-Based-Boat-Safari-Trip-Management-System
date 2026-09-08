package com.boatsafari.common.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.model.User;
import com.boatsafari.common.service.UserService;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.common.util.SessionHelper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Optional;

/**
 * Authentication and User Profile Controller (Common Function).
 * Manages Customer Registration, Universal Role-based Login, Logout, and Profile updates.
 */
@WebServlet(name = "AuthController", urlPatterns = {"/login", "/register", "/logout", "/profile"})
public class AuthController extends BaseController {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        switch (path) {
            case "/login":
                if (SessionHelper.isLoggedIn(request)) {
                    redirect(response, request.getContextPath() + SessionHelper.getCurrentUser(request).getRole().getDefaultDashboard());
                    return;
                }
                render(request, response, "common/login.jsp");
                break;

            case "/register":
                if (SessionHelper.isLoggedIn(request)) {
                    redirect(response, request.getContextPath() + "/home");
                    return;
                }
                render(request, response, "common/register.jsp");
                break;

            case "/logout":
                SessionHelper.logout(request);
                flashSuccess(request, "You have been logged out successfully.");
                redirect(response, request.getContextPath() + "/home");
                break;

            case "/profile":
                if (!SessionHelper.isLoggedIn(request)) {
                    redirect(response, request.getContextPath() + "/login");
                    return;
                }
                request.setAttribute("user", SessionHelper.getCurrentUser(request));
                render(request, response, "common/profile.jsp");
                break;

            default:
                redirect(response, request.getContextPath() + "/home");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Validate Anti-CSRF token
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed. Please try again.");
            redirect(response, request.getContextPath() + path);
            return;
        }

        switch (path) {
            case "/login":
                handleLogin(request, response);
                break;
            case "/register":
                handleRegister(request, response);
                break;
            case "/profile":
                handleProfileUpdate(request, response);
                break;
            default:
                redirect(response, request.getContextPath() + "/home");
                break;
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String email = getStringParam(request, "email", "");
        String password = getStringParam(request, "password", "");
        String returnUrl = getStringParam(request, "returnUrl", "");

        Optional<User> userOpt = userService.authenticate(email, password, getClientIp(request));
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            SessionHelper.setCurrentUser(request, user);
            flashSuccess(request, "Welcome back, " + user.getFullName() + "!");

            if (returnUrl != null && !returnUrl.isBlank() && !returnUrl.contains("/login")) {
                redirect(response, returnUrl);
            } else {
                redirect(response, request.getContextPath() + user.getRole().getDefaultDashboard());
            }
        } else {
            flashError(request, "Invalid email address or password. Please try again.");
            redirect(response, request.getContextPath() + "/login");
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String fullName = getStringParam(request, "fullName", "");
        String email = getStringParam(request, "email", "");
        String password = getStringParam(request, "password", "");
        String phone = getStringParam(request, "phone", "");
        String country = getStringParam(request, "country", "Sri Lanka");

        try {
            User newUser = userService.registerCustomer(fullName, email, password, phone, country, getClientIp(request));
            flashSuccess(request, "Account created successfully! Please log in with your email and password.");
            redirect(response, request.getContextPath() + "/login");
        } catch (ValidationException e) {
            String errorMsg = e.getErrors() != null && !e.getErrors().isEmpty() 
                    ? String.join(". ", e.getErrors().values()) 
                    : e.getMessage();
            flashError(request, errorMsg);
            redirect(response, request.getContextPath() + "/register");
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        User currentUser = SessionHelper.getCurrentUser(request);
        if (currentUser == null) {
            redirect(response, request.getContextPath() + "/login");
            return;
        }

        String fullName = getStringParam(request, "fullName", currentUser.getFullName());
        String phone = getStringParam(request, "phone", currentUser.getPhone());

        currentUser.setFullName(fullName);
        currentUser.setPhone(phone);

        try {
            userService.updateProfile(currentUser, getClientIp(request));
            flashSuccess(request, "Your profile has been updated successfully.");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
        }

        redirect(response, request.getContextPath() + "/profile");
    }
}
