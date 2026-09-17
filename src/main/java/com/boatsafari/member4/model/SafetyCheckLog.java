package com.boatsafari.member4.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.core.Displayable;
import com.boatsafari.common.core.Validatable;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 4: Pre-Trip Safety Check Log Model.
 * Represents the official maritime pre-departure inspection checklist performed by the Boat Captain.
 * Enforces SOLAS safety compliance, fuel adequacy, weather logging, passenger briefings, and digital signature.
 * 
 * Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
 */
public class SafetyCheckLog extends BaseModel implements Validatable, Displayable {
    private int scheduleId;
    private int vesselId;
    private int captainId;
    private boolean safetyItemsVerified;
    private int lifeJacketsCount;
    private int fuelLevelPercent;
    private String weatherConditions;
    private boolean briefingConfirmed;
    private boolean allClear;
    private String captainSignature;
    private SafetyCheckStatus status = SafetyCheckStatus.READY_FOR_DEPARTURE;
    private String notes;
    private Timestamp loggedAt;

    // Transient display fields
    private String tourTitle;
    private String vesselName;
    private String captainName;
    private Timestamp departureTime;

    public SafetyCheckLog() {
        this.loggedAt = new Timestamp(System.currentTimeMillis());
        this.safetyItemsVerified = true;
        this.briefingConfirmed = true;
        this.allClear = true;
        this.fuelLevelPercent = 100;
        this.lifeJacketsCount = 30;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (scheduleId <= 0) {
            errors.put("scheduleId", "Assigned tour schedule departure is required.");
        }
        if (vesselId <= 0) {
            errors.put("vesselId", "Vessel must be specified for inspection.");
        }
        if (captainId <= 0) {
            errors.put("captainId", "Inspecting Boat Captain must be assigned.");
        }
        if (!safetyItemsVerified) {
            errors.put("safetyItemsVerified", "All mandatory SOLAS safety items (life rafts, flares, VHF radio, first aid) must be verified.");
        }
        if (lifeJacketsCount <= 0) {
            errors.put("lifeJacketsCount", "Verified count of operational life jackets must be greater than zero.");
        }
        if (fuelLevelPercent < 25 || fuelLevelPercent > 100) {
            errors.put("fuelLevelPercent", "Fuel level must be at least 25% for open-sea departure clearance (max 100%).");
        }
        if (weatherConditions == null || weatherConditions.trim().length() < 5) {
            errors.put("weatherConditions", "Weather and sea state observation notes are mandatory (min 5 chars).");
        }
        if (!briefingConfirmed) {
            errors.put("briefingConfirmed", "Passenger maritime safety briefing must be conducted and confirmed.");
        }
        if (!allClear) {
            errors.put("allClear", "Captain 'All Clear' declaration is mandatory for departure clearance.");
        }
        if (captainSignature == null || captainSignature.trim().length() < 3) {
            errors.put("captainSignature", "Captain digital signature / name confirmation is required.");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return "Safety Check #" + getId() + " - " + (vesselName != null ? vesselName : "Vessel #" + vesselId) + " (" + status.getLabel() + ")";
    }

    @Override
    public String getStatusLabel() {
        return status != null ? status.getLabel() : "Pending";
    }

    @Override
    public String getStatusBadgeClass() {
        return status != null ? status.getBadgeClass() : "badge-secondary";
    }

    public String getFormattedLoggedAt() {
        if (loggedAt == null) return "N/A";
        return loggedAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    // Getters and Setters
    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }

    public int getVesselId() { return vesselId; }
    public void setVesselId(int vesselId) { this.vesselId = vesselId; }

    public int getCaptainId() { return captainId; }
    public void setCaptainId(int captainId) { this.captainId = captainId; }

    public boolean isSafetyItemsVerified() { return safetyItemsVerified; }
    public void setSafetyItemsVerified(boolean safetyItemsVerified) { this.safetyItemsVerified = safetyItemsVerified; }

    public int getLifeJacketsCount() { return lifeJacketsCount; }
    public void setLifeJacketsCount(int lifeJacketsCount) { this.lifeJacketsCount = lifeJacketsCount; }

    public int getFuelLevelPercent() { return fuelLevelPercent; }
    public void setFuelLevelPercent(int fuelLevelPercent) { this.fuelLevelPercent = fuelLevelPercent; }

    public String getWeatherConditions() { return weatherConditions; }
    public void setWeatherConditions(String weatherConditions) { this.weatherConditions = weatherConditions; }

    public boolean isBriefingConfirmed() { return briefingConfirmed; }
    public void setBriefingConfirmed(boolean briefingConfirmed) { this.briefingConfirmed = briefingConfirmed; }

    public boolean isAllClear() { return allClear; }
    public void setAllClear(boolean allClear) { this.allClear = allClear; }

    public String getCaptainSignature() { return captainSignature; }
    public void setCaptainSignature(String captainSignature) { this.captainSignature = captainSignature; }

    public SafetyCheckStatus getStatus() { return status; }
    public void setStatus(SafetyCheckStatus status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getLoggedAt() { return loggedAt; }
    public void setLoggedAt(Timestamp loggedAt) { this.loggedAt = loggedAt; }

    public String getTourTitle() { return tourTitle; }
    public void setTourTitle(String tourTitle) { this.tourTitle = tourTitle; }

    public String getVesselName() { return vesselName; }
    public void setVesselName(String vesselName) { this.vesselName = vesselName; }

    public String getCaptainName() { return captainName; }
    public void setCaptainName(String captainName) { this.captainName = captainName; }

    public Timestamp getDepartureTime() { return departureTime; }
    public void setDepartureTime(Timestamp departureTime) { this.departureTime = departureTime; }
}
