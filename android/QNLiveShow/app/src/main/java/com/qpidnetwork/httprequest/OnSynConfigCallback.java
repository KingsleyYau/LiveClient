package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.ConfigItem;

public interface OnSynConfigCallback {
	void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem);
}
