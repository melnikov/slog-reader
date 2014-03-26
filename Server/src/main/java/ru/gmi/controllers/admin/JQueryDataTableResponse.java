package ru.gmi.controllers.admin;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import ru.gmi.tools.Str;

/**
 * Objects of this class are serialized to JSON by Jackson library in a format
 * supported by jQuery DataTables plugin.
 * @author Andrey Polikanov
 *
 */
public class JQueryDataTableResponse {
    
    /**
     * Integer value that is used by DataTables for 
     * synchronization purposes. Response from the server-side code should 
     * return the same value to the plug-in.
     */
    private String sEcho;
    
    private int iTotalRecords;
    
    private int iTotalDisplayRecords;
    
    private List<List<String>> aaData = new ArrayList<List<String>>();
    
    public String getsEcho() {
        return sEcho;
    }

    public void setsEcho(String sEcho) {
        this.sEcho = sEcho;
    }

    public int getiTotalRecords() {
        return iTotalRecords;
    }

    public void setiTotalRecords(int iTotalRecords) {
        this.iTotalRecords = iTotalRecords;
    }

    public int getiTotalDisplayRecords() {
        return iTotalDisplayRecords;
    }

    public void setiTotalDisplayRecords(int iTotalDisplayRecords) {
        this.iTotalDisplayRecords = iTotalDisplayRecords;
    }

    public List<List<String>> getAaData() {
        return aaData;
    }
    
    public void addData(String ... values) {
        aaData.add(Arrays.asList(values));
    }

    @Override
    public String toString() {
        return Str.toJson(this);
    }
}
