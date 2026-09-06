package com.boatsafari.common.model;

/**
 * Operational staff entity for guides, skippers, captains, and officers.
 * Demonstrates Inheritance and polymorphism.
 */
public class Staff extends User {
    private String employeeCode;
    private String maritimeLicenseNo;
    private int experienceYears = 1;

    public Staff() {
        super();
    }

    public Staff(Integer id, String fullName, String email, String phone, UserRole role, String employeeCode) {
        super(id, fullName, email, phone, role);
        this.employeeCode = employeeCode;
    }

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    public String getMaritimeLicenseNo() {
        return maritimeLicenseNo;
    }

    public void setMaritimeLicenseNo(String maritimeLicenseNo) {
        this.maritimeLicenseNo = maritimeLicenseNo;
    }

    public int getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(int experienceYears) {
        this.experienceYears = experienceYears;
    }

    @Override
    public String getSummary() {
        return getRole().getDisplayName() + ": " + getFullName() + " [" + employeeCode + "]";
    }
}
