package com.qpidnetwork.livemodule.httprequest;

/**
 * HttpRequest 普通请求Callback
 * Created by Hunter Mun on 2017/5/17.
 */

public interface OnRequestSidCallback {
    public void onRequestSid(boolean isSuccess, int errCode, String errMsg, String memberId, String sid);
}
