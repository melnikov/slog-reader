package ru.gmi.controllers;
 
import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.codehaus.jackson.JsonFactory;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.JsonGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.CannotCreateTransactionException;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import ru.gmi.controllers.admin.BookCategoryDto;
import ru.gmi.controllers.admin.BookForm;
import ru.gmi.controllers.admin.JQueryDataTableResponse;
import ru.gmi.domain.Book;
import ru.gmi.domain.Category;
import ru.gmi.domain.Price;
import ru.gmi.filters.BookFilter;
import ru.gmi.filters.FilterResult;
import ru.gmi.service.CategoryService;
import ru.gmi.service.BookService;
import ru.gmi.service.PriceService;
import ru.gmi.service.PurchaseService;

/**
 * Handles requests from administrator panel web interface.
 * @author Andrey Polikanov
 *
 */
@Controller
@RequestMapping(value="/admin")
public class AdminController {
    
    private static final Logger LOG = Logger.getLogger(AdminController.class);
    
    private static final String AJAX_SUCCESS    = "success";
    
    private static ResourceBundle messages;
    
    static {
        Locale locale = new Locale("ru", "RU");
        messages = ResourceBundle.getBundle("MessagesBundle", locale);
    }
    
    @Autowired
    BookService bookService;
    
    @Autowired
    CategoryService categoryService;
    
    @Autowired
    PriceService priceService;
    
    @Autowired
    private PurchaseService purchaseService;
    
    @RequestMapping(value = "/**")
    public String redirect() {
        return "redirect:/admin/books";
    }
 
    @RequestMapping(value="/login", method = RequestMethod.GET)
    public String login(ModelMap model) {
        return "admin/login";
    }
 
    @RequestMapping(value = "/books", method = RequestMethod.GET)
    public String books() {
        return "admin/books";
    }
    
    /**
     * jQuery DataTables plugin data accessor.
     * @param sEcho Integer value that is used by DataTables for 
     * synchronization purposes. Response from the server-side code should 
     * return the same value to the plug-in.
     * @param sKeyword Text entered in the filter text box and it should be 
     * used for filtering records.
     * @param iDisplayStart First record that should be shown 
     * (used for pagination).
     * @param iDisplayLength The number of records that should be returned 
     * (this value is equal to the value selected in the 
     * 'Show XXX items per page' dropdown). 
     * This value is also used for pagination.
     * @param filterByDate 
     * @param filterByUser
     * @return JSON response which contains video table data
     */
    @RequestMapping(value = "/books/data_source", method = RequestMethod.GET) 
    public @ResponseBody JQueryDataTableResponse getBooks(
            @RequestParam String sEcho,
            @RequestParam(value = "iDisplayStart") Integer startNumber, 
            @RequestParam(value = "iDisplayLength") Integer maxCount, 
            @RequestParam(value = "iSortCol_0") Integer sortByColumn,
            @RequestParam(value = "sSearch_0", required = false) String filterByName,
            @RequestParam(value = "sSearch_1", required = false) String filterByAuthor,
            @RequestParam(value = "sSearch_2", required = false) String filterByCategory,
            @RequestParam(value = "sSearch_3", required = false) String filterByPublisher,
            @RequestParam(value = "sSearch_4", required = false) String filterByPrice,
            @RequestParam(value = "sSearch_5", required = false) Integer filterByViews,
            @RequestParam(value = "sSearch_6", required = false) Integer filterByPurchases,
            @RequestParam(value = "sSortDir_0") String sortDirection,
            HttpServletRequest request) {
        
        
        JQueryDataTableResponse response = new JQueryDataTableResponse();
        response.setsEcho(sEcho);
        
        try {
            BookFilter filter = new BookFilter();
            filter.setStartNumber(startNumber);
            filter.setMaxCount(maxCount);
            filter.setName(filterByName);
            filter.setAuthor(filterByAuthor);
            filter.setCategory(filterByCategory);
            filter.setPublisher(filterByPublisher);
            filter.setPrice(filterByPrice);
            filter.setViews(filterByViews);
            filter.setPurchases(filterByPurchases);
            filter.setSortBy(sortByColumn);
            filter.setSortDirection(sortDirection.equals("asc") ? BookFilter.SORT_ASC : BookFilter.SORT_DESC);
            
            FilterResult<Book> filterResult = bookService.getBooks(filter);
            
            //
            // Prepare response.
            //
            response.setiTotalRecords(filterResult.getUnfilteredNumber());
            response.setiTotalDisplayRecords(filterResult.getFilteredNumber());
            
            for (int i = 0; i < filterResult.getResultList().size(); i++) {
                Book book = filterResult.getResultList().get(i);
                response.addData(
                        String.valueOf(startNumber + i + 1), 
                        book.getName(),
                        book.getAuthors(),
                        book.getCategory().getName(),
                        book.getPublisher(),
                        book.getPrice().getName(),
                        String.valueOf(book.getViews()),
                        String.valueOf(book.getPurchases()),
                        String.valueOf(book.getId()));
            }
        } catch (Throwable t) {
            LOG.error("Cannot get books", t);
        }
        
        return response;
    }

    
    @RequestMapping(value = "/new_book", method = RequestMethod.GET)
    public String newBook(ModelMap model) {
        List<Price> categories = priceService.getAll();
        model.addAttribute("priceCategories", categories);
        return "admin/new_book";
    }
    
    @RequestMapping(value = "/new_book", method = RequestMethod.POST)
    public String newBook(@ModelAttribute("book") BookForm bookForm) {
        LOG.info(String.format("newBook(bookForm=%s)", bookForm.toString()));
        try {
            Book book = new Book();
            book.setName(bookForm.getName());
            book.setDescription(bookForm.getDescription());
            book.setPublisher(bookForm.getPublisher());
            book.setAuthors(bookForm.getAuthors());
            book.setCategory(categoryService.getById(bookForm.getCategory()));
            book.setPrice(priceService.getById(bookForm.getPriceCategory()));
            book.setDuration(bookForm.getDuration());
            bookService.addBook(book, 
                    bookForm.getFile().getBytes(),
                    bookForm.getDemo().getBytes(),
                    bookForm.getCover().getBytes());
        } catch (Throwable t) {
            LOG.error("Cannot add book", t);
        }
        
        return "redirect:/admin/books";
    }
    
    @RequestMapping(value = "/edit_book", method = RequestMethod.GET)
    public String editBook(@RequestParam Integer id, ModelMap model) {
        List<Price> categories = priceService.getAll();
        model.addAttribute("priceCategories", categories);
        Book book = bookService.getById(id);
        model.addAttribute("book", book);
        model.addAttribute("demoExists", bookService.demoExists(book));
        return "admin/new_book";
    }

    @RequestMapping(value = "/edit_book", method = RequestMethod.POST)
    public String editBook(@ModelAttribute("book") BookForm bookForm, ModelMap model) {
        LOG.info(String.format("editBook(bookForm=%s)", bookForm.toString()));
        try {
            Book book = bookService.getById(Integer.valueOf(bookForm.getId()));
            book.setName(bookForm.getName());
            book.setDescription(bookForm.getDescription());
            book.setPublisher(bookForm.getPublisher());
            book.setAuthors(bookForm.getAuthors());
            book.setCategory(categoryService.getById(bookForm.getCategory()));
            book.setPrice(priceService.getById(bookForm.getPriceCategory()));
            book.setDuration(bookForm.getDuration());
            bookService.updateBook(book, 
                    bookForm.getFile().getBytes(),
                    bookForm.getDemo().getBytes(),
                    bookForm.getCover().getBytes());
        } catch (Throwable t) {
            LOG.error("Cannot edit book", t);
        }

        return "redirect:/admin/books";
    }

    
    @RequestMapping(value = "/books/genres", method = RequestMethod.GET)
    public @ResponseBody List<BookCategoryDto> getGenres() {
        List<Category> genres = categoryService.getGenres();
        List<BookCategoryDto> result = new ArrayList<BookCategoryDto>();
        for (Category genre : genres) {
            result.add(new BookCategoryDto(genre.getId(), genre.getName()));
        }
        return result;
    }
    
    @RequestMapping(value = "/books/genres/{id}", method = RequestMethod.GET)
    public @ResponseBody List<BookCategoryDto> getCategories(@PathVariable String id) {
        LOG.info(String.format("getCategories(id=%s)", id));
        List<Category> categories = null;
        if (id.equals("none")) {
            categories = categoryService.getSpecialCategories();
        } else {
            categories = categoryService.getSubCategories(Integer.valueOf(id));
        }
       
        List<BookCategoryDto> result = new ArrayList<BookCategoryDto>();
        for (Category category : categories) {
            result.add(new BookCategoryDto(category.getId(), category.getName()));
        }
        
        return result;
    }
    
    @RequestMapping(value = "/books/{id}", method = RequestMethod.DELETE)
    public @ResponseBody String deleteBook(@PathVariable Integer id) {
        LOG.info(String.format("deleteBook(id=%d)", id));
        purchaseService.removeBookPurchases(id);
        bookService.deleteBook(id);
        return AJAX_SUCCESS;
    }
    
    @RequestMapping(value = "/categories", method = RequestMethod.GET)
    public String bookCategories(ModelMap model) {
        LOG.info("bookCategories()");
        List<Category> genres = categoryService.getGenres();
        model.addAttribute("genres", genres);        
        return "admin/categories";
    }
    
    @RequestMapping(value = "/categories/{id}/", method = RequestMethod.GET)
    public void getSubCategories(HttpServletResponse response,
            @PathVariable String id) 
            throws JsonGenerationException, IOException {
        
        LOG.info(String.format("getSubCategories(id=%s)", id));
        
        List<Category> categories = null;
        if (id.equals("none")) {
            categories = categoryService.getSpecialCategories();
        } else {
            categories = categoryService.getSubCategories(
                    Integer.valueOf(id));
        }
        
        StringWriter out = new StringWriter();
        JsonGenerator gen = new JsonFactory().createJsonGenerator(out);
        gen.writeStartArray();
        for (Category category : categories) {
            gen.writeStartObject();
            gen.writeNumberField("id", category.getId());
            gen.writeStringField("name", category.getName());
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.close();
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.getOutputStream().write(out.toString().getBytes("UTF-8"));
    }
    
    @RequestMapping(value = "/categories/{id}", method = RequestMethod.POST)
    public @ResponseBody BookCategoryDto editCategory(
            @PathVariable String id,
            @RequestParam String name,
            @RequestParam(required = false) String parentId) {
        
        LOG.info(String.format("editCategory(id=%s, name=%s, parentId=%s)", 
                id, name, parentId));
        
        BookCategoryDto categoryDto = new BookCategoryDto();
        if (id.equals("new")) {
            Category category = new Category();
            category.setName(name);
            categoryDto.setName(name);
            if (parentId != null) {
                if (parentId.equals("none")) {
                    category.setSpecial(true);
                } else {
                    Category parent = categoryService.getById(
                            Integer.valueOf(parentId));
                    category.setParent(parent);
                }
            }
            category = categoryService.save(category);
            categoryDto.setId(category.getId());
        } else if (!id.isEmpty()) {
            Category category = categoryService.getById(Integer.valueOf(id));
            category.setName(name);
            categoryDto.setId(category.getId());
            categoryDto.setName(name);
            categoryService.update(category);
        }
        return categoryDto;
    }
    
    @RequestMapping(value = "/categories/{id}", method = RequestMethod.DELETE)
    public @ResponseBody String deleteCategory(@PathVariable Integer id) {
        LOG.info(String.format("deleteCategory(id=%s)", id.toString()));
        categoryService.delete(id);
        return AJAX_SUCCESS;
    }
    
    @RequestMapping(value = "/prices", method = RequestMethod.GET)
    public String priceCategories(ModelMap model) {
        
        List<Price> categories = priceService.getAll();
        model.addAttribute("categories", categories);
        
        return "admin/prices";
    }
    
    @RequestMapping(value = "/prices/{id}", method = RequestMethod.POST)
    public @ResponseBody Price editPriceCategory(@PathVariable String id,
            @RequestParam String name,
            @RequestParam String price) {
        
        LOG.info(String.format("editPriceCategory(id=%s, name=%s, price=%s)", 
                id, name, price));
        
        Price category = null;
        try {
            if (id.equals("new")) {
                category = new Price();
                category.setName(name);
                category.setPrice(price);
                priceService.save(category);
            } else {
                category = priceService.getById(
                        Integer.valueOf(id));
                category.setName(name);
                category.setPrice(price);
                priceService.update(category);
            } 
        } catch (Throwable t) {
            LOG.warn("Cannot edit price category", t);
        }
        
        return category;
    }
    
    @RequestMapping(value = "/prices/{id}", method = RequestMethod.DELETE)
    public @ResponseBody String deletePriceCategory(@PathVariable Integer id) {
        LOG.info(String.format("deletePriceCategory(id=%s)", id));
        priceService.delete(id);
        return AJAX_SUCCESS;
    }
    
    @RequestMapping(value = "/books/download/{id}.zip", method = RequestMethod.GET)
    public void downloadBook(@PathVariable Integer id, 
            HttpServletResponse response) throws Exception {
        LOG.info(String.format("downloadBook(id=%s)", id.toString()));
        Book book = bookService.getById(id);
        byte[] data = bookService.getDecryptedBookFile(book);
        ServletOutputStream out = response.getOutputStream();
        out.write(data);
        out.close();
    }
    
    @RequestMapping(value = "/books/demo/{id}.demo.zip", method = RequestMethod.GET)
    public void downloadDemo(@PathVariable Integer id, 
            HttpServletResponse response) throws IOException {
        LOG.info(String.format("downloadDemo(id=%s)", id.toString()));
        Book book = bookService.getById(id);
        byte[] data = bookService.getDemoFile(book.getUid());
        ServletOutputStream out = response.getOutputStream();
        out.write(data);
        out.close();
    }
    
    @RequestMapping(value = "/books/check_demo/{id}", method = RequestMethod.GET)
    public @ResponseBody String checkDemo(@PathVariable Integer id, 
            HttpServletResponse response) throws IOException {
        LOG.info(String.format("checkDemo(id=%s)", id.toString()));
        Book book = bookService.getById(id);
        return bookService.demoExists(book) ? "true" : "false";
    }
    
    @RequestMapping(value = "/books/demo/{id}", method = RequestMethod.DELETE)
    public @ResponseBody String deleteDemo(@PathVariable Integer id, 
            HttpServletResponse response) throws IOException {
        LOG.info(String.format("deleteDemo(id=%s)", id.toString()));
        bookService.deleteDemo(id);
        return AJAX_SUCCESS;
    }
    
    @ExceptionHandler(CannotCreateTransactionException.class)
    public ModelAndView error(CannotCreateTransactionException ex) {
        Map<String, Object> attr = new HashMap<String, Object>();
        attr.put("msg", messages.getString("db_connection_error"));
        attr.put("ex", ex);
        return new ModelAndView("admin/error", attr);
    }
}