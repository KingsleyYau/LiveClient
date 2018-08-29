package com.qpidnetwork.anchor.im.listener;

public class IMScheduleRoomItem {
	
	public IMScheduleRoomItem(){
		
	}
	
	public IMScheduleRoomItem( String anchorId,
							String nickName,
							String anchorPhotoUrl,
							String anchorCoverImage,
							int lastEnterTime,
							int leftSeconds,
							String roomId){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.anchorPhotoUrl = anchorPhotoUrl;
		this.anchorCoverImage = anchorCoverImage;
		this.lastEnterTime = lastEnterTime;
		this.leftSeconds = leftSeconds;
		this.roomId = roomId;
	}

	public String anchorId;
	public String nickName;
	public String anchorPhotoUrl;
	public String anchorCoverImage;
	public int lastEnterTime;
	public int leftSeconds;
	public String roomId;
}
