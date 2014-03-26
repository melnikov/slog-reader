package ru.gmi.service;

import java.io.IOException;
import java.util.List;

import ru.gmi.dao.GenericDAO;
import ru.gmi.domain.Book;
import ru.gmi.filters.BookFilter;
import ru.gmi.filters.FilterResult;

/**
 * Book service interface.
 * @author Andrey Polikanov
 *
 */
public interface BookService extends GenericDAO<Book> {

    FilterResult<Book> getBooks(BookFilter filter);

    void addBook(Book book, byte[] file, byte[] demo, byte[] cover) throws Exception;
    
    void updateBook(Book book, byte[] file, byte[] demo, byte[] cover) throws Exception;

    List<Book> getBookForCategory(Integer categoryId);

    List<Book> search(String keyword);
    
    byte[] getDecryptedBookFile(Book book) throws Exception;

    byte[] getBookFile(String uid) throws IOException;

    byte[] getDemoFile(String uid) throws IOException;

    byte[] getCoverFile(String uid) throws IOException;

    void addView(String uid);

    void deleteBook(Integer id);

    void deleteDemo(Integer id);
    
    boolean demoExists(Book book);

    void addPurchase(Integer bookId);
    
}
