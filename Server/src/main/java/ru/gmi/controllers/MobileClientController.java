package ru.gmi.controllers;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import ru.gmi.controllers.mobile.BookDto;
import ru.gmi.controllers.mobile.CategoryDto;
import ru.gmi.controllers.mobile.Error;
import ru.gmi.controllers.mobile.Response;
import ru.gmi.domain.Book;
import ru.gmi.domain.Category;
import ru.gmi.service.CategoryService;
import ru.gmi.service.BookService;
import ru.gmi.service.PriceService;
import ru.gmi.service.PurchaseService;
import ru.gmi.tools.Crypto;
import ru.gmi.tools.Str;

/**
 * Handles requests from mobile clients.
 * @author Andrey Polikanov
 *
 */
@Controller
@RequestMapping(value="/mobile")
public class MobileClientController {
    
    private static final Logger LOG = Logger.getLogger(MobileClientController.class);
    
    @Autowired
    private BookService bookService;
    
    @Autowired
    private CategoryService categoryService;
    
    @Autowired
    private PriceService priceService;
    
    @Autowired
    private PurchaseService purchaseService;
    
    private static final String SECRET_KEY_SAULT = "0ad20cec16fd9bf8eaa17020c030df04";
    private static final String AUTH_TOKEN_KEY   = "3e37c047ba2e113c";
    private static final String BIN_CONTENT_TYPE = "application/octet-stream";
    private static final String JPG_CONTENT_TYPE = "image/jpeg";
    
    /**
     * 
     * @param token
     * @return
     */
    private boolean checkToken(String token) {
        try {
            Crypto.aesDecrypt(token, AUTH_TOKEN_KEY);
        } catch (Exception e) {
            return false;
        }
        return true;        
    }
    
    private String getToken(String deviceId) {
        String token = null;
        try {
            token = Crypto.aesEncrypt(deviceId, AUTH_TOKEN_KEY);
        } catch (Exception e) {
            LOG.error("Cannot get token", e);
        }
        return token;
    }
    
    private String getDeviceId(String token) {
        String deviceId = null;
        try {
            deviceId = Crypto.aesDecrypt(token, AUTH_TOKEN_KEY);
        } catch (Exception e) {
            LOG.error("Cannot get device id", e);
        }
        return deviceId;
    }
    
    @RequestMapping(value = "/{method}")
    public @ResponseBody Response errorHandler(@PathVariable String method) {
        Response response = new Response(method);
        response.setCode(Error.BAD_PARAMETERS);
        response.setData("Bad request");
        return response;
    }
    
    @RequestMapping(value = "/authorization")
    public @ResponseBody Response authorization(
            @RequestParam("device_id") String deviceId,
            @RequestParam("secret_key") String secretKey)  {
        
        LOG.info(String.format("authorization(deviceId=%s, secretKey=%s)", 
                deviceId, secretKey));
        Response response = new Response("authorization");
        if (!checkSecretKey(deviceId, secretKey)) {
            response.setCode(Error.AUTHORIZATION_FAILED);
            response.setText("Bad secret key");
        } else {
            String token = getToken(deviceId);
            response.setData(token);
        }
        return response;
    }
    
    private boolean checkSecretKey(String deviceId, String secretKey) {
        String trueSecretKey = Str.md5(deviceId + SECRET_KEY_SAULT);
        return trueSecretKey.equals(secretKey);
    }
    
    @RequestMapping(value = "/get_categories")
    public @ResponseBody Response getCategories(@RequestParam String token) {
        LOG.info(String.format("getCategories(token=%s)", token));
        Response response = new Response("get_categories");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            List<CategoryDto> dtos = new ArrayList<CategoryDto>();
            List<Category> genres = categoryService.getGenres();
            List<Category> specials = categoryService.getSpecialCategories();
            
            for (Category genre : genres) {
                dtos.add(new CategoryDto(
                        genre, categoryService.getSubCategories(genre.getId())));
            }
            for (Category spec : specials) {
                CategoryDto specDto = new CategoryDto(spec);
                specDto.setSpecial(true);
                dtos.add(specDto);
            }
            response.setData(dtos);
        } catch (Throwable t) {
            LOG.error("Cannot get categories", t);
            response.setCode(Error.INTERNAL_SERVER_ERROR);
        }
        
        return response;
    }
    
    @RequestMapping(value = "/get_books_for_category")
    public @ResponseBody Response getBooksForCategory(
            @RequestParam String token,
            @RequestParam("category_id") Integer categoryId,
            HttpServletRequest request) {
        
        LOG.info(String.format("getBooksForCategory(%s, %d)", token, categoryId));
        Response response = new Response("get_books_for_category");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            List<Book> books = bookService.getBookForCategory(categoryId);
            response.setData(createDtos(books, buildBaseUrl(request), getDeviceId(token)));
        } catch (Throwable t) {
            LOG.error("Cannot get books for category", t);
            response.setCode(Error.INTERNAL_SERVER_ERROR);
        }
        return response;
    }
    
    private String buildBaseUrl(HttpServletRequest request) {
        String context = request.getContextPath() + "/mobile";
        String url = request.getRequestURL().toString();
        int pos = url.indexOf(context);
        return url.substring(0, pos + context.length());
    }
    
    private String buildBookUrl(String baseUrl, String uid) {
        return baseUrl + "/books/" + uid;
    }
    
    private String buildDemoUrl(String baseUrl, String uid) {
        return baseUrl + "/demos/" + uid;
    }
    
    private String buildCoverUrl(String baseUrl, String uid) {
        return baseUrl + "/covers/" + uid;
    }
    
    @RequestMapping(value = "/find_books")
    public @ResponseBody Response findBooks(
            @RequestParam String token,
            @RequestParam("key_words") String keywords,
            HttpServletRequest request) {
        
        LOG.info(String.format("findBooks(token=%s, keywords=%s)", 
                token, keywords));
        Response response = new Response("find_books");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            List<Book> books = bookService.search(keywords);
            response.setData(createDtos(books, buildBaseUrl(request), getDeviceId(token)));
        } catch (Throwable t) {
            LOG.error("Cannot perform search", t);
            response.setCode(Error.INTERNAL_SERVER_ERROR);
        }
        return response;
    }
    
    private List<BookDto> createDtos(List<Book> books, String baseUrl, String deviceId) {
        List<BookDto> dtos = new ArrayList<BookDto>();
        List<Book> purchased = purchaseService.getUserBooks(deviceId);
        List<Integer> saled = new ArrayList<Integer>();
        for (Book book : purchased) {
            saled.add(book.getId());
        }
        for (Book book : books) {
            BookDto dto = new BookDto(book);
            dto.setCoverUrl(buildCoverUrl(baseUrl, book.getUid()));
            dto.setFragmentUrl(buildDemoUrl(baseUrl, book.getUid()));
            if (saled.contains(dto.getId())) {
                dto.setSaled(true);
            }
            dtos.add(dto);
        }
        if (LOG.isInfoEnabled()) {
            StringBuilder str = new StringBuilder();
            for (Integer sale : saled) {
                str.append(sale).append(";");
            }
            LOG.info("Saled books: " + str.toString());
        }
        return dtos;
    }

    @RequestMapping(value = "/get_product_id")
    public @ResponseBody Response getPrice(
            @RequestParam String token,
            @RequestParam("book_id") Integer bookId) {
        
        LOG.info(String.format("getPrice(token=%s, bookId=%d)",
                token, bookId));
        Response response = new Response("get_product_id");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            Book book = bookService.getById(bookId);
            response.setData(book.getPrice().getName());
        } catch (Throwable t) {
            LOG.error("Cannot get product id", t);
            response.setCode(Error.BOOK_NOT_FOUND);
        }
        return response;
    }
    
    @RequestMapping(value = "/get_book_url")
    public @ResponseBody Response getBookUrl(
            @RequestParam String token,
            @RequestParam("book_id") Integer bookId,
            HttpServletRequest request) {
        
        LOG.info(String.format("getBookUrl(token=%s, bookId=%d)",
                token, bookId));
        Response response = new Response("get_book_url");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            Book book = bookService.getById(bookId);
            String url = buildBookUrl(buildBaseUrl(request), book.getUid());
            response.setData(url);
        } catch (Throwable t) {
            LOG.error("Cannot get book url", t);
            response.setCode(Error.BOOK_NOT_FOUND);
        }
        return response;
    }
    
    private Response authorizationFailed(Response response) {
        response.setCode(Error.AUTHORIZATION_FAILED);
        response.setText("Authorization request expected");
        return response;
    }
    
    @RequestMapping(value = "/get_purchased_books")
    public @ResponseBody Response getPurchasedBooks(@RequestParam String token,
            HttpServletRequest request) {
        
        LOG.info(String.format("get_purchased_books(token=%s)", token));
        Response response = new Response("get_purchased_books");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            String deviceId = getDeviceId(token);
            List<Book> books = purchaseService.getUserBooks(deviceId);
            response.setData(createDtos(books, buildBaseUrl(request), deviceId));
        } catch (Throwable t) {
            LOG.error("Cannot get purchased books", t);
            response.setCode(Error.INTERNAL_SERVER_ERROR);
        }
        return response;
    }
    
    @RequestMapping(value = "/add_purchase", method = RequestMethod.POST)
    public @ResponseBody Response addPurchase(
            @RequestParam String token,
            @RequestParam("receiptdata") String receiptData,
            @RequestParam("book_id") Integer bookId) {
        
        LOG.info(String.format("addPurchase(token=%s, receiptData=%s, bookId=%s)",
                token, receiptData, bookId.toString()));
        
        Response response = new Response("add_purchase");
        if (!checkToken(token)) {
            return authorizationFailed(response);
        }
        try {
            String deviceId = getDeviceId(token);
            Book book = bookService.getById(bookId);
            if (book == null) {
                response.setCode(Error.BOOK_NOT_FOUND);
            } else {
                purchaseService.addPurchase(deviceId, book, receiptData);
                bookService.addPurchase(bookId);
            }
        } catch (IllegalArgumentException e) {
            response.setCode(Error.INTERNAL_SERVER_ERROR);
            response.setText(e.getMessage());
        } catch (Throwable t) {
            LOG.error("Cannot get purchased books", t);
            response.setCode(Error.INTERNAL_SERVER_ERROR);
        }
        return response;
    }
    
    @RequestMapping(value = "/books/{uid}", method = RequestMethod.GET)
    public void getBookFile(@PathVariable String uid, HttpServletResponse response) {
        LOG.info(String.format("getBookFile(uid=%s)", uid));
        try {
            response.setContentType(BIN_CONTENT_TYPE);
            writeBinaryData(response, bookService.getBookFile(uid));
        } catch (Throwable t) {
            LOG.error("Cannot get book file", t);
        }
    }
    
    @RequestMapping(value = "/demos/{uid}", method = RequestMethod.GET)
    public void getDemoFile(@PathVariable String uid, HttpServletResponse response) {
        LOG.info(String.format("getDemoFile(uid=%s)", uid));
        try {
            response.setContentType(BIN_CONTENT_TYPE);
            writeBinaryData(response, bookService.getDemoFile(uid));
            bookService.addView(uid);
        } catch (Throwable t) {
            LOG.error("Cannot get demo file", t);
        }
    }
    
    @RequestMapping(value = "/covers/{uid}", method = RequestMethod.GET)
    public void getCoverFile(@PathVariable String uid, HttpServletResponse response) {
        LOG.info(String.format("getCoverFile(uid=%s)", uid));
        try {
            response.setContentType(JPG_CONTENT_TYPE);
            writeBinaryData(response, bookService.getCoverFile(uid));
        } catch (Throwable t) {
            LOG.error("Cannot get cover file", t);
        }
    }
    
    private void writeBinaryData(HttpServletResponse response, byte[] data) {
        try {
            ServletOutputStream out = response.getOutputStream();
            out.write(data);  
            out.close(); 
        } catch (IOException e) {
            LOG.error("Cannot send file", e);
        }
    }
}
