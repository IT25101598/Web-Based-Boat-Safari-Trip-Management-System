package com.boatsafari.member4.controller;

import com.boatsafari.common.core.BaseController;
import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.util.Csrf;
import com.boatsafari.member3.service.BoatService;
import com.boatsafari.member4.model.MaintenanceRecord;
import com.boatsafari.member4.model.MaintenanceStatus;
import com.boatsafari.member4.model.MaintenanceType;
import com.boatsafari.member4.model.ServiceReminder;
import com.boatsafari.member4.service.MaintenanceService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

/**
 * Member 4: Boat Maintenance Controller (Member 4: Boat Maintenance & Service Management).
 */
@WebServlet(name = "MaintenanceController", urlPatterns = {"/maintenance", "/maintenance/delete", "/admin/maintenance", "/admin/maintenance/create", "/admin/maintenance/edit", "/admin/maintenance/delete", "/admin/maintenance/reminders", "/admin/maintenance/reminders/create"})
public class MaintenanceController extends BaseController {
    private final MaintenanceService maintenanceService = new MaintenanceService();
    private final BoatService boatService = new BoatService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // ==========================================
        // Member 4: READ (Reminders)
        // ==========================================
        if ("/admin/maintenance/reminders".equals(path)) {
            List<ServiceReminder> reminders = maintenanceService.getAllReminders();
            request.setAttribute("reminders", reminders);
            request.setAttribute("vessels", boatService.getAllVessels());
            render(request, response, "member4/service-reminders.jsp");
            return;
        }

        // ==========================================
        // Member 4: CREATE (Maintenance Form)
        // ==========================================
        if ("/admin/maintenance/create".equals(path)) {
            request.setAttribute("vessels", boatService.getAllVessels());
            request.setAttribute("maintenanceTypes", MaintenanceType.values());
            request.setAttribute("maintenanceStatuses", MaintenanceStatus.values());
            render(request, response, "member4/maintenance-form.jsp");
            return;
        }

        // ==========================================
        // Member 4: UPDATE (Maintenance Form)
        // ==========================================
        if ("/admin/maintenance/edit".equals(path)) {
            int editId = getIntParam(request, "id", 0);
            java.util.Optional<MaintenanceRecord> opt = maintenanceService.getRecordById(editId);
            if (opt.isPresent()) {
                request.setAttribute("record", opt.get());
                request.setAttribute("vessels", boatService.getAllVessels());
                request.setAttribute("maintenanceTypes", MaintenanceType.values());
                request.setAttribute("maintenanceStatuses", MaintenanceStatus.values());
                render(request, response, "member4/maintenance-form.jsp");
            } else {
                flashError(request, "Maintenance log #" + editId + " not found.");
                redirect(response, request.getContextPath() + "/admin/maintenance");
            }
            return;
        }

        // ==========================================
        // Member 4: READ (List)
        // ==========================================
        List<MaintenanceRecord> records = maintenanceService.getAllRecords();
        request.setAttribute("records", records);
        request.setAttribute("totalCost", maintenanceService.getTotalMaintenanceExpense());
        request.setAttribute("vessels", boatService.getAllVessels());
        render(request, response, "member4/maintenance-list.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!Csrf.validate(request)) {
            flashError(request, "Security verification failed.");
            redirect(response, request.getContextPath() + "/admin/maintenance");
            return;
        }

        String path = request.getServletPath();

        // ==========================================
        // Member 4: DELETE
        // ==========================================
        if ("/admin/maintenance/delete".equals(path) || "/maintenance/delete".equals(path)) {
            int deleteId = getIntParam(request, "id", 0);
            boolean ok = maintenanceService.deleteRecord(deleteId);
            if (ok) {
                flashSuccess(request, "Maintenance log #" + deleteId + " successfully deleted.");
            } else {
                flashError(request, "Failed to delete maintenance log #" + deleteId + ".");
            }
            redirect(response, request.getContextPath() + (path.startsWith("/admin") ? "/admin/maintenance" : "/maintenance"));
            return;
        }

        // ==========================================
        // Member 4: CREATE (Service Reminder)
        // ==========================================
        if ("/admin/maintenance/reminders/create".equals(path)) {
            int vesselId = getIntParam(request, "vesselId", 0);
            String title = getStringParam(request, "reminderTitle", "");
            int days = getIntParam(request, "intervalDays", 90);
            String notes = getStringParam(request, "notes", "");

            ServiceReminder reminder = new ServiceReminder();
            reminder.setVesselId(vesselId);
            reminder.setReminderTitle(title);
            reminder.setIntervalDays(days);
            reminder.setLastServicedDate(Date.valueOf(LocalDate.now()));
            reminder.setNextDueDate(Date.valueOf(LocalDate.now().plusDays(days)));
            reminder.setNotes(notes);

            try {
                maintenanceService.saveReminder(reminder);
                flashSuccess(request, "Service reminder configured successfully!");
            } catch (ValidationException e) {
                flashError(request, e.getMessage());
            }
            redirect(response, request.getContextPath() + "/admin/maintenance/reminders");
            return;
        }

        // ==========================================
        // Member 4: CREATE & UPDATE (Save Record)
        // ==========================================
        // Log / Edit Maintenance
        int id = getIntParam(request, "id", 0);
        int vesselId = getIntParam(request, "vesselId", 0);
        String typeStr = getStringParam(request, "maintenanceType", "ROUTINE_SERVICE");
        String desc = getStringParam(request, "description", "");
        String schedDateStr = getStringParam(request, "scheduledDate", LocalDate.now().toString());
        String compDateStr = getStringParam(request, "completedDate", "");
        double cost = getDoubleParam(request, "cost", 0.0);
        String provider = getStringParam(request, "serviceProvider", "");
        String statusStr = getStringParam(request, "status", "SCHEDULED");

        MaintenanceRecord record = new MaintenanceRecord();
        if (id > 0) {
            record.setId(id);
        }
        record.setVesselId(vesselId);
        try {
            record.setMaintenanceType(MaintenanceType.valueOf(typeStr));
        } catch (Exception e) {
            record.setMaintenanceType(MaintenanceType.ROUTINE_SERVICE);
        }
        record.setDescription(desc);
        try {
            record.setScheduledDate(Date.valueOf(schedDateStr));
            if (!compDateStr.isBlank()) {
                record.setCompletedDate(Date.valueOf(compDateStr));
            }
        } catch (Exception ignored) {}
        record.setCostAmount(BigDecimal.valueOf(cost));
        record.setServiceProvider(provider);
        try {
            record.setStatus(MaintenanceStatus.valueOf(statusStr));
        } catch (Exception e) {
            record.setStatus(MaintenanceStatus.SCHEDULED);
        }

        try {
            maintenanceService.logMaintenance(record);
            flashSuccess(request, "Maintenance log entry successfully " + (id > 0 ? "updated!" : "recorded!"));
            redirect(response, request.getContextPath() + "/admin/maintenance");
        } catch (ValidationException e) {
            flashError(request, e.getMessage());
            redirect(response, request.getContextPath() + (id > 0 ? "/admin/maintenance/edit?id=" + id : "/admin/maintenance/create"));
        }
    }
}
