package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.GiftItem;

public interface OnGetAllGiftCallback {
	void onGetAllGift(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList);
}
