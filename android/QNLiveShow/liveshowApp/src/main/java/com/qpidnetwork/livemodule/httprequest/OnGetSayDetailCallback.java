package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiDetailItem;

public interface OnGetSayDetailCallback {
	public void onGetSayDetail(boolean isSuccess, int errCode, String errMsg, SayHiDetailItem detailItem);
}
