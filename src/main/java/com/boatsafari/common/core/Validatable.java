package com.boatsafari.common.core;

import java.util.Map;

/**
 * Contract for self-validating entities.
 * Demonstrates Abstraction for entity data validation.
 */
public interface Validatable {
    /**
     * Validates domain model constraints.
     * @return Map of field name to error message. Empty map if valid.
     */
    Map<String, String> validate();

    /**
     * Helper to quickly check if the model is currently valid.
     * @return true if no validation errors exist.
     */
    default boolean isValid() {
        Map<String, String> errors = validate();
        return errors == null || errors.isEmpty();
    }
}
