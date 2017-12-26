package com.qpidnetwork.livemodule.httprequest;
import com.qpidnetwork.livemodule.httprequest.item.ManBaseInfoItem;


/**
 * 6.14.获取个人信息（仅独立）接口回调
 * Created by Hunter Mun on 2017/12/23.
 */

public interface OnRequestLSGetManBaseInfoCallback {

    public void onGetManBaseInfo(boolean isSuccess, int errCode, String errMsg, ManBaseInfoItem item);
    
}
