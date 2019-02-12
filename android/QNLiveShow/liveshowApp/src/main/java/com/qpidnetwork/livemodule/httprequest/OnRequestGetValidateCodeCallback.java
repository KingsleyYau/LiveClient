package com.qpidnetwork.livemodule.httprequest;

public interface OnRequestGetValidateCodeCallback {
	public void OnGetValidateCode(boolean isSuccess, int errno, String errmsg, byte[] data);
}
