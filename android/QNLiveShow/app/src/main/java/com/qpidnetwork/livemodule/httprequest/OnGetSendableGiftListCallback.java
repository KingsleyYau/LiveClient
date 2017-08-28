package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;

public interface OnGetSendableGiftListCallback {
	public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] sendableGiftItems);
}
