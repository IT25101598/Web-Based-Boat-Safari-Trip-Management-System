package com.boatsafari.member1.model;

/**
 * Member 1: Safari Tour Types (Member 1: Safari Tour & Schedule Management)
 */
public enum TourType {
    WHALE_WATCHING("Blue Whale & Dolphin Safari", "Deep ocean pelagic expedition tracking ocean leviathans."),
    DAYLIGHT_CRUISE("Daylight Coastal Sail", "Refreshing daytime catamaran cruising along scenic coastlines."),
    SUNSET_SAIL("Sunset Champagne Sail", "Romantic golden-hour cruise with artisanal drinks and canapés."),
    OVERNIGHT_CHARTER("Multi-Day Yacht Charter", "Bespoke starlight overnight voyages with private cabins."),
    SNORKELING_SAFARI("Coral Reef & Marine Safari", "Snorkeling amidst living corals, sea turtles, and reef sharks."),
    DINE_AT_SEA("Starlight Dine-at-Sea", "Luxury dining anchored under the stars with a dedicated private chef.");

    private final String title;
    private final String description;

    TourType(String title, String description) {
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
