package com.qpidnetwork.qnbridgemodule.interfaces;

/**
 * 获取验证码回调
 */
public interface OnGetVerifyCodeCallback {
    public void onGetVerifyCode(boolean isSuccess, String errno, String errmsg, byte[] data);
}
