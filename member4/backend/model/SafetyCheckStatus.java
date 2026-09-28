package com.boatsafari.member4.model;

/**
 * Member 4: Pre-Trip Safety Check Status.
 * Represents the readiness state of a vessel following the captain's pre-trip safety checklist.
 * 
 * Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
 */
public enum SafetyCheckStatus {
    READY_FOR_DEPARTURE("Ready for Departure", "badge-success"),
    PENDING_RECHECK("Pending Re-Check", "badge-warning"),
    VOIDED("Voided / Cancelled", "badge-danger");

    private final String label;
    private final String badgeClass;

    SafetyCheckStatus(String label, String badgeClass) {
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
