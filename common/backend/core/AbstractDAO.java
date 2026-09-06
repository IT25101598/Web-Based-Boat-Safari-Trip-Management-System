package com.boatsafari.common.core;

import com.boatsafari.common.db.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Abstract Template Method DAO implementation providing generic SQL execution.
 * Demonstrates Abstraction, Inheritance, and the Template Method Design Pattern.
 *
 * @param <T> Entity type extending BaseModel
 */
public abstract class AbstractDAO<T extends BaseModel> implements CrudDAO<T> {
    protected final Logger logger = Logger.getLogger(getClass().getName());
    protected final DatabaseConnection db = DatabaseConnection.getInstance();

    /**
     * Template Hook: Returns the SQL database table name.
     */
    protected abstract String getTableName();

    /**
     * Template Hook: Maps a current ResultSet row into entity T.
     */
    protected abstract T mapRow(ResultSet rs) throws SQLException;

    protected Connection getConnection() throws SQLException {
        return db.getConnection();
    }

    @Override
    public Optional<T> findById(int id) {
        String sql = "SELECT * FROM " + getTableName() + " WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error in findById for table " + getTableName(), e);
        }
        return Optional.empty();
    }

    @Override
    public List<T> findAll() {
        List<T> list = new ArrayList<>();
        String sql = "SELECT * FROM " + getTableName() + " ORDER BY id DESC";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error in findAll for table " + getTableName(), e);
        }
        return list;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM " + getTableName() + " WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            boolean ok = stmt.executeUpdate() > 0;
            if (ok) {
                com.boatsafari.common.util.LiveFileLogger.logTableUpdate(getTableName(), "DELETE", id, "Record deleted from " + getTableName());
            }
            return ok;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error in delete for table " + getTableName(), e);
            return false;
        }
    }

    @Override
    public long count() {
        String sql = "SELECT COUNT(*) FROM " + getTableName();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error in count for table " + getTableName(), e);
        }
        return 0;
    }
}
