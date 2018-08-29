package com.qpidnetwork.anchor.liveshow.model.http;

import com.qpidnetwork.anchor.im.listener.IMClientListener;

/**
 * IM Response package
 * Created by Hunter Mun on 2017/6/20.
 */

public class IMRespObject {

    public IMRespObject(){

    }

    public IMRespObject(int reqId,
                        boolean isSuccess,
                        IMClientListener.LCC_ERR_TYPE errType,
                        String errMsg,
                        Object data){
        this.reqId = reqId;
        this.isSuccess = isSuccess;
        this.errType = errType;
        this.errMsg = errMsg;
        this.data = data;
    }

    public int reqId;
    public boolean isSuccess;
    public IMClientListener.LCC_ERR_TYPE errType;
    public String errMsg;
    public Object data;
}
