package ru.gmi.domain;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.codehaus.jackson.annotate.JsonProperty;

/**
 * Book category entity.
 * @author Andrey Polikanov
 *
 */
@Entity
@Table(name = "categories")
public class Category {

    @Id  
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    @JsonProperty("category_id")
    private int id;
    
    @OneToOne
    @JsonIgnore
    private Category parent;
    
    @Column(name = "name")
    @JsonProperty("category_title")
    private String name;
    
    @Column(name = "special")
    @JsonProperty("special")
    private boolean special;
    
    public Category() {
        
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Category getParent() {
        return parent;
    }

    public void setParent(Category parent) {
        this.parent = parent;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isSpecial() {
        return special;
    }

    public void setSpecial(boolean special) {
        this.special = special;
    }

}
