package com.boatsafari.member1.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member1.model.Tour;
import com.boatsafari.member1.model.TourType;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 1: Safari Tour DAO (Member 1: Safari Tour & Schedule Management).
 */
public class TourDAO extends AbstractDAO<Tour> {
    private static final List<Tour> FALLBACK_TOURS = new CopyOnWriteArrayList<>();

    static {
        Tour t1 = new Tour(1, "Mirissa Blue Whale & Dolphin Luxury Catamaran Safari", TourType.WHALE_WATCHING, 1, 4.5, BigDecimal.valueOf(24500.00), 25);
        t1.setDescription("Sail into the deep southern Indian Ocean aboard our premier 55-foot luxury catamaran. Witness Blue Whales and Spinner Dolphins with fresh gourmet breakfast.");
        t1.setInclusions("Gourmet breakfast, Tropical fruit platter, Ceylon tea, Marine naturalist guide, Binoculars, Life jackets");
        t1.setImageUrl("assets/img/tours/mirissa-whale.jpg");
        FALLBACK_TOURS.add(t1);

        Tour t2 = new Tour(2, "Galle Fort Heritage & Sunset Champagne Sail", TourType.SUNSET_SAIL, 2, 3.0, BigDecimal.valueOf(18500.00), 20);
        t2.setDescription("Glaze across the historic Galle coastline as the sun dips into the crimson ocean. Enjoy chilled beverages and canapés.");
        t2.setInclusions("Welcome mocktail, Artisanal canapés, Chilled wine/beer, Snorkeling gear, Stand-up paddleboards");
        t2.setImageUrl("assets/img/tours/galle-sunset.jpg");
        FALLBACK_TOURS.add(t2);

        Tour t3 = new Tour(3, "Trincomalee Pigeon Island Reef Snorkeling Safari", TourType.SNORKELING_SAFARI, 3, 5.0, BigDecimal.valueOf(29000.00), 22);
        t3.setDescription("Discover vibrant marine biodiversity of Sri Lanka's east coast. Snorkel with sea turtles and blacktip reef sharks.");
        t3.setInclusions("Seafood BBQ lunch, Fresh coconut water, Snorkeling masks & fins, Marine park permit, Guide");
        t3.setImageUrl("assets/img/tours/trinco-snorkeling.jpg");
        FALLBACK_TOURS.add(t3);

        Tour t4 = new Tour(4, "Private Starlight Dine-at-Sea Yacht Experience", TourType.DINE_AT_SEA, 2, 4.0, BigDecimal.valueOf(65000.00), 10);
        t4.setDescription("An exclusive culinary voyage anchored under the stars in a calm secluded bay with a private chef.");
        t4.setInclusions("Private 4-course seafood dinner, Wine pairing, Dedicated captain and steward");
        t4.setImageUrl("assets/img/tours/dine-at-sea.jpg");
        FALLBACK_TOURS.add(t4);
    }

    @Override
    protected String getTableName() {
        return "tours";
    }

    @Override
    protected Tour mapRow(ResultSet rs) throws SQLException {
        Tour t = new Tour();
        t.setId(rs.getInt("id"));
        t.setTitle(rs.getString("title"));
        try {
            t.setTourType(TourType.valueOf(rs.getString("tour_type")));
        } catch (Exception e) {
            t.setTourType(TourType.WHALE_WATCHING);
        }
        t.setRouteId(rs.getInt("route_id"));
        t.setDescription(rs.getString("description"));
        t.setDurationHours(rs.getDouble("duration_hours"));
        t.setBasePriceAmount(rs.getBigDecimal("base_price"));
        t.setMaxPassengers(rs.getInt("max_passengers"));
        t.setInclusions(rs.getString("inclusions"));
        t.setExclusions(rs.getString("exclusions"));
        t.setImageUrl(rs.getString("image_url"));
        t.setActive(rs.getBoolean("is_active"));
        try {
            t.setSpecialInstructions(rs.getString("special_instructions"));
        } catch (SQLException ignored) {}
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    @Override
    public Optional<Tour> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_TOURS.stream().filter(t -> t.getId() != null && t.getId() == id).findFirst();
        }
        try {
            return super.findById(id);
        } catch (Exception e) {
            return FALLBACK_TOURS.stream().filter(t -> t.getId() != null && t.getId() == id).findFirst();
        }
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    @Override
    public List<Tour> findAll() {
        if (!db.isDatabaseAvailable()) {
            return new ArrayList<>(FALLBACK_TOURS);
        }
        try {
            List<Tour> list = super.findAll();
            return (list != null) ? list : new ArrayList<>(FALLBACK_TOURS);
        } catch (Exception e) {
            return new ArrayList<>(FALLBACK_TOURS);
        }
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<Tour> findActive() {
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT * FROM tours WHERE is_active = 1 ORDER BY id ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            return FALLBACK_TOURS.stream().filter(Tour::isActive).toList();
        }
        return list;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<Tour> findByType(TourType type) {
        List<Tour> list = new ArrayList<>();
        String sql = "SELECT * FROM tours WHERE tour_type = ? AND is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, type.name());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            return FALLBACK_TOURS.stream().filter(t -> t.getTourType() == type && t.isActive()).toList();
        }
        return list;
    }

    // ==========================================
    // Member 1: CREATE
    // ==========================================
    @Override
    public Tour create(Tour entity) {
        String sql = "INSERT INTO tours (title, tour_type, route_id, description, duration_hours, base_price, max_passengers, inclusions, exclusions, image_url, is_active, special_instructions) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getTitle());
            stmt.setString(2, entity.getTourType().name());
            stmt.setInt(3, entity.getRouteId());
            stmt.setString(4, entity.getDescription());
            stmt.setDouble(5, entity.getDurationHours());
            stmt.setBigDecimal(6, entity.getBasePrice().getAmount());
            stmt.setInt(7, entity.getMaxPassengers());
            stmt.setString(8, entity.getInclusions());
            stmt.setString(9, entity.getExclusions());
            stmt.setString(10, entity.getImageUrl());
            stmt.setBoolean(11, entity.isActive());
            stmt.setString(12, entity.getSpecialInstructions());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_TOURS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding tour to fallback list.");
            entity.setId(FALLBACK_TOURS.size() + 1);
            FALLBACK_TOURS.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 1: UPDATE
    // ==========================================
    @Override
    public boolean update(Tour entity) {
        String sql = "UPDATE tours SET title = ?, tour_type = ?, route_id = ?, description = ?, duration_hours = ?, base_price = ?, max_passengers = ?, inclusions = ?, exclusions = ?, image_url = ?, is_active = ?, special_instructions = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getTitle());
            stmt.setString(2, entity.getTourType().name());
            stmt.setInt(3, entity.getRouteId());
            stmt.setString(4, entity.getDescription());
            stmt.setDouble(5, entity.getDurationHours());
            stmt.setBigDecimal(6, entity.getBasePrice().getAmount());
            stmt.setInt(7, entity.getMaxPassengers());
            stmt.setString(8, entity.getInclusions());
            stmt.setString(9, entity.getExclusions());
            stmt.setString(10, entity.getImageUrl());
            stmt.setBoolean(11, entity.isActive());
            stmt.setString(12, entity.getSpecialInstructions());
            stmt.setInt(13, entity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_TOURS.size(); i++) {
                if (FALLBACK_TOURS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_TOURS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 1: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        boolean removed = FALLBACK_TOURS.removeIf(t -> t.getId() != null && t.getId() == id);
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Clear emergency notices referencing this tour
                try (PreparedStatement s1 = conn.prepareStatement("UPDATE emergency_notices SET affected_tour_id = NULL WHERE affected_tour_id = ?")) {
                    s1.setInt(1, id);
                    s1.executeUpdate();
                }
                // 2. Clear promo redemptions for reservations of schedules for this tour
                String delPromoRedemptionsSql = "DELETE FROM promo_redemptions WHERE reservation_id IN " +
                        "(SELECT id FROM reservations WHERE schedule_id IN (SELECT id FROM tour_schedules WHERE tour_id = ?))";
                try (PreparedStatement sPromo = conn.prepareStatement(delPromoRedemptionsSql)) {
                    sPromo.setInt(1, id);
                    sPromo.executeUpdate();
                }
                // 3. Delete reservation passengers of schedules for this tour
                String delPassengersSql = "DELETE FROM passengers WHERE reservation_id IN " +
                        "(SELECT id FROM reservations WHERE schedule_id IN (SELECT id FROM tour_schedules WHERE tour_id = ?))";
                try (PreparedStatement s2 = conn.prepareStatement(delPassengersSql)) {
                    s2.setInt(1, id);
                    s2.executeUpdate();
                }
                // 4. Delete reservations of schedules for this tour
                String delResSql = "DELETE FROM reservations WHERE schedule_id IN (SELECT id FROM tour_schedules WHERE tour_id = ?)";
                try (PreparedStatement s3 = conn.prepareStatement(delResSql)) {
                    s3.setInt(1, id);
                    s3.executeUpdate();
                }
                // 4. Delete safety check logs of schedules for this tour
                String delSafetySql = "DELETE FROM safety_check_logs WHERE schedule_id IN (SELECT id FROM tour_schedules WHERE tour_id = ?)";
                try (PreparedStatement s4 = conn.prepareStatement(delSafetySql)) {
                    s4.setInt(1, id);
                    s4.executeUpdate();
                }
                // 5. Delete tour schedules
                try (PreparedStatement s5 = conn.prepareStatement("DELETE FROM tour_schedules WHERE tour_id = ?")) {
                    s5.setInt(1, id);
                    s5.executeUpdate();
                }
                // 6. Delete the tour itself
                boolean ok;
                try (PreparedStatement s6 = conn.prepareStatement("DELETE FROM tours WHERE id = ?")) {
                    s6.setInt(1, id);
                    ok = s6.executeUpdate() > 0;
                }
                conn.commit();

                if (ok) {
                    com.boatsafari.common.util.LiveFileLogger.logTableUpdate("tours", "DELETE", id, "Tour #" + id + " deleted with dependent schedules");
                    com.boatsafari.common.util.LiveFileLogger.logTableUpdate("tour_schedules", "CASCADE_DELETE", id, "Schedules removed for tour #" + id);
                }
                return ok;
            } catch (SQLException ex) {
                conn.rollback();
                logger.log(Level.WARNING, "Failed to delete tour in DB: " + ex.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.log(Level.FINE, "DB unavailable during tour delete, fallback: " + e.getMessage());
            return removed;
        }
    }
}
