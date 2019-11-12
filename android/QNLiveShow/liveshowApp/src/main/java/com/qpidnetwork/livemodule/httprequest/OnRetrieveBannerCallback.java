package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;

/**
 * 6.24.获取直播广告回调
 * @author Alex
 * @since 2019-8-9
 */
public interface OnRetrieveBannerCallback {

	/**
	 * 6.24.获取直播广告回调
	 * @author Alex
	 * @param  htmlUrl  	广告的html
	 */
	public void onRetrieveBanner(boolean isSuccess, int errCode, String errMsg, String htmlUrl);
}
