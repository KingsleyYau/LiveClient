package com.qpidnetwork.livemodule.httprequest;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;

/**
 * 获取可进入的节目信息回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnGetShowRoomInfoCallback {
	/**
	 * 获取可进入的节目信息回调
	 * @item 			节目信息
	 * @roomId			直播间ID
	 */
	public void onGetShowRoomInfo(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem item, String roomId);
}
