package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.LCSendPhotoItem;

/**
 * LiveChat发送私密照片
 */
public interface OnLCSendPhotoCallback {
	public void OnLCSendPhoto(long requestId, boolean isSuccess, String errno, String errmsg, LCSendPhotoItem item);
}
