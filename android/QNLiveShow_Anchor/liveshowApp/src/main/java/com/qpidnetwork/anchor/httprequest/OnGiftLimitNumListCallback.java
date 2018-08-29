package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;

public interface OnGiftLimitNumListCallback {
	public void onGiftLimitNumList(boolean isSuccess, int errCode, String errMsg, GiftLimitNumItem[] giftList);
}
