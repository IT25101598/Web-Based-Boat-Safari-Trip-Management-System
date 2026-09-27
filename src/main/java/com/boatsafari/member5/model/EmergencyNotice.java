package com.boatsafari.member5.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Validator;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 5: Emergency Notice Entity (Member 5: Maritime Safety & Emergency Notice Management).
 * Manages urgent maritime safety alerts, weather warnings, and status resolutions.
 */
public class EmergencyNotice extends BaseModel {
    private String title;
    private EmergencyCategory category = EmergencyCategory.BAD_WEATHER;
    private EmergencySeverity severity = EmergencySeverity.HIGH;
    private Integer affectedTourId;
    private String affectedTourTitle;
    private Integer affectedVesselId;
    private String affectedVesselName;
    private String affectedRegion = "SOUTH_COAST";
    private String message;
    private String broadcastChannels = "PORTAL,SMS,EMAIL";
    private EmergencyStatus status = EmergencyStatus.ACTIVE;
    private Integer createdById;
    private String createdByName;
    private Timestamp resolvedAt;

    public EmergencyNotice() {
        super();
    }

    public EmergencyNotice(Integer id, String title, EmergencyCategory category, EmergencySeverity severity, String message, String region) {
        super(id);
        this.title = title;
        this.category = category;
        this.severity = severity;
        this.message = message;
        this.affectedRegion = region;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title != null ? title.trim() : null;
    }

    public EmergencyCategory getCategory() {
        return category;
    }

    public void setCategory(EmergencyCategory category) {
        this.category = category != null ? category : EmergencyCategory.BAD_WEATHER;
    }

    public String getCategoryLabel() {
        return category != null ? category.name().replace('_', ' ') : "GENERAL";
    }

    public EmergencySeverity getSeverity() {
        return severity;
    }

    public void setSeverity(EmergencySeverity severity) {
        this.severity = severity != null ? severity : EmergencySeverity.HIGH;
    }

    public Integer getAffectedTourId() {
        return affectedTourId;
    }

    public void setAffectedTourId(Integer affectedTourId) {
        this.affectedTourId = affectedTourId;
    }

    public String getAffectedTourTitle() {
        return affectedTourTitle;
    }

    public void setAffectedTourTitle(String affectedTourTitle) {
        this.affectedTourTitle = affectedTourTitle;
    }

    public Integer getAffectedVesselId() {
        return affectedVesselId;
    }

    public void setAffectedVesselId(Integer affectedVesselId) {
        this.affectedVesselId = affectedVesselId;
    }

    public String getAffectedVesselName() {
        return affectedVesselName;
    }

    public void setAffectedVesselName(String affectedVesselName) {
        this.affectedVesselName = affectedVesselName;
    }

    public String getAffectedRegion() {
        return affectedRegion;
    }

    public void setAffectedRegion(String affectedRegion) {
        this.affectedRegion = affectedRegion != null ? affectedRegion : "ALL_REGIONS";
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getBroadcastChannels() {
        return broadcastChannels;
    }

    public void setBroadcastChannels(String broadcastChannels) {
        this.broadcastChannels = broadcastChannels;
    }

    public EmergencyStatus getStatus() {
        return status;
    }

    public void setStatus(EmergencyStatus status) {
        this.status = status != null ? status : EmergencyStatus.ACTIVE;
    }

    public Integer getCreatedById() {
        return createdById;
    }

    public void setCreatedById(Integer createdById) {
        this.createdById = createdById;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt != null ? (Timestamp) resolvedAt.clone() : null;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt != null ? (Timestamp) resolvedAt.clone() : null;
    }

    public boolean isActive() {
        return status == EmergencyStatus.ACTIVE;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(title)) {
            errors.put("title", "Emergency alert title is required");
        }
        if (!Validator.isNotBlank(message)) {
            errors.put("message", "Detailed advisory message is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return "[" + severity.name() + "] " + title + ": " + message;
    }

    @Override
    public String getStatusLabel() {
        return status.getLabel();
    }

    @Override
    public String getStatusBadgeClass() {
        return severity.getBadgeClass();
    }

    public String getSeverityBadgeClass() {
        return severity != null ? severity.getBadgeClass() : "badge-secondary";
    }
}
