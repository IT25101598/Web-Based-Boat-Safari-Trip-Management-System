package com.boatsafari.member1.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member1.model.ScheduleStatus;
import com.boatsafari.member1.model.TourSchedule;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 1: Tour Schedule DAO (Member 1: Safari Tour & Schedule Management).
 */
public class TourScheduleDAO extends AbstractDAO<TourSchedule> {
    private static final List<TourSchedule> FALLBACK_SCHEDULES = new CopyOnWriteArrayList<>();

    static {
        LocalDateTime now = LocalDateTime.now();
        TourSchedule s1 = new TourSchedule(1, 1, 1, Timestamp.valueOf(now.plusDays(1).withHour(6).withMinute(30)), Timestamp.valueOf(now.plusDays(1).withHour(11).withMinute(0)), 22);
        s1.setVesselName("Ocean Pearl (Ceycat 55)");
        s1.setCaptainName("Capt. Shantha Perera");
        s1.setGuideName("Kasun Fernando");
        FALLBACK_SCHEDULES.add(s1);

        TourSchedule s2 = new TourSchedule(2, 1, 1, Timestamp.valueOf(now.plusDays(2).withHour(6).withMinute(30)), Timestamp.valueOf(now.plusDays(2).withHour(11).withMinute(0)), 25);
        s2.setVesselName("Ocean Pearl (Ceycat 55)");
        s2.setCaptainName("Capt. Shantha Perera");
        s2.setGuideName("Kasun Fernando");
        FALLBACK_SCHEDULES.add(s2);

        TourSchedule s3 = new TourSchedule(3, 2, 2, Timestamp.valueOf(now.plusDays(1).withHour(15).withMinute(30)), Timestamp.valueOf(now.plusDays(1).withHour(18).withMinute(30)), 18);
        s3.setVesselName("Sapphire Blue (Topaz 48)");
        s3.setCaptainName("Capt. Ruwan Kumara");
        s3.setGuideName("Dilshan Silva");
        FALLBACK_SCHEDULES.add(s3);

        TourSchedule s4 = new TourSchedule(4, 3, 2, Timestamp.valueOf(now.plusDays(3).withHour(8).withMinute(0)), Timestamp.valueOf(now.plusDays(3).withHour(13).withMinute(0)), 20);
        s4.setVesselName("Sapphire Blue (Topaz 48)");
        s4.setCaptainName("Capt. Ruwan Kumara");
        s4.setGuideName("Dilshan Silva");
        FALLBACK_SCHEDULES.add(s4);
    }

    @Override
    protected String getTableName() {
        return "tour_schedules";
    }

    @Override
    protected TourSchedule mapRow(ResultSet rs) throws SQLException {
        TourSchedule s = new TourSchedule();
        s.setId(rs.getInt("id"));
        s.setTourId(rs.getInt("tour_id"));
        s.setVesselId(rs.getInt("vessel_id"));
        s.setCaptainId(rs.getInt("captain_id"));
        s.setGuideId(rs.getInt("guide_id"));
        s.setDepartureTime(rs.getTimestamp("departure_time"));
        s.setReturnTime(rs.getTimestamp("return_time"));
        s.setAvailableSeats(rs.getInt("available_seats"));
        try {
            s.setStatus(ScheduleStatus.valueOf(rs.getString("status")));
        } catch (Exception e) {
            s.setStatus(ScheduleStatus.SCHEDULED);
        }
        s.setCancellationReason(rs.getString("cancellation_reason"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    @Override
    public Optional<TourSchedule> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_SCHEDULES.stream().filter(s -> s.getId() != null && s.getId() == id).findFirst();
        }
        String sql = "SELECT s.*, t.title AS tour_title, v.name AS vessel_name, uc.full_name AS captain_name, ug.full_name AS guide_name " +
                     "FROM tour_schedules s " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "LEFT JOIN vessels v ON s.vessel_id = v.id " +
                     "LEFT JOIN users uc ON s.captain_id = uc.id " +
                     "LEFT JOIN users ug ON s.guide_id = ug.id " +
                     "WHERE s.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    TourSchedule ts = mapRow(rs);
                    ts.setVesselName(rs.getString("vessel_name"));
                    ts.setCaptainName(rs.getString("captain_name"));
                    ts.setGuideName(rs.getString("guide_name"));
                    return Optional.of(ts);
                }
            }
        } catch (SQLException e) {
            return FALLBACK_SCHEDULES.stream().filter(s -> s.getId() != null && s.getId() == id).findFirst();
        }
        return Optional.empty();
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    @Override
    public List<TourSchedule> findAll() {
        List<TourSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, t.title AS tour_title, v.name AS vessel_name, uc.full_name AS captain_name, ug.full_name AS guide_name " +
                     "FROM tour_schedules s " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "LEFT JOIN vessels v ON s.vessel_id = v.id " +
                     "LEFT JOIN users uc ON s.captain_id = uc.id " +
                     "LEFT JOIN users ug ON s.guide_id = ug.id " +
                     "ORDER BY s.departure_time DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                TourSchedule ts = mapRow(rs);
                ts.setVesselName(rs.getString("vessel_name"));
                ts.setCaptainName(rs.getString("captain_name"));
                ts.setGuideName(rs.getString("guide_name"));
                list.add(ts);
            }
        } catch (SQLException e) {
            return FALLBACK_SCHEDULES;
        }
        return list;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<TourSchedule> findUpcoming() {
        List<TourSchedule> list = new ArrayList<>();
        String sql = "SELECT s.*, t.title AS tour_title, v.name AS vessel_name, uc.full_name AS captain_name, ug.full_name AS guide_name " +
                     "FROM tour_schedules s " +
                     "LEFT JOIN tours t ON s.tour_id = t.id " +
                     "LEFT JOIN vessels v ON s.vessel_id = v.id " +
                     "LEFT JOIN users uc ON s.captain_id = uc.id " +
                     "LEFT JOIN users ug ON s.guide_id = ug.id " +
                     "WHERE s.status = 'SCHEDULED' " +
                     "ORDER BY s.departure_time ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                TourSchedule ts = mapRow(rs);
                ts.setVesselName(rs.getString("vessel_name"));
                ts.setCaptainName(rs.getString("captain_name"));
                ts.setGuideName(rs.getString("guide_name"));
                list.add(ts);
            }
        } catch (SQLException e) {
            return FALLBACK_SCHEDULES.stream().filter(s -> s.getStatus() == ScheduleStatus.SCHEDULED).toList();
        }
        return list;
    }

    // ==========================================
    // Member 1: READ
    // ==========================================
    public List<TourSchedule> findByTourId(int tourId) {
        List<TourSchedule> list = new ArrayList<>();
        String sql = "SELECT * FROM tour_schedules WHERE tour_id = ? AND status = 'SCHEDULED' ORDER BY departure_time ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, tourId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            return FALLBACK_SCHEDULES.stream().filter(s -> s.getTourId().equals(tourId) && s.getStatus() == ScheduleStatus.SCHEDULED).toList();
        }
        return list;
    }

    // ==========================================
    // Member 1: UPDATE
    // ==========================================
    public boolean updateAvailableSeats(int scheduleId, int seatsToDeduct) {
        String sql = "UPDATE tour_schedules SET available_seats = available_seats - ? WHERE id = ? AND available_seats >= ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, seatsToDeduct);
            stmt.setInt(2, scheduleId);
            stmt.setInt(3, seatsToDeduct);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (TourSchedule s : FALLBACK_SCHEDULES) {
                if (s.getId().equals(scheduleId)) {
                    return s.reserveSeats(seatsToDeduct);
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 1: UPDATE (Release / Restore Seats)
    // ==========================================
    public boolean releaseSeats(int scheduleId, int seatsToRestore) {
        String sql = "UPDATE tour_schedules SET available_seats = available_seats + ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, seatsToRestore);
            stmt.setInt(2, scheduleId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (TourSchedule s : FALLBACK_SCHEDULES) {
                if (s.getId().equals(scheduleId)) {
                    s.releaseSeats(seatsToRestore);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 1: UPDATE (Cancel Departure)
    // ==========================================
    public boolean cancelSchedule(int scheduleId, String reason) {
        String sql = "UPDATE tour_schedules SET status = 'CANCELLED', cancellation_reason = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, reason);
            stmt.setInt(2, scheduleId);
            boolean ok = stmt.executeUpdate() > 0;
            if (ok) {
                com.boatsafari.common.util.LiveFileLogger.logTableUpdate("tour_schedules", "CANCEL", scheduleId, "Schedule #" + scheduleId + " cancelled: " + reason);
            }
            return ok;
        } catch (SQLException e) {
            for (TourSchedule s : FALLBACK_SCHEDULES) {
                if (s.getId().equals(scheduleId)) {
                    s.setStatus(ScheduleStatus.CANCELLED);
                    s.setCancellationReason(reason);
                    com.boatsafari.common.util.LiveFileLogger.logTableUpdate("tour_schedules", "CANCEL", scheduleId, "Schedule #" + scheduleId + " cancelled (fallback): " + reason);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 1: CREATE
    // ==========================================
    @Override
    public TourSchedule create(TourSchedule entity) {
        String sql = "INSERT INTO tour_schedules (tour_id, vessel_id, captain_id, guide_id, departure_time, return_time, available_seats, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, entity.getTourId());
            stmt.setInt(2, entity.getVesselId());
            if (entity.getCaptainId() != null) stmt.setInt(3, entity.getCaptainId()); else stmt.setNull(3, Types.INTEGER);
            if (entity.getGuideId() != null) stmt.setInt(4, entity.getGuideId()); else stmt.setNull(4, Types.INTEGER);
            stmt.setTimestamp(5, entity.getDepartureTime());
            stmt.setTimestamp(6, entity.getReturnTime());
            stmt.setInt(7, entity.getAvailableSeats());
            stmt.setString(8, entity.getStatus().name());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_SCHEDULES.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding schedule to fallback list.");
            entity.setId(FALLBACK_SCHEDULES.size() + 1);
            FALLBACK_SCHEDULES.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 1: UPDATE
    // ==========================================
    @Override
    public boolean update(TourSchedule entity) {
        String sql = "UPDATE tour_schedules SET tour_id = ?, vessel_id = ?, captain_id = ?, guide_id = ?, departure_time = ?, return_time = ?, available_seats = ?, status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, entity.getTourId());
            stmt.setInt(2, entity.getVesselId());
            if (entity.getCaptainId() != null) stmt.setInt(3, entity.getCaptainId()); else stmt.setNull(3, Types.INTEGER);
            if (entity.getGuideId() != null) stmt.setInt(4, entity.getGuideId()); else stmt.setNull(4, Types.INTEGER);
            stmt.setTimestamp(5, entity.getDepartureTime());
            stmt.setTimestamp(6, entity.getReturnTime());
            stmt.setInt(7, entity.getAvailableSeats());
            stmt.setString(8, entity.getStatus().name());
            stmt.setInt(9, entity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_SCHEDULES.size(); i++) {
                if (FALLBACK_SCHEDULES.get(i).getId().equals(entity.getId())) {
                    FALLBACK_SCHEDULES.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 1: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        FALLBACK_SCHEDULES.removeIf(s -> s.getId() != null && s.getId() == id);
        if (!db.isDatabaseAvailable()) {
            return true;
        }
        return super.delete(id);
    }
}
