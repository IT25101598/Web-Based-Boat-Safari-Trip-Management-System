package com.boatsafari.member3.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Capacity;
import com.boatsafari.common.util.Validator;

import java.util.HashMap;
import java.util.Map;

/**
 * Member 3: Abstract Vessel entity (Member 3: Boat Fleet Management).
 * Root class demonstrating Abstraction, Inheritance, and Composition (has-a Capacity).
 */
public abstract class Vessel extends BaseModel {
    private String name;
    private String registrationNo;
    private VesselType vesselType;
    private Capacity capacity;
    private String engines;
    private double cruisingSpeedKnots;
    private VesselStatus status = VesselStatus.AVAILABLE;
    private Integer ownerId;
    private String imageUrl = "assets/img/fleet/ocean-pearl.jpg";
    private String safetyEquipmentNotes;

    public Vessel() {
        super();
        this.capacity = new Capacity(20);
    }

    public Vessel(Integer id, String name, String registrationNo, VesselType vesselType, int maxPassengers, int cabins) {
        super(id);
        this.name = name;
        this.registrationNo = registrationNo;
        this.vesselType = vesselType;
        this.capacity = new Capacity(maxPassengers, cabins);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name != null ? name.trim() : null;
    }

    public String getRegistrationNo() {
        return registrationNo;
    }

    public void setRegistrationNo(String registrationNo) {
        this.registrationNo = registrationNo != null ? registrationNo.trim().toUpperCase() : null;
    }

    public VesselType getVesselType() {
        return vesselType;
    }

    public VesselType getType() {
        return vesselType;
    }

    public void setVesselType(VesselType vesselType) {
        this.vesselType = vesselType;
    }

    public String getRegistrationNumber() {
        return registrationNo;
    }

    public Capacity getCapacity() {
        return capacity;
    }

    public void setCapacity(Capacity capacity) {
        this.capacity = capacity != null ? capacity : new Capacity(20);
    }

    public void setCapacityValues(int maxPassengers, int cabins) {
        this.capacity = new Capacity(maxPassengers, cabins);
    }

    public String getEngines() {
        return engines;
    }

    public void setEngines(String engines) {
        this.engines = engines;
    }

    public double getCruisingSpeedKnots() {
        return cruisingSpeedKnots;
    }

    public void setCruisingSpeedKnots(double cruisingSpeedKnots) {
        this.cruisingSpeedKnots = cruisingSpeedKnots;
    }

    public VesselStatus getStatus() {
        return status;
    }

    public void setStatus(VesselStatus status) {
        this.status = status != null ? status : VesselStatus.AVAILABLE;
    }

    public Integer getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(Integer ownerId) {
        this.ownerId = ownerId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getSafetyEquipmentNotes() {
        return safetyEquipmentNotes;
    }

    public void setSafetyEquipmentNotes(String safetyEquipmentNotes) {
        this.safetyEquipmentNotes = safetyEquipmentNotes;
    }

    public boolean isAvailable() {
        return status == VesselStatus.AVAILABLE;
    }

    /**
     * Polymorphic method overridden by subclasses describing specific architectural features.
     */
    public abstract String getVesselArchitecture();

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(name)) {
            errors.put("name", "Vessel name is required");
        }
        if (!Validator.isNotBlank(registrationNo)) {
            errors.put("registrationNo", "Official maritime registration number is required");
        }
        if (capacity == null || capacity.getMaxPassengers() <= 0) {
            errors.put("capacity", "Valid licensed capacity is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return name + " [" + registrationNo + "] - " + vesselType.getDisplayName() + " (" + capacity.toString() + ")";
    }

    @Override
    public String getStatusLabel() {
        return status.getLabel();
    }

    @Override
    public String getStatusBadgeClass() {
        return status.getBadgeClass();
    }
}
