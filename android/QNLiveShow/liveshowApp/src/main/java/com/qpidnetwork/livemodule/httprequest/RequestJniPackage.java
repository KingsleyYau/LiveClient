package com.qpidnetwork.livemodule.httprequest;

/**
 * 背包礼物相关接口
 * @author Hunter Mun
 *
 */
public class RequestJniPackage {
	
	/**
	 * 5.1.获取背包礼物列表
	 * @param callback
	 * @return
	 */
	static public native long GetPackageGiftList(OnGetPackageGiftListCallback callback);
	
	/**
	 * 5.2.获取试用券列表
	 * @param callback
	 * @return
	 */
	static public native long GetVouchersList(OnGetVouchersListCallback callback);
	
	/**
	 * 5.3.获取座驾列表
	 * @param callback
	 * @return
	 */
	static public native long GetRidesList(OnGetRidesListCallback callback);
	
	/**
	 * 5.4.使用/取消座驾
	 * @param rideId
	 * @return
	 */
	static public native long UseOrCancelRide(String rideId, OnRequestCallback callback);
	
	/**
	 * 5.5.获取背包未读数量
	 * @param callback
	 * @return
	 */
	static public native long GetPackageUnreadCount(OnGetPackageUnreadCountCallback callback);

	/**
	 * 5.6.获取试用券可用信息
	 * @param callback
	 * @return
	 */
	static public native long GetVoucherAvailableInfo(OnGetVoucherAvailableInfoCallback callback);

	/**
	 * 5.7.获取LiveChat聊天试用券列表
	 * @param start                         起始，用于分页，表示从第几个元素开始获取
	 * @param step                          步长，用于分页，表示本次请求获取多少个元素
	 * @param callback
	 * @return
	 */
	static public native long GetChatVoucherList(int start, int step, OnGetChatVoucherListCallback callback);
}
