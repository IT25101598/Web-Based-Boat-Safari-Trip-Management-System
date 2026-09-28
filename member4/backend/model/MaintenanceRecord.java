package com.boatsafari.member4.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Money;
import com.boatsafari.common.util.Validator;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 4: Boat Maintenance Log Record (Member 4: Boat Maintenance & Service Management).
 * Tracks maintenance costs, service providers, and marine surveyor signoffs.
 */
public class MaintenanceRecord extends BaseModel {
    private Integer vesselId;
    private String vesselName;
    private MaintenanceType maintenanceType = MaintenanceType.ROUTINE_SERVICE;
    private String description;
    private Date scheduledDate;
    private Date completedDate;
    private Money cost = Money.zero();
    private String serviceProvider;
    private MaintenanceStatus status = MaintenanceStatus.SCHEDULED;

    public MaintenanceRecord() {
        super();
        this.scheduledDate = new Date(System.currentTimeMillis());
    }

    public MaintenanceRecord(Integer id, int vesselId, MaintenanceType type, String description, Date scheduledDate, BigDecimal cost, String provider) {
        super(id);
        this.vesselId = vesselId;
        this.maintenanceType = type;
        this.description = description;
        this.scheduledDate = scheduledDate;
        this.cost = new Money(cost);
        this.serviceProvider = provider;
    }

    public Integer getVesselId() {
        return vesselId;
    }

    public void setVesselId(Integer vesselId) {
        this.vesselId = vesselId;
    }

    public String getVesselName() {
        return vesselName;
    }

    public void setVesselName(String vesselName) {
        this.vesselName = vesselName;
    }

    public MaintenanceType getMaintenanceType() {
        return maintenanceType;
    }

    public void setMaintenanceType(MaintenanceType maintenanceType) {
        this.maintenanceType = maintenanceType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(Date scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public Date getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(Date completedDate) {
        this.completedDate = completedDate;
    }

    public Money getCost() {
        return cost;
    }

    public void setCost(Money cost) {
        this.cost = cost != null ? cost : Money.zero();
    }

    public void setCostAmount(BigDecimal amount) {
        this.cost = new Money(amount);
    }

    public String getServiceProvider() {
        return serviceProvider;
    }

    public void setServiceProvider(String serviceProvider) {
        this.serviceProvider = serviceProvider;
    }

    public MaintenanceStatus getStatus() {
        return status;
    }

    public void setStatus(MaintenanceStatus status) {
        this.status = status != null ? status : MaintenanceStatus.SCHEDULED;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (vesselId == null || vesselId <= 0) {
            errors.put("vesselId", "Vessel selection is required");
        }
        if (!Validator.isNotBlank(description)) {
            errors.put("description", "Maintenance description is required");
        }
        if (scheduledDate == null) {
            errors.put("scheduledDate", "Scheduled service date is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return maintenanceType.getTitle() + " for " + (vesselName != null ? vesselName : "Vessel #" + vesselId) + " - " + cost.getFormatted();
    }

    @Override
    public String getStatusLabel() {
        return status.getLabel();
    }

    @Override
    public String getStatusBadgeClass() {
        return status.getBadgeClass();
    }
}
