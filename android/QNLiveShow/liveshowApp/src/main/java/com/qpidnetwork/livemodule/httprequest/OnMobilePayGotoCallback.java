package com.qpidnetwork.livemodule.httprequest;


public interface OnMobilePayGotoCallback {
	public void onMobilePayGoto(boolean isSuccess, int errCode, String errMsg, String redirtctUrl);
}
