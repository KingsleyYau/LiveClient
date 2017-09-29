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
	
	/**
	 * 6.3.添加/取消收藏
	 * @param anchorId
	 * @param roomId  直播间ID（可无，无则表示不在直播间操作）
	 * @param isFav
	 * @param callback
	 * @return
	 */
	static public native long AddOrCancelFavorite(String anchorId, String roomId, boolean isFav, OnRequestCallback callback);
	/**
	 * 6.4.获取QN广告列表
	 * @param number      客户端需要获取的数量
	 * @param callback
	 * @return
	 */
	static public native long GetAdAnchorList(int number, OnGetAdAnchorListCallback callback);
	
	/**
	 * 6.5.关闭QN广告列表
	 * @param callback
	 * @return
	 */
	static public native long CloseAdAnchorList(OnRequestCallback callback);
	
	/**
	 * 6.6.获取手机验证码
	 * @param country      国家
	 * @param areaCode     手机区号
	 * @param phoneNo      手机号码
	 * @param callback
	 * @return
	 */
	static public native long GetPhoneVerifyCode(String country, String areaCode, String phoneNo, OnRequestCallback callback);
	
	/**
	 * 6.7.提交手机验证码
	 * @param country      国家
	 * @param areaCode     手机区号
	 * @param phoneNo      手机号码
	 * @param verifyCode   验证码
	 * @param callback
	 * @return
	 */
	static public native long SubmitPhoneVerifyCode(String country, String areaCode, String phoneNo, String verifyCode, OnRequestCallback callback);
	
}
