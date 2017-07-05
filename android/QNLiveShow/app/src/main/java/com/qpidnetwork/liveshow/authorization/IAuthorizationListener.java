package com.qpidnetwork.liveshow.authorization;

import com.qpidnetwork.httprequest.item.LoginItem;

/**
 * 认证模块对外接口
 * @author Hunter Mun
 * @since 2017-6-1
 */
public interface IAuthorizationListener {
	void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item);
	void onLogout();
}
