package ru.gmi.controllers.admin;

import org.springframework.web.multipart.MultipartFile;

/**
 * Data transfer object for book.
 * @author Andrey Polikanov
 *
 */
public class BookForm {
    
    private String id;

    private String name;
    
    private String authors;
    
    private String description;
    
    private String publisher;
    
    private int category;
    
    private int priceCategory;
    
    private int duration;
    
    private MultipartFile file;
    
    private MultipartFile demo;
    
    private MultipartFile cover;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAuthors() {
        return authors;
    }

    public void setAuthors(String authors) {
        this.authors = authors;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public int getCategory() {
        return category;
    }

    public void setCategory(int category) {
        this.category = category;
    }

    public int getPriceCategory() {
        return priceCategory;
    }

    public void setPriceCategory(int priceCategory) {
        this.priceCategory = priceCategory;
    }

    public MultipartFile getFile() {
        return file;
    }

    public void setFile(MultipartFile file) {
        this.file = file;
    }

    public MultipartFile getDemo() {
        return demo;
    }

    public void setDemo(MultipartFile demo) {
        this.demo = demo;
    }

    public MultipartFile getCover() {
        return cover;
    }

    public void setCover(MultipartFile cover) {
        this.cover = cover;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }
    
    @Override
    public String toString() {
        return String.format("[id=%s;name=%s;authors=%s;category=%d;priceCategory=%d]", 
                id, name, authors, category, priceCategory);
    }
}
