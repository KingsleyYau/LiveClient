package com.qpidnetwork.liveshow.model.http;

/**
 * Description:Http请求的响应数据封装类
 * <p>
 * Created by Harry on 2017/5/25.
 */

public class HttpRespObject {
    public HttpRespObject(boolean isSuccess, int errCode, String errMsg, Object data){
        this.isSuccess = isSuccess;
        this.errCode = errCode;
        this.errMsg = errMsg;
        this.data = data;
    }
    public boolean isSuccess;
    public int errCode;
    public String errMsg;
    public Object data;
}
