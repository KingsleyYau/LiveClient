package com.qpidnetwork.livemodule.im.listener;


public class IMInviteListItem {
	
	public enum IMInviteReplyType{
		Unknown,
		Pending,		//待确定
		Accepted,		//同意
		Rejected,		//已拒绝
		OverTime,		//已超时
		Canceled,		//观众/主播取消
		AnchorAbsent,	//主播缺席
		AudienceAbsent,	//观众缺席
		Confirmed		//已完成
	}
	
	public IMInviteListItem(){
		
	}
	
	/**
	 * @param inviteId		邀请ID
	 * @param toId			接收者ID
	 * @param fromId		发送者ID
	 */
	public IMInviteListItem(String inviteId,
							String toId,
							String oppositeNickname,
							String oppositePhotoUrl,
							int oppositeLevel,
							int oppositeAge,
							String oppositeCountry,
							boolean isReaded,
							int inviteTime,
							int inviteType,
							int validTime,
							String roomId){
		this.inviteId = inviteId;
		this.toId = toId;
		this.oppositeNickname = oppositeNickname;
		this.oppositePhotoUrl = oppositePhotoUrl;
		this.oppositeLevel = oppositeLevel;
		this.oppositeAge = oppositeAge;
		this.oppositeCountry = oppositeCountry;
		this.isReaded = isReaded;
		this.inviteTime = inviteTime;
		
		if( inviteType < 0 || inviteType >= IMInviteReplyType.values().length ) {
			this.inviteType = IMInviteReplyType.Unknown;
		} else {
			this.inviteType = IMInviteReplyType.values()[inviteType];
		}
		this.validTime = validTime;
		this.roomId = roomId;
	}
	
	public String inviteId;
	public String toId;
	public String oppositeNickname;
	public String oppositePhotoUrl;
	public int oppositeLevel;
	public int oppositeAge;
	public String oppositeCountry;
	public boolean isReaded;
	public int inviteTime;
	public IMInviteReplyType inviteType;
	public int validTime;
	public String roomId;
}
