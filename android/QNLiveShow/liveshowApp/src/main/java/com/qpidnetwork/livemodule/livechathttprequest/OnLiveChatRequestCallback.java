package com.qpidnetwork.livemodule.livechathttprequest;

public interface OnLiveChatRequestCallback {
    public void onLiveChatRequest(boolean isSuccess, int errCode, String errMsg);
}
