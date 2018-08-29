package com.qpidnetwork.anchor.httprequest.item;


public class BookInviteItem {
	
	public enum BookInviteStatus{
		Unknown,
		Pending,			//待确定 
		Confirmed,			//已接受
		Defined,			//已拒绝
		Missed,				//错过
		Canceled,			//观众取消
		AnchorOff,			//主播缺席
		AudienceOff,		//观众缺席
		Finished			//已完成
	}
	
	public BookInviteItem(){
		
	}
	
	public BookInviteItem(String inviteId,
						String toId,
						String fromId,
						String oppositePhotoUrl,
						String oppositeNickname,
						boolean isReaded,
						int love_level,
						int bookInviteStatus,
						int bookTime,
						String giftId,
						String giftName,
						String giftBigImageUrl,
						String giftSmallImageUrl,
						int giftNum,
						int validTime,
						String roomId){
		this.inviteId = inviteId;
		this.toId = toId;
		this.fromId = fromId;
		this.oppositePhotoUrl = oppositePhotoUrl;
		this.oppositeNickname = oppositeNickname;
		this.isReaded = isReaded;
		this.love_level = love_level;
		
		if( bookInviteStatus < 0 || bookInviteStatus >= BookInviteStatus.values().length ) {
			this.bookInviteStatus = BookInviteStatus.Unknown;
		} else {
			this.bookInviteStatus = BookInviteStatus.values()[bookInviteStatus];
		}
		
		this.bookTime = bookTime;
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftBigImageUrl = giftBigImageUrl;
		this.giftSmallImageUrl = giftSmallImageUrl;
		this.giftNum = giftNum;
		this.validTime = validTime;
		this.roomId = roomId;
	}
	
	public String inviteId;
	public String toId;
	public String fromId;
	public String oppositePhotoUrl;
	public String oppositeNickname;
	public boolean isReaded;
	public int love_level;
	public BookInviteStatus bookInviteStatus;
	public int bookTime;
	public String giftId;
	public String giftName;
	public String giftBigImageUrl;
	public String giftSmallImageUrl;
	public int giftNum;
	public int validTime;
	public String roomId;
}
