package com.qpidnetwork.livemodule.livechat.jni;


/**
 * 获取邀请/在聊用户列表
 * @author Samson Fan
 */
public class LiveChatTalkListInfo {
	public LiveChatTalkListInfo() {
		
	}
	
	public LiveChatTalkListInfo(
			LiveChatTalkUserListItem[] inviteArray
			, LiveChatTalkSessionListItem[] inviteSessionArray
			, LiveChatTalkUserListItem[] invitedArray
			, LiveChatTalkSessionListItem[] invitedSessionArray
			, LiveChatTalkUserListItem[] chatingArray
			, LiveChatTalkSessionListItem[] chatingSessionArray
			, LiveChatTalkUserListItem[] pauseArray
			, LiveChatTalkSessionListItem[] pauseSessionArray) 
	{
		this.inviteArray = inviteArray;
		this.inviteSessionArray = inviteSessionArray;
		this.invitedArray = invitedArray;
		this.invitedSessionArray = invitedSessionArray;
		this.chatingArray = chatingArray;
		this.chatingSessionArray = chatingSessionArray;
		this.pauseArray = pauseArray;
		this.pauseSessionArray = pauseSessionArray;
	}
	
	
	/**
	 * 邀请用户数组
	 */
	public LiveChatTalkUserListItem[] inviteArray;
	
	/**
	 * 邀请用户session数组
	 */
	public LiveChatTalkSessionListItem[] inviteSessionArray;
	
	/**
	 * 被邀请用户数组
	 */
	public LiveChatTalkUserListItem[] invitedArray;
	
	/**
	 * 被邀请用户session数组
	 */
	public LiveChatTalkSessionListItem[] invitedSessionArray;
	
	/**
	 * 在聊用户数组
	 */
	public LiveChatTalkUserListItem[] chatingArray;
	
	/**
	 * 在聊用户session数组
	 */
	public LiveChatTalkSessionListItem[] chatingSessionArray;
	
	/**
	 * 在聊已暂停用户数组
	 */
	public LiveChatTalkUserListItem[] pauseArray;
	
	/**
	 * 在聊已暂停用户session数组
	 */
	public LiveChatTalkSessionListItem[] pauseSessionArray;
}
