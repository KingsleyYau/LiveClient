package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.HotListItem;

public interface OnGetPromoAnchorListCallback {
	public void onGetPromoAnchorList(boolean isSuccess, int errCode, String errMsg, HotListItem[] anchorList);
}
