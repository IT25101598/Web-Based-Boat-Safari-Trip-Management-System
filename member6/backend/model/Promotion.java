package com.boatsafari.member6.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Money;
import com.boatsafari.common.util.Validator;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 6: Promotion Campaign Entity (Member 6: Promotion & Discount Strategy Management).
 * Encapsulates promo codes, validity dates, redemption limits, and strategy.
 */
public class Promotion extends BaseModel {
    private String name;
    private String promoCode;
    private DiscountType discountType = DiscountType.PERCENTAGE;
    private BigDecimal discountValue = BigDecimal.valueOf(10.0);
    private BigDecimal minSpend = BigDecimal.ZERO;
    private BigDecimal maxDiscount = BigDecimal.ZERO;
    private int maxRedemptions = 100;
    private int timesRedeemed = 0;
    private Date startDate;
    private Date endDate;
    private boolean active = true;

    private transient DiscountStrategy strategy;

    public Promotion() {
        super();
        this.startDate = Date.valueOf(LocalDate.now());
        this.endDate = Date.valueOf(LocalDate.now().plusMonths(3));
    }

    public Promotion(Integer id, String name, String promoCode, DiscountType discountType, BigDecimal value, BigDecimal minSpend, BigDecimal maxDiscount) {
        super(id);
        this.name = name;
        this.promoCode = promoCode != null ? promoCode.trim().toUpperCase() : null;
        this.discountType = discountType;
        this.discountValue = value;
        this.minSpend = minSpend;
        this.maxDiscount = maxDiscount;
        this.startDate = Date.valueOf(LocalDate.now());
        this.endDate = Date.valueOf(LocalDate.now().plusMonths(3));
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name != null ? name.trim() : null;
    }

    public String getPromoCode() {
        return promoCode;
    }

    public void setPromoCode(String promoCode) {
        this.promoCode = promoCode != null ? promoCode.trim().toUpperCase() : null;
    }

    public DiscountType getDiscountType() {
        return discountType;
    }

    public void setDiscountType(DiscountType discountType) {
        this.discountType = discountType != null ? discountType : DiscountType.PERCENTAGE;
        this.strategy = null; // Invalidate cached strategy
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
        this.strategy = null;
    }

    public BigDecimal getMinSpend() {
        return minSpend;
    }

    public void setMinSpend(BigDecimal minSpend) {
        this.minSpend = minSpend;
    }

    public BigDecimal getMaxDiscount() {
        return maxDiscount;
    }

    public void setMaxDiscount(BigDecimal maxDiscount) {
        this.maxDiscount = maxDiscount;
        this.strategy = null;
    }

    public int getMaxRedemptions() {
        return maxRedemptions;
    }

    public void setMaxRedemptions(int maxRedemptions) {
        this.maxRedemptions = maxRedemptions;
    }

    public int getTimesRedeemed() {
        return timesRedeemed;
    }

    public void setTimesRedeemed(int timesRedeemed) {
        this.timesRedeemed = timesRedeemed;
    }

    public void incrementRedemption() {
        this.timesRedeemed++;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    /**
     * Lazy-loads the appropriate Strategy object based on discountType.
     * Demonstrates Polymorphism & Factory logic.
     */
    public DiscountStrategy getStrategy() {
        if (strategy == null) {
            switch (discountType) {
                case FIXED_AMOUNT:
                    strategy = new FixedAmountDiscount(discountValue);
                    break;
                case SEASONAL:
                    strategy = new SeasonalDiscount(discountValue, maxDiscount, minSpend);
                    break;
                case PERCENTAGE:
                default:
                    strategy = new PercentageDiscount(discountValue, maxDiscount);
                    break;
            }
        }
        return strategy;
    }

    /**
     * Checks if this promotion can be applied to a given booking amount right now.
     */
    public boolean isEligible(Money bookingTotal) {
        if (!active) return false;
        if (timesRedeemed >= maxRedemptions) return false;
        Date today = Date.valueOf(LocalDate.now());
        if (startDate != null && today.before(startDate)) return false;
        if (endDate != null && today.after(endDate)) return false;
        if (minSpend != null && bookingTotal.getAmount().compareTo(minSpend) < 0) return false;
        return true;
    }

    /**
     * Applies discount strategy polymorphically.
     */
    public Money applyDiscount(Money bookingTotal) {
        if (!isEligible(bookingTotal)) {
            return Money.zero();
        }
        return getStrategy().calculateDiscount(bookingTotal);
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(name)) {
            errors.put("name", "Promotion campaign name is required");
        }
        if (!Validator.isNotBlank(promoCode)) {
            errors.put("promoCode", "Promo code string is required");
        }
        if (discountValue == null || discountValue.compareTo(BigDecimal.ZERO) <= 0) {
            errors.put("discountValue", "Discount value must be greater than zero");
        }
        if (startDate != null && endDate != null && endDate.before(startDate)) {
            errors.put("endDate", "End date cannot be prior to start date");
        }
        return errors;
    }

    public String getDiscountSummary() {
        if (discountType == DiscountType.PERCENTAGE) {
            return discountValue + "% OFF" + (maxDiscount != null && maxDiscount.compareTo(BigDecimal.ZERO) > 0 ? " (Max LKR " + maxDiscount + ")" : "");
        } else if (discountType == DiscountType.FIXED_AMOUNT) {
            return "LKR " + discountValue + " OFF";
        } else {
            return discountValue + "% Seasonal Special";
        }
    }

    public Money getMinSpendMoney() {
        return new Money(minSpend != null ? minSpend : BigDecimal.ZERO);
    }

    public int getCurrentRedemptions() {
        return timesRedeemed;
    }

    @Override
    public String getSummary() {
        return name + " [" + promoCode + "] - " + discountType.getDisplayName() + " " + discountValue + (discountType == DiscountType.PERCENTAGE ? "%" : " LKR");
    }

    @Override
    public String getStatusLabel() {
        return active ? "Active" : "Disabled";
    }

    @Override
    public String getStatusBadgeClass() {
        return active ? "badge-success" : "badge-secondary";
    }
}
