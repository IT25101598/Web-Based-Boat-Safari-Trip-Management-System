package com.boatsafari.member3.model;

/**
 * Member 3: Motor Yacht Subclass (Member 3: Boat Fleet Management).
 * Demonstrates Inheritance and Polymorphic method overriding.
 */
public class Yacht extends Vessel {
    private boolean flybridgeDeck = true;
    private boolean airConditionedSalon = true;
    private int luxuryStaterooms = 3;

    public Yacht() {
        super();
        setVesselType(VesselType.YACHT);
    }

    public Yacht(Integer id, String name, String registrationNo, int maxPassengers, int cabins) {
        super(id, name, registrationNo, VesselType.YACHT, maxPassengers, cabins);
    }

    public boolean isFlybridgeDeck() {
        return flybridgeDeck;
    }

    public void setFlybridgeDeck(boolean flybridgeDeck) {
        this.flybridgeDeck = flybridgeDeck;
    }

    public boolean isAirConditionedSalon() {
        return airConditionedSalon;
    }

    public void setAirConditionedSalon(boolean airConditionedSalon) {
        this.airConditionedSalon = airConditionedSalon;
    }

    public int getLuxuryStaterooms() {
        return luxuryStaterooms;
    }

    public void setLuxuryStaterooms(int luxuryStaterooms) {
        this.luxuryStaterooms = luxuryStaterooms;
    }

    @Override
    public String getVesselArchitecture() {
        return "Monohull Motor Yacht featuring elevated flybridge deck and " + luxuryStaterooms + " private en-suite staterooms.";
    }
}
