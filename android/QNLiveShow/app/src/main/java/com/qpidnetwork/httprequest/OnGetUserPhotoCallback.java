package com.qpidnetwork.httprequest;

public interface OnGetUserPhotoCallback {
	void onGetUserPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl);
}
