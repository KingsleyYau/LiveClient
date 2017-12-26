package com.qpidnetwork.livemodule.httprequest;


/**
 * 2.6.邮箱登录（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/20.
 */

public interface OnRequestMailLoginCallback {

    public void onRequestMailLogin(boolean isSuccess, int errCode, String errMsg, String sessionId);
    
}
