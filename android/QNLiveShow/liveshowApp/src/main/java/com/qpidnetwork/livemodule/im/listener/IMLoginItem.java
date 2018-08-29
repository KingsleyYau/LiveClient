package com.qpidnetwork.livemodule.im.listener;

public class IMLoginItem {
	
	public IMLoginItem(){
		
	}
	
	public IMLoginItem(IMLoginRoomItem[] roomList,
					IMInviteListItem[] inviteList,
					IMScheduleRoomItem[] scheduleRoomList,
					IMOngoingShowItem[] ongoingShowList){
		this.roomList = roomList;
		this.inviteList = inviteList;
		this.scheduleRoomList = scheduleRoomList;
		this.ongoingShowList = ongoingShowList;
	}
	
	public IMLoginRoomItem[] roomList;
	public IMInviteListItem[] inviteList;
	public IMScheduleRoomItem[] scheduleRoomList;
	public IMOngoingShowItem[] ongoingShowList;
}
