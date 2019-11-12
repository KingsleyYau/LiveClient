package com.qpidnetwork.livemodule.httprequest;




/**
 * 11. 设置相关接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniSetting {
	
	/**
	 * 11.1. 获取推送设置
	 * @param callback
	 * @return
	 */
	static public native long GetPushConfig(OnGetPushConfigCallback callback);

	
	/**
	 * 6.3.添加/取消收藏
	 * @param isPriMsgAppPush		是否接收私信推送通知
	 * @param isMailAppPush  		是否接收私信推送通知
	 * @param isSayHiAppPush  		是否接收SayHi推送通知
	 * @param callback
	 * @return
	 */
	static public native long SetPushConfig(boolean isPriMsgAppPush, boolean isMailAppPush, boolean isSayHiAppPush, OnRequestCallback callback);

}
