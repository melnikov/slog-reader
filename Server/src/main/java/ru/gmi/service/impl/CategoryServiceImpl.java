package ru.gmi.service.impl;

import java.util.List;

import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import ru.gmi.dao.impl.GenericDAOImpl;
import ru.gmi.domain.Category;
import ru.gmi.service.CategoryService;

/**
 * Category service implementation.
 * @author Andrey Polikanov
 *
 */
@Service
@Repository
public class CategoryServiceImpl extends GenericDAOImpl<Category> 
    implements CategoryService {

    @Override
    public List<Category> getGenres() {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Category> query = cb.createQuery(Category.class);
        Root<Category> category = query.from(Category.class);
        Predicate pred = cb.and(cb.isNull(category.get("parent")), 
                cb.equal(category.get("special"), false));
        query.where(pred);
        TypedQuery<Category> typedQuery = em.createQuery(query);
        List<Category> result = typedQuery.getResultList();
        return result;
    }

    @Override
    public List<Category> getSubCategories(int parentId) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Category> query = cb.createQuery(Category.class);
        Root<Category> category = query.from(Category.class);
        Path<Category> parentField = category.get("parent");
        
        Predicate pred = cb.equal(parentField.get("id"), parentId);
        
        query.where(pred);
        TypedQuery<Category> typedQuery = em.createQuery(query);
        List<Category> result = typedQuery.getResultList();
        return result;
    }

    @Override
    public List<Category> getSpecialCategories() {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Category> query = cb.createQuery(Category.class);
        Root<Category> category = query.from(Category.class);
        Predicate pred = cb.equal(category.get("special"), true);
        query.where(pred);
        TypedQuery<Category> typedQuery = em.createQuery(query);
        List<Category> result = typedQuery.getResultList();
        return result;
    }

}
