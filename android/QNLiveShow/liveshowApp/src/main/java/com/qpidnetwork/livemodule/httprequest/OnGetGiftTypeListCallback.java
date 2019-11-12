package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;

public interface OnGetGiftTypeListCallback {
	public void onGetGiftTypeList(boolean isSuccess, int errCode, String errMsg, GiftTypeItem[] giftTypeList);
}
