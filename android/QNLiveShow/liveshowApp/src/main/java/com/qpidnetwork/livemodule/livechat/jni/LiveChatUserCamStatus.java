package com.qpidnetwork.livemodule.livechat.jni;


/**
 * LiveChat在线状态对象
 * @author Samson Fan
 */
public class LiveChatUserCamStatus {
	public LiveChatUserCamStatus() {
		
	}
	
	public LiveChatUserCamStatus(
			String userId
			, int statusType) 
	{
		this.userId = userId;
		this.statusType = LiveChatClient.UserCamStatusType.values()[statusType];
	}
	
	/**
	 * 用户ID
	 */
	public String userId;
	
	/**
	 * 用户在线状态
	 */
	public LiveChatClient.UserCamStatusType statusType;
}
