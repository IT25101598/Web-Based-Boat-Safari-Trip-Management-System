package com.boatsafari.member2.model;

/**
 * Member 2: Reservation Booking Statuses (Member 2: Reservation & Guest Booking Management)
 */
public enum ReservationStatus {
    PENDING("Payment Pending", "badge-warning"),
    CONFIRMED("Confirmed & Ticket Issued", "badge-success"),
    CHECKED_IN("Checked In / Boarded", "badge-info"),
    CANCELLED("Booking Cancelled", "badge-danger");

    private final String label;
    private final String badgeClass;

    ReservationStatus(String label, String badgeClass) {
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
