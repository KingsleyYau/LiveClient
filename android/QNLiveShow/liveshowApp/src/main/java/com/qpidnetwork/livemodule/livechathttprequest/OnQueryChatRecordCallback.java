package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.Record;

public interface OnQueryChatRecordCallback {
	public void OnQueryChatRecord(boolean isSuccess, String errno, String errmsg, int dbTime, Record[] recordList, String inviteId);
}
