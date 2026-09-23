package com.boatsafari.member3.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.member3.dao.BoatDAO;
import com.boatsafari.member3.model.Vessel;
import com.boatsafari.member3.model.VesselStatus;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 3: Boat Fleet Service Facade (Member 3: Boat Fleet Management).
 */
public class BoatService {
    private final BoatDAO boatDAO;
    private final com.boatsafari.member1.dao.TourScheduleDAO scheduleDAO;

    public BoatService() {
        this.boatDAO = new BoatDAO();
        this.scheduleDAO = new com.boatsafari.member1.dao.TourScheduleDAO();
    }

    public BoatService(BoatDAO boatDAO) {
        this.boatDAO = boatDAO;
        this.scheduleDAO = new com.boatsafari.member1.dao.TourScheduleDAO();
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    public List<Vessel> getAllVessels() {
        return boatDAO.findAll();
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    public List<Vessel> getAvailableVessels() {
        return boatDAO.findAvailableVessels();
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    public Optional<Vessel> getVesselById(int id) {
        return boatDAO.findById(id);
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    public List<com.boatsafari.member1.model.TourSchedule> checkVesselScheduleConflicts(int vesselId) {
        return scheduleDAO.findAll().stream()
                .filter(s -> s.getVesselId() != null && s.getVesselId() == vesselId && s.getStatus() == com.boatsafari.member1.model.ScheduleStatus.SCHEDULED)
                .toList();
    }

    // ==========================================
    // Member 3: CREATE & UPDATE
    // ==========================================
    public Vessel saveVessel(Vessel vessel) {
        Map<String, String> errors = vessel.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Vessel validation failed", errors);
        }
        if (vessel.getId() == null || vessel.getId() == 0) {
            // Member 3: CREATE
            return boatDAO.create(vessel);
        } else {
            // Member 3: UPDATE
            boatDAO.update(vessel);
            return vessel;
        }
    }

    // ==========================================
    // Member 3: UPDATE
    // ==========================================
    public boolean updateStatus(int vesselId, VesselStatus newStatus) {
        return boatDAO.updateStatus(vesselId, newStatus, null);
    }

    public boolean updateStatus(int vesselId, VesselStatus newStatus, String reason) {
        return boatDAO.updateStatus(vesselId, newStatus, reason);
    }

    // ==========================================
    // Member 3: DELETE
    // ==========================================
    public boolean deleteVessel(int vesselId) {
        return boatDAO.delete(vesselId);
    }
}
