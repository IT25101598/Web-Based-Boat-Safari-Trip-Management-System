package com.boatsafari.member5.model;

/**
 * Member 5: Emergency Notice Status (Member 5: Maritime Safety & Emergency Notice Management)
 */
public enum EmergencyStatus {
    ACTIVE("Active Live Broadcast", "badge-danger"),
    RESOLVED("Resolved & All-Clear", "badge-success"),
    ARCHIVED("Archived Record", "badge-secondary");

    private final String label;
    private final String badgeClass;

    EmergencyStatus(String label, String badgeClass) {
        this.label = label;
        this.badgeClass = badgeClass;
    }

    public String getLabel() {
        return label;
    }

    public String getBadgeClass() {
        return badgeClass;
    }
}
