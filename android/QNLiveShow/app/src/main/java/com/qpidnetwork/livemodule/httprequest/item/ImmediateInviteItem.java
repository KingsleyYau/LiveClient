package com.qpidnetwork.livemodule.httprequest.item;


/**
 * 有效邀请item
 * @author Hunter Mun
 *
 */
public class ImmediateInviteItem {
	
	public enum ImediateInviteStatus{
		Unknown,
		Defined,		//拒绝
		Confirmed,		//同意
		UnReplied,		//未回复
		OverTime		//已超时
	}
	
	public ImmediateInviteItem(){
		
	}
	
	/**
	 * @param inviteId		邀请ID
	 * @param toId			接收者ID
	 * @param fromId		发送者ID
	 */
	public ImmediateInviteItem(String inviteId,
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
		
		if( inviteType < 0 || inviteType >= ImediateInviteStatus.values().length ) {
			this.inviteType = ImediateInviteStatus.Unknown;
		} else {
			this.inviteType = ImediateInviteStatus.values()[inviteType];
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
	public ImediateInviteStatus inviteType;
	public int validTime;
	public String roomId;
}
