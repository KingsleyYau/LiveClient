package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.ProgramInfoItem;

/**
 * 7.3.获取可进入的节目信息回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetShowRoomInfoCallback {

	/**
	 * 7.3.获取可进入的节目信息回调
	 * @param  item 			节目列表
	 * @param  roomId			直播间ID
	 */
	public void onGetShowRoomInfo(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem item, String roomId);
}
