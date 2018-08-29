package com.qpidnetwork.anchor.im.listener;


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
	 * @param inviteId
	 * @param toId
	 * @param oppositeNickname
	 * @param oppositePhotoUrl
	 * @param oppositeLevel
	 * @param oppositeAge
	 * @param oppositeCountry
	 * @param isReaded
	 * @param inviteTime
	 * @param inviteType
	 * @param validTime
	 * @param roomId
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
	
    /**
     * 立即私密邀请结构体
     * inviteId             	邀请ID
     * toId               		主播ID
     * oppositeNickname		           主播头像url
     * oppositePhotoUrl		           主播昵称
     * oppositeLevel		  	主播头像url
     * oppositeAge              主播头像url
     * oppositeCountry		             主播头像url
     * isReaded                  主播头像url
     * inviteTime                主播头像url
     * inviteType                回复状态（0:拒绝 1:同意 2:未回复 3:已超时 4:超时 5:观众／主播取消 6:主播缺席 7:观众缺席 8:已完成）
     * validTime                 邀请的剩余有效时间（秒）（可无，仅reply_type = 2 存在）
     * roomId                    直播间ID(可无， 仅reply_type = 1 存在)
     */
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
