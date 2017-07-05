package com.qpidnetwork.httprequest;


public interface OnGetSendableGiftListCallback {
	void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, String[] giftIds);
}
