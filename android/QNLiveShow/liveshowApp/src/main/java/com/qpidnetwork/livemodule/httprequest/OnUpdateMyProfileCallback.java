package com.qpidnetwork.livemodule.httprequest;

public interface OnUpdateMyProfileCallback {
	public void onUpdateMyProfile(boolean isSuccess, int errno, String errmsg, boolean rsModified);
}
