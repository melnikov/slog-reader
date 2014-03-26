package ru.gmi.domain;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * Purchase entity.
 * @author Andrey Polikanov
 *
 */
@Entity
@Table(name = "purchases")
public class Purchase {

    @Id  
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    private int id;
    
    @Column(name = "date")
    @Temporal(TemporalType.TIMESTAMP)
    private Date date = new Date();
    
    @Column(name = "book")
    private String deviceId;
    
    @OneToOne
    private Book book;
    
    public Purchase() {
        
    }
    
    public Purchase(String deviceId, Book book) {
        this.deviceId = deviceId;
        this.book = book;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public Book getBook() {
        return book;
    }

    public void setBook(Book book) {
        this.book = book;
    }
    
}
