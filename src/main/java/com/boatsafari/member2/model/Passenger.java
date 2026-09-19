package com.boatsafari.member2.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Validator;

import java.util.HashMap;
import java.util.Map;

/**
 * Member 2: Passenger Manifest Record (Member 2: Reservation & Guest Booking Management).
 */
public class Passenger extends BaseModel {
    private Integer reservationId;
    private String fullName;
    private String idOrPassport;
    private int age = 30;
    private String gender = "MALE";
    private String nationality = "Sri Lankan";
    private String emergencyContact;

    public Passenger() {
        super();
    }

    public Passenger(String fullName, String idOrPassport, int age, String gender, String nationality, String emergencyContact) {
        super();
        this.fullName = fullName;
        this.idOrPassport = idOrPassport;
        this.age = age;
        this.gender = gender;
        this.nationality = nationality;
        this.emergencyContact = emergencyContact;
    }

    public Integer getReservationId() {
        return reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName != null ? fullName.trim() : null;
    }

    public String getIdOrPassport() {
        return idOrPassport;
    }

    public void setIdOrPassport(String idOrPassport) {
        this.idOrPassport = idOrPassport != null ? idOrPassport.trim() : null;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender != null ? gender.toUpperCase() : "MALE";
    }

    public String getNationality() {
        return nationality;
    }

    public void setNationality(String nationality) {
        this.nationality = nationality;
    }

    public String getEmergencyContact() {
        return emergencyContact;
    }

    public void setEmergencyContact(String emergencyContact) {
        this.emergencyContact = emergencyContact;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(fullName)) {
            errors.put("fullName", "Passenger full name is required");
        }
        if (!Validator.isNotBlank(idOrPassport)) {
            errors.put("idOrPassport", "Passport or NIC number is required for manifest");
        }
        if (age <= 0 || age > 120) {
            errors.put("age", "Valid age is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return fullName + " (" + nationality + ", Age: " + age + ") - " + idOrPassport;
    }

    @Override
    public String getStatusLabel() {
        return nationality;
    }
}
