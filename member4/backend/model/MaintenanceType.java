package com.boatsafari.member4.model;

/**
 * Member 4: Maintenance Job Classification (Member 4: Boat Maintenance & Service Management)
 */
public enum MaintenanceType {
    ROUTINE_SERVICE("Routine Engine Service", "Oil changes, impeller inspection, fuel line purging, and filter swap."),
    SAFETY_INSPECTION("Maritime Safety Survey", "SOLAS life raft recertification, flare checks, EPIRB, and life jackets."),
    HULL_CLEANING("Hull Cleaning & Antifouling", "Haul-out slipway cleaning, barnacle scraping, zinc anodes, and antifouling paint."),
    ENGINE_OVERHAUL("Major Engine Overhaul", "Piston, injector, and cylinder head rebuilding by certified marine engineers."),
    ELECTRICAL("Marine Electronics & Radar", "VHF radio, GPS chartplotter, depth sounder, and battery bank maintenance.");

    private final String title;
    private final String description;

    MaintenanceType(String title, String description) {
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
