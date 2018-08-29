package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.VouchorAvailableInfoItem;

public interface OnGetVoucherAvailableInfoCallback {
	public void onGetVoucherAvailableInfo(boolean isSuccess, int errCode, String errMsg, VouchorAvailableInfoItem infoItem);
}
