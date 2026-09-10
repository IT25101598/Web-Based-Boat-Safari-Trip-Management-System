package com.boatsafari.member1.model;

/**
 * Member 1: Tour Schedule Operational Statuses (Member 1: Safari Tour & Schedule Management)
 */
public enum ScheduleStatus {
    SCHEDULED("Scheduled", "badge-primary"),
    BOARDING("Boarding Now", "badge-warning"),
    DEPARTED("At Sea / Cruising", "badge-info"),
    COMPLETED("Completed", "badge-success"),
    CANCELLED("Trip Cancelled", "badge-danger");

    private final String label;
    private final String badgeClass;

    ScheduleStatus(String label, String badgeClass) {
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
