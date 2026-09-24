package com.boatsafari.member1.service;

import com.boatsafari.common.core.ValidationException;
import com.boatsafari.member1.dao.DestinationDAO;
import com.boatsafari.member1.dao.RouteDAO;
import com.boatsafari.member1.dao.TourDAO;
import com.boatsafari.member1.dao.TourScheduleDAO;
import com.boatsafari.member1.model.Destination;
import com.boatsafari.member1.model.Route;
import com.boatsafari.member1.model.Tour;
import com.boatsafari.member1.model.TourSchedule;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Member 1: Safari Tour Service Facade (Member 1: Safari Tour & Schedule Management).
 * Coordinates business operations across Tours, Routes, Destinations, and Departures.
 */
public class TourService {
    private final TourDAO tourDAO;
    private final TourScheduleDAO scheduleDAO;
    private final RouteDAO routeDAO;
    private final DestinationDAO destinationDAO;

    public TourService() {
        this.tourDAO = new TourDAO();
        this.scheduleDAO = new TourScheduleDAO();
        this.routeDAO = new RouteDAO();
        this.destinationDAO = new DestinationDAO();
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<Tour> getActiveTours() {
        List<Tour> tours = tourDAO.findActive();
        for (Tour t : tours) {
            if (t.getRouteId() != null) {
                routeDAO.findById(t.getRouteId()).ifPresent(t::setRoute);
            }
        }
        return tours;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<Tour> getAllTours() {
        return tourDAO.findAll();
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public Optional<Tour> getTourById(int id) {
        Optional<Tour> opt = tourDAO.findById(id);
        opt.ifPresent(t -> {
            if (t.getRouteId() != null) {
                routeDAO.findById(t.getRouteId()).ifPresent(t::setRoute);
            }
        });
        return opt;
    }

    // ==========================================
    // Member 1: CREATE & UPDATE
    // ==========================================
    public Tour saveTour(Tour tour) {
        Map<String, String> errors = tour.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Tour validation failed", errors);
        }
        if (tour.getId() == null || tour.getId() == 0) {
            // Member 1: CREATE
            return tourDAO.create(tour);
        } else {
            // Member 1: UPDATE
            tourDAO.update(tour);
            return tour;
        }
    }

    // ==========================================
    // Member 1: DELETE
    // ==========================================
    public boolean deleteTour(int tourId) {
        return tourDAO.delete(tourId);
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<Route> getAllRoutes() {
        List<Route> routes = routeDAO.findAll();
        for (Route r : routes) {
            if (r.getStartDestinationId() != null) {
                destinationDAO.findById(r.getStartDestinationId()).ifPresent(r::setStartDestination);
            }
            if (r.getEndDestinationId() != null) {
                destinationDAO.findById(r.getEndDestinationId()).ifPresent(r::setEndDestination);
            }
        }
        return routes;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<Destination> getAllDestinations() {
        return destinationDAO.findAll();
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<TourSchedule> getUpcomingSchedules() {
        List<TourSchedule> schedules = scheduleDAO.findUpcoming();
        for (TourSchedule s : schedules) {
            tourDAO.findById(s.getTourId()).ifPresent(s::setTour);
        }
        return schedules;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<TourSchedule> getAllSchedules() {
        List<TourSchedule> schedules = scheduleDAO.findAll();
        for (TourSchedule s : schedules) {
            if (s.getTourId() != null) {
                tourDAO.findById(s.getTourId()).ifPresent(s::setTour);
            }
        }
        return schedules;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<TourSchedule> getSchedulesForTour(int tourId) {
        return scheduleDAO.findByTourId(tourId);
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public Optional<TourSchedule> getScheduleById(int scheduleId) {
        Optional<TourSchedule> opt = scheduleDAO.findById(scheduleId);
        opt.ifPresent(s -> tourDAO.findById(s.getTourId()).ifPresent(s::setTour));
        return opt;
    }

    public void validateScheduleConflicts(TourSchedule schedule) {
        List<TourSchedule> allSchedules = scheduleDAO.findAll();
        for (TourSchedule existing : allSchedules) {
            if (existing.getId() != null && schedule.getId() != null && existing.getId().equals(schedule.getId())) {
                continue;
            }
            if (existing.getStatus() == com.boatsafari.member1.model.ScheduleStatus.CANCELLED) {
                continue;
            }
            if (existing.getDepartureTime() != null && existing.getReturnTime() != null &&
                schedule.getDepartureTime() != null && schedule.getReturnTime() != null) {
                boolean overlap = existing.getDepartureTime().before(schedule.getReturnTime()) &&
                                  existing.getReturnTime().after(schedule.getDepartureTime());
                if (overlap) {
                    if (existing.getVesselId() != null && existing.getVesselId().equals(schedule.getVesselId())) {
                        throw new ValidationException("Boat conflict detected: Assigned boat is already booked for another departure between " +
                                existing.getFormattedDeparture() + " and " + existing.getFormattedReturn());
                    }
                    if (schedule.getCaptainId() != null && existing.getCaptainId() != null &&
                        existing.getCaptainId().equals(schedule.getCaptainId())) {
                        throw new ValidationException("Captain conflict detected: Assigned boat captain is already on duty on another tour between " +
                                existing.getFormattedDeparture() + " and " + existing.getFormattedReturn());
                    }
                    if (schedule.getGuideId() != null && existing.getGuideId() != null &&
                        existing.getGuideId().equals(schedule.getGuideId())) {
                        throw new ValidationException("Guide conflict detected: Assigned tour guide is already scheduled on another departure between " +
                                existing.getFormattedDeparture() + " and " + existing.getFormattedReturn());
                    }
                }
            }
        }
    }

    // ==========================================
    // Member 1: CREATE
    // ==========================================
    public TourSchedule createSchedule(TourSchedule schedule) {
        Map<String, String> errors = schedule.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Schedule validation failed", errors);
        }
        validateScheduleConflicts(schedule);
        return scheduleDAO.create(schedule);
    }

    // ==========================================
    // Member 1: UPDATE
    // ==========================================
    public boolean updateSchedule(TourSchedule schedule) {
        Map<String, String> errors = schedule.validate();
        if (!errors.isEmpty()) {
            throw new ValidationException("Schedule validation failed", errors);
        }
        validateScheduleConflicts(schedule);
        return scheduleDAO.update(schedule);
    }

    // ==========================================
    // Member 1: UPDATE (Cancel Departure)
    // ==========================================
    public boolean cancelSchedule(int scheduleId, String reason) {
        return scheduleDAO.cancelSchedule(scheduleId, reason);
    }

    // ==========================================
    // Member 1: UPDATE (Deduct Seats)
    // ==========================================
    public boolean deductSeats(int scheduleId, int count) {
        return scheduleDAO.updateAvailableSeats(scheduleId, count);
    }

    // ==========================================
    // Member 1: UPDATE (Release / Restore Seats)
    // ==========================================
    public boolean releaseSeats(int scheduleId, int count) {
        return scheduleDAO.releaseSeats(scheduleId, count);
    }
}
