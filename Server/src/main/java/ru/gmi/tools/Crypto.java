package ru.gmi.tools;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Hex;

public class Crypto {
    
    private static final String AES = "AES";
    private static final String ENCODING = "UTF-8";
    
    public static byte[] aesEncrypt(byte[] data, String key) throws Exception {
        SecretKeySpec skeySpec = new SecretKeySpec(key.getBytes(ENCODING), AES);
        Cipher cipher = Cipher.getInstance(AES);
        cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
        return cipher.doFinal(data);
    }
    
    public static byte[] aesDecrypt(byte[] data, String key) throws Exception {
        SecretKeySpec skeySpec = new SecretKeySpec(key.getBytes(ENCODING), AES);
        Cipher cipher = Cipher.getInstance(AES);
        cipher.init(Cipher.DECRYPT_MODE, skeySpec);
        return cipher.doFinal(data);
    }
    
    public static String aesEncrypt(String data, String key) throws Exception {
        return Hex.encodeHexString(aesEncrypt(data.getBytes(ENCODING), key));
    }
    
    public static String aesDecrypt(String data, String key) throws Exception {
        return new String(aesDecrypt(Hex.decodeHex(data.toCharArray()), key), ENCODING);
    }
    
}
