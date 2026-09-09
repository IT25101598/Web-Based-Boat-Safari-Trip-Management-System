package com.boatsafari.member3.model;

/**
 * Member 3: SpeedBoat Subclass (Member 3: Boat Fleet Management).
 * Demonstrates Inheritance and Polymorphic method overriding.
 */
public class SpeedBoat extends Vessel {
    private int outboardCount = 2;
    private double maxSpeedKnots = 32.0;

    public SpeedBoat() {
        super();
        setVesselType(VesselType.SPEEDBOAT);
    }

    public SpeedBoat(Integer id, String name, String registrationNo, int maxPassengers) {
        super(id, name, registrationNo, VesselType.SPEEDBOAT, maxPassengers, 0);
    }

    public int getOutboardCount() {
        return outboardCount;
    }

    public void setOutboardCount(int outboardCount) {
        this.outboardCount = outboardCount;
    }

    public double getMaxSpeedKnots() {
        return maxSpeedKnots;
    }

    public void setMaxSpeedKnots(double maxSpeedKnots) {
        this.maxSpeedKnots = maxSpeedKnots;
    }

    @Override
    public String getVesselArchitecture() {
        return "Deep-V Fiberglass Hull with " + outboardCount + " high-output marine outboard engines delivering up to " + maxSpeedKnots + " knots.";
    }
}
