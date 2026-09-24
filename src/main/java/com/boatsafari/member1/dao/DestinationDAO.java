package com.boatsafari.member1.dao;

import com.boatsafari.common.core.AbstractDAO;
import com.boatsafari.member1.model.CoastRegion;
import com.boatsafari.member1.model.Destination;

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
 * Member 1: Destination and Harbour DAO (Member 1: Safari Tour & Schedule Management).
 */
public class DestinationDAO extends AbstractDAO<Destination> {
    private static final List<Destination> FALLBACK_DESTINATIONS = new CopyOnWriteArrayList<>();

    static {
        FALLBACK_DESTINATIONS.add(new Destination(1, "Mirissa Bay & Deep Ocean", CoastRegion.SOUTH_COAST, "Mirissa Fishery Harbour", "Sri Lanka's premier whale and dolphin watching capital."));
        FALLBACK_DESTINATIONS.add(new Destination(2, "Galle Fort Heritage Coast", CoastRegion.SOUTH_COAST, "Galle International Harbour", "UNESCO world heritage ramparts viewed from the ocean."));
        FALLBACK_DESTINATIONS.add(new Destination(3, "Trincomalee & Pigeon Island", CoastRegion.EAST_COAST, "Trincomalee Cod Bay Pier", "World-famous coral reefs and calm blue sailing waters."));
        FALLBACK_DESTINATIONS.add(new Destination(4, "Bentota Lagoon & Sea Route", CoastRegion.WEST_COAST, "Bentota River Marina", "Scenic riverine mangrove safari and open-sea cruising."));
        FALLBACK_DESTINATIONS.add(new Destination(5, "Passikudah Coral Bay", CoastRegion.EAST_COAST, "Passikudah Outer Pier", "Shallow crystalline waters ideal for swimming and snorkeling."));
    }

    @Override
    protected String getTableName() {
        return "destinations";
    }

    @Override
    protected Destination mapRow(ResultSet rs) throws SQLException {
        Destination d = new Destination();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        try {
            d.setRegion(CoastRegion.valueOf(rs.getString("region")));
        } catch (Exception e) {
            d.setRegion(CoastRegion.SOUTH_COAST);
        }
        d.setHarborName(rs.getString("harbor_name"));
        d.setDescription(rs.getString("description"));
        d.setImageUrl(rs.getString("image_url"));
        d.setCreatedAt(rs.getTimestamp("created_at"));
        return d;
    }

    @Override
    public Optional<Destination> findById(int id) {
        if (!db.isDatabaseAvailable()) {
            return FALLBACK_DESTINATIONS.stream().filter(d -> d.getId() != null && d.getId() == id).findFirst();
        }
        try {
            Optional<Destination> opt = super.findById(id);
            if (opt.isPresent()) return opt;
        } catch (Exception ignored) {}
        return FALLBACK_DESTINATIONS.stream().filter(d -> d.getId() != null && d.getId() == id).findFirst();
    }

    @Override
    public List<Destination> findAll() {
        if (!db.isDatabaseAvailable()) {
            return new ArrayList<>(FALLBACK_DESTINATIONS);
        }
        try {
            List<Destination> list = super.findAll();
            return (list != null && !list.isEmpty()) ? list : new ArrayList<>(FALLBACK_DESTINATIONS);
        } catch (Exception e) {
            return new ArrayList<>(FALLBACK_DESTINATIONS);
        }
    }

    @Override
    public Destination create(Destination entity) {
        String sql = "INSERT INTO destinations (name, region, harbor_name, description, image_url) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, entity.getName());
            stmt.setString(2, entity.getRegion().name());
            stmt.setString(3, entity.getHarborName());
            stmt.setString(4, entity.getDescription());
            stmt.setString(5, entity.getImageUrl());
            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) entity.setId(rs.getInt(1));
                }
            }
            FALLBACK_DESTINATIONS.add(entity);
            return entity;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Database unavailable, adding destination to fallback list.");
            entity.setId(FALLBACK_DESTINATIONS.size() + 1);
            FALLBACK_DESTINATIONS.add(entity);
            return entity;
        }
    }

    @Override
    public boolean update(Destination entity) {
        String sql = "UPDATE destinations SET name = ?, region = ?, harbor_name = ?, description = ?, image_url = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, entity.getName());
            stmt.setString(2, entity.getRegion().name());
            stmt.setString(3, entity.getHarborName());
            stmt.setString(4, entity.getDescription());
            stmt.setString(5, entity.getImageUrl());
            stmt.setInt(6, entity.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            for (int i = 0; i < FALLBACK_DESTINATIONS.size(); i++) {
                if (FALLBACK_DESTINATIONS.get(i).getId().equals(entity.getId())) {
                    FALLBACK_DESTINATIONS.set(i, entity);
                    return true;
                }
            }
            return false;
        }
    }
}
