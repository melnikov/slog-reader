package ru.gmi.filters;

/**
 * Encapsulates parameters of book querying.
 * @author Andrey Polikanov
 *
 */
public class BookFilter {
    
    public static final int SORT_BY_NUMBER      = 0;
    public static final int SORT_BY_NAME        = 1;
    public static final int SORT_BY_AUTHORS     = 2;
    public static final int SORT_BY_CATEGORY    = 3;
    public static final int SORT_BY_PUBLISHER   = 4;
    public static final int SORT_BY_PRICE       = 5;
    public static final int SORT_BY_VIEWS       = 6;
    public static final int SORT_BY_PURCHASES   = 7;
    public static final int SORT_BY_ID          = 8;
    
    public static final int SORT_ASC            = 0;
    public static final int SORT_DESC           = 1;

    private String name;
    
    private String author;
    
    private String category;
    
    private String publisher;
    
    private String price;
    
    private int startNumber;
    
    private int maxCount;
    
    private Integer views;
    
    private Integer purchases;
    
    private Integer sortBy;
    
    private Integer sortDirection;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public int getStartNumber() {
        return startNumber;
    }

    public void setStartNumber(int startNumber) {
        this.startNumber = startNumber;
    }

    public int getMaxCount() {
        return maxCount;
    }

    public void setMaxCount(int maxCount) {
        this.maxCount = maxCount;
    }

    public Integer getViews() {
        return views;
    }

    public void setViews(Integer views) {
        this.views = views;
    }

    public Integer getPurchases() {
        return purchases;
    }

    public void setPurchases(Integer purchases) {
        this.purchases = purchases;
    }

    public Integer getSortBy() {
        return sortBy;
    }

    public void setSortBy(Integer sortBy) {
        this.sortBy = sortBy;
    }

    public Integer getSortDirection() {
        return sortDirection;
    }

    public void setSortDirection(Integer sortDirection) {
        this.sortDirection = sortDirection;
    }
    
}
