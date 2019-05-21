package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;

/**
 * 8.7.获取Hang-out在线主播列表回调
 * @author Alex
 * @since 2019-3-5
 */
public interface OnGetHangoutOnlineAnchorCallback {

	/**
	 * 8.7.获取Hang-out在线主播列表回调
	 * @author Alex
	 * @param  list  	线主播列表
	 */
	public void onGetHangoutOnlineAnchor(boolean isSuccess, int errCode, String errMsg, HangoutOnlineAnchorItem[] list);
}
