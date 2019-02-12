package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.RecordMutiple;

public interface OnQueryChatRecordMutipleCallback {
	public void OnQueryChatRecordMutiple(boolean isSuccess, String errno, String errmsg, int dbTime, RecordMutiple[] recordMutipleList);
}
