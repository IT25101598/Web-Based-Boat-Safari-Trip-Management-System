package com.boatsafari.member1.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.util.Validator;

import java.util.HashMap;
import java.util.Map;

/**
 * Member 1: Destination and Harbour entity (Member 1: Safari Tour & Schedule Management)
 */
public class Destination extends BaseModel {
    private String name;
    private CoastRegion region = CoastRegion.SOUTH_COAST;
    private String harborName;
    private String description;
    private String imageUrl = "assets/img/destinations/mirissa.jpg";

    public Destination() {
        super();
    }

    public Destination(Integer id, String name, CoastRegion region, String harborName, String description) {
        super(id);
        this.name = name;
        this.region = region;
        this.harborName = harborName;
        this.description = description;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name != null ? name.trim() : null;
    }

    public CoastRegion getRegion() {
        return region;
    }

    public void setRegion(CoastRegion region) {
        this.region = region != null ? region : CoastRegion.SOUTH_COAST;
    }

    public String getHarborName() {
        return harborName;
    }

    public void setHarborName(String harborName) {
        this.harborName = harborName != null ? harborName.trim() : null;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (!Validator.isNotBlank(name)) {
            errors.put("name", "Destination name is required");
        }
        if (!Validator.isNotBlank(harborName)) {
            errors.put("harborName", "Harbour or Pier name is required");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        return name + " (" + harborName + ", " + region.getDisplayName() + ")";
    }

    @Override
    public String getStatusLabel() {
        return region.getDisplayName();
    }
}
