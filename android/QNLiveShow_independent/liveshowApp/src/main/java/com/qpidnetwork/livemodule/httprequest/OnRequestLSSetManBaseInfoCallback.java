package com.qpidnetwork.livemodule.httprequest;


/**
 * 6.15.设置个人信息（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/20.
 */

public interface OnRequestLSSetManBaseInfoCallback {

    public void onSetManBaseInfo(boolean isSuccess, int errCode, String errMsg);
    
}
