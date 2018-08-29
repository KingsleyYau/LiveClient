package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.GiftItem;

public interface OnGetGiftListCallback {
	public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList);
}
