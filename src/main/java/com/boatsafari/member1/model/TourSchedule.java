package com.boatsafari.member1.model;

import com.boatsafari.common.core.BaseModel;
import com.boatsafari.common.model.User;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * Member 1: Scheduled Departure entity (Member 1: Safari Tour & Schedule Management).
 * Manages calendar departures, crew assignments, and real-time seat availability.
 */
public class TourSchedule extends BaseModel {
    private static final DateTimeFormatter DISPLAY_FMT = DateTimeFormatter.ofPattern("EEE, dd MMM yyyy 'at' HH:mm");

    private Integer tourId;
    private Tour tour;
    private Integer vesselId;
    private String vesselName;
    private Integer captainId;
    private String captainName;
    private Integer guideId;
    private String guideName;
    private Timestamp departureTime;
    private Timestamp returnTime;
    private int availableSeats;
    private ScheduleStatus status = ScheduleStatus.SCHEDULED;
    private String cancellationReason;

    public TourSchedule() {
        super();
    }

    public TourSchedule(Integer id, int tourId, int vesselId, Timestamp departureTime, Timestamp returnTime, int availableSeats) {
        super(id);
        this.tourId = tourId;
        this.vesselId = vesselId;
        this.departureTime = departureTime != null ? (Timestamp) departureTime.clone() : null;
        this.returnTime = returnTime != null ? (Timestamp) returnTime.clone() : null;
        this.availableSeats = availableSeats;
    }

    public Integer getTourId() {
        return tourId;
    }

    public void setTourId(Integer tourId) {
        this.tourId = tourId;
    }

    public Tour getTour() {
        return tour;
    }

    public void setTour(Tour tour) {
        this.tour = tour;
        if (tour != null) {
            this.tourId = tour.getId();
        }
    }

    public Integer getVesselId() {
        return vesselId;
    }

    public void setVesselId(Integer vesselId) {
        this.vesselId = vesselId;
    }

    public String getVesselName() {
        return vesselName;
    }

    public void setVesselName(String vesselName) {
        this.vesselName = vesselName;
    }

    public Integer getCaptainId() {
        return captainId;
    }

    public void setCaptainId(Integer captainId) {
        this.captainId = captainId;
    }

    public String getCaptainName() {
        return captainName;
    }

    public void setCaptainName(String captainName) {
        this.captainName = captainName;
    }

    public Integer getGuideId() {
        return guideId;
    }

    public void setGuideId(Integer guideId) {
        this.guideId = guideId;
    }

    public String getGuideName() {
        return guideName;
    }

    public void setGuideName(String guideName) {
        this.guideName = guideName;
    }

    public Timestamp getDepartureTime() {
        return departureTime != null ? (Timestamp) departureTime.clone() : null;
    }

    public void setDepartureTime(Timestamp departureTime) {
        this.departureTime = departureTime != null ? (Timestamp) departureTime.clone() : null;
    }

    public Timestamp getReturnTime() {
        return returnTime != null ? (Timestamp) returnTime.clone() : null;
    }

    public void setReturnTime(Timestamp returnTime) {
        this.returnTime = returnTime != null ? (Timestamp) returnTime.clone() : null;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public boolean reserveSeats(int count) {
        if (count > 0 && availableSeats >= count && status == ScheduleStatus.SCHEDULED) {
            this.availableSeats -= count;
            return true;
        }
        return false;
    }

    public void releaseSeats(int count) {
        if (count > 0) {
            this.availableSeats += count;
        }
    }

    public ScheduleStatus getStatus() {
        return status;
    }

    public void setStatus(ScheduleStatus status) {
        this.status = status != null ? status : ScheduleStatus.SCHEDULED;
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public void setCancellationReason(String cancellationReason) {
        this.cancellationReason = cancellationReason;
    }

    public String getFormattedDeparture() {
        if (departureTime == null) return "TBD";
        return departureTime.toLocalDateTime().format(DISPLAY_FMT);
    }

    public String getFormattedDepartureTime() {
        return getFormattedDeparture();
    }

    public String getTourTitle() {
        if (tour != null && tour.getTitle() != null) {
            return tour.getTitle();
        }
        return "Tour #" + (tourId != null ? tourId : "");
    }

    public String getFormattedReturn() {
        if (returnTime == null) return "TBD";
        return returnTime.toLocalDateTime().format(DISPLAY_FMT);
    }

    @Override
    public Map<String, String> validate() {
        Map<String, String> errors = new HashMap<>();
        if (tourId == null || tourId <= 0) {
            errors.put("tourId", "Tour selection is required");
        }
        if (vesselId == null || vesselId <= 0) {
            errors.put("vesselId", "Boat assignment is required");
        }
        if (departureTime == null) {
            errors.put("departureTime", "Departure date and time is required");
        }
        if (returnTime == null) {
            errors.put("returnTime", "Return date and time is required");
        } else if (departureTime != null && returnTime.before(departureTime)) {
            errors.put("returnTime", "Return time cannot be before departure time");
        }
        return errors;
    }

    @Override
    public String getSummary() {
        String title = tour != null ? tour.getTitle() : "Safari Tour #" + tourId;
        return title + " - Departs " + getFormattedDeparture() + " (" + availableSeats + " seats left)";
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
