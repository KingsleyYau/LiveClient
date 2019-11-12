package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiDetailResponseListItem;

public interface OnReadSayHiResponseCallback {
	public void onReadSayHiResponse(boolean isSuccess, int errCode, String errMsg, SayHiDetailResponseListItem detailItem);
}
