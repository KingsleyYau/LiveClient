package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.GiftItem;

public interface OnGetGiftDetailCallback {
	void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail);
}
