package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiSendInfoItem;

public interface OnSendSayHiCallback {
	public void onSendSayHi(boolean isSuccess, int errCode, String errMsg, SayHiSendInfoItem item);
}
