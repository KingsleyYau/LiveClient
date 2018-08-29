package com.qpidnetwork.livemodule.livemessage;


import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;

public interface OnGetPrivateMsgListWithUserIdCallback {
	public void onGetPrivateMsgListWithUserId(boolean isSuccess, int errCode, String errMsg, LiveMessageItem[] MessageList);
}
