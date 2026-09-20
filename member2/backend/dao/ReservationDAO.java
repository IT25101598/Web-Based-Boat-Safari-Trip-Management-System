package com.boatsafari.member2.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member2.model.Reservation;
import com.boatsafari.member2.model.ReservationStatus;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 2: Reservation DAO (Member 2: Reservation & Guest Booking Management).
 */
public class ReservationDAO extends AbstractDAO<Reservation> {
    private static final List<Reservation> FALLBACK_RESERVATIONS = new CopyOnWriteArrayList<>();

    static {
        Reservation r1 = new Reservation(1, "SLC-2026-0901", 1, 10, 2, BigDecimal.valueOf(49000.00), BigDecimal.valueOf(7350.00), BigDecimal.valueOf(41650.00));
        r1.setTourTitle("Mirissa Blue Whale & Dolphin Luxury Catamaran Safari");
        r1.setCustomerName("David Miller");
        r1.setCustomerEmail("david.miller@gmail.com");
        r1.setPromoCode("SAIL15");
        r1.setStatus(ReservationStatus.CONFIRMED);
        r1.setSpecialNotes("Vegetarian breakfast requested for 1 guest");
        FALLBACK_RESERVATIONS.add(r1);

        Reservation r2 = new Reservation(2, "SLC-2026-0902", 3, 11, 2, BigDecimal.valueOf(37000.00), BigDecimal.valueOf(3500.00), BigDecimal.valueOf(33500.00));
        r2.setTourTitle("Galle Fort Heritage & Sunset Champagne Sail");
        r2.setCustomerName("Sarah Jenkins");
        r2.setCustomerEmail("sarah.j@outlook.com");
        r2.setPromoCode("EARLYBIRD");
        r2.setStatus(ReservationStatus.CONFIRMED);
        r2.setSpecialNotes("Celebrating anniversary; requested special dessert");
        FALLBACK_RESERVATIONS.add(r2);
    }

    @Override
    protected String getTableName() {
        return "reservations";
    }

    @Override
    protected Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getInt("id"));
        r.setBookingRef(rs.getString("booking_ref"));
        r.setScheduleId(rs.getInt("schedule_id"));
        r.setCustomerId(rs.getInt("customer_id"));
        r.setPassengerCount(rs.getInt("passenger_count"));
        r.setTotalAmountValue(rs.getBigDecimal("total_amount"));
        r.setDiscountAmountValue(rs.getBigDecimal("discount_amount"));
        r.setFinalAmountValue(rs.getBigDecimal("final_amount"));
        int pId = rs.getInt("promo_id");
        r.setPromoId(rs.wasNull() ? null : pId);
        try {
            r.setStatus(ReservationStatus.valueOf(rs.getString("status")));
        } catch (Exception e) {
            r.setStatus(ReservationStatus.CONFIRMED);
        }
        r.setSpecialNotes(rs.getString("special_notes"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    @Override
    public List<Reservation> findAll() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS customer_name, u.email AS customer_email, u.phone AS customer_phone, t.title AS tour_title, p.promo_code " +
                     "FROM reservations r " +
                     "LEFT JOIN users u ON r.customer_id = u.id " +
                     "LEFT JOIN tour_schedules s ON r.schedule_id = s.id " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "LEFT JOIN promotions p ON r.promo_id = p.id " +
                     "ORDER BY r.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Reservation res = mapRow(rs);
                res.setCustomerName(rs.getString("customer_name"));
                res.setCustomerEmail(rs.getString("customer_email"));
                res.setCustomerPhone(rs.getString("customer_phone"));
                res.setTourTitle(rs.getString("tour_title"));
                res.setPromoCode(rs.getString("promo_code"));
                list.add(res);
            }
        } catch (SQLException e) {
            return FALLBACK_RESERVATIONS;
        }
        return list;
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public List<Reservation> findByCustomerId(int customerId) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, t.title AS tour_title FROM reservations r " +
                     "LEFT JOIN tour_schedules s ON r.schedule_id = s.id " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "WHERE r.customer_id = ? ORDER BY r.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Reservation r = mapRow(rs);
                    r.setTourTitle(rs.getString("tour_title"));
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            return FALLBACK_RESERVATIONS.stream().filter(r -> r.getCustomerId().equals(customerId)).toList();
        }
        return list;
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    @Override
    public Optional<Reservation> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_RESERVATIONS.stream().filter(r -> r.getId() != null && r.getId() == id).findFirst();
        }
        String sql = "SELECT r.*, u.full_name AS customer_name, u.email AS customer_email, u.phone AS customer_phone, t.title AS tour_title, p.promo_code " +
                     "FROM reservations r " +
                     "LEFT JOIN users u ON r.customer_id = u.id " +
                     "LEFT JOIN tour_schedules s ON r.schedule_id = s.id " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "LEFT JOIN promotions p ON r.promo_id = p.id " +
                     "WHERE r.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Reservation res = mapRow(rs);
                    res.setCustomerName(rs.getString("customer_name"));
                    res.setCustomerEmail(rs.getString("customer_email"));
                    res.setCustomerPhone(rs.getString("customer_phone"));
                    res.setTourTitle(rs.getString("tour_title"));
                    res.setPromoCode(rs.getString("promo_code"));
                    return Optional.of(res);
                }
            }
        } catch (SQLException e) {
            return FALLBACK_RESERVATIONS.stream().filter(r -> r.getId() != null && r.getId() == id).findFirst();
        }
        return Optional.empty();
    }

    // ==========================================
    // Member 2: READ
    // ==========================================
    public Optional<Reservation> findByBookingRef(String ref) {
        if (ref == null) return Optional.empty();
        String sql = "SELECT r.*, u.full_name AS customer_name, u.email AS customer_email, u.phone AS customer_phone, t.title AS tour_title, p.promo_code " +
                     "FROM reservations r " +
                     "LEFT JOIN users u ON r.customer_id = u.id " +
                     "LEFT JOIN tour_schedules s ON r.schedule_id = s.id " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "LEFT JOIN promotions p ON r.promo_id = p.id " +
                     "WHERE UPPER(r.booking_ref) = UPPER(?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ref.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Reservation res = mapRow(rs);
                    res.setCustomerName(rs.getString("customer_name"));
                    res.setCustomerEmail(rs.getString("customer_email"));
                    res.setCustomerPhone(rs.getString("customer_phone"));
                    res.setTourTitle(rs.getString("tour_title"));
                    res.setPromoCode(rs.getString("promo_code"));
                    return Optional.of(res);
                }
            }
        } catch (SQLException e) {
            return FALLBACK_RESERVATIONS.stream().filter(r -> r.getBookingRef().equalsIgnoreCase(ref.trim())).findFirst();
        }
        return Optional.empty();
    }

    // ==========================================
    // Member 2: UPDATE (Status)
    // ==========================================
    public boolean updateStatus(int reservationId, ReservationStatus newStatus) {
        String sql = "UPDATE reservations SET status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus.name());
            stmt.setInt(2, reservationId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (Reservation r : FALLBACK_RESERVATIONS) {
                if (r.getId().equals(reservationId)) {
                    r.setStatus(newStatus);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 2: CREATE
    // ==========================================
    @Override
    public Reservation create(Reservation entity) {
        String sql = "INSERT INTO reservations (booking_ref, schedule_id, customer_id, passenger_count, total_amount, discount_amount, final_amount, promo_id, status, special_notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getBookingRef());
            stmt.setInt(2, entity.getScheduleId());
            stmt.setInt(3, entity.getCustomerId());
            stmt.setInt(4, entity.getPassengerCount());
            stmt.setBigDecimal(5, entity.getTotalAmount().getAmount());
            stmt.setBigDecimal(6, entity.getDiscountAmount().getAmount());
            stmt.setBigDecimal(7, entity.getFinalAmount().getAmount());
            if (entity.getPromoId() != null && entity.getPromoId() > 0) stmt.setInt(8, entity.getPromoId()); else stmt.setNull(8, Types.INTEGER);
            stmt.setString(9, entity.getStatus().name());
            stmt.setString(10, entity.getSpecialNotes());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_RESERVATIONS.add(0, entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding reservation to fallback list.");
            entity.setId(FALLBACK_RESERVATIONS.size() + 1);
            FALLBACK_RESERVATIONS.add(0, entity);
            return entity;
        }
    }

    // ==========================================
    // Member 2: UPDATE
    // ==========================================
    @Override
    public boolean update(Reservation entity) {
        String sql = "UPDATE reservations SET schedule_id = ?, passenger_count = ?, total_amount = ?, discount_amount = ?, final_amount = ?, status = ?, special_notes = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, entity.getScheduleId());
            stmt.setInt(2, entity.getPassengerCount());
            stmt.setBigDecimal(3, entity.getTotalAmount().getAmount());
            stmt.setBigDecimal(4, entity.getDiscountAmount().getAmount());
            stmt.setBigDecimal(5, entity.getFinalAmount().getAmount());
            stmt.setString(6, entity.getStatus().name());
            stmt.setString(7, entity.getSpecialNotes());
            stmt.setInt(8, entity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_RESERVATIONS.size(); i++) {
                if (FALLBACK_RESERVATIONS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_RESERVATIONS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 2: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        FALLBACK_RESERVATIONS.removeIf(r -> r.getId() != null && r.getId() == id);
        if (!db.isDatabaseAvailable()) {
            return true;
        }
        return super.delete(id);
    }
}
