package com.qpidnetwork.anchor.im.listener;

public class IMLoginRoomItem {

	public IMLoginRoomItem(){

	}

	public IMLoginRoomItem(String roomId,
						   int roomType){
		this.roomId = roomId;
		if( roomType < 0 || roomType >= IMRoomInItem.IMLiveRoomType.values().length ) {
			this.roomType = IMRoomInItem.IMLiveRoomType.Unknown;
		} else {
			this.roomType = IMRoomInItem.IMLiveRoomType.values()[roomType];
		}
	}
	
	public String roomId;
	public IMRoomInItem.IMLiveRoomType roomType;
}
