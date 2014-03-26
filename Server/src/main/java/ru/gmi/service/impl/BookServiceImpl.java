package ru.gmi.service.impl;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import ru.gmi.Config;
import ru.gmi.dao.impl.GenericDAOImpl;
import ru.gmi.domain.Book;
import ru.gmi.domain.Category;
import ru.gmi.domain.Price;
import ru.gmi.filters.BookFilter;
import ru.gmi.filters.FilterResult;
import ru.gmi.service.BookService;
import ru.gmi.tools.Crypto;
import ru.gmi.tools.IO;
import ru.gmi.tools.Str;

/**
 * Book service implementation.
 * @author Andrey Polikanov
 *
 */
@Service
@Repository
public class BookServiceImpl extends GenericDAOImpl<Book> 
        implements BookService {
    
    private static final Logger LOG = Logger.getLogger(BookServiceImpl.class);
            
    private final Config CONFIG = Config.getInstance();
    
    private final static int BOOK_UID_LENGTH = 16;
    private final static String DEFAULT_BOOK_FILE_NAME = "book.fb2";
    private final static String DEFAULT_DEMO_FILE_NAME = "book.demo.fb2";

    @Override
    public FilterResult<Book> getBooks(BookFilter filter) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Book> selectQuery = cb.createQuery(Book.class);
        Root<Book> book = selectQuery.from(Book.class);
        
        List<Predicate> predicates = new ArrayList<Predicate>();
        
        Path<Category> category = book.get("category");
        if (!filter.getCategory().isEmpty()) {
            predicates.add(cb.like(cb.lower(category.<String>get("name")), 
                    "%" + filter.getCategory().toLowerCase() + "%"));
        }
        
        if (!filter.getName().isEmpty()) {
            predicates.add(cb.like(cb.lower(book.<String>get("name")), 
                    "%" + filter.getName().toLowerCase() + "%"));
        }
        
        if (!filter.getAuthor().isEmpty()) {
            predicates.add(cb.like(cb.lower(book.<String>get("authors")), 
                    "%" + filter.getAuthor().toLowerCase() + "%"));
        }

        if (!filter.getPublisher().isEmpty()) {
            predicates.add(cb.like(cb.lower(book.<String>get("publisher")), 
                    "%" + filter.getPublisher().toLowerCase() + "%"));
        }

        Path<Price> price = book.get("price");
        if (!filter.getPrice().isEmpty()) {
            predicates.add(cb.like(cb.lower(price.<String>get("name")), 
                    "%" + filter.getPrice().toLowerCase() + "%"));
        }
        
        if (filter.getViews() != null) {
            predicates.add(cb.ge(book.<Integer>get("views"), filter.getViews()));
        }
        
        if (filter.getPurchases() != null) {
            predicates.add(cb.ge(book.<Integer>get("purchases"), filter.getPurchases()));
        }

        CriteriaQuery<Long> countQuery = cb.createQuery(Long.class);
        countQuery.select(cb.count(countQuery.from(Book.class)));
        Long unfilteredNumber = em.createQuery(countQuery).getSingleResult();
        if (!predicates.isEmpty()) {
            Predicate[] p = predicates.toArray(new Predicate[0]);
            Predicate all = cb.and(p); 
            selectQuery.where(all);
            countQuery.where(all);
        }
        
        Map<Integer, Path<Object>> map = new HashMap<Integer, Path<Object>>();
        map.put(BookFilter.SORT_BY_NUMBER,      book.get("id"));
        map.put(BookFilter.SORT_BY_NAME,        book.get("name"));
        map.put(BookFilter.SORT_BY_AUTHORS,     book.get("authors"));
        map.put(BookFilter.SORT_BY_CATEGORY,    category.get("name"));
        map.put(BookFilter.SORT_BY_PUBLISHER,   book.get("publisher"));
        map.put(BookFilter.SORT_BY_PRICE,       price.get("name"));
        map.put(BookFilter.SORT_BY_VIEWS,       book.get("views"));
        map.put(BookFilter.SORT_BY_PURCHASES,   book.get("purchases"));
        map.put(BookFilter.SORT_BY_ID,          book.get("id"));
        
        Path<Object> sortByField = map.get(filter.getSortBy());
        
        if (filter.getSortDirection() == BookFilter.SORT_ASC) {
            selectQuery.orderBy(cb.asc(sortByField));
        } else {
            selectQuery.orderBy(cb.desc(sortByField));
        }
        
        TypedQuery<Book> typedQuery = em.createQuery(selectQuery);
        typedQuery.setFirstResult(filter.getStartNumber());
        typedQuery.setMaxResults(filter.getMaxCount());
        List<Book> books = typedQuery.getResultList();

        Long filteredNumber = em.createQuery(countQuery).getSingleResult();
        
        FilterResult<Book> result = new FilterResult<Book>();
        result.setResultList(books);
        result.setFilteredNumber(filteredNumber.intValue());
        result.setUnfilteredNumber(unfilteredNumber.intValue());
        
        return result;
    }

    @Override
    public void addBook(Book book, byte[] file, byte[] demo, byte[] cover)
            throws Exception {
        
        String uid = Str.generateUid(BOOK_UID_LENGTH);
        book.setUid(uid);
        String dirPath = buildBookDirectoryPath(uid);
        File dir = new File(dirPath);
        
        if (!dir.exists()) {
            if (!dir.mkdirs()) {
                throw new IOException("Cannot create directory: " + dirPath);
            }
        }
        
        book = save(book);
        
        writeBookFile(book, file);
        writeDemoFile(book, demo);
        writeCoverFile(book, cover);
    }
    
    private void writeBookFile(Book book, byte[] data) throws Exception {
        byte[] zipped = IO.zipSingleFile(data, DEFAULT_BOOK_FILE_NAME);
        String key = Str.md5(String.valueOf(book.getId())).substring(0, 16);
        byte[] encrypted = Crypto.aesEncrypt(zipped, key);
        String fileName = buildBookFilePath(book.getUid());
        IO.writeFile(fileName, encrypted);
    }
    
    private void writeDemoFile(Book book, byte[] data) throws IOException {
        byte[] zipped = IO.zipSingleFile(data, DEFAULT_DEMO_FILE_NAME);
        String fileName = buildDemoFilePath(book.getUid());
        IO.writeFile(fileName, zipped);
    }
    
    private void writeCoverFile(Book book, byte[] cover) throws IOException {
        cover = adjustCover(cover);
        IO.writeFile(buildCoverFilePath(book.getUid()), cover);
    }
    
    private byte[] adjustCover(byte[] imageData) throws IOException {
        ByteArrayInputStream in = new ByteArrayInputStream(imageData);
        BufferedImage original = ImageIO.read(in);
        
        if (original.getWidth() > CONFIG.getMaxCoverWidth()) {
            // Image scaling.
            int height = CONFIG.getMaxCoverWidth() * original.getHeight() 
                    / original.getWidth();
            Image scaled = original.getScaledInstance(CONFIG.getMaxCoverWidth(), 
                    height, Image.SCALE_SMOOTH);
            BufferedImage scaledBuff = new BufferedImage(
                    CONFIG.getMaxCoverWidth(), height, BufferedImage.TYPE_INT_RGB);
            Graphics graphics = scaledBuff.createGraphics();
            graphics.drawImage(scaled, 0, 0, new Color(0, 0, 0), null);
            graphics.dispose();
            // Getting image bytes.
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ImageIO.write(scaledBuff, "JPG", out);
            return out.toByteArray();
        }
        return imageData; // Original image doesn't need to be scaled.
    }
    
    private String buildBookDirectoryPath(String uid) {
        return CONFIG.getBooksDirectory()  
                + uid.charAt(0) + File.separator 
                + uid.charAt(1) + File.separator;
    }
    
    private String buildBookFilePath(String uid) {
        return buildBookDirectoryPath(uid) + uid + ".zip";
    }
    
    private String buildDemoFilePath(String uid) {
        return buildBookDirectoryPath(uid) + uid + ".demo.zip";
    }    
    
    private String buildCoverFilePath(String uid) {
        return buildBookDirectoryPath(uid) + uid + ".jpg";
    }
    
    @Override
    public List<Book> getBookForCategory(Integer categoryId) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Book> query = cb.createQuery(Book.class);
        Root<Book> book = query.from(Book.class);
        Path<Category> category = book.get("category");
        Predicate pred = cb.equal(category.get("id"), categoryId);
        query.where(pred);
        TypedQuery<Book> typedQuery = em.createQuery(query);
        List<Book> result = typedQuery.getResultList();
        return result;
    }

    @Override
    public List<Book> search(String keyword) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Book> query = cb.createQuery(Book.class);
        Root<Book> book = query.from(Book.class);
        Predicate namePred = cb.like(cb.lower(book.<String>get("name")),
                "%" + keyword.toLowerCase() + "%");
        Predicate authorPred = cb.like(cb.lower(book.<String>get("authors")), 
                "%" + keyword.toLowerCase() + "%");
        query.where(cb.or(namePred, authorPred));
        TypedQuery<Book> typedQuery = em.createQuery(query);
        List<Book> result = typedQuery.getResultList();
        return result;
    }
    
    public Book getByUid(String uid) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Book> query = cb.createQuery(Book.class);
        Root<Book> book = query.from(Book.class);
        Predicate pred = cb.equal(book.<String>get("uid"), uid);
        query.where(pred);
        TypedQuery<Book> typedQuery = em.createQuery(query);
        Book result = typedQuery.getSingleResult();
        return result;
    }

    @Override
    public byte[] getBookFile(String uid) throws IOException {
        return IO.readFile(buildBookFilePath(uid));
    }

    @Override
    public byte[] getDemoFile(String uid) throws IOException {
        return IO.readFile(buildDemoFilePath(uid));
    }

    @Override
    public byte[] getCoverFile(String uid) throws IOException {
        return IO.readFile(buildCoverFilePath(uid));
    }
    

    @Override
    public byte[] getDecryptedBookFile(Book book) throws Exception {
        byte[] data = IO.readFile(buildBookFilePath(book.getUid()));
        String key = Str.md5(String.valueOf(book.getId())).substring(0, 16);
        LOG.info(String.format("Decrypt book: id=%d, key=%s", book.getId(), key));
        byte[] decrypted = Crypto.aesDecrypt(data, key);
        return decrypted;
    }


    @Override
    public synchronized void addView(String uid) {
        try {
            Book book = getByUid(uid);
            book.setViews(book.getViews() + 1);
            update(book);
        } catch (Throwable t) {
            LOG.error("Cannot update views number", t);
        }
    }

    @Override
    public void deleteBook(Integer id) {
        Book book  = getById(id);
        File file  = new File(buildBookFilePath(book.getUid()));
        File demo  = new File(buildDemoFilePath(book.getUid()));
        File cover = new File(buildCoverFilePath(book.getUid()));
        file.delete();
        demo.delete();
        cover.delete();
        delete(id);
    }

    @Override
    public void updateBook(Book book, byte[] file, byte[] demo, byte[] cover)
            throws Exception {

        if (file.length > 0) {
            writeBookFile(book, file);
        }
        if (demo.length > 0) {
            writeDemoFile(book, demo);
        }
        if (cover.length > 0) {
            writeCoverFile(book, cover);
        }
        update(book);
    }

    @Override
    public void deleteDemo(Integer id) {
        Book book  = getById(id);
        File demo  = new File(buildDemoFilePath(book.getUid()));
        demo.delete();
    }

    @Override
    public boolean demoExists(Book book) {
        File demo  = new File(buildDemoFilePath(book.getUid()));
        return demo.exists();
    }

    @Override
    public synchronized void addPurchase(Integer bookId) {
        try {
            Book book = getById(bookId);
            book.setPurchases(book.getPurchases() + 1);
            update(book);
        } catch (Throwable t) {
            LOG.error("Cannot update purchase number", t);
        }
    }

}
