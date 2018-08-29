package com.qpidnetwork.livemodule.liveshow.authorization.interfaces;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;

/**
 * LoginHandler专用
 * 注册结果监听
 * Created by Jagger on 2017/12/26.
 */

public interface onRegisterListener {
    /**
     * 登录接口返回结果
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param sessionId
     */
    void onResult(boolean isSuccess, int errCode, String errMsg, String sessionId);
}
