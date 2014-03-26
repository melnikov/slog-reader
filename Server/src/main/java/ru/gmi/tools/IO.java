package ru.gmi.tools;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

public abstract class IO {

    public static byte[] readFile(String fileName) throws IOException {
        File file = new File(fileName);
        int size = (int) file.length();
        byte[] data = new byte[size];
        FileInputStream in = new FileInputStream(file);
        try {
            in.read(data);
        } finally {
            in.close();
        }
        return data;
    }
    
    public static void writeFile(String fileName, byte[] data) throws IOException {
        FileOutputStream out = new FileOutputStream(new File(fileName));
        try {
            out.write(data);
        } finally {
            out.close();
        }
    }
    
    public static byte[] zipSingleFile(byte[] data, String name) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ZipOutputStream zOut = new ZipOutputStream(out);
        zOut.putNextEntry(new ZipEntry(name));
        zOut.write(data);
        zOut.closeEntry();
        zOut.close();
        return out.toByteArray();
    }
    
    public static byte[] unzipSingleFile(byte[] data) throws IOException {
        ByteArrayInputStream in = new ByteArrayInputStream(data);
        ZipInputStream zIn = new ZipInputStream(in);
        ZipEntry entry = zIn.getNextEntry();
        byte[] result = new byte[(int) entry.getSize()];
        zIn.read(result);
        zIn.closeEntry();
        zIn.close();
        return result;
    }

}
