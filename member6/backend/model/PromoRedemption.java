package com.boatsafari.member6.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Money;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.Map;

/**
 * Member 6: Promotion Redemption Audit Entity (Member 6: Promotion & Discount Strategy Management).
 */
public class PromoRedemption extends BaseModel {
    private Integer promoId;
    private String promoCode;
    private Integer customerId;
    private String customerName;
    private Integer reservationId;
    private String bookingRef;
    private Money discountApplied = Money.zero();
    private Timestamp redeemedAt;

    public PromoRedemption() {
        super();
        this.redeemedAt = new Timestamp(System.currentTimeMillis());
    }

    public PromoRedemption(int promoId, int customerId, int reservationId, BigDecimal discount) {
        super();
        this.promoId = promoId;
        this.customerId = customerId;
        this.reservationId = reservationId;
        this.discountApplied = new Money(discount);
        this.redeemedAt = new Timestamp(System.currentTimeMillis());
    }

    public Integer getPromoId() {
        return promoId;
    }

    public void setPromoId(Integer promoId) {
        this.promoId = promoId;
    }

    public String getPromoCode() {
        return promoCode;
    }

    public void setPromoCode(String promoCode) {
        this.promoCode = promoCode;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public String getCustomerEmail() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public Integer getReservationId() {
        return reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public String getBookingRef() {
        return bookingRef;
    }

    public void setBookingRef(String bookingRef) {
        this.bookingRef = bookingRef;
    }

    public Money getDiscountApplied() {
        return discountApplied;
    }

    public void setDiscountApplied(Money discountApplied) {
        this.discountApplied = discountApplied;
    }

    public void setDiscountAppliedAmount(BigDecimal amount) {
        this.discountApplied = new Money(amount);
    }

    public Timestamp getRedeemedAt() {
        return redeemedAt != null ? (Timestamp) redeemedAt.clone() : null;
    }

    public void setRedeemedAt(Timestamp redeemedAt) {
        this.redeemedAt = redeemedAt != null ? (Timestamp) redeemedAt.clone() : null;
    }

    @Override
    public Map<String, String> validate() {
        return Collections.emptyMap();
    }

    @Override
    public String getSummary() {
        return "Promo [" + promoCode + "] redeemed for booking " + bookingRef + " (Saved: " + discountApplied.getFormatted() + ")";
    }

    @Override
    public String getStatusLabel() {
        return "Redeemed";
    }
}
