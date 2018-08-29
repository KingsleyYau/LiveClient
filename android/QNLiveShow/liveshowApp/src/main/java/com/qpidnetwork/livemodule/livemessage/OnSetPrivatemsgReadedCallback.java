package com.qpidnetwork.livemodule.livemessage;


import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;

public interface OnSetPrivatemsgReadedCallback {
	public void onSetPrivateMsgReaded(boolean isSuccess, int errCode, String errMsg, boolean isModify, String userId);
}
