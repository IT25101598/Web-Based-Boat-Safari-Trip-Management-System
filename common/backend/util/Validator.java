package com.boatsafari.common.util;

import java.util.regex.Pattern;

/**
 * Data validation utility for emails, phone numbers, and input sanitation.
 */
public final class Validator {
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[+0-9\\s-]{8,20}$");

    private Validator() {}

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isNotBlank(String text) {
        return text != null && !text.trim().isEmpty();
    }

    public static boolean isPositive(Double value) {
        return value != null && value > 0;
    }

    public static boolean isPositive(Integer value) {
        return value != null && value > 0;
    }

    public static String sanitize(String input) {
        if (input == null) return "";
        return input.trim()
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}
