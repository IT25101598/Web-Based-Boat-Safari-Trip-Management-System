package com.boatsafari.common.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.dao.ActivityLogDAO;
import com.boatsafari.common.dao.UserDAO;
import com.boatsafari.common.model.*;
import com.boatsafari.common.util.PasswordHasher;
import com.boatsafari.common.util.Validator;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Service Layer for User Management and Security Authentication.
 * Demonstrates Service façade, Business Rules validation, and Activity Logging.
 */
public class UserService {
    private final UserDAO userDAO;
    private final ActivityLogDAO logDAO;

    public UserService() {
        this.userDAO = new UserDAO();
        this.logDAO = new ActivityLogDAO();
    }

    public UserService(UserDAO userDAO, ActivityLogDAO logDAO) {
        this.userDAO = userDAO;
        this.logDAO = logDAO;
    }

    public Optional<User> authenticate(String email, String password, String ipAddress) {
        if (!Validator.isValidEmail(email) || password == null || password.isEmpty()) {
            return Optional.empty();
        }
        Optional<User> userOpt = userDAO.authenticate(email, password);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            logDAO.create(new ActivityLog(user.getId(), "LOGIN_SUCCESS", "AUTH", "User logged in successfully", ipAddress));
            com.boatsafari.common.util.LiveFileLogger.logCustomerSignIn("LOGIN_SUCCESS", user.getId(), user.getFullName(), user.getEmail(), user.getRole().name(), ipAddress, "SUCCESS");
        } else {
            logDAO.create(new ActivityLog(null, "LOGIN_FAILED", "AUTH", "Failed login attempt for: " + email, ipAddress));
            com.boatsafari.common.util.LiveFileLogger.logCustomerSignIn("LOGIN_FAILED", 0, "Unknown Guest", email, "GUEST", ipAddress, "FAILED - INVALID CREDENTIALS");
        }
        return userOpt;
    }

    public User registerCustomer(String fullName, String email, String password, String phone, String country, String ipAddress) {
        Map<String, String> errors = new java.util.HashMap<>();

        if (!Validator.isNotBlank(fullName)) {
            errors.put("fullName", "Full name is required");
        }
        if (!Validator.isValidEmail(email)) {
            errors.put("email", "A valid email address is required");
        } else if (userDAO.findByEmail(email).isPresent()) {
            errors.put("email", "Email is already registered. Please login.");
        }
        if (password == null || password.length() < 6) {
            errors.put("password", "Password must be at least 6 characters");
        }

        if (!errors.isEmpty()) {
            throw new ValidationException("Registration validation failed", errors);
        }

        Customer customer = new Customer();
        customer.setFullName(fullName);
        customer.setEmail(email);
        customer.setPassword(password);
        customer.setPhone(phone);
        customer.setCountry(country != null && !country.isBlank() ? country : "Sri Lanka");
        customer.setStatus("ACTIVE");

        User created = userDAO.create(customer);
        logDAO.create(new ActivityLog(created.getId(), "CUSTOMER_REGISTERED", "AUTH", "New tourist registered: " + email, ipAddress));
        com.boatsafari.common.util.LiveFileLogger.logCustomerSignIn("CUSTOMER_REGISTERED", created.getId(), created.getFullName(), created.getEmail(), "CUSTOMER", ipAddress, "SUCCESS - NEW ACCOUNT");
        return created;
    }

    public boolean updateProfile(User user, String ipAddress) {
        Map<String, String> errors = user.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("User profile update failed", errors);
        }
        boolean updated = userDAO.update(user);
        if (updated) {
            logDAO.create(new ActivityLog(user.getId(), "PROFILE_UPDATED", "USER", "User updated profile details", ipAddress));
        }
        return updated;
    }

    public boolean changePassword(int userId, String currentPassword, String newPassword, String ipAddress) {
        Optional<User> userOpt = userDAO.findById(userId);
        if (userOpt.isEmpty()) return false;

        User user = userOpt.get();
        if (!user.checkPassword(currentPassword)) {
            throw new ValidationException("Current password is incorrect");
        }
        if (newPassword == null || newPassword.length() < 6) {
            throw new ValidationException("New password must be at least 6 characters");
        }

        user.setPassword(newPassword);
        boolean ok = userDAO.update(user);
        if (ok) {
            logDAO.create(new ActivityLog(userId, "PASSWORD_CHANGED", "AUTH", "Password updated successfully", ipAddress));
        }
        return ok;
    }

    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    public Optional<User> getUserById(int id) {
        return userDAO.findById(id);
    }

    public List<User> getCaptains() {
        return userDAO.findByRole(UserRole.CAPTAIN);
    }

    public List<User> getTourGuides() {
        return userDAO.findByRole(UserRole.GUIDE);
    }

    public List<ActivityLog> getRecentActivityLogs(int limit) {
        return logDAO.findRecent(limit);
    }
}
