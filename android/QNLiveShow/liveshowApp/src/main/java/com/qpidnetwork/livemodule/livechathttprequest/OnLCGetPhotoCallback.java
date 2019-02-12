package com.qpidnetwork.livemodule.livechathttprequest;


/**
 * LiveChat获取私密照片
 */
public interface OnLCGetPhotoCallback {
	public void OnLCGetPhoto(long requestId, boolean isSuccess, String errno, String errmsg, String filePath);
}
