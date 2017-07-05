package com.qpidnetwork.httprequest;

/**
 * HttpRequest 普通请求Callback
 * Created by Hunter Mun on 2017/5/17.
 */

public interface OnRequestCallback {
    void onRequest(boolean isSuccess, int errCode, String errMsg);
}
