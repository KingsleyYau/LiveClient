package com.qpidnetwork.livemodule.im.listener;

public class IMScheduleRoomItem {
	
	public IMScheduleRoomItem(){
		
	}
	
	public IMScheduleRoomItem(String anchorPhotoUrl,
							String anchorCoverImage,
							int lastEnterTime,
							String roomId){
		this.anchorPhotoUrl = anchorPhotoUrl;
		this.anchorCoverImage = anchorCoverImage;
		this.lastEnterTime = lastEnterTime;
		this.roomId = roomId;
	}
	
	public String anchorPhotoUrl;
	public String anchorCoverImage;
	public int lastEnterTime;
	public String roomId;
}
