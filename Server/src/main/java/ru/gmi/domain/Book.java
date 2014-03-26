package ru.gmi.domain;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;

/**
 * Book entity.
 * @author Andrey Polikanov
 *
 */
@Entity
@Table(name = "books")
public class Book {
    
    @Id  
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    private int id;
    
    private String uid;
    
    @Column(name = "name")
    private String name;
    
    @Column(name = "authors")
    private String authors;

    @Column(name = "duration")
    private int duration;

    @OneToOne
    private Category category;
    
    @Column(name = "publisher")
    private String publisher;

    @OneToOne
    private Price price;
    
    @Column(name = "description", length = 10240)
    private String description;
    
    @Column(name = "views")
    private int views;
    
    @Column(name = "purchases")
    private int purchases;
    
    public Book() {
        
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

    public String getAuthors() {
        return authors;
    }

    public void setAuthors(String authors) {
        this.authors = authors;
    }

    public Category getCategory() {
        return category;
    }

    public void setCategory(Category category) {
        this.category = category;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public Price getPrice() {
        return price;
    }

    public void setPrice(Price price) {
        this.price = price;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public int getViews() {
        return views;
    }

    public void setViews(int views) {
        this.views = views;
    }

    public int getPurchases() {
        return purchases;
    }

    public void setPurchases(int purchases) {
        this.purchases = purchases;
    }
    
}
