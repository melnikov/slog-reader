package ru.gmi.service.impl;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import org.apache.log4j.Logger;
import org.codehaus.jackson.JsonFactory;
import org.codehaus.jackson.JsonGenerator;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

import ru.gmi.Config;
import ru.gmi.dao.impl.GenericDAOImpl;
import ru.gmi.domain.Book;
import ru.gmi.domain.Purchase;
import ru.gmi.service.PurchaseService;

/**
 * Purchase service implementation.
 * @author Andrey Polikanov
 *
 */
@Service
@Repository
public class PurchaseServiceImpl extends GenericDAOImpl<Purchase> 
    implements PurchaseService  {
    
    private static final Logger LOG = Logger.getLogger(PurchaseServiceImpl.class);
    
    private final Config CONFIG = Config.getInstance();

    @Override
    public List<Book> getUserBooks(String deviceId) {
        CriteriaBuilder cb = em.getCriteriaBuilder();
        CriteriaQuery<Purchase> query = cb.createQuery(Purchase.class);
        Root<Purchase> purchase = query.from(Purchase.class);
        Predicate pred = cb.equal(purchase.get("deviceId"), deviceId);
        query.where(pred);
        TypedQuery<Purchase> typedQuery = em.createQuery(query);
        List<Purchase> purchases = typedQuery.getResultList();
        
        List<Book> result = new ArrayList<Book>();
        for (Purchase p : purchases) {
            result.add(p.getBook());
        }
        
        return result;
    }

    @Override
    public void addPurchase(String deviceId, Book book, String receiptData) {
        
        if (CONFIG.isCheckPurchases()) {
            int code = verifyReceipt(receiptData); 
            if (code != 0) {
                throw new IllegalArgumentException("Cannot verify receipt. Return code " + code);
            }
        }
        
        Purchase purchase = new Purchase(deviceId, book);
        save(purchase);
    }
    
    private int verifyReceipt(String receiptData) {
        try {
            URL url = new URL(CONFIG.getVerifyReceiptUrl());
            URLConnection conn = url.openConnection();
            conn.setDoInput(true);
            conn.setDoOutput(true);
            
            JsonFactory factory = new JsonFactory();
            JsonGenerator generator = factory.createJsonGenerator(
                    new OutputStreamWriter(conn.getOutputStream(), "UTF-8"));
            generator.writeStartObject();
            generator.writeStringField("receipt-data", receiptData);
            generator.writeEndObject();
            generator.close();
            
            ObjectMapper mapper = new ObjectMapper();
            VerifyReceiptResponse response = 
                    mapper.readValue(conn.getInputStream(), VerifyReceiptResponse.class);
            return response.getStatus();
        } catch (MalformedURLException e) { 
            LOG.error("Bad verify receipt URL", e);
        } catch (JsonMappingException e) {
            LOG.error("Cannot map JSON", e);
        } catch (JsonParseException e) {
            LOG.error("Cannot parse JSON", e);
        } catch (IOException e) {
            LOG.error("Cannot veriry receipt", e);
        }
        
        return -1;
    }
    
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class VerifyReceiptResponse {
        
        private int status;
        
        private String exception;
        
        public int getStatus() {
            return this.status;
        }
        
        public void setStatus(int status) {
            this.status = status;
        }

        public String getException() {
            return exception;
        }

        public void setException(String exception) {
            this.exception = exception;
        }
        
        
    }

    @Override
    public void removeBookPurchases(int bookId) {
        Query query = em.createQuery("delete from Purchase p where p.book.id = :id");
        query.setParameter("id", bookId);
        query.executeUpdate();
    }

}
