package com.boatsafari.common.core;

/**
 * Presentation contract enabling polymorphic rendering of heterogeneous entities
 * in shared UI components (e.g. search results, dashboard tickers, badges).
 */
public interface Displayable {
    /**
     * Concise human-readable summary for list cards, search results, and notifications.
     */
    String getSummary();

    /**
     * Formatted visual status label (e.g., "Available", "Confirmed", "Active Alert").
     */
    String getStatusLabel();

    /**
     * Badge CSS class for styled status pills (e.g. "badge-success", "badge-warning").
     */
    default String getStatusBadgeClass() {
        return "badge-primary";
    }
}
