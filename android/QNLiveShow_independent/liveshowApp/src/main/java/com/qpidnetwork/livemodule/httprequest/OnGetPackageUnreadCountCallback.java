package com.qpidnetwork.livemodule.httprequest;

public interface OnGetPackageUnreadCountCallback {
	public void onGetPackageUnreadCount(boolean isSuccess, int errCode, String errMsg, int total, int voucherNum, int giftNum, int rideNum);
}
