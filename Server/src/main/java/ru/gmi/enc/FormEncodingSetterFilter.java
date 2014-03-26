package ru.gmi.enc;

import java.io.*;

import javax.servlet.*;

/**
 * Fixes tomcat encoding problems.
 * @author Andrey Polikanov
 *
 */
public class FormEncodingSetterFilter implements Filter {

    private static final String ENCODING_DEFAULT = "UTF-8";

    private static final String ENCODING_INIT_PARAM_NAME = "encoding";

    private String encoding;

    public void destroy() {
        
    }

    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws ServletException, IOException {
        if (req.getCharacterEncoding() == null) {
            req.setCharacterEncoding(encoding);
        }
        chain.doFilter(req, resp);
    }

    public void init(FilterConfig config) throws ServletException {
        encoding = config.getInitParameter(ENCODING_INIT_PARAM_NAME);
        if (encoding == null) {
            encoding = ENCODING_DEFAULT;
        }
    }
}