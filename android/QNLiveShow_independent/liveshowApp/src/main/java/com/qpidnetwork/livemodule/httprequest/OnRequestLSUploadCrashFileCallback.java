package com.qpidnetwork.livemodule.httprequest;


/**
 * 6.16.提交crash dump文件（仅独立）接口回调
 * Created by Hunter Mun on 2018/01/11.
 */

public interface OnRequestLSUploadCrashFileCallback {

    public void onUploadCrashFile(boolean isSuccess, int errCode, String errMsg);
    
}
