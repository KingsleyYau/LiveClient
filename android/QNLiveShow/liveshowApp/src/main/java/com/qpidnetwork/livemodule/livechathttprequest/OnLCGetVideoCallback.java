package com.qpidnetwork.livemodule.livechathttprequest;

public interface OnLCGetVideoCallback {
    public void OnLCGetVideo(long requestId, boolean isSuccess, String errno, String errmsg, String url);
}
