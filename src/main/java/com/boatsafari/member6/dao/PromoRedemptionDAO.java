package com.boatsafari.member6.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member6.model.PromoRedemption;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 6: Promotion Redemption Audit DAO (Member 6: Promotion & Discount Strategy Management).
 */
public class PromoRedemptionDAO extends AbstractDAO<PromoRedemption> {
    private static final List<PromoRedemption> FALLBACK_REDEMPTIONS = new CopyOnWriteArrayList<>();

    @Override
    protected String getTableName() {
        return "promo_redemptions";
    }

    @Override
    protected PromoRedemption mapRow(ResultSet rs) throws SQLException {
        PromoRedemption r = new PromoRedemption();
        r.setId(rs.getInt("id"));
        r.setPromoId(rs.getInt("promo_id"));
        r.setCustomerId(rs.getInt("customer_id"));
        r.setReservationId(rs.getInt("reservation_id"));
        r.setDiscountAppliedAmount(rs.getBigDecimal("discount_applied"));
        r.setRedeemedAt(rs.getTimestamp("redeemed_at"));
        return r;
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    @Override
    public List<PromoRedemption> findAll() {
        List<PromoRedemption> list = new ArrayList<>();
        String sql = "SELECT r.*, p.promo_code, u.full_name AS customer_name, res.booking_ref " +
                     "FROM promo_redemptions r " +
                     "LEFT JOIN promotions p ON r.promo_id = p.id " +
                     "LEFT JOIN users u ON r.customer_id = u.id " +
                     "LEFT JOIN reservations res ON r.reservation_id = res.id " +
                     "ORDER BY r.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                PromoRedemption pr = mapRow(rs);
                pr.setPromoCode(rs.getString("promo_code"));
                pr.setCustomerName(rs.getString("customer_name"));
                pr.setBookingRef(rs.getString("booking_ref"));
                list.add(pr);
            }
        } catch (SQLException e) {
            return FALLBACK_REDEMPTIONS;
        }
        return list;
    }

    // ==========================================
    // Member 6: CREATE
    // ==========================================
    @Override
    public PromoRedemption create(PromoRedemption entity) {
        String sql = "INSERT INTO promo_redemptions (promo_id, customer_id, reservation_id, discount_applied) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, entity.getPromoId());
            stmt.setInt(2, entity.getCustomerId());
            stmt.setInt(3, entity.getReservationId());
            stmt.setBigDecimal(4, entity.getDiscountApplied().getAmount());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_REDEMPTIONS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding redemption to fallback list.");
            entity.setId(FALLBACK_REDEMPTIONS.size() + 1);
            FALLBACK_REDEMPTIONS.add(entity);
            return entity;
        }
    }

    @Override
    public boolean update(PromoRedemption entity) {
        return false;
    }
}
