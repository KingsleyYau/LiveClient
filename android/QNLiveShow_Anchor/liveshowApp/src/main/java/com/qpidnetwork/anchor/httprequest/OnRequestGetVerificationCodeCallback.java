package com.qpidnetwork.anchor.httprequest;


/**
 *2.3.获取验证码 接口回调
 * Created by Hunter Mun on 2017/12/23.
 */

public interface OnRequestGetVerificationCodeCallback {

    public void onGetVerificationCode(boolean isSuccess, int errCode, String errMsg, byte[] date);
    
}
