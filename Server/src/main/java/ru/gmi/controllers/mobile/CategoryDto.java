package ru.gmi.controllers.mobile;

import java.util.ArrayList;
import java.util.List;

import org.codehaus.jackson.annotate.JsonProperty;

import ru.gmi.domain.Category;

/**
 * Data transfer object for book category.
 * @author Andrey Polikanov
 *
 */
public class CategoryDto {

    @JsonProperty("category_id")
    private int id;
    
    @JsonProperty("category_title")
    private String title;
    
    @JsonProperty("special")
    private boolean special;
    
    @JsonProperty("subcategories")
    private List<CategoryDto> subcategories = new ArrayList<CategoryDto>();
    
    public CategoryDto(Category category) {
        id      = category.getId();
        title   = category.getName();
    }

    public CategoryDto(Category category, List<Category> children) {
        id      = category.getId();
        title   = category.getName();
        for (Category child : children) {
            subcategories.add(new CategoryDto(child));
        }
    }
    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<CategoryDto> getSubcategories() {
        return subcategories;
    }

    public void setSubcategories(List<CategoryDto> subcategories) {
        this.subcategories = subcategories;
    }

    public boolean isSpecial() {
        return special;
    }

    public void setSpecial(boolean special) {
        this.special = special;
    }

}
