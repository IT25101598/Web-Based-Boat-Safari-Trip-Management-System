package com.boatsafari.member5.model;

/**
 * Member 5: Emergency Severity Levels (Member 5: Maritime Safety & Emergency Notice Management)
 */
public enum EmergencySeverity {
    LOW("Low Advisory", "badge-info", "banner-info"),
    MEDIUM("Moderate Attention", "badge-warning", "banner-warning"),
    HIGH("High Caution", "badge-danger", "banner-danger"),
    CRITICAL("CRITICAL IMMEDIATE ALERT", "badge-critical", "banner-critical");

    private final String label;
    private final String badgeClass;
    private final String bannerClass;

    EmergencySeverity(String label, String badgeClass, String bannerClass) {
        this.label = label;
        this.badgeClass = badgeClass;
        this.bannerClass = bannerClass;
    }

    public String getLabel() {
        return label;
    }

    public String getBadgeClass() {
        return badgeClass;
    }

    public String getBannerClass() {
        return bannerClass;
    }
}
