package ru.gmi.dao.impl;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.springframework.transaction.annotation.Transactional;

import ru.gmi.dao.GenericDAO;

/**
 * Generic data access object implementation.
 * @author Andrey Polikanov
 *
 * @param <T> - type to work with.
 */
@Transactional
public abstract class GenericDAOImpl<T> implements GenericDAO<T> {
    
    @PersistenceContext
    protected EntityManager em;
    
    private Class<T> type;
    
    @SuppressWarnings("unchecked")
    public GenericDAOImpl() {
        Type t = getClass().getGenericSuperclass();
        ParameterizedType pt = (ParameterizedType) t;
        type = (Class<T>) pt.getActualTypeArguments()[0];
    }
    
    @Override
    public T save(T t) {
        em.persist(t);
        return t;
    }

    @Override
    @Transactional(readOnly = true)
    public T getById(int id) {
        return (T) em.find(type, id);
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<T> getAll() {
        @SuppressWarnings("unchecked")
        List<T> result = em.createQuery("SELECT t FROM " + type.getName() + " t").getResultList(); 
        return result;
    }

    @Override
    public void delete(int id) {
        this.em.remove(em.getReference(type, id));
    }

    @Override
    public T update(T t) {
        return em.merge(t); 
    }

}
