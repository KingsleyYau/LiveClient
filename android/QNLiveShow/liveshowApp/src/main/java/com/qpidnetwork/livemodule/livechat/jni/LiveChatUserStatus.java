package com.qpidnetwork.livemodule.livechat.jni;


/**
 * LiveChat在线状态对象
 * @author Samson Fan
 */
public class LiveChatUserStatus {
	public LiveChatUserStatus() {
		
	}
	
	public LiveChatUserStatus(
			String userId
			, int statusType) 
	{
		this.userId = userId;
		this.statusType = LiveChatClient.UserStatusType.values()[statusType];
	}
	
	/**
	 * 用户ID
	 */
	public String userId;
	
	/**
	 * 用户在线状态
	 */
	public LiveChatClient.UserStatusType statusType;
}
