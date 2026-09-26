package com.boatsafari.member6.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.common.util.Money;
import com.boatsafari.member6.dao.PromoRedemptionDAO;
import com.boatsafari.member6.dao.PromotionDAO;
import com.boatsafari.member6.model.PromoRedemption;
import com.boatsafari.member6.model.Promotion;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 6: Promotion and Discount Service Facade (Member 6: Promotion & Discount Strategy Management).
 */
public class PromotionService {
    private final PromotionDAO promotionDAO;
    private final PromoRedemptionDAO redemptionDAO;

    public PromotionService() {
        this.promotionDAO = new PromotionDAO();
        this.redemptionDAO = new PromoRedemptionDAO();
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    public List<Promotion> getAllPromotions() {
        return promotionDAO.findAll();
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    public Optional<Promotion> getPromotionById(int id) {
        return promotionDAO.findById(id);
    }

    // ==========================================
    // Member 6: READ
    // ==========================================
    public Optional<Promotion> findValidPromo(String code, Money orderTotal) {
        if (code == null || code.isBlank()) return Optional.empty();
        Optional<Promotion> promoOpt = promotionDAO.findByCode(code.trim());
        if (promoOpt.isPresent()) {
            Promotion p = promoOpt.get();
            if (p.isEligible(orderTotal)) {
                return Optional.of(p);
            }
        }
        return Optional.empty();
    }

    // ==========================================
    // Member 6: CREATE & UPDATE
    // ==========================================
    public Promotion savePromotion(Promotion promotion) {
        Map<String, String> errors = promotion.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Promotion validation failed", errors);
        }
        if (promotion.getId() == null || promotion.getId() == 0) {
            // Member 6: CREATE
            return promotionDAO.create(promotion);
        } else {
            // Member 6: UPDATE
            promotionDAO.update(promotion);
            return promotion;
        }
    }

    // ==========================================
    // Member 6: DELETE
    // ==========================================
    public boolean deletePromotion(int id) {
        return promotionDAO.delete(id);
    }

    // ==========================================
    // Member 6: CREATE (Record Redemption)
    // ==========================================
    public void recordRedemption(int promoId, int customerId, int reservationId, Money discount) {
        promotionDAO.incrementUsage(promoId);
        redemptionDAO.create(new PromoRedemption(promoId, customerId, reservationId, discount.getAmount()));
    }

    // ==========================================
    // Member 6: READ (Redemptions)
    // ==========================================
    public List<PromoRedemption> getAllRedemptions() {
        return redemptionDAO.findAll();
    }
}
