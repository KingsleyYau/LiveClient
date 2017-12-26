package com.qpidnetwork.livemodule.httprequest;


/**
 * 2.7.找回密码（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/20.
 */

public interface OnRequestLSFindPasswordCallback {

    public void onLSFindPassword(boolean isSuccess, int errCode, String errMsg);
    
}
