package com.qpidnetwork.livemodule.liveshow.model.http;

public class RequestBaseResponse {

    public boolean isSuccess;
    public String errno;
    public String errmsg;
    public Object body;

    public RequestBaseResponse(){

    }

    public RequestBaseResponse(boolean isSuccess, String errno, String errmsg, Object body){
        this.isSuccess = isSuccess;
        this.errno = errno;
        this.errmsg = errmsg;
        this.body = body;
    }
}
