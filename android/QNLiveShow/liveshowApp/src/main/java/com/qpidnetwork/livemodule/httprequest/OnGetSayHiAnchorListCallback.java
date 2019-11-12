package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiRecommendAnchorItem;

public interface OnGetSayHiAnchorListCallback {
	public void onGetSayHiAnchorList(boolean isSuccess, int errCode, String errMsg, SayHiRecommendAnchorItem[] RecommendList);
}
