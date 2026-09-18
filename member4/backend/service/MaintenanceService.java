package com.boatsafari.member4.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.member3.dao.BoatDAO;
import com.boatsafari.member3.model.VesselStatus;
import com.boatsafari.member4.dao.MaintenanceDAO;
import com.boatsafari.member4.dao.ReminderDAO;
import com.boatsafari.member4.model.MaintenanceRecord;
import com.boatsafari.member4.model.MaintenanceStatus;
import com.boatsafari.member4.model.ServiceReminder;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 4: Boat Maintenance Service Facade (Member 4: Boat Maintenance & Service Management).
 */
public class MaintenanceService {
    private final MaintenanceDAO maintenanceDAO;
    private final ReminderDAO reminderDAO;
    private final BoatDAO boatDAO;

    public MaintenanceService() {
        this.maintenanceDAO = new MaintenanceDAO();
        this.reminderDAO = new ReminderDAO();
        this.boatDAO = new BoatDAO();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public List<MaintenanceRecord> getAllRecords() {
        return maintenanceDAO.findAll();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public List<ServiceReminder> getAllReminders() {
        return reminderDAO.findAll();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public Optional<MaintenanceRecord> getRecordById(int id) {
        return maintenanceDAO.findById(id);
    }

    // ==========================================
    // Member 4: CREATE & UPDATE
    // ==========================================
    public MaintenanceRecord logMaintenance(MaintenanceRecord record) {
        Map<String, String> errors = record.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Maintenance validation failed", errors);
        }

        // If maintenance is in progress or scheduled, update vessel status
        if (record.getStatus() == MaintenanceStatus.IN_PROGRESS) {
            boatDAO.updateStatus(record.getVesselId(), VesselStatus.UNDER_MAINTENANCE);
        } else if (record.getStatus() == MaintenanceStatus.COMPLETED) {
            boatDAO.updateStatus(record.getVesselId(), VesselStatus.AVAILABLE);
        }

        if (record.getId() == null || record.getId() == 0) {
            // Member 4: CREATE
            return maintenanceDAO.create(record);
        } else {
            // Member 4: UPDATE
            maintenanceDAO.update(record);
            return record;
        }
    }

    // ==========================================
    // Member 4: CREATE & UPDATE
    // ==========================================
    public ServiceReminder saveReminder(ServiceReminder reminder) {
        Map<String, String> errors = reminder.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Reminder validation failed", errors);
        }
        if (reminder.getId() == null || reminder.getId() == 0) {
            // Member 4: CREATE
            return reminderDAO.create(reminder);
        } else {
            // Member 4: UPDATE
            reminderDAO.update(reminder);
            return reminder;
        }
    }

    public double getTotalMaintenanceExpense() {
        return maintenanceDAO.calculateTotalCost();
    }

    // ==========================================
    // Member 4: DELETE
    // ==========================================
    public boolean deleteRecord(int id) {
        return maintenanceDAO.delete(id);
    }
}
