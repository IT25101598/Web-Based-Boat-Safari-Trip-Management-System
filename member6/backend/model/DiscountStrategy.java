package com.boatsafari.member6.model;

import com.boatsafari.common.util.Money;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Member 6: Abstract Discount Strategy (Member 6: Promotion & Discount Strategy Management).
 * Demonstrates the Strategy Design Pattern and Polymorphism.
 */
public abstract class DiscountStrategy implements Serializable {
    private static final long serialVersionUID = 1L;

    protected final BigDecimal value;
    protected final BigDecimal maxDiscount;

    public DiscountStrategy(BigDecimal value, BigDecimal maxDiscount) {
        this.value = value != null ? value : BigDecimal.ZERO;
        this.maxDiscount = maxDiscount != null ? maxDiscount : BigDecimal.ZERO;
    }

    /**
     * Polymorphic method computing monetary discount amount for a given order total.
     * @param originalTotal Original booking total before promo
     * @return Discount Money value
     */
    public abstract Money calculateDiscount(Money originalTotal);

    public BigDecimal getValue() {
        return value;
    }

    public BigDecimal getMaxDiscount() {
        return maxDiscount;
    }
}
