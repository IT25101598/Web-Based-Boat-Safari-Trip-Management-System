package com.boatsafari.member3.model;

/**
 * Member 3: Vessel Classification (Member 3: Boat Fleet Management)
 */
public enum VesselType {
    CATAMARAN("Luxury Sailing Catamaran", "Dual-hull luxury vessel offering peerless stability, trampolines, and shaded lounges."),
    YACHT("Motor Yacht", "Ultra-luxurious vessel equipped with salon, sun deck, and private staterooms."),
    SPEEDBOAT("Rapid Coastal Patrol Craft", "High-velocity twin-outboard vessel for expedited transfer and intimate wildlife encounters.");

    private final String displayName;
    private final String description;

    VesselType(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getLabel() {
        return displayName;
    }

    public String getTitle() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }
}
