package ru.gmi.controllers.mobile;

/**
 * Error codes.
 * @author Andrey Polikanov
 *
 */
public interface Error {

    public static final int NO_ERROR                    = 0;
    public static final int BAD_PARAMETERS              = 1;
    public static final int AUTHORIZATION_FAILED        = 10;
    public static final int BOOK_CATEGORY_NOT_FOUND     = 11;
    public static final int BOOK_NOT_FOUND              = 12;
    public static final int BOOK_NOT_PURCHASED          = 16;
    public static final int INTERNAL_SERVER_ERROR       = 20;
    
}
