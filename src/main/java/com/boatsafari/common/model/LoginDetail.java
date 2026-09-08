package com.boatsafari.common.model;

import com.boatsafari.common.core.BaseModel;

import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * Model representing authentication and login audit details.
 * Mapped to the `login_details` database table.
 */
public class LoginDetail extends BaseModel {
    private Integer userId;
    private String fullName;
    private String email;
    private String role;
    private String ipAddress;
    private String status;
    private Timestamp loginTime;
    private String userAgent;
    private String details;

    public LoginDetail() {
        super();
        this.loginTime = new Timestamp(System.currentTimeMillis());
        this.ipAddress = "127.0.0.1";
        this.userAgent = "Browser / Web Client";
    }

    public LoginDetail(Integer userId, String fullName, String email, String role, String ipAddress, String status, String details) {
        super();
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
        this.ipAddress = ipAddress != null ? ipAddress : "127.0.0.1";
        this.status = status != null ? status : "SUCCESS";
        this.details = details;
        this.loginTime = new Timestamp(System.currentTimeMillis());
        this.userAgent = "Browser / Web Client";
    }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getLoginTime() { return loginTime; }
    public void setLoginTime(Timestamp loginTime) { this.loginTime = loginTime; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (email == null || email.trim().isEmpty()) {
            errors.put("email", "Email is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return (fullName != null ? fullName : "User") + " (" + email + ") - " + status;
    }

    @Override
    public String getStatusLabel() {
        return status != null ? status : "SUCCESS";
    }
}
