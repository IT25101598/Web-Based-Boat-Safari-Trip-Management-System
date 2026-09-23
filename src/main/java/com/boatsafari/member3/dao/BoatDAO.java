package com.boatsafari.member3.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member3.model.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;

/**
 * Member 3: Boat Fleet DAO (Member 3: Boat Fleet Management).
 * Demonstrates Polymorphic Factory mapping and persistence for Vessel hierarchy.
 */
public class BoatDAO extends AbstractDAO<Vessel> {
    private static final List<Vessel> FALLBACK_VESSELS = new CopyOnWriteArrayList<>();

    static {
        Catamaran c1 = new Catamaran(1, "Ocean Pearl (Ceycat 55)", "SLC-CAT-001", 30, 4);
        c1.setEngines("Twin 75HP Yanmar Marine Diesel");
        c1.setCruisingSpeedKnots(9.5);
        c1.setStatus(VesselStatus.AVAILABLE);
        c1.setImageUrl("assets/img/fleet/ocean-pearl.jpg");
        c1.setSafetyEquipmentNotes("SOLAS life jackets x35, Life rafts x2 (capacity 40), EPIRB, VHF Radio");
        FALLBACK_VESSELS.add(c1);

        Catamaran c2 = new Catamaran(2, "Sapphire Blue (Topaz 48)", "SLC-CAT-002", 25, 3);
        c2.setEngines("Twin 55HP Volvo Penta");
        c2.setCruisingSpeedKnots(8.5);
        c2.setStatus(VesselStatus.AVAILABLE);
        c2.setImageUrl("assets/img/fleet/sapphire-blue.jpg");
        c2.setSafetyEquipmentNotes("SOLAS life jackets x30, Life raft x1 (capacity 30), VHF Radio, Flares");
        FALLBACK_VESSELS.add(c2);

        Yacht y1 = new Yacht(3, "Ceylon Monarch (Majesty 62)", "SLC-YACHT-003", 15, 3);
        y1.setEngines("Twin 800HP MAN Marine Diesel");
        y1.setCruisingSpeedKnots(18.0);
        y1.setStatus(VesselStatus.AVAILABLE);
        y1.setImageUrl("assets/img/fleet/ceylon-monarch.jpg");
        y1.setSafetyEquipmentNotes("SOLAS life jackets x20, Life raft x1 (capacity 20), Radar, Sonar");
        FALLBACK_VESSELS.add(y1);

        SpeedBoat s1 = new SpeedBoat(4, "Wave Runner (SeaRay 32)", "SLC-SPD-004", 12);
        s1.setEngines("Twin 250HP Yamaha Outboards");
        s1.setCruisingSpeedKnots(28.0);
        s1.setStatus(VesselStatus.AVAILABLE);
        s1.setImageUrl("assets/img/fleet/wave-runner.jpg");
        s1.setSafetyEquipmentNotes("SOLAS life jackets x15, VHF Radio, Emergency Bilge Pump");
        FALLBACK_VESSELS.add(s1);

        Catamaran c3 = new Catamaran(5, "Mirissa Sun (Lagoon 42)", "SLC-CAT-005", 20, 4);
        c3.setEngines("Twin 45HP Yanmar");
        c3.setCruisingSpeedKnots(8.0);
        c3.setStatus(VesselStatus.UNDER_MAINTENANCE);
        c3.setImageUrl("assets/img/fleet/mirissa-sun.jpg");
        c3.setSafetyEquipmentNotes("Scheduled for slipway antifouling repaint and rudder check");
        FALLBACK_VESSELS.add(c3);
    }

    @Override
    protected String getTableName() {
        return "vessels";
    }

    @Override
    protected Vessel mapRow(ResultSet rs) throws SQLException {
        String typeStr = rs.getString("vessel_type");
        VesselType type;
        try {
            type = VesselType.valueOf(typeStr);
        } catch (Exception e) {
            type = VesselType.CATAMARAN;
        }

        // Factory Pattern: Instantiate specific subclass
        Vessel vessel;
        switch (type) {
            case YACHT:
                vessel = new Yacht();
                break;
            case SPEEDBOAT:
                vessel = new SpeedBoat();
                break;
            case CATAMARAN:
            default:
                vessel = new Catamaran();
                break;
        }

        vessel.setId(rs.getInt("id"));
        vessel.setName(rs.getString("name"));
        vessel.setRegistrationNo(rs.getString("registration_no"));
        vessel.setVesselType(type);
        vessel.setCapacityValues(rs.getInt("capacity"), rs.getInt("cabins"));
        vessel.setEngines(rs.getString("engines"));
        vessel.setCruisingSpeedKnots(rs.getDouble("cruising_speed_knots"));
        try {
            vessel.setStatus(VesselStatus.valueOf(rs.getString("status")));
        } catch (Exception e) {
            vessel.setStatus(VesselStatus.AVAILABLE);
        }
        int ownerId = rs.getInt("owner_id");
        vessel.setOwnerId(rs.wasNull() ? null : ownerId);
        vessel.setImageUrl(rs.getString("image_url"));
        vessel.setSafetyEquipmentNotes(rs.getString("safety_equipment_notes"));
        vessel.setCreatedAt(rs.getTimestamp("created_at"));

        return vessel;
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    @Override
    public Optional<Vessel> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_VESSELS.stream().filter(v -> v.getId() != null && v.getId() == id).findFirst();
        }
        try {
            return super.findById(id);
        } catch (Exception e) {
            return FALLBACK_VESSELS.stream().filter(v -> v.getId() != null && v.getId() == id).findFirst();
        }
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    @Override
    public List<Vessel> findAll() {
        if (!db.isDatabaseAvailable()) {
            return new ArrayList<>(FALLBACK_VESSELS);
        }
        try {
            List<Vessel> list = super.findAll();
            return (list != null && !list.isEmpty()) ? list : new ArrayList<>(FALLBACK_VESSELS);
        } catch (Exception e) {
            return new ArrayList<>(FALLBACK_VESSELS);
        }
    }

    // ==========================================
    // Member 3: READ
    // ==========================================
    public List<Vessel> findAvailableVessels() {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_VESSELS.stream().filter(Vessel::isAvailable).toList();
        }
        List<Vessel> list = new ArrayList<>();
        String sql = "SELECT * FROM vessels WHERE status = 'AVAILABLE' ORDER BY id ASC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            return FALLBACK_VESSELS.stream().filter(Vessel::isAvailable).toList();
        }
        return list.isEmpty() ? FALLBACK_VESSELS.stream().filter(Vessel::isAvailable).toList() : list;
    }

    // ==========================================
    // Member 3: UPDATE
    // ==========================================
    public boolean updateStatus(int vesselId, VesselStatus newStatus) {
        return updateStatus(vesselId, newStatus, null);
    }

    public boolean updateStatus(int vesselId, VesselStatus newStatus, String reason) {
        String sql = (reason != null && !reason.isBlank()) ?
            "UPDATE vessels SET status = ?, safety_equipment_notes = ? WHERE id = ?" :
            "UPDATE vessels SET status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus.name());
            if (reason != null && !reason.isBlank()) {
                stmt.setString(2, reason);
                stmt.setInt(3, vesselId);
            } else {
                stmt.setInt(2, vesselId);
            }
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (Vessel v : FALLBACK_VESSELS) {
                if (v.getId().equals(vesselId)) {
                    v.setStatus(newStatus);
                    if (reason != null && !reason.isBlank()) {
                        v.setSafetyEquipmentNotes(reason);
                    }
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 3: CREATE
    // ==========================================
    @Override
    public Vessel create(Vessel entity) {
        if (!db.isDatabaseAvailable()) {
            int nextId = FALLBACK_VESSELS.stream().mapToInt(v -> v.getId() != null ? v.getId() : 0).max().orElse(0) + 1;
            entity.setId(nextId);
            FALLBACK_VESSELS.add(entity);
            return entity;
        }
        String sql = "INSERT INTO vessels (name, registration_no, vessel_type, capacity, cabins, engines, cruising_speed_knots, status, owner_id, image_url, safety_equipment_notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getName());
            stmt.setString(2, entity.getRegistrationNo());
            stmt.setString(3, entity.getVesselType().name());
            stmt.setInt(4, entity.getCapacity().getMaxPassengers());
            stmt.setInt(5, entity.getCapacity().getCabins());
            stmt.setString(6, entity.getEngines());
            stmt.setDouble(7, entity.getCruisingSpeedKnots());
            stmt.setString(8, entity.getStatus().name());
            if (entity.getOwnerId() != null) stmt.setInt(9, entity.getOwnerId()); else stmt.setNull(9, java.sql.Types.INTEGER);
            stmt.setString(10, entity.getImageUrl());
            stmt.setString(11, entity.getSafetyEquipmentNotes());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_VESSELS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database insert failed. Adding vessel to fallback memory store.", e);
            int nextId = FALLBACK_VESSELS.stream().mapToInt(v -> v.getId() != null ? v.getId() : 0).max().orElse(0) + 1;
            entity.setId(nextId);
            FALLBACK_VESSELS.add(entity);
            return entity;
        }
    }

    // ==========================================
    // Member 3: UPDATE
    // ==========================================
    @Override
    public boolean update(Vessel entity) {
        if (!db.isDatabaseAvailable()) {
            for (int i = 0; i < FALLBACK_VESSELS.size(); i++) {
                if (FALLBACK_VESSELS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_VESSELS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
        String sql = "UPDATE vessels SET name = ?, registration_no = ?, vessel_type = ?, capacity = ?, cabins = ?, engines = ?, cruising_speed_knots = ?, status = ?, image_url = ?, safety_equipment_notes = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getName());
            stmt.setString(2, entity.getRegistrationNo());
            stmt.setString(3, entity.getVesselType().name());
            stmt.setInt(4, entity.getCapacity().getMaxPassengers());
            stmt.setInt(5, entity.getCapacity().getCabins());
            stmt.setString(6, entity.getEngines());
            stmt.setDouble(7, entity.getCruisingSpeedKnots());
            stmt.setString(8, entity.getStatus().name());
            stmt.setString(9, entity.getImageUrl());
            stmt.setString(10, entity.getSafetyEquipmentNotes());
            stmt.setInt(11, entity.getId());

            boolean ok = stmt.executeUpdate() > 0;
            for (int i = 0; i < FALLBACK_VESSELS.size(); i++) {
                if (FALLBACK_VESSELS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_VESSELS.set(i, entity);
                    break;
                }
            }
            return ok;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_VESSELS.size(); i++) {
                if (FALLBACK_VESSELS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_VESSELS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }

    // ==========================================
    // Member 3: DELETE
    // ==========================================
    @Override
    public boolean delete(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_VESSELS.removeIf(v -> v.getId() != null && v.getId() == id);
        }
        try {
            boolean ok = super.delete(id);
            if (ok) {
                FALLBACK_VESSELS.removeIf(v -> v.getId() != null && v.getId() == id);
            }
            return ok;
        } catch (Exception e) {
            logger.log(Level.WARNING, "Failed to delete vessel in DB: " + e.getMessage());
            return false;
        }
    }
}
