package com.boatsafari.common.core;

import java.util.Collections;
import java.util.Map;

/**
 * Domain validation exception carrying field-specific validation errors.
 */
public class ValidationException extends RuntimeException {
    private final Map<String, String> errors;

    public ValidationException(String message) {
        super(message);
        this.errors = Collections.emptyMap();
    }

    public ValidationException(String message, Map<String, String> errors) {
        super(message);
        this.errors = errors != null ? Collections.unmodifiableMap(errors) : Collections.emptyMap();
    }

    public ValidationException(Map<String, String> errors) {
        super("Validation failed: " + (errors != null ? errors.toString() : ""));
        this.errors = errors != null ? Collections.unmodifiableMap(errors) : Collections.emptyMap();
    }

    public Map<String, String> getErrors() {
        return errors;
    }
}
