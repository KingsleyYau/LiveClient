package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;

public interface OnGetMyProfileCallback {
	public void onGetMyProfile(boolean isSuccess, int errno, String errmsg, LSProfileItem item);
}
