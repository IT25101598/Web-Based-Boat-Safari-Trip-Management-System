package com.boatsafari.member3.model;

/**
 * Member 3: Vessel Operational Status (Member 3: Boat Fleet Management)
 */
public enum VesselStatus {
    AVAILABLE("Available for Charter", "badge-success"),
    ASSIGNED("Assigned / Cruising", "badge-primary"),
    UNDER_MAINTENANCE("Under Slipway Maintenance", "badge-warning"),
    INACTIVE("Out of Commission", "badge-danger");

    private final String label;
    private final String badgeClass;

    VesselStatus(String label, String badgeClass) {
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
