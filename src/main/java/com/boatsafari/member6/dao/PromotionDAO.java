package com.boatsafari.member6.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member6.model.DiscountType;
import com.boatsafari.member6.model.Promotion;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 6: Promotion Strategy DAO (Member 6: Promotion & Discount Strategy Management).
 */
public class PromotionDAO extends AbstractDAO<Promotion> {
    private static final List<Promotion> FALLBACK_PROMOTIONS = new CopyOnWriteArrayList<>();

    static {
        Promotion p1 = new Promotion(1, "Sail Lanka Welcome Privilege", "SAIL15", DiscountType.PERCENTAGE, BigDecimal.valueOf(15.00), BigDecimal.valueOf(15000.00), BigDecimal.valueOf(10000.00));
        p1.setTimesRedeemed(2);
        FALLBACK_PROMOTIONS.add(p1);

        Promotion p2 = new Promotion(2, "Early Bird Safari Special", "EARLYBIRD", DiscountType.FIXED_AMOUNT, BigDecimal.valueOf(3500.00), BigDecimal.valueOf(20000.00), BigDecimal.valueOf(3500.00));
        p2.setTimesRedeemed(1);
        FALLBACK_PROMOTIONS.add(p2);

        Promotion p3 = new Promotion(3, "Monsoon Coastal Voyage Deal", "MONSOON20", DiscountType.PERCENTAGE, BigDecimal.valueOf(20.00), BigDecimal.valueOf(25000.00), BigDecimal.valueOf(15000.00));
        FALLBACK_PROMOTIONS.add(p3);

        Promotion p4 = new Promotion(4, "Luxury Yacht VIP Offer", "LUXYACHT", DiscountType.FIXED_AMOUNT, BigDecimal.valueOf(8000.00), BigDecimal.valueOf(50000.00), BigDecimal.valueOf(8000.00));
        FALLBACK_PROMOTIONS.add(p4);
    }

    @Override
    protected String getTableName() {
        return "promotions";
    }

    @Override
    protected Promotion mapRow(ResultSet rs) throws SQLException {
        Promotion p = new Promotion();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setPromoCode(rs.getString("promo_code"));
        try {
            p.setDiscountType(DiscountType.valueOf(rs.getString("discount_type")));
        } catch (Exception e) {
            p.setDiscountType(DiscountType.PERCENTAGE);
        }
        p.setDiscountValue(rs.getBigDecimal("discount_value"));
        p.setMinSpend(rs.getBigDecimal("min_spend"));
        p.setMaxDiscount(rs.getBigDecimal("max_discount"));
        p.setMaxRedemptions(rs.getInt("max_redemptions"));
        p.setTimesRedeemed(rs.getInt("times_redeemed"));
        p.setStartDate(rs.getDate("start_date"));
        p.setEndDate(rs.getDate("end_date"));
        p.setActive(rs.getBoolean("is_active"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    @Override
    public Optional<Promotion> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_PROMOTIONS.stream().filter(p -> p.getId() != null && p.getId() == id).findFirst();
        }
        try {
            return super.findById(id);
        } catch (Exception e) {
            return FALLBACK_PROMOTIONS.stream().filter(p -> p.getId() != null && p.getId() == id).findFirst();
        }
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    @Override
    public List<Promotion> findAll() {
        if (!db.isDatabaseAvailable()) {
            return new ArrayList<>(FALLBACK_PROMOTIONS);
        }
        try {
            List<Promotion> list = super.findAll();
            return (list != null) ? list : new ArrayList<>(FALLBACK_PROMOTIONS);
        } catch (Exception e) {
            return new ArrayList<>(FALLBACK_PROMOTIONS);
        }
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    public Optional<Promotion> findByCode(String promoCode) {
        if (promoCode == null || promoCode.isBlank()) return Optional.empty();
        String sql = "SELECT * FROM promotions WHERE UPPER(promo_code) = UPPER(?) AND is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, promoCode.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            return FALLBACK_PROMOTIONS.stream()
                    .filter(p -> p.getPromoCode().equalsIgnoreCase(promoCode.trim()) && p.isActive())
                    .findFirst();
        }
        return Optional.empty();
    }

    // ==========================================
    // Member 6: UPDATE
    // ==========================================
    public boolean incrementUsage(int promoId) {
        String sql = "UPDATE promotions SET times_redeemed = times_redeemed + 1 WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, promoId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (Promotion p : FALLBACK_PROMOTIONS) {
                if (p.getId().equals(promoId)) {
                    p.incrementRedemption();
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 6: CREATE
    // ==========================================
    @Override
    public Promotion create(Promotion entity) {
        String sql = "INSERT INTO promotions (name, promo_code, discount_type, discount_value, min_spend, max_discount, max_redemptions, times_redeemed, start_date, end_date, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getName());
            stmt.setString(2, entity.getPromoCode());
            stmt.setString(3, entity.getDiscountType().name());
            stmt.setBigDecimal(4, entity.getDiscountValue());
            stmt.setBigDecimal(5, entity.getMinSpend());
            stmt.setBigDecimal(6, entity.getMaxDiscount());
            stmt.setInt(7, entity.getMaxRedemptions());
            stmt.setInt(8, entity.getTimesRedeemed());
            stmt.setDate(9, entity.getStartDate());
            stmt.setDate(10, entity.getEndDate());
            stmt.setBoolean(11, entity.isActive());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_PROMOTIONS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding promotion to fallback list.");
            entity.setId(FALLBACK_PROMOTIONS.size() + 1);
            FALLBACK_PROMOTIONS.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 6: UPDATE
    // ==========================================
    @Override
    public boolean update(Promotion entity) {
        String sql = "UPDATE promotions SET name = ?, promo_code = ?, discount_type = ?, discount_value = ?, min_spend = ?, max_discount = ?, max_redemptions = ?, start_date = ?, end_date = ?, is_active = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getName());
            stmt.setString(2, entity.getPromoCode());
            stmt.setString(3, entity.getDiscountType().name());
            stmt.setBigDecimal(4, entity.getDiscountValue());
            stmt.setBigDecimal(5, entity.getMinSpend());
            stmt.setBigDecimal(6, entity.getMaxDiscount());
            stmt.setInt(7, entity.getMaxRedemptions());
            stmt.setDate(8, entity.getStartDate());
            stmt.setDate(9, entity.getEndDate());
            stmt.setBoolean(10, entity.isActive());
            stmt.setInt(11, entity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_PROMOTIONS.size(); i++) {
                if (FALLBACK_PROMOTIONS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_PROMOTIONS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 6: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        boolean removed = FALLBACK_PROMOTIONS.removeIf(p -> p.getId() != null && p.getId() == id);
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Delete promo redemptions
                try (PreparedStatement s1 = conn.prepareStatement("DELETE FROM promo_redemptions WHERE promo_id = ?")) {
                    s1.setInt(1, id);
                    s1.executeUpdate();
                }
                // 2. Set promo_id to NULL in any reservations
                try (PreparedStatement s2 = conn.prepareStatement("UPDATE reservations SET promo_id = NULL WHERE promo_id = ?")) {
                    s2.setInt(1, id);
                    s2.executeUpdate();
                }
                // 3. Delete the promotion
                boolean ok;
                try (PreparedStatement s3 = conn.prepareStatement("DELETE FROM promotions WHERE id = ?")) {
                    s3.setInt(1, id);
                    ok = s3.executeUpdate() > 0;
                }
                conn.commit();

                if (ok) {
                    com.boatsafari.common.util.LiveFileLogger.logTableUpdate("promotions", "DELETE", id, "Promotion #" + id + " deleted");
                    com.boatsafari.common.util.LiveFileLogger.logTableUpdate("promo_redemptions", "DELETE", id, "Redemptions cleared for promo #" + id);
                }
                return ok;
            } catch (SQLException ex) {
                conn.rollback();
                logger.log(Level.WARNING, "Failed to delete promotion in DB: " + ex.getMessage());
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.log(Level.FINE, "DB unavailable during promotion delete, fallback: " + e.getMessage());
            return removed;
        }
    }
}
