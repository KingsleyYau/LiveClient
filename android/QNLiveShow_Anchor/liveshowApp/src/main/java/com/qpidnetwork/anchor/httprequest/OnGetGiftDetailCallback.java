package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.GiftItem;

public interface OnGetGiftDetailCallback {
	public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail);
}
