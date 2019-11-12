package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.PushRoomInfoItem;

public interface OnGetCurrentRoomInfoCallback {
	public void onGetCurrentRoomInfo(boolean isSuccess, int errCode, String errMsg, PushRoomInfoItem pushItem);
}
