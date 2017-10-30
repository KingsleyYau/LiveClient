package com.qpidnetwork.livemodule.httprequest;

public interface OnGetUserPhotoCallback {
	public void onGetUserPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl);
}
