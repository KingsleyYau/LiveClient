package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.item.UserInfoItem;

public interface OnGetProfileCallback {
	void onGetProfile(boolean isSuccess, int errCode, String errMsg, UserInfoItem userInfo);
}
