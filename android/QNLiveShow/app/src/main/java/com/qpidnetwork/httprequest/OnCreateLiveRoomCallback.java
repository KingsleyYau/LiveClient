package com.qpidnetwork.httprequest;

/**
 * 创建直播间回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnCreateLiveRoomCallback {
	
	void onCreateLiveRoom(boolean isSuccess, int errCode, String errMsg, String roomId, String roomStreamUrl);
	
}
