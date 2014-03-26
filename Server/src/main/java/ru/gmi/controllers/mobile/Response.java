package ru.gmi.controllers.mobile;

import java.util.ArrayList;

import org.codehaus.jackson.annotate.JsonProperty;

/**
 * This class is a part of mobile client protocol. It represents a request that
 * is serialized in JSON by Jackson library using ResponseBody annotation in
 * MobileClientController.
 * @author Andrey Polikanov
 *
 */
public class Response {
    
    @JsonProperty("response_method")
    private String methodName;
    
    @JsonProperty("response_code")
    private int code = 0;
    
    @JsonProperty("response_text")
    private String text = "";
    
    @JsonProperty("response_data")
    private Object data = new ArrayList<String>();
    
    public Response() {
        
    }
    
    public Response(String methodName) {
        this.methodName = methodName;
    }

    public String getMethodName() {
        return methodName;
    }

    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

}
