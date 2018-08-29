package com.qpidnetwork.livemodule.liveshow.authorization.interfaces;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;

/**
 * LoginHandler专用
 * Created by Jagger on 2017/12/26.
 */

public interface ILoginHandlerListener {
    /**
     * 登录接口返回结果
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    void onLoginServer(boolean isSuccess, int errCode, String errMsg, LoginItem item);

    /**
     * 注销
     */
    void onLogout();
}
