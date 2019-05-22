package com.qpidnetwork.qnbridgemodule.bean;

public class BaseHttpResponseBean {

    /**
     * http请求返回数据类
     * @param isSuccess
     * @param errno
     * @param errMsg
     * @param data
     */
    public BaseHttpResponseBean(boolean isSuccess,
                                String errno,
                                String errMsg,
                                Object data){
        this.isSuccess = isSuccess;
        this.errno = errno;
        this.errMsg = errMsg;
        this.data = data;
    }

    public boolean isSuccess;
    public String errno;
    public String errMsg;
    public Object data;
}
