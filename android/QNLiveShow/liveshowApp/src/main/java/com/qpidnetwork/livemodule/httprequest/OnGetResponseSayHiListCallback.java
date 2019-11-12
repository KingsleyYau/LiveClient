package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiResponseListInfoItem;

public interface OnGetResponseSayHiListCallback {
	public void onGetResponseSayHiList(boolean isSuccess, int errCode, String errMsg, SayHiResponseListInfoItem responseItem);
}
