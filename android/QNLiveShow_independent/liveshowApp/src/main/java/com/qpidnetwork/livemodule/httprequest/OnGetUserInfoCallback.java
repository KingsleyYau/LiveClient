package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;

public interface OnGetUserInfoCallback {
	public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, UserInfoItem userItem);
}
