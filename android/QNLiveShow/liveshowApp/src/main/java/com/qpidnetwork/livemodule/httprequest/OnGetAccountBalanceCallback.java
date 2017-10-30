package com.qpidnetwork.livemodule.httprequest;


public interface OnGetAccountBalanceCallback {
	public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, double balance);
}
