package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HotListItem;

public interface OnGetAdAnchorListCallback {
	public void onGetAdAnchorList(boolean isSuccess, int errCode, String errMsg, HotListItem[] hotList);
}
