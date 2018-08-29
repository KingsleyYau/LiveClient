package com.qpidnetwork.livemodule.livemessage;


import com.qpidnetwork.livemodule.livemessage.item.LMPrivateMsgContactItem;

public interface OnGetPrivateMsgFriendListCallback {
	public void onGetPrivateMsgFriendList(boolean isSuccess, int errCode, String errMsg, LMPrivateMsgContactItem[] contactList);
}
