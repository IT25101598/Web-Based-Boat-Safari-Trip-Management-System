package com.boatsafari.common.model;

import com.boatsafari.common.core.BaseModel;

import java.util.Collections;
import java.util.Map;

/**
 * Activity audit log recording all major user actions for security and traceability.
 */
public class ActivityLog extends BaseModel {
    private Integer userId;
    private String userName;
    private String action;
    private String module;
    private String details;
    private String ipAddress;

    public ActivityLog() {
        super();
    }

    public ActivityLog(Integer userId, String action, String module, String details, String ipAddress) {
        super();
        this.userId = userId;
        this.action = action;
        this.module = module;
        this.details = details;
        this.ipAddress = ipAddress;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    @Override
    public Map<String, String> validate() {
        return Collections.emptyMap();
    }

    @Override
    public String getSummary() {
        return "[" + module + "] " + action + " by " + (userName != null ? userName : "User #" + userId) + ": " + details;
    }

    @Override
    public String getStatusLabel() {
        return action;
    }
}
