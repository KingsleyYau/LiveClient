package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;

public interface OnGetShareLinkCallback {
	public void onGetShareLink(boolean isSuccess, int errCode, String errMsg, String shareId, String shareLink);
}
