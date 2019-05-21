package com.qpidnetwork.qnbridgemodule.interfaces;

/**
 * 认证登陆接口
 */
public interface OnAuthorizationCallback {
    public void onLogin(boolean isSuccess, String errno, String errmsg, String userId);
}
