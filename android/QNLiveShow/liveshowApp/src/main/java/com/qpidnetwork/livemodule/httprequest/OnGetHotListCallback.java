package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HotListItem;

public interface OnGetHotListCallback {
	public void onGetHotList(boolean isSuccess, int errCode, String errMsg, HotListItem[] hotList);
}
