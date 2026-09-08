package com.boatsafari.common.model;

/**
 * System Administrator entity with complete operational privilege.
 */
public class Admin extends User {
    public Admin() {
        super();
        setRole(UserRole.ADMIN);
    }

    public Admin(Integer id, String fullName, String email, String phone) {
        super(id, fullName, email, phone, UserRole.ADMIN);
    }

    @Override
    public String getSummary() {
        return "System Administrator: " + getFullName() + " (" + getEmail() + ")";
    }
}
