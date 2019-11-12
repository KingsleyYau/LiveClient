package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.LSLeftCreditItem;

public interface OnGetAccountBalanceCallback {
	public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, LSLeftCreditItem creditItem);
}
