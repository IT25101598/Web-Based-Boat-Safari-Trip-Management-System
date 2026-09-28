package com.boatsafari.member4.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member4.model.MaintenanceRecord;
import com.boatsafari.member4.model.MaintenanceStatus;
import com.boatsafari.member4.model.MaintenanceType;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 4: Boat Maintenance Log DAO (Member 4: Boat Maintenance & Service Management).
 */
public class MaintenanceDAO extends AbstractDAO<MaintenanceRecord> {
    private static final List<MaintenanceRecord> FALLBACK_RECORDS = new CopyOnWriteArrayList<>();

    static {
        MaintenanceRecord r1 = new MaintenanceRecord(1, 1, MaintenanceType.ROUTINE_SERVICE, "500-hour engine service, oil filter replacement, fuel line purge", Date.valueOf("2026-08-10"), BigDecimal.valueOf(85000.00), "Colombo Marine Dockyard Eng.");
        r1.setVesselName("Ocean Pearl (Ceycat 55)");
        r1.setStatus(MaintenanceStatus.COMPLETED);
        r1.setCompletedDate(Date.valueOf("2026-08-11"));
        FALLBACK_RECORDS.add(r1);

        MaintenanceRecord r2 = new MaintenanceRecord(2, 2, MaintenanceType.SAFETY_INSPECTION, "Annual Merchant Shipping Secretariat survey and life raft recertification", Date.valueOf("2026-08-25"), BigDecimal.valueOf(45000.00), "Ceylon Maritime Surveyors");
        r2.setVesselName("Sapphire Blue (Topaz 48)");
        r2.setStatus(MaintenanceStatus.COMPLETED);
        r2.setCompletedDate(Date.valueOf("2026-08-26"));
        FALLBACK_RECORDS.add(r2);

        MaintenanceRecord r3 = new MaintenanceRecord(3, 5, MaintenanceType.HULL_CLEANING, "Antifouling hull scrape and repaint, rudder bearing inspection", Date.valueOf("2026-09-12"), BigDecimal.valueOf(125000.00), "Galle Fishery Harbour Slipway");
        r3.setVesselName("Mirissa Sun (Lagoon 42)");
        r3.setStatus(MaintenanceStatus.IN_PROGRESS);
        FALLBACK_RECORDS.add(r3);
    }

    @Override
    protected String getTableName() {
        return "maintenance_records";
    }

    @Override
    protected MaintenanceRecord mapRow(ResultSet rs) throws SQLException {
        MaintenanceRecord r = new MaintenanceRecord();
        r.setId(rs.getInt("id"));
        r.setVesselId(rs.getInt("vessel_id"));
        try {
            r.setMaintenanceType(MaintenanceType.valueOf(rs.getString("maintenance_type")));
        } catch (Exception e) {
            r.setMaintenanceType(MaintenanceType.ROUTINE_SERVICE);
        }
        r.setDescription(rs.getString("description"));
        r.setScheduledDate(rs.getDate("scheduled_date"));
        r.setCompletedDate(rs.getDate("completed_date"));
        r.setCostAmount(rs.getBigDecimal("cost"));
        r.setServiceProvider(rs.getString("service_provider"));
        try {
            r.setStatus(MaintenanceStatus.valueOf(rs.getString("status")));
        } catch (Exception e) {
            r.setStatus(MaintenanceStatus.SCHEDULED);
        }
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    @Override
    public List<MaintenanceRecord> findAll() {
        List<MaintenanceRecord> list = new ArrayList<>();
        String sql = "SELECT m.*, v.name AS vessel_name FROM maintenance_records m LEFT JOIN vessels v ON m.vessel_id = v.id ORDER BY m.scheduled_date DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                MaintenanceRecord mr = mapRow(rs);
                mr.setVesselName(rs.getString("vessel_name"));
                list.add(mr);
            }
        } catch (SQLException e) {
            return FALLBACK_RECORDS;
        }
        return list;
    }

    private void resolveVesselName(MaintenanceRecord record) {
        if (record == null || record.getVesselId() == null) return;
        try {
            com.boatsafari.member3.dao.BoatDAO boatDao = new com.boatsafari.member3.dao.BoatDAO();
            boatDao.findById(record.getVesselId()).ifPresent(v -> {
                String typeStr = v.getVesselType() != null ? v.getVesselType().getDisplayName() : "";
                record.setVesselName(v.getName() + (!typeStr.isEmpty() ? " (" + typeStr + ")" : ""));
            });
        } catch (Exception ignored) {}
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    @Override
    public java.util.Optional<MaintenanceRecord> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_RECORDS.stream().filter(r -> r.getId() != null && r.getId() == id).findFirst();
        }
        try {
            java.util.Optional<MaintenanceRecord> opt = super.findById(id);
            if (opt.isPresent()) {
                resolveVesselName(opt.get());
                return opt;
            }
            return java.util.Optional.empty();
        } catch (Exception e) {
            return FALLBACK_RECORDS.stream().filter(r -> r.getId() != null && r.getId() == id).findFirst();
        }
    }

    // ==========================================
    // Member 4: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        if (!db.isDatabaseAvailable()) {
            boolean removed = FALLBACK_RECORDS.removeIf(r -> r.getId() != null && r.getId() == id);
            if (removed) {
                com.boatsafari.common.util.LiveFileLogger.logTableUpdate("maintenance_records", "DELETE", id, "Maintenance record #" + id + " deleted (fallback)");
            }
            return removed;
        }
        try {
            boolean ok = super.delete(id);
            if (ok) {
                FALLBACK_RECORDS.removeIf(r -> r.getId() != null && r.getId() == id);
                com.boatsafari.common.util.LiveFileLogger.logTableUpdate("maintenance_records", "DELETE", id, "Maintenance record #" + id + " deleted");
            }
            return ok;
        } catch (Exception e) {
            logger.log(Level.WARNING, "Failed to delete maintenance record in DB: " + e.getMessage());
            return false;
        }
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    public List<MaintenanceRecord> findByVesselId(int vesselId) {
        List<MaintenanceRecord> list = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_records WHERE vessel_id = ? ORDER BY scheduled_date DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, vesselId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            return FALLBACK_RECORDS.stream().filter(r -> r.getVesselId().equals(vesselId)).toList();
        }
        return list;
    }

    public double calculateTotalCost() {
        String sql = "SELECT SUM(cost) FROM maintenance_records WHERE status = 'COMPLETED'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            return FALLBACK_RECORDS.stream()
                    .filter(r -> r.getStatus() == MaintenanceStatus.COMPLETED)
                    .mapToDouble(r -> r.getCost().getAmount().doubleValue())
                    .sum();
        }
        return 0.0;
    }

    // ==========================================
    // Member 4: CREATE
    // ==========================================
    @Override
    public MaintenanceRecord create(MaintenanceRecord entity) {
        resolveVesselName(entity);
        String sql = "INSERT INTO maintenance_records (vessel_id, maintenance_type, description, scheduled_date, completed_date, cost, service_provider, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, entity.getVesselId());
            stmt.setString(2, entity.getMaintenanceType().name());
            stmt.setString(3, entity.getDescription());
            stmt.setDate(4, entity.getScheduledDate());
            stmt.setDate(5, entity.getCompletedDate());
            stmt.setBigDecimal(6, entity.getCost().getAmount());
            stmt.setString(7, entity.getServiceProvider());
            stmt.setString(8, entity.getStatus().name());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_RECORDS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding maintenance record to fallback list.");
            int maxId = FALLBACK_RECORDS.stream().mapToInt(r -> r.getId() != null ? r.getId() : 0).max().orElse(0);
            entity.setId(maxId + 1);
            FALLBACK_RECORDS.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 4: UPDATE
    // ==========================================
    @Override
    public boolean update(MaintenanceRecord entity) {
        resolveVesselName(entity);
        String sql = "UPDATE maintenance_records SET vessel_id = ?, maintenance_type = ?, description = ?, scheduled_date = ?, completed_date = ?, cost = ?, service_provider = ?, status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, entity.getVesselId());
            stmt.setString(2, entity.getMaintenanceType().name());
            stmt.setString(3, entity.getDescription());
            stmt.setDate(4, entity.getScheduledDate());
            stmt.setDate(5, entity.getCompletedDate());
            stmt.setBigDecimal(6, entity.getCost().getAmount());
            stmt.setString(7, entity.getServiceProvider());
            stmt.setString(8, entity.getStatus().name());
            stmt.setInt(9, entity.getId());

            boolean ok = stmt.executeUpdate() > 0;
            for (int i = 0; i < FALLBACK_RECORDS.size(); i++) {
                if (FALLBACK_RECORDS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_RECORDS.set(i, entity);
                    break;
                }
            }
            return ok;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_RECORDS.size(); i++) {
                if (FALLBACK_RECORDS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_RECORDS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }
}
