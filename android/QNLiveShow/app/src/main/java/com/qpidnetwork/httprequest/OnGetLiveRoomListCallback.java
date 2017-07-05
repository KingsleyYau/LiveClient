package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.LiveRoomInfoItem;

public interface OnGetLiveRoomListCallback {
	void onGetLiveRoomList(boolean isSuccess, int errCode, String errMsg, LiveRoomInfoItem[] roomList);
}
