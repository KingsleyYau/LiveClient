package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.MainUnreadNumItem;

public interface OnGetMainUnreadNumCallback {
	public void onGetMainUnreadNum(boolean isSuccess, int errCode, String errMsg, MainUnreadNumItem unreadItem);
}
