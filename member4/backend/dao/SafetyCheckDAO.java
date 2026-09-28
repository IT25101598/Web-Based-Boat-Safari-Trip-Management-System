package com.boatsafari.member4.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.common.core.CrudDAO;
import com.boatsafari.member4.model.SafetyCheckLog;
import com.boatsafari.member4.model.SafetyCheckStatus;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;

/**
 * Member 4: Pre-Trip Safety Check DAO.
 * Provides resilient CRUD operations for pre-trip safety checklist logs with thread-safe in-memory fallback.
 * 
 * Group: Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering
 */
public class SafetyCheckDAO extends AbstractDAO<SafetyCheckLog> {
    private static final List<SafetyCheckLog> FALLBACK_LOGS = new CopyOnWriteArrayList<>();
    private static final AtomicInteger ID_GEN = new AtomicInteger(10);

    static {
        // Pre-seeded fallback records
        SafetyCheckLog log1 = new SafetyCheckLog();
        log1.setId(1);
        log1.setScheduleId(1);
        log1.setVesselId(1);
        log1.setCaptainId(4);
        log1.setTourTitle("Mirissa Blue Whale & Dolphin Luxury Catamaran Safari");
        log1.setVesselName("Ocean Pearl (Ceycat 55)");
        log1.setCaptainName("Capt. Shantha Perera (Master Mariner)");
        log1.setDepartureTime(Timestamp.valueOf("2026-09-20 06:30:00"));
        log1.setSafetyItemsVerified(true);
        log1.setLifeJacketsCount(35);
        log1.setFuelLevelPercent(95);
        log1.setWeatherConditions("Calm seas, wave swell 0.8m, wind 10 knots SW, visibility 12nm");
        log1.setBriefingConfirmed(true);
        log1.setAllClear(true);
        log1.setCaptainSignature("Capt. Shantha Perera");
        log1.setStatus(SafetyCheckStatus.READY_FOR_DEPARTURE);
        log1.setNotes("All SOLAS life vests inspected, bilge pumps operational, marine radio tested on Channel 16.");
        log1.setLoggedAt(new Timestamp(System.currentTimeMillis() - 86400000L));
        FALLBACK_LOGS.add(log1);

        SafetyCheckLog log2 = new SafetyCheckLog();
        log2.setId(2);
        log2.setScheduleId(3);
        log2.setVesselId(2);
        log2.setCaptainId(5);
        log2.setTourTitle("Galle Fort Heritage & Sunset Champagne Sail");
        log2.setVesselName("Sapphire Blue (Topaz 48)");
        log2.setCaptainName("Capt. Ruwan Kumara (Catamaran Skipper)");
        log2.setDepartureTime(Timestamp.valueOf("2026-09-20 15:30:00"));
        log2.setSafetyItemsVerified(true);
        log2.setLifeJacketsCount(30);
        log2.setFuelLevelPercent(90);
        log2.setWeatherConditions("Gentle breeze, sea state 2, horizon clear for sunset cruise");
        log2.setBriefingConfirmed(true);
        log2.setAllClear(true);
        log2.setCaptainSignature("Capt. Ruwan Kumara");
        log2.setStatus(SafetyCheckStatus.READY_FOR_DEPARTURE);
        log2.setNotes("Safety briefings completed for all boarding guests; navigation lights tested.");
        log2.setLoggedAt(new Timestamp(System.currentTimeMillis() - 43200000L));
        FALLBACK_LOGS.add(log2);
    }

    @Override
    protected String getTableName() {
        return "safety_check_logs";
    }

    public SafetyCheckDAO() {
        super();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    @Override
    public Optional<SafetyCheckLog> findById(int id) {
        String sql = "SELECT s.*, ts.departure_time, t.title as tour_title, v.name as vessel_name, u.full_name as captain_name " +
                     "FROM safety_check_logs s " +
                     "LEFT JOIN tour_schedules ts ON s.schedule_id = ts.id " +
                     "LEFT JOIN tours t ON ts.tour_id = t.id " +
                     "LEFT JOIN vessels v ON s.vessel_id = v.id " +
                     "LEFT JOIN users u ON s.captain_id = u.id " +
                     "WHERE s.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.FINE, "Falling back to in-memory store for safety check #" + id);
        }
        return FALLBACK_LOGS.stream().filter(l -> l.getId() == id).findFirst();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public Optional<SafetyCheckLog> findByScheduleId(int scheduleId) {
        String sql = "SELECT s.*, ts.departure_time, t.title as tour_title, v.name as vessel_name, u.full_name as captain_name " +
                     "FROM safety_check_logs s " +
                     "LEFT JOIN tour_schedules ts ON s.schedule_id = ts.id " +
                     "LEFT JOIN tours t ON ts.tour_id = t.id " +
                     "LEFT JOIN vessels v ON s.vessel_id = v.id " +
                     "LEFT JOIN users u ON s.captain_id = u.id " +
                     "WHERE s.schedule_id = ? AND s.status != 'VOIDED' ORDER BY s.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, scheduleId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.FINE, "Falling back to in-memory store for schedule #" + scheduleId);
        }
        return FALLBACK_LOGS.stream()
                .filter(l -> l.getScheduleId() == scheduleId && l.getStatus() != SafetyCheckStatus.VOIDED)
                .findFirst();
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    @Override
    public List<SafetyCheckLog> findAll() {
        List<SafetyCheckLog> list = new ArrayList<>();
        String sql = "SELECT s.*, ts.departure_time, t.title as tour_title, v.name as vessel_name, u.full_name as captain_name " +
                     "FROM safety_check_logs s " +
                     "LEFT JOIN tour_schedules ts ON s.schedule_id = ts.id " +
                     "LEFT JOIN tours t ON ts.tour_id = t.id " +
                     "LEFT JOIN vessels v ON s.vessel_id = v.id " +
                     "LEFT JOIN users u ON s.captain_id = u.id " +
                     "ORDER BY s.id DESC";
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException e) {
            logger.log(Level.FINE, "Falling back to in-memory store for safety check logs");
            return new ArrayList<>(FALLBACK_LOGS);
        }
    }

    // ==========================================
    // Member 4: CREATE
    // ==========================================
    @Override
    public SafetyCheckLog create(SafetyCheckLog entity) {
        return save(entity);
    }

    // ==========================================
    // Member 4: CREATE / SAVE
    // ==========================================
    public SafetyCheckLog save(SafetyCheckLog entity) {
        String sql = "INSERT INTO safety_check_logs (schedule_id, vessel_id, captain_id, safety_items_verified, " +
                     "life_jackets_count, fuel_level_percent, weather_conditions, briefing_confirmed, all_clear, " +
                     "captain_signature, status, notes, logged_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, entity.getScheduleId());
            stmt.setInt(2, entity.getVesselId());
            stmt.setInt(3, entity.getCaptainId());
            stmt.setBoolean(4, entity.isSafetyItemsVerified());
            stmt.setInt(5, entity.getLifeJacketsCount());
            stmt.setInt(6, entity.getFuelLevelPercent());
            stmt.setString(7, entity.getWeatherConditions());
            stmt.setBoolean(8, entity.isBriefingConfirmed());
            stmt.setBoolean(9, entity.isAllClear());
            stmt.setString(10, entity.getCaptainSignature());
            stmt.setString(11, entity.getStatus() != null ? entity.getStatus().name() : "READY_FOR_DEPARTURE");
            stmt.setString(12, entity.getNotes());
            stmt.setTimestamp(13, entity.getLoggedAt() != null ? entity.getLoggedAt() : new Timestamp(System.currentTimeMillis()));

            stmt.executeUpdate();
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    entity.setId(keys.getInt(1));
                }
            }
            FALLBACK_LOGS.removeIf(l -> java.util.Objects.equals(l.getId(), entity.getId()));
            FALLBACK_LOGS.add(0, entity);
            return entity;
        } catch (SQLException e) {
            if (entity.getId() == null || entity.getId() == 0) {
                entity.setId(ID_GEN.incrementAndGet());
            }
            FALLBACK_LOGS.removeIf(l -> java.util.Objects.equals(l.getId(), entity.getId()));
            FALLBACK_LOGS.add(0, entity);
            return entity;
        }
    }

    // ==========================================
    // Member 4: UPDATE
    // ==========================================
    @Override
    public boolean update(SafetyCheckLog entity) {
        String sql = "UPDATE safety_check_logs SET safety_items_verified = ?, life_jackets_count = ?, " +
                     "fuel_level_percent = ?, weather_conditions = ?, briefing_confirmed = ?, all_clear = ?, " +
                     "captain_signature = ?, status = ?, notes = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, entity.isSafetyItemsVerified());
            stmt.setInt(2, entity.getLifeJacketsCount());
            stmt.setInt(3, entity.getFuelLevelPercent());
            stmt.setString(4, entity.getWeatherConditions());
            stmt.setBoolean(5, entity.isBriefingConfirmed());
            stmt.setBoolean(6, entity.isAllClear());
            stmt.setString(7, entity.getCaptainSignature());
            stmt.setString(8, entity.getStatus() != null ? entity.getStatus().name() : "READY_FOR_DEPARTURE");
            stmt.setString(9, entity.getNotes());
            stmt.setInt(10, entity.getId());
            boolean updated = stmt.executeUpdate() > 0;
            updateFallback(entity);
            return updated;
        } catch (SQLException e) {
            updateFallback(entity);
            return true;
        }
    }

    private void updateFallback(SafetyCheckLog entity) {
        for (int i = 0; i < FALLBACK_LOGS.size(); i++) {
            if (java.util.Objects.equals(FALLBACK_LOGS.get(i).getId(), entity.getId())) {
                FALLBACK_LOGS.set(i, entity);
                return;
            }
        }
        FALLBACK_LOGS.add(entity);
    }

    // ==========================================
    // Member 4: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        return voidLog(id, "Voided / Cancelled by Administrator");
    }

    // ==========================================
    // Member 4: DELETE / VOID
    // ==========================================
    public boolean voidLog(int id, String reason) {
        String sql = "UPDATE safety_check_logs SET status = 'VOIDED', notes = CONCAT(COALESCE(notes, ''), ' [VOIDED: ', ?, ']') WHERE id = ?";
        boolean dbOk = false;
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, reason);
            stmt.setInt(2, id);
            dbOk = stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Failed to void safety check in DB, falling back: " + e.getMessage());
        }

        boolean fallbackOk = false;
        for (SafetyCheckLog log : FALLBACK_LOGS) {
            if (log.getId() != null && log.getId().equals(id)) {
                log.setStatus(SafetyCheckStatus.VOIDED);
                log.setNotes((log.getNotes() != null ? log.getNotes() : "") + " [VOIDED: " + reason + "]");
                fallbackOk = true;
                break;
            }
        }
        boolean ok = dbOk || fallbackOk;
        if (ok) {
            com.boatsafari.common.util.LiveFileLogger.logTableUpdate("safety_check_logs", "VOID", id, "Safety check #" + id + " marked VOIDED: " + reason);
        }
        return ok;
    }

    @Override
    protected SafetyCheckLog mapRow(ResultSet rs) throws SQLException {
        SafetyCheckLog log = new SafetyCheckLog();
        log.setId(rs.getInt("id"));
        log.setScheduleId(rs.getInt("schedule_id"));
        log.setVesselId(rs.getInt("vessel_id"));
        log.setCaptainId(rs.getInt("captain_id"));
        log.setSafetyItemsVerified(rs.getBoolean("safety_items_verified"));
        log.setLifeJacketsCount(rs.getInt("life_jackets_count"));
        log.setFuelLevelPercent(rs.getInt("fuel_level_percent"));
        log.setWeatherConditions(rs.getString("weather_conditions"));
        log.setBriefingConfirmed(rs.getBoolean("briefing_confirmed"));
        log.setAllClear(rs.getBoolean("all_clear"));
        log.setCaptainSignature(rs.getString("captain_signature"));
        try {
            log.setStatus(SafetyCheckStatus.valueOf(rs.getString("status")));
        } catch (Exception e) {
            log.setStatus(SafetyCheckStatus.READY_FOR_DEPARTURE);
        }
        log.setNotes(rs.getString("notes"));
        log.setLoggedAt(rs.getTimestamp("logged_at"));

        // Join columns if present
        try {
            log.setDepartureTime(rs.getTimestamp("departure_time"));
            log.setTourTitle(rs.getString("tour_title"));
            log.setVesselName(rs.getString("vessel_name"));
            log.setCaptainName(rs.getString("captain_name"));
        } catch (SQLException ignored) {}

        return log;
    }
}
