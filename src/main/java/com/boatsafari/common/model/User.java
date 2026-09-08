package com.boatsafari.common.model;

import com.boatsafari.common.util.PasswordHasher;
import com.boatsafari.common.util.Validator;

import java.util.Map;

/**
 * Base User entity for all system users.
 * Demonstrates Inheritance (extends Person) and strict Encapsulation.
 */
public class User extends Person {
    private String email;
    private String passwordHash;
    private UserRole role = UserRole.CUSTOMER;
    private String status = "ACTIVE";
    private String profileImage = "assets/img/default-avatar.png";

    public User() {
        super();
    }

    public User(Integer id, String fullName, String email, String phone, UserRole role) {
        super(id, fullName, phone);
        this.email = email;
        this.role = role;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email != null ? email.trim().toLowerCase() : null;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public void setPassword(String plainPassword) {
        if (plainPassword != null && !plainPassword.isEmpty()) {
            this.passwordHash = PasswordHasher.hash(plainPassword);
        }
    }

    public boolean checkPassword(String plainPassword) {
        return PasswordHasher.verify(plainPassword, this.passwordHash);
    }

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role != null ? role : UserRole.CUSTOMER;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status != null ? status.toUpperCase() : "ACTIVE";
    }

    public String getProfileImage() {
        return profileImage;
    }

    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.status);
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = super.validate();
        if (!Validator.isValidEmail(email)) {
            errors.put("email", "Valid email address is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return getFullName() + " (" + (role != null ? role.getDisplayName() : "User") + ") - " + email;
    }

    @Override
    public String getStatusLabel() {
        return status;
    }

    @Override
    public String getStatusBadgeClass() {
        return isActive() ? "badge-success" : "badge-danger";
    }
}
