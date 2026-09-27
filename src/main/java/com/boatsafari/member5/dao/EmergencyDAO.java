package com.boatsafari.member5.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member5.model.EmergencyCategory;
import com.boatsafari.member5.model.EmergencyNotice;
import com.boatsafari.member5.model.EmergencySeverity;
import com.boatsafari.member5.model.EmergencyStatus;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 5: Emergency Notices DAO (Member 5: Maritime Safety & Emergency Notice Management).
 */
public class EmergencyDAO extends AbstractDAO<EmergencyNotice> {
    private static final List<EmergencyNotice> FALLBACK_NOTICES = new CopyOnWriteArrayList<>();

    static {
        EmergencyNotice n1 = new EmergencyNotice(1, "Rough Seas Advisory for Southern Waters", EmergencyCategory.BAD_WEATHER, EmergencySeverity.HIGH, "Gusty winds up to 55 km/h and wave swells reaching 2.8m expected along Mirissa to Galle. Afternoon departures suspended.", "SOUTH_COAST");
        n1.setStatus(EmergencyStatus.ACTIVE);
        n1.setCreatedByName("System Administrator");
        FALLBACK_NOTICES.add(n1);

        EmergencyNotice n2 = new EmergencyNotice(2, "Technical Slipway Notice: Mirissa Sun (Lagoon 42)", EmergencyCategory.TECHNICAL_DELAY, EmergencySeverity.MEDIUM, "Vessel undergoing scheduled slipway maintenance. Existing bookings reassigned to Ocean Pearl with zero disruption.", "SOUTH_COAST");
        n2.setStatus(EmergencyStatus.ACTIVE);
        n2.setAffectedVesselName("Mirissa Sun (Lagoon 42)");
        n2.setCreatedByName("Tour Manager");
        FALLBACK_NOTICES.add(n2);
    }

    @Override
    protected String getTableName() {
        return "emergency_notices";
    }

    @Override
    protected EmergencyNotice mapRow(ResultSet rs) throws SQLException {
        EmergencyNotice n = new EmergencyNotice();
        n.setId(rs.getInt("id"));
        n.setTitle(rs.getString("title"));
        try {
            n.setCategory(EmergencyCategory.valueOf(rs.getString("category")));
        } catch (Exception e) {
            n.setCategory(EmergencyCategory.BAD_WEATHER);
        }
        try {
            n.setSeverity(EmergencySeverity.valueOf(rs.getString("severity")));
        } catch (Exception e) {
            n.setSeverity(EmergencySeverity.HIGH);
        }
        int tourId = rs.getInt("affected_tour_id");
        n.setAffectedTourId(rs.wasNull() ? null : tourId);
        int vesselId = rs.getInt("affected_vessel_id");
        n.setAffectedVesselId(rs.wasNull() ? null : vesselId);
        n.setAffectedRegion(rs.getString("affected_region"));
        n.setMessage(rs.getString("message"));
        n.setBroadcastChannels(rs.getString("broadcast_channels"));
        try {
            n.setStatus(EmergencyStatus.valueOf(rs.getString("status")));
        } catch (Exception e) {
            n.setStatus(EmergencyStatus.ACTIVE);
        }
        int createdById = rs.getInt("created_by_id");
        n.setCreatedById(rs.wasNull() ? null : createdById);
        n.setCreatedAt(rs.getTimestamp("created_at"));
        n.setResolvedAt(rs.getTimestamp("resolved_at"));
        return n;
    }

    // ==========================================
    // Member 5: READ
    // ==========================================
    @Override
    public Optional<EmergencyNotice> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_NOTICES.stream().filter(n -> n.getId() != null && n.getId() == id).findFirst();
        }
        String sql = "SELECT e.*, u.full_name AS created_by_name FROM emergency_notices e LEFT JOIN users u ON e.created_by_id = u.id WHERE e.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    EmergencyNotice en = mapRow(rs);
                    en.setCreatedByName(rs.getString("created_by_name"));
                    return Optional.of(en);
                }
            }
        } catch (SQLException e) {
            return FALLBACK_NOTICES.stream().filter(n -> n.getId() != null && n.getId() == id).findFirst();
        }
        return Optional.empty();
    }

    // ==========================================
    // Member 5: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        FALLBACK_NOTICES.removeIf(n -> n.getId() != null && n.getId() == id);
        if (!db.isDatabaseAvailable()) {
            return true;
        }
        return super.delete(id);
    }

    // ==========================================
    // Member 5: READ
    // ==========================================
    @Override
    public List<EmergencyNotice> findAll() {
        List<EmergencyNotice> list = new ArrayList<>();
        String sql = "SELECT e.*, u.full_name AS created_by_name FROM emergency_notices e LEFT JOIN users u ON e.created_by_id = u.id ORDER BY e.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                EmergencyNotice en = mapRow(rs);
                en.setCreatedByName(rs.getString("created_by_name"));
                list.add(en);
            }
        } catch (SQLException e) {
            return FALLBACK_NOTICES;
        }
        return list;
    }

    // ==========================================
    // Member 5: READ
    // ==========================================
    public List<EmergencyNotice> findActiveNotices() {
        List<EmergencyNotice> list = new ArrayList<>();
        String sql = "SELECT * FROM emergency_notices WHERE status = 'ACTIVE' ORDER BY severity DESC, id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            return FALLBACK_NOTICES.stream().filter(EmergencyNotice::isActive).toList();
        }
        return list;
    }

    // ==========================================
    // Member 5: UPDATE
    // ==========================================
    public boolean resolveNotice(int id) {
        String sql = "UPDATE emergency_notices SET status = 'RESOLVED', resolved_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (EmergencyNotice n : FALLBACK_NOTICES) {
                if (n.getId().equals(id)) {
                    n.setStatus(EmergencyStatus.RESOLVED);
                    n.setResolvedAt(new Timestamp(System.currentTimeMillis()));
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 5: CREATE
    // ==========================================
    @Override
    public EmergencyNotice create(EmergencyNotice entity) {
        String sql = "INSERT INTO emergency_notices (title, category, severity, affected_tour_id, affected_vessel_id, affected_region, message, broadcast_channels, status, created_by_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getTitle());
            stmt.setString(2, entity.getCategory().name());
            stmt.setString(3, entity.getSeverity().name());
            if (entity.getAffectedTourId() != null) stmt.setInt(4, entity.getAffectedTourId()); else stmt.setNull(4, Types.INTEGER);
            if (entity.getAffectedVesselId() != null) stmt.setInt(5, entity.getAffectedVesselId()); else stmt.setNull(5, Types.INTEGER);
            stmt.setString(6, entity.getAffectedRegion());
            stmt.setString(7, entity.getMessage());
            stmt.setString(8, entity.getBroadcastChannels());
            stmt.setString(9, entity.getStatus().name());
            if (entity.getCreatedById() != null) stmt.setInt(10, entity.getCreatedById()); else stmt.setNull(10, Types.INTEGER);

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_NOTICES.add(0, entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database insert failed for emergency notice: " + e.getMessage(), e);
            entity.setId(FALLBACK_NOTICES.size() + 1);
            FALLBACK_NOTICES.add(0, entity);
            return entity;
        }
    }

    // ==========================================
    // Member 5: UPDATE
    // ==========================================
    @Override
    public boolean update(EmergencyNotice entity) {
        String sql = "UPDATE emergency_notices SET title = ?, category = ?, severity = ?, affected_tour_id = ?, affected_vessel_id = ?, affected_region = ?, message = ?, broadcast_channels = ?, status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getTitle());
            stmt.setString(2, entity.getCategory().name());
            stmt.setString(3, entity.getSeverity().name());
            if (entity.getAffectedTourId() != null) stmt.setInt(4, entity.getAffectedTourId()); else stmt.setNull(4, Types.INTEGER);
            if (entity.getAffectedVesselId() != null) stmt.setInt(5, entity.getAffectedVesselId()); else stmt.setNull(5, Types.INTEGER);
            stmt.setString(6, entity.getAffectedRegion());
            stmt.setString(7, entity.getMessage());
            stmt.setString(8, entity.getBroadcastChannels());
            stmt.setString(9, entity.getStatus().name());
            stmt.setInt(10, entity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_NOTICES.size(); i++) {
                if (FALLBACK_NOTICES.get(i).getId().equals(entity.getId())) {
                    FALLBACK_NOTICES.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }
}
