package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSValidSiteIdItem;

public interface OnGetValidSiteIdCallback {
	public void onGetValidSiteId(boolean isSuccess, int errCode, String errMsg, LSValidSiteIdItem[] siteIdList);
}
