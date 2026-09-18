package com.boatsafari.member4.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.dao.ActivityLogDAO;
import com.boatsafari.common.model.ActivityLog;
import com.boatsafari.member3.dao.BoatDAO;
import com.boatsafari.member3.model.Vessel;
import com.boatsafari.member3.model.VesselStatus;
import com.boatsafari.member4.dao.SafetyCheckDAO;
import com.boatsafari.member4.model.SafetyCheckLog;
import com.boatsafari.member4.model.SafetyCheckStatus;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 4: Pre-Trip Safety Check Service.
 * Business logic orchestrator for pre-trip checklists, departure clearance, and fleet readiness.
 * 
 * Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
 */
public class SafetyCheckService {
    private final SafetyCheckDAO safetyCheckDAO = new SafetyCheckDAO();
    private final BoatDAO boatDAO = new BoatDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    // ==========================================
    // Member 4: READ
    // ==========================================
    public List<SafetyCheckLog> getAllSafetyChecks() {
        return safetyCheckDAO.findAll();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public Optional<SafetyCheckLog> getSafetyCheckById(int id) {
        return safetyCheckDAO.findById(id);
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public Optional<SafetyCheckLog> getSafetyCheckForSchedule(int scheduleId) {
        return safetyCheckDAO.findByScheduleId(scheduleId);
    }

    /**
     * Captain submits "All Clear" pre-trip safety checklist.
     * System logs the check with timestamp & signature, and marks vessel "Ready for Departure".
     */
    // ==========================================
    // Member 4: CREATE
    // ==========================================
    public SafetyCheckLog submitPreTripSafetyCheck(SafetyCheckLog log) throws ValidationException {
        Map<String, String> errors = log.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException(errors);
        }

        log.setStatus(SafetyCheckStatus.READY_FOR_DEPARTURE);
        SafetyCheckLog saved = safetyCheckDAO.save(log);

        // Update vessel status to AVAILABLE / Ready for Departure if it was pending
        Optional<Vessel> vesselOpt = boatDAO.findById(log.getVesselId());
        vesselOpt.ifPresent(v -> {
            if (v.getStatus() == VesselStatus.UNDER_MAINTENANCE) {
                boatDAO.updateStatus(v.getId(), VesselStatus.AVAILABLE);
            }
        });

        // Audit log
        ActivityLog audit = new ActivityLog(
                log.getCaptainId(),
                "PRE_TRIP_SAFETY_CHECK_SUBMITTED",
                "SAFETY",
                "Captain submitted 'All Clear' pre-trip safety check for schedule #" + log.getScheduleId() + " (Vessel #" + log.getVesselId() + ")",
                "127.0.0.1"
        );
        logDAO.create(audit);

        return saved;
    }

    /**
     * Captain amends safety check log if a re-check is required (e.g. after refueling or maintenance fix).
     */
    // ==========================================
    // Member 4: UPDATE
    // ==========================================
    public boolean updateSafetyCheck(SafetyCheckLog log) throws ValidationException {
        Map<String, String> errors = log.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException(errors);
        }

        boolean ok = safetyCheckDAO.update(log);
        if (ok) {
            ActivityLog audit = new ActivityLog(
                    log.getCaptainId(),
                    "SAFETY_CHECK_AMENDED",
                    "SAFETY",
                    "Safety check #" + log.getId() + " re-verified and updated by Captain " + log.getCaptainSignature(),
                    "127.0.0.1"
            );
            logDAO.create(audit);
        }
        return ok;
    }

    /**
     * Administrator voids/cancels a logged check if entered in error.
     */
    // ==========================================
    // Member 4: DELETE / VOID
    // ==========================================
    public boolean voidSafetyCheck(int id, String reason) {
        boolean ok = safetyCheckDAO.voidLog(id, reason);
        if (ok) {
            ActivityLog audit = new ActivityLog(
                    1,
                    "SAFETY_CHECK_VOIDED",
                    "SAFETY",
                    "Safety check log #" + id + " marked as VOIDED. Reason: " + reason,
                    "127.0.0.1"
            );
            logDAO.create(audit);
        }
        return ok;
    }
}
