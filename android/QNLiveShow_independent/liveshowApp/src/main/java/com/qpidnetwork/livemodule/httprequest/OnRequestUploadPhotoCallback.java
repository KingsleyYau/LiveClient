package com.qpidnetwork.livemodule.httprequest;

public interface OnRequestUploadPhotoCallback {
	public void onUploadPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl);
}
