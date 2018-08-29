package com.qpidnetwork.anchor.httprequest;

/**
 * HttpRequest 普通请求Callback
 * Created by Hunter Mun on 2017/5/17.
 */

public interface OnRequestCallback {
    public void onRequest(boolean isSuccess, int errCode, String errMsg);
}
