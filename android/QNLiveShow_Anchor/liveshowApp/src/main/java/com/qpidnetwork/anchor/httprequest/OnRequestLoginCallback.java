package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.LoginItem;

/**
 * 登录接口回调
 * Created by Hunter Mun on 2017/5/17.
 */

public interface OnRequestLoginCallback {

    public void onRequestLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item);
    
}
