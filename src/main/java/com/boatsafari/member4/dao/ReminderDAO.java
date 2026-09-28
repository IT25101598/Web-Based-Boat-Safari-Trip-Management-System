package com.boatsafari.member4.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member4.model.ServiceReminder;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 4: Service Reminder DAO (Member 4: Boat Maintenance & Service Management).
 */
public class ReminderDAO extends AbstractDAO<ServiceReminder> {
    private static final List<ServiceReminder> FALLBACK_REMINDERS = new CopyOnWriteArrayList<>();

    static {
        ServiceReminder sr1 = new ServiceReminder(1, 1, "Yanmar Port Engine Impeller Replacement", 120, Date.valueOf("2026-06-01"), Date.valueOf(LocalDate.now().plusDays(25)));
        sr1.setVesselName("Ocean Pearl (Ceycat 55)");
        sr1.setNotes("Inspect seawater cooling pumps");
        FALLBACK_REMINDERS.add(sr1);

        ServiceReminder sr2 = new ServiceReminder(2, 3, "Majesty Yacht Generator 200hr Service", 90, Date.valueOf("2026-05-15"), Date.valueOf(LocalDate.now().minusDays(10)));
        sr2.setVesselName("Ceylon Monarch (Majesty 62)");
        sr2.setOverdue(true);
        sr2.setNotes("Overdue by 10 days! Immediate inspection recommended");
        FALLBACK_REMINDERS.add(sr2);

        ServiceReminder sr3 = new ServiceReminder(3, 4, "Yamaha Outboard Gear Oil Change", 60, Date.valueOf("2026-08-01"), Date.valueOf(LocalDate.now().plusDays(40)));
        sr3.setVesselName("Wave Runner (SeaRay 32)");
        sr3.setNotes("Routine pre-season check");
        FALLBACK_REMINDERS.add(sr3);
    }

    @Override
    protected String getTableName() {
        return "service_reminders";
    }

    @Override
    protected ServiceReminder mapRow(ResultSet rs) throws SQLException {
        ServiceReminder sr = new ServiceReminder();
        sr.setId(rs.getInt("id"));
        sr.setVesselId(rs.getInt("vessel_id"));
        sr.setReminderTitle(rs.getString("reminder_title"));
        sr.setIntervalDays(rs.getInt("interval_days"));
        sr.setLastServicedDate(rs.getDate("last_serviced_date"));
        sr.setNextDueDate(rs.getDate("next_due_date"));
        sr.setOverdue(rs.getBoolean("is_overdue"));
        sr.setNotes(rs.getString("notes"));
        sr.setCreatedAt(rs.getTimestamp("created_at"));
        return sr;
    }

    // ==========================================
    // Member 4: READ
    // ==========================================
    @Override
    public List<ServiceReminder> findAll() {
        List<ServiceReminder> list = new ArrayList<>();
        String sql = "SELECT r.*, v.name AS vessel_name FROM service_reminders r LEFT JOIN vessels v ON r.vessel_id = v.id ORDER BY r.next_due_date ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                ServiceReminder sr = mapRow(rs);
                sr.setVesselName(rs.getString("vessel_name"));
                list.add(sr);
            }
        } catch (SQLException e) {
            return FALLBACK_REMINDERS;
        }
        return list;
    }

    // ==========================================
    // Member 4: CREATE
    // ==========================================
    @Override
    public ServiceReminder create(ServiceReminder entity) {
        String sql = "INSERT INTO service_reminders (vessel_id, reminder_title, interval_days, last_serviced_date, next_due_date, is_overdue, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, entity.getVesselId());
            stmt.setString(2, entity.getReminderTitle());
            stmt.setInt(3, entity.getIntervalDays());
            stmt.setDate(4, entity.getLastServicedDate());
            stmt.setDate(5, entity.getNextDueDate());
            stmt.setBoolean(6, entity.isOverdue());
            stmt.setString(7, entity.getNotes());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_REMINDERS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding reminder to fallback list.");
            entity.setId(FALLBACK_REMINDERS.size() + 1);
            FALLBACK_REMINDERS.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 4: UPDATE
    // ==========================================
    @Override
    public boolean update(ServiceReminder entity) {
        String sql = "UPDATE service_reminders SET vessel_id = ?, reminder_title = ?, interval_days = ?, last_serviced_date = ?, next_due_date = ?, is_overdue = ?, notes = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, entity.getVesselId());
            stmt.setString(2, entity.getReminderTitle());
            stmt.setInt(3, entity.getIntervalDays());
            stmt.setDate(4, entity.getLastServicedDate());
            stmt.setDate(5, entity.getNextDueDate());
            stmt.setBoolean(6, entity.isOverdue());
            stmt.setString(7, entity.getNotes());
            stmt.setInt(8, entity.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_REMINDERS.size(); i++) {
                if (FALLBACK_REMINDERS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_REMINDERS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }
}
