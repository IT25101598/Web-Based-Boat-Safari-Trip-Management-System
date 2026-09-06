package com.boatsafari.common.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.common.model.LoginDetail;
import com.boatsafari.common.util.LiveTableManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;

/**
 * DAO for the `login_details` table.
 * Records authentication attempts, successful logins, and registration events with live file sync.
 */
public class LoginDetailsDAO extends AbstractDAO<LoginDetail> {
    private static final List<LoginDetail> FALLBACK_LOGINS = new CopyOnWriteArrayList<>();
    private static final AtomicInteger ID_GEN = new AtomicInteger(100);

    public LoginDetailsDAO() {
        super();
    }

    @Override
    protected String getTableName() {
        return "login_details";
    }

    public LoginDetail recordLogin(Integer userId, String fullName, String email, String role, String ipAddress, String status, String details) {
        LoginDetail log = new LoginDetail(userId, fullName, email, role, ipAddress, status, details);
        return create(log);
    }

    @Override
    public Optional<LoginDetail> findById(int id) {
        String sql = "SELECT * FROM login_details WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.FINE, "Error finding login detail #" + id + ", checking fallback: " + e.getMessage());
        }
        return FALLBACK_LOGINS.stream().filter(l -> l.getId() != null && l.getId() == id).findFirst();
    }

    @Override
    public List<LoginDetail> findAll() {
        List<LoginDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM login_details ORDER BY id DESC";
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException e) {
            logger.log(Level.FINE, "Falling back to in-memory login details: " + e.getMessage());
            return new ArrayList<>(FALLBACK_LOGINS);
        }
    }

    @Override
    public LoginDetail create(LoginDetail entity) {
        String sql = "INSERT INTO login_details (user_id, full_name, email, role, ip_address, status, login_time, user_agent, details) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (entity.getUserId() != null && entity.getUserId() > 0) {
                stmt.setInt(1, entity.getUserId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }
            stmt.setString(2, entity.getFullName());
            stmt.setString(3, entity.getEmail());
            stmt.setString(4, entity.getRole());
            stmt.setString(5, entity.getIpAddress());
            stmt.setString(6, entity.getStatus());
            stmt.setTimestamp(7, entity.getLoginTime() != null ? entity.getLoginTime() : new Timestamp(System.currentTimeMillis()));
            stmt.setString(8, entity.getUserAgent());
            stmt.setString(9, entity.getDetails());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        entity.setId(rs.getInt(1));
                    }
                }
            }
            FALLBACK_LOGINS.add(0, entity);
            LiveTableManager.onTableModified("login_details", "INSERT", entity.getId(), "User '" + entity.getFullName() + "' (" + entity.getEmail() + ") - Status: " + entity.getStatus());
            LiveTableManager.refreshCustomerDetails();
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Failed to insert into login_details in MySQL, saving to memory fallback: " + e.getMessage());
            if (entity.getId() == null) {
                entity.setId(ID_GEN.incrementAndGet());
            }
            FALLBACK_LOGINS.add(0, entity);
            LiveTableManager.onTableModified("login_details", "INSERT", entity.getId(), "User '" + entity.getFullName() + "' (" + entity.getEmail() + ") - Status: " + entity.getStatus());
            LiveTableManager.refreshCustomerDetails();
            return entity;
        }
    }

    @Override
    public boolean update(LoginDetail entity) {
        return false; // Authentication logs are append-only by design
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM login_details WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            boolean ok = stmt.executeUpdate() > 0;
            FALLBACK_LOGINS.removeIf(l -> l.getId() != null && l.getId() == id);
            LiveTableManager.onTableModified("login_details", "DELETE", id, "Login record #" + id + " deleted");
            return ok;
        } catch (SQLException e) {
            FALLBACK_LOGINS.removeIf(l -> l.getId() != null && l.getId() == id);
            LiveTableManager.onTableModified("login_details", "DELETE", id, "Login record #" + id + " deleted");
            return true;
        }
    }

    @Override
    protected LoginDetail mapRow(ResultSet rs) throws SQLException {
        LoginDetail log = new LoginDetail();
        log.setId(rs.getInt("id"));
        int uid = rs.getInt("user_id");
        if (!rs.wasNull()) {
            log.setUserId(uid);
        }
        log.setFullName(rs.getString("full_name"));
        log.setEmail(rs.getString("email"));
        log.setRole(rs.getString("role"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setStatus(rs.getString("status"));
        log.setLoginTime(rs.getTimestamp("login_time"));
        log.setUserAgent(rs.getString("user_agent"));
        log.setDetails(rs.getString("details"));
        return log;
    }
}
