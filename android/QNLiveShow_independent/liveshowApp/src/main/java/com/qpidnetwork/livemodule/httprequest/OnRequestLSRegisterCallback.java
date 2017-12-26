package com.qpidnetwork.livemodule.httprequest;


/**
 * 邮箱注册（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/20.
 */

public interface OnRequestLSRegisterCallback {

    public void onRequestLSRegister(boolean isSuccess, int errCode, String errMsg, String sessionId);
    
}
