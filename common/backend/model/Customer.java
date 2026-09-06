package com.boatsafari.common.model;

/**
 * Customer / Tourist entity specialized for booking safari adventures.
 * Demonstrates Inheritance (User -> Customer).
 */
public class Customer extends User {
    private String passportOrNic;
    private String country = "Sri Lanka";
    private int completedBookings = 0;

    public Customer() {
        super();
        setRole(UserRole.CUSTOMER);
    }

    public Customer(Integer id, String fullName, String email, String phone, String country) {
        super(id, fullName, email, phone, UserRole.CUSTOMER);
        this.country = country;
    }

    public String getPassportOrNic() {
        return passportOrNic;
    }

    public void setPassportOrNic(String passportOrNic) {
        this.passportOrNic = passportOrNic;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public int getCompletedBookings() {
        return completedBookings;
    }

    public void setCompletedBookings(int completedBookings) {
        this.completedBookings = completedBookings;
    }

    @Override
    public String getSummary() {
        return "Tourist: " + getFullName() + " (" + country + ") - " + getEmail();
    }
}
