package com.boatsafari.common.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.common.model.ActivityLog;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Data Access Object for audit trail activity logs.
 */
public class ActivityLogDAO extends AbstractDAO<ActivityLog> {
    private static final List<ActivityLog> FALLBACK_LOGS = new CopyOnWriteArrayList<>();

    @Override
    protected String getTableName() {
        return "activity_logs";
    }

    @Override
    protected ActivityLog mapRow(ResultSet rs) throws SQLException {
        ActivityLog log = new ActivityLog();
        log.setId(rs.getInt("id"));
        log.setUserId(rs.getInt("user_id"));
        log.setAction(rs.getString("action"));
        log.setModule(rs.getString("module"));
        log.setDetails(rs.getString("details"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setCreatedAt(rs.getTimestamp("created_at"));
        return log;
    }

    @Override
    public ActivityLog create(ActivityLog entity) {
        String sql = "INSERT INTO activity_logs (user_id, action, module, details, ip_address) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (entity.getUserId() != null) {
                stmt.setInt(1, entity.getUserId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setString(2, entity.getAction());
            stmt.setString(3, entity.getModule());
            stmt.setString(4, entity.getDetails());
            stmt.setString(5, entity.getIpAddress());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        entity.setId(rs.getInt(1));
                    }
                }
            }
            FALLBACK_LOGS.add(entity);
            com.boatsafari.common.util.LiveFileLogger.logTableUpdate("activity_logs", "INSERT", entity.getId(), "Action=" + entity.getAction() + " | Module=" + entity.getModule() + " | Details=" + entity.getDetails() + " | IP=" + entity.getIpAddress());
            return entity;
        } catch (SQLException e) {
            logger.log(Level.FINE, "Logged activity to memory store: " + entity.getSummary());
            FALLBACK_LOGS.add(entity);
            com.boatsafari.common.util.LiveFileLogger.logTableUpdate("activity_logs", "INSERT", entity.getId(), "Action=" + entity.getAction() + " | Module=" + entity.getModule() + " | Details=" + entity.getDetails() + " | IP=" + entity.getIpAddress());
            return entity;
        }
    }

    @Override
    public boolean update(ActivityLog entity) {
        // Logs are append-only; update not supported by design
        return false;
    }

    public List<ActivityLog> findRecent(int limit) {
        List<ActivityLog> list = new ArrayList<>();
        String sql = "SELECT * FROM activity_logs ORDER BY id DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = getConnection()) {
            String dbProduct = "";
            try {
                dbProduct = conn.getMetaData().getDatabaseProductName();
            } catch (SQLException ignored) {}
            if (dbProduct != null && dbProduct.toLowerCase().contains("mysql")) {
                sql = "SELECT * FROM activity_logs ORDER BY id DESC LIMIT ?";
            }
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, limit);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRow(rs));
                    }
                }
            }
        } catch (SQLException e) {
            int size = FALLBACK_LOGS.size();
            int from = Math.max(0, size - limit);
            return new ArrayList<>(FALLBACK_LOGS.subList(from, size));
        }
        return list;
    }
}
