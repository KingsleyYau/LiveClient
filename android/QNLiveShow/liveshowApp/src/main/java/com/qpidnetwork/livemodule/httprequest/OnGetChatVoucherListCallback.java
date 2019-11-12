package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;

public interface OnGetChatVoucherListCallback {
	public void onGetChatVoucherList(boolean isSuccess, int errCode, String errMsg, VoucherItem[] voucherList, int totalCount);
}
