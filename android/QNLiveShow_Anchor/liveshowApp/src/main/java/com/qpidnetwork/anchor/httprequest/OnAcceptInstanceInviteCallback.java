package com.qpidnetwork.anchor.httprequest;

public interface OnAcceptInstanceInviteCallback {
	public void onAcceptInstanceInvite(boolean isSuccess, int errCode, String errMsg, String roomId, int roomType);
}
