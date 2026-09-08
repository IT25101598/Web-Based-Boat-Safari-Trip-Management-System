package com.boatsafari.common.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Validator;

import java.util.HashMap;
import java.util.Map;

/**
 * Abstract human entity establishing base demographic identity.
 * Demonstrates Abstraction and Encapsulation.
 */
public abstract class Person extends BaseModel {
    private String fullName;
    private String phone;

    public Person() {
        super();
    }

    public Person(Integer id, String fullName, String phone) {
        super(id);
        this.fullName = fullName;
        this.phone = phone;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName != null ? fullName.trim() : null;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone != null ? phone.trim() : null;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(fullName)) {
            errors.put("fullName", "Full name is required");
        }
        if (Validator.isNotBlank(phone) && !Validator.isValidPhone(phone)) {
            errors.put("phone", "Invalid phone number format");
        }
        return errors;
    }
}
