package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.ConfigItem;

public interface OnSynConfigCallback {
	public void onSynConfig(boolean isSuccess, int errCode, String errMsg, ConfigItem configItem);
}
