package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;

public interface OnLCOtherEmotionConfigCallback {
	public void OnOtherEmotionConfig(boolean isSuccess, String errno, String errmsg, OtherEmotionConfigItem item);
}
