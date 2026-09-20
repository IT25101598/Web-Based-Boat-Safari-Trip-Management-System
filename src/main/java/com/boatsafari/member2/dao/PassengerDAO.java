package com.boatsafari.member2.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member2.model.Passenger;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 2: Passenger Manifest DAO (Member 2: Reservation & Guest Booking Management).
 */
public class PassengerDAO extends AbstractDAO<Passenger> {
    private static final List<Passenger> FALLBACK_PASSENGERS = new CopyOnWriteArrayList<>();

    static {
        Passenger p1 = new Passenger("David Miller", "GB44908123", 38, "MALE", "British", "+44 7911 123456");
        p1.setId(1);
        p1.setReservationId(1);
        FALLBACK_PASSENGERS.add(p1);

        Passenger p2 = new Passenger("Emma Miller", "GB44908124", 35, "FEMALE", "British", "+44 7911 123456");
        p2.setId(2);
        p2.setReservationId(1);
        FALLBACK_PASSENGERS.add(p2);

        Passenger p3 = new Passenger("Sarah Jenkins", "AU99201481", 29, "FEMALE", "Australian", "+61 412 345 678");
        p3.setId(3);
        p3.setReservationId(2);
        FALLBACK_PASSENGERS.add(p3);

        Passenger p4 = new Passenger("Liam Evans", "AU99201482", 31, "MALE", "Australian", "+61 412 345 678");
        p4.setId(4);
        p4.setReservationId(2);
        FALLBACK_PASSENGERS.add(p4);
    }

    @Override
    protected String getTableName() {
        return "passengers";
    }

    @Override
    protected Passenger mapRow(ResultSet rs) throws SQLException {
        Passenger p = new Passenger();
        p.setId(rs.getInt("id"));
        p.setReservationId(rs.getInt("reservation_id"));
        p.setFullName(rs.getString("full_name"));
        p.setIdOrPassport(rs.getString("id_or_passport"));
        p.setAge(rs.getInt("age"));
        p.setGender(rs.getString("gender"));
        p.setNationality(rs.getString("nationality"));
        p.setEmergencyContact(rs.getString("emergency_contact"));
        return p;
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public List<Passenger> findByReservationId(int reservationId) {
        List<Passenger> list = new ArrayList<>();
        String sql = "SELECT * FROM passengers WHERE reservation_id = ? ORDER BY id ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, reservationId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            return FALLBACK_PASSENGERS.stream().filter(p -> p.getReservationId() != null && p.getReservationId().equals(reservationId)).toList();
        }
        return list;
    }

    // ==========================================
    // Member 2: CREATE
    // ==========================================
    @Override
    public Passenger create(Passenger entity) {
        String sql = "INSERT INTO passengers (reservation_id, full_name, id_or_passport, age, gender, nationality, emergency_contact) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, entity.getReservationId());
            stmt.setString(2, entity.getFullName());
            stmt.setString(3, entity.getIdOrPassport());
            stmt.setInt(4, entity.getAge());
            stmt.setString(5, entity.getGender());
            stmt.setString(6, entity.getNationality());
            stmt.setString(7, entity.getEmergencyContact());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_PASSENGERS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding passenger to fallback list.");
            entity.setId(FALLBACK_PASSENGERS.size() + 1);
            FALLBACK_PASSENGERS.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 2: UPDATE
    // ==========================================
    @Override
    public boolean update(Passenger entity) {
        String sql = "UPDATE passengers SET full_name = ?, id_or_passport = ?, age = ?, gender = ?, nationality = ?, emergency_contact = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getFullName());
            stmt.setString(2, entity.getIdOrPassport());
            stmt.setInt(3, entity.getAge());
            stmt.setString(4, entity.getGender());
            stmt.setString(5, entity.getNationality());
            stmt.setString(6, entity.getEmergencyContact());
            stmt.setInt(7, entity.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_PASSENGERS.size(); i++) {
                if (FALLBACK_PASSENGERS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_PASSENGERS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 2: DELETE
    // ==========================================
    public boolean deleteByReservationId(int reservationId) {
        String sql = "DELETE FROM passengers WHERE reservation_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, reservationId);
            stmt.executeUpdate();
        } catch (SQLException ignored) {}
        FALLBACK_PASSENGERS.removeIf(p -> p.getReservationId() != null && p.getReservationId().equals(reservationId));
        return true;
    }
}
