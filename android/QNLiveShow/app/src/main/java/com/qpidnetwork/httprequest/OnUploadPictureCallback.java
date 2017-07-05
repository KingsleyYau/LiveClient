package com.qpidnetwork.httprequest;

public interface OnUploadPictureCallback {
	void onUploadPicture(boolean isSuccess, int errCode, String errMsg, String photoId, String photoUrl);
}
