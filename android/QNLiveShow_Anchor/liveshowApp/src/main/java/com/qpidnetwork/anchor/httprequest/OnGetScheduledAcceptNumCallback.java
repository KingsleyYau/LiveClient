package com.qpidnetwork.anchor.httprequest;


public interface OnGetScheduledAcceptNumCallback {
	public void onGetScheduledAcceptNum(boolean isSuccess, int errCode, String errMsg, int scheduledNum);
}
