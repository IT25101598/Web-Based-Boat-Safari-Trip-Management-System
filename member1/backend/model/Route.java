package com.boatsafari.member1.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Validator;

import java.util.HashMap;
import java.util.Map;

/**
 * Member 1: Maritime Sailing Route entity (Member 1: Safari Tour & Schedule Management).
 * Demonstrates Composition: Route has-a start Destination and has-a end Destination.
 */
public class Route extends BaseModel {
    private String name;
    private Integer startDestinationId;
    private Integer endDestinationId;
    private Destination startDestination;
    private Destination endDestination;
    private double durationHours;
    private double distanceNm;
    private String highlights;

    public Route() {
        super();
    }

    public Route(Integer id, String name, int startDestinationId, int endDestinationId, double durationHours, double distanceNm) {
        super(id);
        this.name = name;
        this.startDestinationId = startDestinationId;
        this.endDestinationId = endDestinationId;
        this.durationHours = durationHours;
        this.distanceNm = distanceNm;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name != null ? name.trim() : null;
    }

    public Integer getStartDestinationId() {
        return startDestinationId;
    }

    public void setStartDestinationId(Integer startDestinationId) {
        this.startDestinationId = startDestinationId;
    }

    public Integer getEndDestinationId() {
        return endDestinationId;
    }

    public void setEndDestinationId(Integer endDestinationId) {
        this.endDestinationId = endDestinationId;
    }

    public Destination getStartDestination() {
        return startDestination;
    }

    public void setStartDestination(Destination startDestination) {
        this.startDestination = startDestination;
        if (startDestination != null) {
            this.startDestinationId = startDestination.getId();
        }
    }

    public Destination getEndDestination() {
        return endDestination;
    }

    public void setEndDestination(Destination endDestination) {
        this.endDestination = endDestination;
        if (endDestination != null) {
            this.endDestinationId = endDestination.getId();
        }
    }

    public double getDurationHours() {
        return durationHours;
    }

    public void setDurationHours(double durationHours) {
        if (durationHours <= 0) {
            throw new IllegalArgumentException("Route duration must be greater than zero");
        }
        this.durationHours = durationHours;
    }

    public double getDistanceNm() {
        return distanceNm;
    }

    public void setDistanceNm(double distanceNm) {
        if (distanceNm <= 0) {
            throw new IllegalArgumentException("Route distance must be greater than zero");
        }
        this.distanceNm = distanceNm;
    }

    public String getHighlights() {
        return highlights;
    }

    public void setHighlights(String highlights) {
        this.highlights = highlights;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(name)) {
            errors.put("name", "Route name is required");
        }
        if (startDestinationId == null || startDestinationId <= 0) {
            errors.put("startDestinationId", "Departure harbour is required");
        }
        if (endDestinationId == null || endDestinationId <= 0) {
            errors.put("endDestinationId", "Arrival harbour is required");
        }
        if (durationHours <= 0) {
            errors.put("durationHours", "Duration must be greater than 0");
        }
        if (distanceNm <= 0) {
            errors.put("distanceNm", "Distance must be greater than 0");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return name + " (" + distanceNm + " NM, ~" + durationHours + " hrs)";
    }

    @Override
    public String getStatusLabel() {
        return distanceNm + " NM";
    }
}
