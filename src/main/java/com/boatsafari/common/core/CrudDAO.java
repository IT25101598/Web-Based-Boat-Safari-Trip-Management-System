package com.boatsafari.common.core;

import java.util.List;
import java.util.Optional;

/**
 * Generic CRUD DAO contract declaring standard data access operations.
 * Demonstrates Abstraction across all database operations.
 *
 * @param <T> Entity type extending BaseModel
 */
public interface CrudDAO<T extends BaseModel> {
    /**
     * Inserts a new entity and sets the generated ID.
     */
    T create(T entity);

    /**
     * Finds entity by primary key.
     */
    Optional<T> findById(int id);

    /**
     * Retrieves all non-deleted entities.
     */
    List<T> findAll();

    /**
     * Updates an existing entity record.
     */
    boolean update(T entity);

    /**
     * Performs a soft or hard delete of the entity.
     */
    boolean delete(int id);

    /**
     * Returns total count of active records.
     */
    long count();
}
