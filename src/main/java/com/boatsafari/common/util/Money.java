package com.boatsafari.common.util;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.util.Objects;

/**
 * Immutable Value Object representing monetary amounts with currency.
 * Demonstrates Encapsulation and Value Object pattern.
 */
public final class Money implements Serializable, Comparable<Money> {
    private static final long serialVersionUID = 1L;
    public static final String DEFAULT_CURRENCY = "LKR";
    private static final DecimalFormat FORMATTER = new DecimalFormat("#,##0.00");

    private final BigDecimal amount;
    private final String currency;

    public Money(BigDecimal amount) {
        this(amount, DEFAULT_CURRENCY);
    }

    public Money(double amount) {
        this(BigDecimal.valueOf(amount), DEFAULT_CURRENCY);
    }

    public Money(BigDecimal amount, String currency) {
        if (amount == null) {
            throw new IllegalArgumentException("Amount cannot be null");
        }
        this.amount = amount.setScale(2, RoundingMode.HALF_UP);
        this.currency = (currency != null && !currency.isBlank()) ? currency.trim().toUpperCase() : DEFAULT_CURRENCY;
    }

    public static Money of(double amount) {
        return new Money(amount);
    }

    public static Money of(BigDecimal amount) {
        return new Money(amount);
    }

    public static Money zero() {
        return new Money(BigDecimal.ZERO);
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getCurrency() {
        return currency;
    }

    public Money add(Money other) {
        checkSameCurrency(other);
        return new Money(this.amount.add(other.amount), this.currency);
    }

    public Money subtract(Money other) {
        checkSameCurrency(other);
        BigDecimal result = this.amount.subtract(other.amount);
        return new Money(result.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : result, this.currency);
    }

    public Money multiply(double factor) {
        return new Money(this.amount.multiply(BigDecimal.valueOf(factor)), this.currency);
    }

    public Money applyPercentageDiscount(double percentage) {
        if (percentage <= 0) return this;
        if (percentage >= 100) return Money.zero();
        BigDecimal factor = BigDecimal.valueOf((100.0 - percentage) / 100.0);
        return new Money(this.amount.multiply(factor), this.currency);
    }

    private void checkSameCurrency(Money other) {
        if (other == null || !this.currency.equals(other.currency)) {
            throw new IllegalArgumentException("Cannot operate on different currencies: " + this.currency + " vs " + (other == null ? "null" : other.currency));
        }
    }

    public String getFormatted() {
        return currency + " " + FORMATTER.format(amount);
    }

    public boolean isGreaterThan(Money other) {
        return this.compareTo(other) > 0;
    }

    public boolean isZero() {
        return this.amount.compareTo(BigDecimal.ZERO) == 0;
    }

    @Override
    public int compareTo(Money o) {
        checkSameCurrency(o);
        return this.amount.compareTo(o.amount);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Money money = (Money) o;
        return Objects.equals(amount, money.amount) && Objects.equals(currency, money.currency);
    }

    @Override
    public int hashCode() {
        return Objects.hash(amount, currency);
    }

    @Override
    public String toString() {
        return getFormatted();
    }
}
