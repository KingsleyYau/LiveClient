package com.qpidnetwork.livemodule.httprequest;


/**
 * 6.13.提交Feedback（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/23.
 */

public interface OnRequestLSSubmitFeedBackCallback {

    public void onSubmitFeedBack(boolean isSuccess, int errCode, String errMsg);
    
}
