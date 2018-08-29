package com.qpidnetwork.anchor.im.listener;

public class IMLoginItem {
	
	public IMLoginItem(){
		
	}
	
	public IMLoginItem(IMLoginRoomItem[] roomList,
					IMInviteListItem[] inviteList,
					IMScheduleRoomItem[] scheduleRoomList){
		this.roomList = roomList;
		this.inviteList = inviteList;
		this.scheduleRoomList = scheduleRoomList;
	}
	
	public IMLoginRoomItem[] roomList;
	public IMInviteListItem[] inviteList;
	public IMScheduleRoomItem[] scheduleRoomList;
}
