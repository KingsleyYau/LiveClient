package com.qpidnetwork.livemodule.httprequest;


/**
 * 2.8.检测邮箱注册状态（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/20.
 */

public interface OnRequestLSCheckMailCallback {

    public void onLSCheckMail(boolean isSuccess, int errCode, String errMsg);
    
}
