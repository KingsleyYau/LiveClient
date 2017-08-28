package com.qpidnetwork.livemodule.httprequest;


/**
 * 5. 其他接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniOther {
	
	/**
	 * 6.1. 同步配置
	 * @param callback
	 * @return
	 */
	static public native long SynConfig(OnSynConfigCallback callback);
	

	/**
	 * 6.2.获取账号余额
	 * @param callback
	 * @return
	 */
	static public native long GetAccountBalance(OnGetAccountBalanceCallback callback);
}
