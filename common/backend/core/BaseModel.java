package com.boatsafari.common.core;

import java.io.Serializable;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Objects;

/**
 * Abstract root model entity for the Boat Safari System.
 * Demonstrates Abstraction & Encapsulation with protected identity and auditing fields.
 */
public abstract class BaseModel implements Serializable, Validatable, Displayable {
    private static final long serialVersionUID = 1L;

    private Integer id;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isDeleted = false;

    public BaseModel() {
        this.createdAt = Timestamp.from(Instant.now());
        this.updatedAt = Timestamp.from(Instant.now());
    }

    public BaseModel(Integer id) {
        this();
        this.id = id;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Timestamp getCreatedAt() {
        return createdAt != null ? (Timestamp) createdAt.clone() : null;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt != null ? (Timestamp) createdAt.clone() : null;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt != null ? (Timestamp) updatedAt.clone() : null;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt != null ? (Timestamp) updatedAt.clone() : null;
    }

    public boolean isDeleted() {
        return isDeleted;
    }

    public void setDeleted(boolean deleted) {
        isDeleted = deleted;
        this.updatedAt = Timestamp.from(Instant.now());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        BaseModel baseModel = (BaseModel) o;
        return Objects.equals(id, baseModel.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
