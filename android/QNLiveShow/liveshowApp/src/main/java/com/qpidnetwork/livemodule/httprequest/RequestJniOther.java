package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.RegionType;

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
	
	/**
	 * 6.8.提交流媒体服务器测速结果
	 * @param sid      	流媒体服务器ID
	 * @param res     	http请求完成时间（毫秒）
	 * @param callback
	 * @return
	 */
	static public native long ServerSpeed(String sid, int res, OnRequestCallback callback);
	
	/**
	 * 6.9.获取Hot/Following列表头部广告
	 * @param callback
	 * @return
	 */
	static public native long Banner(OnBannerCallback callback);
	
	/**
	 * 6.10.获取主播/观众信息
	 * @param userId   		观众ID或者主播ID
	 * @param callback
	 * @return
	 */
	static public native long GetUserInfo(String userId, OnGetUserInfoCallback callback);

	/**
	 * 6.17.获取主界面未读数量
	 * @param callback
	 * @return
	 */
	static public native long GetMainUnreadNum(OnGetMainUnreadNumCallback callback);
}
