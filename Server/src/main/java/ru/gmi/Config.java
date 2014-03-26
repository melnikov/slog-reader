package ru.gmi;

import java.io.File;

import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;
import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;

/**
 * Global application configuration.
 * @author Andrey Polikanov
 *
 */
@Root
public class Config {

    private static final String CONFIG_FILE_NAME = "config.xml";
    
    private static final Config INSTANCE;
    
    public static Config getInstance() {
        return INSTANCE;
    }
    
    static {
        
        try {
            Serializer serializer = new Persister();
   
            INSTANCE = serializer.read(Config.class, 
                    Config.class.getClassLoader().getResourceAsStream(CONFIG_FILE_NAME));
            
            if (!INSTANCE.booksDirectory.endsWith(File.separator)) {
                INSTANCE.booksDirectory = INSTANCE.booksDirectory + File.separator;    
            }
            
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Config file not found", e);
        }
        
    }
    
    @Element
    private String booksDirectory;
    
    @Element
    private int maxCoverWidth;
    
    @Element
    private boolean checkPurchases;
    
    @Element
    private String verifyReceiptUrl;
    
    public String getBooksDirectory() {
        return booksDirectory;
    }

    public int getMaxCoverWidth() {
        return maxCoverWidth;
    }

    public boolean isCheckPurchases() {
        return checkPurchases;
    }

    public String getVerifyReceiptUrl() {
        return verifyReceiptUrl;
    }
    
}
