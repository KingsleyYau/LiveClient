package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSOtherVersionCheckItem;

public interface OnOtherVersionCheckCallback {
	public void onOtherVersionCheck(boolean isSuccess, int errno, String errmsg, LSOtherVersionCheckItem item);
}
