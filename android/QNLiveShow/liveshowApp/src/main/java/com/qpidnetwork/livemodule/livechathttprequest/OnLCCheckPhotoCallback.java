package com.qpidnetwork.livemodule.livechathttprequest;

public interface OnLCCheckPhotoCallback {
	public void OnCheckPhoto(long requestId, boolean isSuccess, String errno, String errmsg, String sendId, boolean isChange);
}
