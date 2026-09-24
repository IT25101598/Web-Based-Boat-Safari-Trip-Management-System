package com.boatsafari.member1.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Money;
import com.boatsafari.common.util.Validator;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 1: Safari Tour Package entity (Member 1: Safari Tour & Schedule Management).
 * Demonstrates Composition (has-a Route, has-a Money object) and strict Encapsulation.
 */
public class Tour extends BaseModel {
    private String title;
    private TourType tourType = TourType.WHALE_WATCHING;
    private Integer routeId;
    private Route route;
    private String description;
    private double durationHours;
    private Money basePrice = Money.zero();
    private int maxPassengers = 25;
    private String inclusions;
    private String exclusions;
    private String imageUrl = "assets/img/tours/mirissa-whale.jpg";
    private String specialInstructions;
    private boolean active = true;

    public Tour() {
        super();
    }

    public Tour(Integer id, String title, TourType tourType, int routeId, double durationHours, BigDecimal basePrice, int maxPassengers) {
        super(id);
        this.title = title;
        this.tourType = tourType;
        this.routeId = routeId;
        this.durationHours = durationHours;
        this.basePrice = new Money(basePrice);
        this.maxPassengers = maxPassengers;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title != null ? title.trim() : null;
    }

    public TourType getTourType() {
        return tourType;
    }

    public void setTourType(TourType tourType) {
        this.tourType = tourType != null ? tourType : TourType.WHALE_WATCHING;
    }

    public Integer getRouteId() {
        return routeId;
    }

    public void setRouteId(Integer routeId) {
        this.routeId = routeId;
    }

    public Route getRoute() {
        return route;
    }

    public void setRoute(Route route) {
        this.route = route;
        if (route != null) {
            this.routeId = route.getId();
        }
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getDurationHours() {
        return durationHours;
    }

    public void setDurationHours(double durationHours) {
        if (durationHours <= 0) {
            throw new IllegalArgumentException("Tour duration must be greater than zero");
        }
        this.durationHours = durationHours;
    }

    public Money getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(Money basePrice) {
        this.basePrice = basePrice != null ? basePrice : Money.zero();
    }

    public void setBasePriceAmount(BigDecimal amount) {
        this.basePrice = new Money(amount);
    }

    public int getMaxPassengers() {
        return maxPassengers;
    }

    public void setMaxPassengers(int maxPassengers) {
        if (maxPassengers <= 0) {
            throw new IllegalArgumentException("Max passengers must be greater than zero");
        }
        this.maxPassengers = maxPassengers;
    }

    public String getInclusions() {
        return inclusions;
    }

    public void setInclusions(String inclusions) {
        this.inclusions = inclusions;
    }

    public String getExclusions() {
        return exclusions;
    }

    public void setExclusions(String exclusions) {
        this.exclusions = exclusions;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getSpecialInstructions() {
        return specialInstructions;
    }

    public void setSpecialInstructions(String specialInstructions) {
        this.specialInstructions = specialInstructions;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(title)) {
            errors.put("title", "Tour title is required");
        }
        if (routeId == null || routeId <= 0) {
            errors.put("routeId", "Sailing route selection is required");
        }
        if (durationHours <= 0) {
            errors.put("durationHours", "Duration must be greater than 0");
        }
        if (basePrice == null || basePrice.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            errors.put("basePrice", "Base price must be greater than zero");
        }
        if (maxPassengers <= 0) {
            errors.put("maxPassengers", "Max passengers must be greater than zero");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return title + " (" + tourType.getTitle() + ") - " + basePrice.getFormatted();
    }

    @Override
    public String getStatusLabel() {
        return active ? "Active" : "Archived";
    }

    @Override
    public String getStatusBadgeClass() {
        return active ? "badge-success" : "badge-secondary";
    }
}
