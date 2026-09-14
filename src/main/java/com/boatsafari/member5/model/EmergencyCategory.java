package com.boatsafari.member5.model;

/**
 * Member 5: Emergency Notice Incident Categories (Member 5: Maritime Safety & Emergency Notice Management)
 */
public enum EmergencyCategory {
    BAD_WEATHER("Severe Marine Weather Advisory", "High winds, torrential rain, or cyclone warning."),
    HIGH_SWELL("Dangerous Sea Swell", "Rough coastal breakers and swells exceeding safe boarding limits."),
    TECHNICAL_DELAY("Vessel Technical Adjustment", "Minor mechanical servicing causing departure rescheduling."),
    TOUR_CANCELLATION("Voyage Cancellation Notice", "Tour cancellation due to safety or maritime authority directives."),
    SAFETY_ADVISORY("Maritime Safety Advisory", "Precautionary wildlife or navigational advisory.");

    private final String title;
    private final String description;

    EmergencyCategory(String title, String description) {
        this.title = title;
        this.description = description;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }
}
