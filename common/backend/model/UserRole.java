package com.boatsafari.common.model;

/**
 * System User Roles for Role-Based Access Control (RBAC).
 */
public enum UserRole {
    ADMIN("System Administrator", "/admin/dashboard"),
    OFFICER("Reservation Officer", "/reservations"),
    GUIDE("Tour Guide", "/tours"),
    CAPTAIN("Boat Captain", "/emergency"),
    OWNER("Boat Owner", "/boats"),
    CUSTOMER("Customer / Tourist", "/my-bookings");

    private final String displayName;
    private final String defaultDashboard;

    UserRole(String displayName, String defaultDashboard) {
        this.displayName = displayName;
        this.defaultDashboard = defaultDashboard;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDefaultDashboard() {
        return defaultDashboard;
    }

    public boolean isStaff() {
        return this != CUSTOMER;
    }

    public boolean isAdmin() {
        return this == ADMIN;
    }
}
