package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.LCOtherGetCountItem;

public interface OnLCOtherGetCountCallback {
	public void OnOtherGetCount(boolean isSuccess, String errno, String errmsg, LCOtherGetCountItem item);
}
