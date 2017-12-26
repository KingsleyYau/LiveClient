package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

public interface OnGetGiftListCallback {
	public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList);
}
