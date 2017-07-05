package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.CoverPhotoItem;

public interface OnGetLiveCoverPhotoListCallback {
	void onGetLiveCoverPhotoList(boolean isSuccess, int errCode, String errMsg, CoverPhotoItem[] photoList);
}
