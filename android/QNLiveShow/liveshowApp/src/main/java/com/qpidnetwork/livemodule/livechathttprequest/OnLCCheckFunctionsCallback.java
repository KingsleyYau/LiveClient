package com.qpidnetwork.livemodule.livechathttprequest;

public interface OnLCCheckFunctionsCallback {
    public void OnLCCheckFunctions(boolean isSuccess, String errno, String errmsg, int[] flags);
}
