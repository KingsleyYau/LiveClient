package com.qpidnetwork.anchor.httprequest;


public interface OnGetCountOfUnreadAndPendingInviteCallback {
	public void onGetCountOfUnreadAndPendingInvite(boolean isSuccess, int errCode, String errMsg, int total, int pendingNum, int confirmedUnreadCount, int otherUnreadCount);
}
