package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;

public interface OnGetPackageUnreadCountCallback {
	public void onGetPackageUnreadCount(boolean isSuccess, int errCode, String errMsg, PackageUnreadCountItem unreadItem);
}
