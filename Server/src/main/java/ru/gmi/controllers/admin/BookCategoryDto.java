package ru.gmi.controllers.admin;

/**
 * Data transfer object for book category.
 * @author Andrey Polikanov
 *
 */
public class BookCategoryDto {
    
    private int id;
    
    private String name;
    
    public BookCategoryDto() {
        
    }
    
    public BookCategoryDto(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    
}
