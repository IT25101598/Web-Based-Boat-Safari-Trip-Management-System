package com.boatsafari.member5.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.member5.dao.EmergencyDAO;
import com.boatsafari.member5.model.EmergencyNotice;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 5: Emergency Management Service Facade (Member 5: Maritime Safety & Emergency Notice Management).
 */
public class EmergencyService {
    private final EmergencyDAO emergencyDAO;

    public EmergencyService() {
        this.emergencyDAO = new EmergencyDAO();
    }

    public EmergencyService(EmergencyDAO emergencyDAO) {
        this.emergencyDAO = emergencyDAO;
    }

    // ==========================================
    // Member 5: READ
    // ==========================================
    public List<EmergencyNotice> getActiveNotices() {
        return emergencyDAO.findActiveNotices();
    }

    // ==========================================
    // Member 5: READ
    // ==========================================
    public List<EmergencyNotice> getAllNotices() {
        return emergencyDAO.findAll();
    }

    // ==========================================
    // Member 5: READ
    // ==========================================
    public Optional<EmergencyNotice> getNoticeById(int id) {
        return emergencyDAO.findById(id);
    }

    // ==========================================
    // Member 5: CREATE
    // ==========================================
    public EmergencyNotice broadcastAlert(EmergencyNotice notice) {
        Map<String, String> errors = notice.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Emergency notice validation failed", errors);
        }
        return emergencyDAO.create(notice);
    }

    // ==========================================
    // Member 5: UPDATE
    // ==========================================
    public boolean updateNotice(EmergencyNotice notice) {
        Map<String, String> errors = notice.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Emergency notice validation failed", errors);
        }
        return emergencyDAO.update(notice);
    }

    // ==========================================
    // Member 5: UPDATE
    // ==========================================
    public boolean resolveAlert(int noticeId) {
        return emergencyDAO.resolveNotice(noticeId);
    }

    // ==========================================
    // Member 5: DELETE
    // ==========================================
    public boolean deleteNotice(int noticeId) {
        return emergencyDAO.delete(noticeId);
    }
}
