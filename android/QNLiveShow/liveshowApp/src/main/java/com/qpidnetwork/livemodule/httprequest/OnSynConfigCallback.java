package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;

public interface OnSynConfigCallback {
	public void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem);
}
