package com.boatsafari.member6.model;

/**
 * Member 6: Promotion Discount Types (Member 6: Promotion & Discount Strategy Management)
 */
public enum DiscountType {
    PERCENTAGE("Percentage Discount (%)", "Applies a percentage deduction off total booking price."),
    FIXED_AMOUNT("Fixed Amount Waiver (LKR)", "Applies a direct monetary value deduction."),
    SEASONAL("Seasonal / Early-Bird Special", "Tiered promotional rate active during specified seasonal windows.");

    private final String displayName;
    private final String description;

    DiscountType(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getTitle() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }
}
