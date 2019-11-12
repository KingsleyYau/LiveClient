package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.PageRecommendItem;

public interface OnGetPageRecommendAnchorListCallback {
	public void onGetPageRecommendAnchorList(boolean isSuccess, int errCode, String errMsg, PageRecommendItem[] anchorList);
}
