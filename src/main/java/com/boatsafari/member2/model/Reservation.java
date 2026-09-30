package com.boatsafari.member2.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Money;
import com.boatsafari.common.util.Validator;
import com.boatsafari.member1.model.TourSchedule;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Member 2: Reservation Booking Entity (Member 2: Reservation & Guest Booking Management).
 * Demonstrates Composition: Reservation has-many Passenger, has-a Money object, and has-a TourSchedule.
 */
public class Reservation extends BaseModel {
    private String bookingRef;
    private Integer scheduleId;
    private TourSchedule schedule;
    private String tourTitle;
    private Integer customerId;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private int passengerCount = 1;
    private Money totalAmount = Money.zero();
    private Money discountAmount = Money.zero();
    private Money finalAmount = Money.zero();
    private Integer promoId;
    private String promoCode;
    private ReservationStatus status = ReservationStatus.CONFIRMED;
    private String specialNotes;
    private List<Passenger> passengers = new ArrayList<>();

    public Reservation() {
        super();
    }

    public Reservation(Integer id, String bookingRef, int scheduleId, int customerId, int passengerCount, BigDecimal total, BigDecimal discount, BigDecimal finalAmount) {
        super(id);
        this.bookingRef = bookingRef;
        this.scheduleId = scheduleId;
        this.customerId = customerId;
        this.passengerCount = passengerCount;
        this.totalAmount = new Money(total);
        this.discountAmount = new Money(discount);
        this.finalAmount = new Money(finalAmount);
    }

    public String getBookingRef() {
        return bookingRef;
    }

    public void setBookingRef(String bookingRef) {
        this.bookingRef = bookingRef != null ? bookingRef.trim().toUpperCase() : null;
    }

    public Integer getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(Integer scheduleId) {
        this.scheduleId = scheduleId;
    }

    public TourSchedule getSchedule() {
        return schedule;
    }

    public void setSchedule(TourSchedule schedule) {
        this.schedule = schedule;
        if (schedule != null) {
            this.scheduleId = schedule.getId();
        }
    }

    public String getTourTitle() {
        return tourTitle;
    }

    public void setTourTitle(String tourTitle) {
        this.tourTitle = tourTitle;
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

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public int getPassengerCount() {
        return passengerCount;
    }

    public void setPassengerCount(int passengerCount) {
        this.passengerCount = passengerCount;
    }

    public Money getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(Money totalAmount) {
        this.totalAmount = totalAmount != null ? totalAmount : Money.zero();
    }

    public void setTotalAmountValue(BigDecimal amount) {
        this.totalAmount = new Money(amount);
    }

    public Money getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(Money discountAmount) {
        this.discountAmount = discountAmount != null ? discountAmount : Money.zero();
    }

    public void setDiscountAmountValue(BigDecimal amount) {
        this.discountAmount = new Money(amount);
    }

    public Money getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(Money finalAmount) {
        this.finalAmount = finalAmount != null ? finalAmount : Money.zero();
    }

    public void setFinalAmountValue(BigDecimal amount) {
        this.finalAmount = new Money(amount);
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

    public ReservationStatus getStatus() {
        return status;
    }

    public void setStatus(ReservationStatus status) {
        this.status = status != null ? status : ReservationStatus.CONFIRMED;
    }

    public String getSpecialNotes() {
        return specialNotes;
    }

    public void setSpecialNotes(String specialNotes) {
        this.specialNotes = specialNotes;
    }

    /**
     * Defensive copying to encapsulate passenger manifest list.
     */
    public List<Passenger> getPassengers() {
        return Collections.unmodifiableList(passengers);
    }

    public void setPassengers(List<Passenger> passengers) {
        this.passengers = passengers != null ? new ArrayList<>(passengers) : new ArrayList<>();
    }

    public void addPassenger(Passenger passenger) {
        if (passenger != null) {
            this.passengers.add(passenger);
        }
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(bookingRef)) {
            errors.put("bookingRef", "Booking reference code is required");
        }
        if (scheduleId == null || scheduleId <= 0) {
            errors.put("scheduleId", "Departure schedule selection is required");
        }
        if (passengerCount <= 0) {
            errors.put("passengerCount", "At least 1 passenger is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return "Booking " + bookingRef + " (" + (tourTitle != null ? tourTitle : "Safari") + ") - " + passengerCount + " Guests [" + finalAmount.getFormatted() + "]";
    }

    @Override
    public String getStatusLabel() {
        return status.getLabel();
    }

    @Override
    public String getStatusBadgeClass() {
        return status.getBadgeClass();
    }
}
