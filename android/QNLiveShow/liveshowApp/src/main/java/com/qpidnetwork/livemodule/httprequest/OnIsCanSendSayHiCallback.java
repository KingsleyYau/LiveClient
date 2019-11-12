package com.qpidnetwork.livemodule.httprequest;


public interface OnIsCanSendSayHiCallback {
	public void onIsCanSendSayHi(boolean isSuccess, int errCode, String errMsg, boolean isCanSend);
}
