package com.boatsafari.member6.model;

import com.boatsafari.common.util.Money;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Member 6: Percentage Discount Strategy (Member 6: Promotion & Discount Strategy Management).
 */
public class PercentageDiscount extends DiscountStrategy {
    public PercentageDiscount(BigDecimal percentage, BigDecimal maxDiscount) {
        super(percentage, maxDiscount);
    }

    @Override
    public Money calculateDiscount(Money originalTotal) {
        if (originalTotal == null || originalTotal.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return Money.zero();
        }
        BigDecimal pct = value.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        BigDecimal discount = originalTotal.getAmount().multiply(pct).setScale(2, RoundingMode.HALF_UP);

        // Cap at max discount if set
        if (maxDiscount.compareTo(BigDecimal.ZERO) > 0 && discount.compareTo(maxDiscount) > 0) {
            discount = maxDiscount;
        }

        return Money.of(discount);
    }
}
