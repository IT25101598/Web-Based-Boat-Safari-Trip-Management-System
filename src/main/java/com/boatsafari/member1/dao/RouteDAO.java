package com.boatsafari.member1.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member1.model.Route;

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
 * Member 1: Maritime Sailing Route DAO (Member 1: Safari Tour & Schedule Management).
 */
public class RouteDAO extends AbstractDAO<Route> {
    private static final List<Route> FALLBACK_ROUTES = new CopyOnWriteArrayList<>();

    static {
        FALLBACK_ROUTES.add(new Route(1, "Mirissa Pelagic Blue Whale Track", 1, 1, 4.5, 18.5));
        FALLBACK_ROUTES.add(new Route(2, "Galle Lighthouse & Coral Reef Sunset", 2, 2, 3.0, 10.0));
        FALLBACK_ROUTES.add(new Route(3, "Trincomalee Pigeon Island Reef Expedition", 3, 3, 5.0, 22.0));
        FALLBACK_ROUTES.add(new Route(4, "Bentota Mangrove & Ocean Breeze", 4, 4, 3.5, 12.0));
        FALLBACK_ROUTES.add(new Route(5, "Passikudah Bay & Coral Garden", 5, 5, 4.0, 15.0));
    }

    @Override
    protected String getTableName() {
        return "routes";
    }

    @Override
    protected Route mapRow(ResultSet rs) throws SQLException {
        Route r = new Route();
        r.setId(rs.getInt("id"));
        r.setName(rs.getString("name"));
        r.setStartDestinationId(rs.getInt("start_destination_id"));
        r.setEndDestinationId(rs.getInt("end_destination_id"));
        r.setDurationHours(rs.getDouble("duration_hours"));
        r.setDistanceNm(rs.getDouble("distance_nm"));
        r.setHighlights(rs.getString("highlights"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }

    @Override
    public Optional<Route> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_ROUTES.stream().filter(r -> r.getId() != null && r.getId() == id).findFirst();
        }
        try {
            Optional<Route> opt = super.findById(id);
            if (opt.isPresent()) return opt;
        } catch (Exception ignored) {}
        return FALLBACK_ROUTES.stream().filter(r -> r.getId() != null && r.getId() == id).findFirst();
    }

    @Override
    public List<Route> findAll() {
        if (!db.isDatabaseAvailable()) {
            return new ArrayList<>(FALLBACK_ROUTES);
        }
        try {
            List<Route> routes = super.findAll();
            return (routes != null && !routes.isEmpty()) ? routes : new ArrayList<>(FALLBACK_ROUTES);
        } catch (Exception e) {
            return new ArrayList<>(FALLBACK_ROUTES);
        }
    }

    @Override
    public Route create(Route entity) {
        String sql = "INSERT INTO routes (name, start_destination_id, end_destination_id, duration_hours, distance_nm, highlights) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getName());
            stmt.setInt(2, entity.getStartDestinationId());
            stmt.setInt(3, entity.getEndDestinationId());
            stmt.setDouble(4, entity.getDurationHours());
            stmt.setDouble(5, entity.getDistanceNm());
            stmt.setString(6, entity.getHighlights());
            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_ROUTES.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding route to fallback list.");
            entity.setId(FALLBACK_ROUTES.size() + 1);
            FALLBACK_ROUTES.add(entity);
            return entity;
        }
    }

    @Override
    public boolean update(Route entity) {
        String sql = "UPDATE routes SET name = ?, start_destination_id = ?, end_destination_id = ?, duration_hours = ?, distance_nm = ?, highlights = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getName());
            stmt.setInt(2, entity.getStartDestinationId());
            stmt.setInt(3, entity.getEndDestinationId());
            stmt.setDouble(4, entity.getDurationHours());
            stmt.setDouble(5, entity.getDistanceNm());
            stmt.setString(6, entity.getHighlights());
            stmt.setInt(7, entity.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_ROUTES.size(); i++) {
                if (FALLBACK_ROUTES.get(i).getId().equals(entity.getId())) {
                    FALLBACK_ROUTES.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }
}
