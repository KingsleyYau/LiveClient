package com.qpidnetwork.livemodule.httprequest;

/**
 * 背包礼物相关接口
 * @author Hunter Mun
 *
 */
public class RequestJniPackage {
	
	/**
	 * 5.1.获取背包礼物列表
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetPackageGiftList(OnGetPackageGiftListCallback callback);
}
