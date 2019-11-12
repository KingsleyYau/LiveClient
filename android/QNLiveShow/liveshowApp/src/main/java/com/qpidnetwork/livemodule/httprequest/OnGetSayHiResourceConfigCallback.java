package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.SayHiResourceConfigItem;

public interface OnGetSayHiResourceConfigCallback {
	public void onGetSayHiResourceConfig(boolean isSuccess, int errCode, String errMsg, SayHiResourceConfigItem configItem);
}
