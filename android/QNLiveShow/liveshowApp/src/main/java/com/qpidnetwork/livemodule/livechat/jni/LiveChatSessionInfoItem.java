package com.qpidnetwork.livemodule.livechat.jni;

/**
 * 用户会话信息Item
 * @author Hunter Mun
 * @since 2016.12.7
 */
public class LiveChatSessionInfoItem {
	
	public LiveChatSessionInfoItem(){
		
	}
	
	/**
	 * 会话信息
	 * @param invitedId //邀请ID
	 * @param targetId  //聊天对象ID
	 * @param chatTime  //剩下的有效聊天时间
	 * @param chatget   //是否已付费
	 * @param freeChat  //是否正在使用试聊券
	 * @param video     //是否存在视频
	 * @param videoType //视频类型
	 * @param videoTime //视频有效期
	 * @param freeTarget//是否试聊券已经绑定目标
	 * @param forbit    //是否禁止
	 * @param inviteDtime//最后发送时间
	 * @param camInvited //是否CamShare会话
	 * @param serviceType//服务类型（0：livechat 1：camshare）
	 */
	public LiveChatSessionInfoItem(String invitedId
							, String targetId
							, int chatTime
							, boolean chatget
							, boolean freeChat
							, boolean video
							, int videoType
							, int videoTime
							, boolean freeTarget
							, boolean forbit
							, int inviteDtime
							, boolean camInvited
							, int serviceType){
		this.inviteId = invitedId;
		this.targetId = targetId;
		this.chatTime = chatTime;
		this.charget = chatget;
		this.freeChat = freeChat;
		this.video = video;
		this.videoType = videoType;
		this.videoTime = videoTime;
		this.freeTarget = freeTarget;
		this.forbit = forbit;
		this.inviteDtime = inviteDtime;
		this.camInvited = camInvited;
		this.serviceType = serviceType;
	}
	
	public String inviteId;
	public String targetId;
	public int chatTime;
	public boolean charget;
	public boolean freeChat;
	public boolean video;
	public int videoType;
	public int videoTime;
	public boolean freeTarget;
	public boolean forbit;
	public int inviteDtime;
	public boolean camInvited;
	public int serviceType;
}
