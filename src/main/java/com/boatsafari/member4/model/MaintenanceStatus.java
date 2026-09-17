package com.boatsafari.member4.model;

/**
 * Member 4: Maintenance Job Status (Member 4: Boat Maintenance & Service Management)
 */
public enum MaintenanceStatus {
    SCHEDULED("Scheduled", "badge-primary"),
    IN_PROGRESS("Work In Progress", "badge-warning"),
    COMPLETED("Completed & Surveyed", "badge-success"),
    CANCELLED("Cancelled", "badge-danger");

    private final String label;
    private final String badgeClass;

    MaintenanceStatus(String label, String badgeClass) {
        this.label = label;
        this.badgeClass = badgeClass;
    }

    public String getLabel() {
        return label;
    }

    public String getTitle() {
        return label;
    }

    public String getBadgeClass() {
        return badgeClass;
    }
}
