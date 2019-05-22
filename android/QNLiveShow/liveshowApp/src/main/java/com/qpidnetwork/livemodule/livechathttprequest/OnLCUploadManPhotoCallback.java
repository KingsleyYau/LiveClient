package com.qpidnetwork.livemodule.livechathttprequest;

public interface OnLCUploadManPhotoCallback {
	public void OnUploadManPhoto(long requestId, boolean isSuccess, int errCode, String errmsg, String photoUrl, String photomd5);
}
