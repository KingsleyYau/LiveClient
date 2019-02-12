package com.qpidnetwork.livemodule.livechathttprequest;

public interface OnLCRequestFileCallback {
    public void OnLCRequestFile(long requestId, boolean isSuccess, String errno, String errmsg, String filePath);
}
