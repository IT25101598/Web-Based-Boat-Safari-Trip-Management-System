package com.boatsafari.member4.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Validator;

import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 4: Service Reminder (Member 4: Boat Maintenance & Service Management).
 * Automated recurring maintenance alerts based on operating intervals.
 */
public class ServiceReminder extends BaseModel {
    private Integer vesselId;
    private String vesselName;
    private String reminderTitle;
    private int intervalDays = 90;
    private Date lastServicedDate;
    private Date nextDueDate;
    private boolean overdue = false;
    private String notes;

    public ServiceReminder() {
        super();
        this.lastServicedDate = Date.valueOf(LocalDate.now());
        this.nextDueDate = Date.valueOf(LocalDate.now().plusDays(90));
    }

    public ServiceReminder(Integer id, int vesselId, String title, int intervalDays, Date lastService, Date nextDue) {
        super(id);
        this.vesselId = vesselId;
        this.reminderTitle = title;
        this.intervalDays = intervalDays;
        this.lastServicedDate = lastService;
        this.nextDueDate = nextDue;
        this.overdue = nextDue != null && nextDue.before(Date.valueOf(LocalDate.now()));
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

    public String getReminderTitle() {
        return reminderTitle;
    }

    public void setReminderTitle(String reminderTitle) {
        this.reminderTitle = reminderTitle;
    }

    public int getIntervalDays() {
        return intervalDays;
    }

    public void setIntervalDays(int intervalDays) {
        this.intervalDays = intervalDays;
    }

    public Date getLastServicedDate() {
        return lastServicedDate;
    }

    public void setLastServicedDate(Date lastServicedDate) {
        this.lastServicedDate = lastServicedDate;
    }

    public Date getNextDueDate() {
        return nextDueDate;
    }

    public void setNextDueDate(Date nextDueDate) {
        this.nextDueDate = nextDueDate;
        if (nextDueDate != null) {
            this.overdue = nextDueDate.before(Date.valueOf(LocalDate.now()));
        }
    }

    public boolean isOverdue() {
        return overdue;
    }

    public void setOverdue(boolean overdue) {
        this.overdue = overdue;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (vesselId == null || vesselId <= 0) {
            errors.put("vesselId", "Vessel selection is required");
        }
        if (!Validator.isNotBlank(reminderTitle)) {
            errors.put("reminderTitle", "Reminder title is required");
        }
        if (nextDueDate == null) {
            errors.put("nextDueDate", "Next service due date is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return reminderTitle + " (Due: " + nextDueDate + (overdue ? " - OVERDUE!" : "") + ")";
    }

    @Override
    public String getStatusLabel() {
        return overdue ? "Overdue" : "On Track";
    }

    @Override
    public String getStatusBadgeClass() {
        return overdue ? "badge-danger" : "badge-success";
    }
}
