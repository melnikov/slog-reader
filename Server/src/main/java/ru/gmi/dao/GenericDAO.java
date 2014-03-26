package ru.gmi.dao;

import java.util.List;

/**
 * Generic data access object interface.
 * @author Andrey Polikanov
 *
 * @param <T> - type to work with.
 */
public interface GenericDAO<T> {
    
    T save(T t);

    T getById(int id);
    
    void delete(int id);
    
    T update(T t);

    List<T> getAll();
}
