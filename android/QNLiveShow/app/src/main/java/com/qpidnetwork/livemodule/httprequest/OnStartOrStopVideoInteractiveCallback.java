package com.qpidnetwork.livemodule.httprequest;


public interface OnStartOrStopVideoInteractiveCallback {
	public void onStartOrStopVideoInteractive(boolean isSuccess, int errCode, String errMsg, String[] uploadUrls);
}
