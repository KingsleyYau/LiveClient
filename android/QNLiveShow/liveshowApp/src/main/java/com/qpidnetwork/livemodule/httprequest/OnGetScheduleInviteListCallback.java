package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;

public interface OnGetScheduleInviteListCallback {
	public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg, int totel, BookInviteItem[] bookInviteList);
}
