package com.qpidnetwork.livemodule.httprequest;


/**
 * 2.4.Facebook注册及登录（仅独立）接口回调
 * Created by Hunter Mun on 2017/5/17.
 */

public interface OnRequestFackBookLoginCallback {

    public void onRequestFackBookLogin(boolean isSuccess, int errCode, String errMsg, String sessionId);
    
}
