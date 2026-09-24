package com.boatsafari.member1.model;

/**
 * Member 1: Sri Lankan Maritime Coast Regions (Member 1: Safari Tour & Schedule Management)
 */
public enum CoastRegion {
    SOUTH_COAST("Southern Coast", "Mirissa, Weligama, Galle, Dondra"),
    EAST_COAST("Eastern Coast", "Trincomalee, Pigeon Island, Passikudah"),
    WEST_COAST("Western Coast", "Colombo Marina, Bentota River, Negombo"),
    NORTH_COAST("Northern Coast", "Jaffna Peninsula, Delft Island");

    private final String displayName;
    private final String ports;

    CoastRegion(String displayName, String ports) {
        this.displayName = displayName;
        this.ports = ports;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getPorts() {
        return ports;
    }
}
