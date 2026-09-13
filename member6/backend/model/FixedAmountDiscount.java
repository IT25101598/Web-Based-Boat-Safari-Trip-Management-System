package com.boatsafari.member6.model;

import com.boatsafari.common.util.Money;

import java.math.BigDecimal;

/**
 * Member 6: Fixed Amount Discount Strategy (Member 6: Promotion & Discount Strategy Management).
 */
public class FixedAmountDiscount extends DiscountStrategy {
    public FixedAmountDiscount(BigDecimal amount) {
        super(amount, amount);
    }

    @Override
    public Money calculateDiscount(Money originalTotal) {
        if (originalTotal == null || originalTotal.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return Money.zero();
        }
        // Discount cannot exceed the original total
        if (value.compareTo(originalTotal.getAmount()) > 0) {
            return originalTotal;
        }
        return Money.of(value);
    }
}
