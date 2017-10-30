package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

public interface OnGetGiftDetailCallback {
	public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail);
}
