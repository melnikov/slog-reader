package ru.gmi.tools;

import java.io.IOException;
import java.io.StringWriter;
import java.security.MessageDigest;

import org.apache.commons.codec.binary.Hex;
import org.codehaus.jackson.map.ObjectMapper;

public class Str {
    
    public static String toJson(Object object) {
        StringWriter out = new StringWriter();
        ObjectMapper mapper = new ObjectMapper();
        try {
            mapper.writeValue(out, object);
        } catch (IOException e) {
            out.write(e.getMessage());
        }
        return out.toString();
    }
    
    public static final String CHARS = "abcdefghijklmnopqrstuvwxyz1234567890";
    
    public static String generateUid(int length) {
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < length; i++) {
            builder.append(CHARS.charAt((int)(Math.random() * CHARS.length())));
        }
        return builder.toString();
    }
    
    public static String md5(String text) {
        try {
            MessageDigest digest = MessageDigest.getInstance("MD5");
            byte[] bytes = digest.digest(text.getBytes("UTF-8"));
            String token = Hex.encodeHexString(bytes);
            return token;
        } catch (Throwable t) {
            
        }
        return null;
    }
}
