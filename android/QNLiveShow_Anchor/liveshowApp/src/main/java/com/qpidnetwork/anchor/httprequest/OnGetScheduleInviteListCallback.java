package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.BookInviteItem;

public interface OnGetScheduleInviteListCallback {
	public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg, int totel, BookInviteItem[] bookInviteList);
}
