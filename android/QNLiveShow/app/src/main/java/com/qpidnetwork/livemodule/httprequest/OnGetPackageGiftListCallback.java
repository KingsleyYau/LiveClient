package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;

public interface OnGetPackageGiftListCallback {
	public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList);
}
