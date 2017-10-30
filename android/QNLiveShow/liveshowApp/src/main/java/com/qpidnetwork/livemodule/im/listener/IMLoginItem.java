package com.qpidnetwork.livemodule.im.listener;

public class IMLoginItem {
	
	public IMLoginItem(){
		
	}
	
	public IMLoginItem(String[] roomList,
					IMInviteListItem[] inviteList,
					IMScheduleRoomItem[] scheduleRoomList){
		this.roomList = roomList;
		this.inviteList = inviteList;
		this.scheduleRoomList = scheduleRoomList;
	}
	
	public String[] roomList;
	public IMInviteListItem[] inviteList;
	public IMScheduleRoomItem[] scheduleRoomList;
}
