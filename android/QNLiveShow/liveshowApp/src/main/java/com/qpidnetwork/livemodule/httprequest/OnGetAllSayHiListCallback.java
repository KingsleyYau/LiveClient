package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiAllListInfoItem;

public interface OnGetAllSayHiListCallback {
	public void onGetAllSayHiList(boolean isSuccess, int errCode, String errMsg, SayHiAllListInfoItem allItem);
}
