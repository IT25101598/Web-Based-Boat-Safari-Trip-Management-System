package com.boatsafari.member6.model;

import com.boatsafari.common.util.Money;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Member 6: Seasonal Discount Strategy (Member 6: Promotion & Discount Strategy Management).
 * Applies higher discount percentage for bookings over high value thresholds.
 */
public class SeasonalDiscount extends DiscountStrategy {
    private final BigDecimal spendThreshold;

    public SeasonalDiscount(BigDecimal percentage, BigDecimal maxDiscount, BigDecimal spendThreshold) {
        super(percentage, maxDiscount);
        this.spendThreshold = spendThreshold != null ? spendThreshold : BigDecimal.ZERO;
    }

    @Override
    public Money calculateDiscount(Money originalTotal) {
        if (originalTotal == null || originalTotal.getAmount().compareTo(spendThreshold) < 0) {
            return Money.zero();
        }
        BigDecimal pct = value.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        BigDecimal discount = originalTotal.getAmount().multiply(pct).setScale(2, RoundingMode.HALF_UP);

        if (maxDiscount.compareTo(BigDecimal.ZERO) > 0 && discount.compareTo(maxDiscount) > 0) {
            discount = maxDiscount;
        }

        return Money.of(discount);
    }
}
