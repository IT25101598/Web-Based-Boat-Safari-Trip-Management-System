package com.boatsafari.member3.model;

/**
 * Member 3: Catamaran Subclass (Member 3: Boat Fleet Management).
 * Demonstrates Inheritance and Polymorphic method overriding.
 */
public class Catamaran extends Vessel {
    private double trampolineAreaSqM = 32.5;
    private boolean shadedCockpitLounge = true;

    public Catamaran() {
        super();
        setVesselType(VesselType.CATAMARAN);
    }

    public Catamaran(Integer id, String name, String registrationNo, int maxPassengers, int cabins) {
        super(id, name, registrationNo, VesselType.CATAMARAN, maxPassengers, cabins);
    }

    public double getTrampolineAreaSqM() {
        return trampolineAreaSqM;
    }

    public void setTrampolineAreaSqM(double trampolineAreaSqM) {
        this.trampolineAreaSqM = trampolineAreaSqM;
    }

    public boolean isShadedCockpitLounge() {
        return shadedCockpitLounge;
    }

    public void setShadedCockpitLounge(boolean shadedCockpitLounge) {
        this.shadedCockpitLounge = shadedCockpitLounge;
    }

    @Override
    public String getVesselArchitecture() {
        return "Twin-Hull Catamaran with " + trampolineAreaSqM + "m² bow sun trampolines and expansive shaded bridge deck.";
    }
}
