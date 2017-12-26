package com.qpidnetwork.livemodule.im.listener;

public class IMLoginRoomItem {

	public IMLoginRoomItem(){

	}

	public IMLoginRoomItem(String roomId,
						   String anchorId,
						   String nickName){
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.nickName = nickName;
	}
	
	public String roomId;
	public String anchorId;
	public String nickName;
}
