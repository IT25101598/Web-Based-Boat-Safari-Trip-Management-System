package com.boatsafari.common.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.common.model.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Level;

/**
 * Data Access Object for User Management.
 * Extends AbstractDAO demonstrating Template Method pattern and Polymorphic instantiation.
 */
public class UserDAO extends AbstractDAO<User> {
    private static final AtomicInteger ID_GEN = new AtomicInteger(100);
    private static final List<User> FALLBACK_USERS = new CopyOnWriteArrayList<>();

    static {
        // Fallback seed accounts in case MySQL service is unpopulated
        User admin = new Admin(1, "System Administrator", "admin@sail-safari.lk", "+94 77 123 4567");
        admin.setPassword("admin123");
        FALLBACK_USERS.add(admin);

        User officer = new Staff(2, "Chief Reservation Officer", "officer@sail-safari.lk", "+94 77 234 5678", UserRole.OFFICER, "EMP-OFF-01");
        officer.setPassword("admin123");
        FALLBACK_USERS.add(officer);

        User tourMgr = new Staff(3, "Safari Tour Operations Manager", "tourmanager@sail-safari.lk", "+94 77 345 6789", UserRole.ADMIN, "EMP-MGR-01");
        tourMgr.setPassword("admin123");
        FALLBACK_USERS.add(tourMgr);

        User captain = new Staff(4, "Capt. Shantha Perera", "captain.perera@sail-safari.lk", "+94 77 456 7890", UserRole.CAPTAIN, "EMP-CPT-01");
        captain.setPassword("admin123");
        FALLBACK_USERS.add(captain);

        User guide = new Staff(6, "Kasun Fernando (Guide)", "guide.kasun@sail-safari.lk", "+94 77 678 9012", UserRole.GUIDE, "EMP-GDE-01");
        guide.setPassword("admin123");
        FALLBACK_USERS.add(guide);

        User owner = new Staff(8, "Luxury Fleet Owner", "owner@sail-safari.lk", "+94 77 890 1234", UserRole.OWNER, "EMP-OWN-01");
        owner.setPassword("admin123");
        FALLBACK_USERS.add(owner);

        User cust = new Customer(10, "David Miller", "david.miller@gmail.com", "+44 7911 123456", "United Kingdom");
        cust.setPassword("password123");
        FALLBACK_USERS.add(cust);

        User tourist = new Customer(12, "Tourist Guest", "tourist@sail-safari.lk", "+94 71 234 5678", "Sri Lanka");
        tourist.setPassword("password123");
        FALLBACK_USERS.add(tourist);
    }

    @Override
    protected String getTableName() {
        return "users";
    }

    @Override
    protected User mapRow(ResultSet rs) throws SQLException {
        String roleStr = rs.getString("role");
        UserRole role;
        try {
            role = UserRole.valueOf(roleStr);
        } catch (Exception e) {
            role = UserRole.CUSTOMER;
        }

        User user;
        switch (role) {
            case ADMIN:
                user = new Admin();
                break;
            case CUSTOMER:
                user = new Customer();
                break;
            default:
                user = new Staff();
                break;
        }

        user.setId(rs.getInt("id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setPhone(rs.getString("phone"));
        user.setRole(role);
        user.setStatus(rs.getString("status"));
        user.setProfileImage(rs.getString("profile_image"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));

        return user;
    }

    public Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        String sql = "SELECT * FROM users WHERE LOWER(email) = LOWER(?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, checking fallback users for email: " + email);
            return FALLBACK_USERS.stream()
                    .filter(u -> u.getEmail().equalsIgnoreCase(email.trim()))
                    .findFirst();
        }
        return Optional.empty();
    }

    public Optional<User> authenticate(String email, String plainPassword) {
        Optional<User> userOpt = findByEmail(email);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.checkPassword(plainPassword) && user.isActive()) {
                return Optional.of(user);
            }
        }
        return Optional.empty();
    }

    @Override
    public User create(User entity) {
        String sql = "INSERT INTO users (full_name, email, password_hash, phone, role, status, profile_image) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getFullName());
            stmt.setString(2, entity.getEmail());
            stmt.setString(3, entity.getPasswordHash());
            stmt.setString(4, entity.getPhone());
            stmt.setString(5, entity.getRole().name());
            stmt.setString(6, entity.getStatus());
            stmt.setString(7, entity.getProfileImage());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        entity.setId(rs.getInt(1));
                    }
                }
            }
            FALLBACK_USERS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database insert failed. Saving to fallback memory store.", e);
            entity.setId(ID_GEN.incrementAndGet());
            FALLBACK_USERS.add(entity);
            return entity;
        }
    }

    @Override
    public boolean update(User entity) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, role = ?, status = ?, profile_image = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getFullName());
            stmt.setString(2, entity.getPhone());
            stmt.setString(3, entity.getRole().name());
            stmt.setString(4, entity.getStatus());
            stmt.setString(5, entity.getProfileImage());
            stmt.setInt(6, entity.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database update failed. Updating in fallback store.");
            for (int i = 0; i < FALLBACK_USERS.size(); i++) {
                if (FALLBACK_USERS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_USERS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    @Override
    public Optional<User> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_USERS.stream().filter(u -> u.getId() != null && u.getId() == id).findFirst();
        }
        try {
            Optional<User> opt = super.findById(id);
            if (opt.isPresent()) return opt;
        } catch (Exception ignored) {}
        return FALLBACK_USERS.stream().filter(u -> u.getId() != null && u.getId() == id).findFirst();
    }

    @Override
    public List<User> findAll() {
        if (!db.isDatabaseAvailable()) {
            return new ArrayList<>(FALLBACK_USERS);
        }
        try {
            List<User> list = super.findAll();
            return (list != null && !list.isEmpty()) ? list : new ArrayList<>(FALLBACK_USERS);
        } catch (Exception e) {
            return new ArrayList<>(FALLBACK_USERS);
        }
    }

    public List<User> findAllStaff() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role != 'CUSTOMER' AND status = 'ACTIVE'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            return FALLBACK_USERS.stream().filter(User::isActive).filter(u -> u.getRole().isStaff()).toList();
        }
        return list;
    }

    public List<User> findByRole(UserRole role) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = ? AND status = 'ACTIVE'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role.name());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            return FALLBACK_USERS.stream().filter(u -> u.getRole() == role && u.isActive()).toList();
        }
        return list;
    }
}
