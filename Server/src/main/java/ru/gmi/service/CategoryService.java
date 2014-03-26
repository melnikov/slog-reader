package ru.gmi.service;

import java.util.List;

import ru.gmi.dao.GenericDAO;
import ru.gmi.domain.Category;

/**
 * Category service interface.
 * @author Andrey Polikanov
 *
 */
public interface CategoryService extends GenericDAO<Category> {

    List<Category> getGenres();
    
    List<Category> getSubCategories(int parentId);

    List<Category> getSpecialCategories();
    
}
