package com.qpidnetwork.livemodule.livechathttprequest.item;


public class RecordMutiple {
	public RecordMutiple() {
		
	}

	/**
	 * 5.5.批量查询聊天记录回调
	 * @param inviteId			邀请ID
	 * @param recordList		聊天记录
	 */
	public RecordMutiple(
			String inviteId,
			Record[] recordList
			) {
		this.inviteId = inviteId;
		this.recordList = recordList;
	}
	
	public String inviteId;
	public Record[] recordList;
}
