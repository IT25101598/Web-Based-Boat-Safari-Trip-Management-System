package com.boatsafari.common.util;

import java.io.Serializable;
import java.util.Objects;

/**
 * Immutable Value Object encapsulating boat passenger and seating capacities.
 * Enforces business bounds (> 0 and <= maximum maritime licensing threshold).
 */
public final class Capacity implements Serializable, Comparable<Capacity> {
    private static final long serialVersionUID = 1L;
    public static final int MAX_SAFARI_CAPACITY = 100;

    private final int maxPassengers;
    private final int cabins;

    public Capacity(int maxPassengers) {
        this(maxPassengers, 0);
    }

    public Capacity(int maxPassengers, int cabins) {
        if (maxPassengers <= 0) {
            throw new IllegalArgumentException("Capacity must be greater than zero");
        }
        if (maxPassengers > MAX_SAFARI_CAPACITY) {
            throw new IllegalArgumentException("Capacity exceeds maximum licensed limit (" + MAX_SAFARI_CAPACITY + ")");
        }
        if (cabins < 0) {
            throw new IllegalArgumentException("Cabins count cannot be negative");
        }
        this.maxPassengers = maxPassengers;
        this.cabins = cabins;
    }

    public int getMaxPassengers() {
        return maxPassengers;
    }

    public int getCabins() {
        return cabins;
    }

    public boolean canAccommodate(int guests) {
        return guests > 0 && guests <= maxPassengers;
    }

    @Override
    public int compareTo(Capacity o) {
        return Integer.compare(this.maxPassengers, o.maxPassengers);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Capacity capacity = (Capacity) o;
        return maxPassengers == capacity.maxPassengers && cabins == capacity.cabins;
    }

    @Override
    public int hashCode() {
        return Objects.hash(maxPassengers, cabins);
    }

    @Override
    public String toString() {
        return maxPassengers + " Guests" + (cabins > 0 ? " (" + cabins + " Cabins)" : "");
    }
}
