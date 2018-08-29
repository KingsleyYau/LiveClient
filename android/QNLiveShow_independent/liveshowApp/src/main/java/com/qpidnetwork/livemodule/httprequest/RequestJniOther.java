package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.SharePageType;
import com.qpidnetwork.livemodule.httprequest.item.ShareType;

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
	 * 6.11.获取分享链接
	 * @param shareUserId   	发起分享的主播/观众ID
	 * @param anchorId   		被分享的主播ID
	 * @param shareType   		分享渠道
	 * @param sharePageType   	分享类型
	 * @param callback
	 * @return
	 */
	static public long GetShareLink(String shareUserId, String anchorId, ShareType shareType, SharePageType sharePageType, OnGetShareLinkCallback callback) {
		return GetShareLink(shareUserId, anchorId, shareType.ordinal(), sharePageType.ordinal(), callback);
	}
	static public native long GetShareLink(String shareUserId, String anchorId, int shareType, int sharePageType, OnGetShareLinkCallback callback);
	/**
	 * 6.12.分享链接成功
	 * @param shareId   	    分享ID（参考《6.11.获取分享链接（http post）》的shareid参数））
	 * @param callback
	 * @return
	 */
	static public native long SetShareSuc(String shareId, OnSetShareSucCallback callback);

	/**
	 * 6.13.提交Feedback（仅独立）
	 * @param mail   	    用户邮箱）
	 * @param msg   	    feedback内容）
	 * @param callback
	 * @return
	 */
	static public native long SubmitFeedBack(String mail, String msg, OnRequestLSSubmitFeedBackCallback callback);

	/**
	 * 6.14.获取个人信息（仅独立）
	 * @return
	 */
	static public native long GetManBaseInfo(OnRequestLSGetManBaseInfoCallback callback);

	/**
	 * 6.15.设置个人信息（仅独立）
	 * @param nickName   	     昵称）
	 * @param callback
	 * @return
	 */
	static public native long SetManBaseInfo(String nickName, OnRequestLSSetManBaseInfoCallback callback);

	/**
	 * 6.16.提交crash dump文件（仅独立）
	 * @param deviceId   	     昵称）
	 * @param crashFile
	 * @return
	 */
	static public native long UploadCrashFile(String deviceId, String directory, String tmpDirectory, OnRequestLSUploadCrashFileCallback callback);

}
