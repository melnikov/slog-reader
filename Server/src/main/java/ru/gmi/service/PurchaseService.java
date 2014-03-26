package ru.gmi.service;

import java.util.List;

import ru.gmi.dao.GenericDAO;
import ru.gmi.domain.Book;
import ru.gmi.domain.Purchase;

/**
 * Purchase service interface.
 * @author user
 *
 */
public interface PurchaseService extends GenericDAO<Purchase> {

    List<Book> getUserBooks(String deviceId);

    void addPurchase(String deviceId, Book book, String receiptData);
    
    void removeBookPurchases(int bookId);

}
