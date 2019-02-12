package com.qpidnetwork.livemodule.liveshow.authorization;


/**
 * 认证模块对外接口
 * @author Hunter Mun
 * @since 2017-6-1
 */
public interface IDomainListener {
	void onDomainHandle(boolean isSuccess, int errCode, String errMsg);
}
