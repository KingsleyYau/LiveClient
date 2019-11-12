package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSAdWomanListAdvertItem;

public interface OnLSAdWomanistAdvertCallback {
	public void onLSAdWomanistAdverte(boolean isSuccess, int errno, String errmsg, LSAdWomanListAdvertItem advert);
}
