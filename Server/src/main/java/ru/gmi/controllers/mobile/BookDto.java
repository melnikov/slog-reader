package ru.gmi.controllers.mobile;

import org.codehaus.jackson.annotate.JsonProperty;

import ru.gmi.domain.Book;

/**
 * Data transfer object for book.
 * @author Andrey Polikanov
 *
 */
public class BookDto {

    @JsonProperty("book_id")
    private int id;

    @JsonProperty("book_title")
    private String title;
    
    @JsonProperty("book_authors")
    private String authors;
    
    @JsonProperty("book_approximate_duration")
    private int approximateDuration;
    
    @JsonProperty("book_price")
    private String price;
    
    @JsonProperty("book_annotation")
    private String annotation;
    
    @JsonProperty("book_fragment_url")
    private String fragmentUrl;
    
    @JsonProperty("book_cover_url")
    private String coverUrl;
    
    @JsonProperty("book_saled")
    private boolean saled;
    
    public BookDto(Book book) {
        id                   = book.getId();
        title                = book.getName();
        authors              = book.getAuthors();
        approximateDuration  = book.getDuration();
        price                = "$" + book.getPrice().getPrice();
        annotation           = book.getDescription();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthors() {
        return authors;
    }

    public void setAuthors(String authors) {
        this.authors = authors;
    }

    public int getApproximateDuration() {
        return approximateDuration;
    }

    public void setApproximateDuration(int approximateDuration) {
        this.approximateDuration = approximateDuration;
    }

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public String getAnnotation() {
        return annotation;
    }

    public void setAnnotation(String annotation) {
        this.annotation = annotation;
    }

    public String getFragmentUrl() {
        return fragmentUrl;
    }

    public void setFragmentUrl(String fragmentUrl) {
        this.fragmentUrl = fragmentUrl;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public boolean isSaled() {
        return saled;
    }

    public void setSaled(boolean saled) {
        this.saled = saled;
    }

}
