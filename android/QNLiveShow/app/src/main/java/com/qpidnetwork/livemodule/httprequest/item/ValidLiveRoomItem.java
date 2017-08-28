package com.qpidnetwork.livemodule.httprequest.item;

public class ValidLiveRoomItem {
	
	public ValidLiveRoomItem(){
		
	}
	
	/**
	 * @param roomId		直播间ID
	 * @param roomUrl		直播间流媒体服务url
	 */
	public ValidLiveRoomItem(String roomId,
							String roomUrl){
		this.roomId = roomId;
		this.roomUrl = roomUrl;
	}

	public String roomId;
	public String roomUrl;
}
