package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 当前会员HangoutItem
 * @author Alex
 *
 */
public class HangoutRoomStatusItem {

	public HangoutRoomStatusItem(){

	}

	/**
	 * 当前会员HangoutItem
	 * @param liveRoomId        Hang-out直播间存在时返回的当前已进行的直播间ID
	 * @param liveRoomAnchor	当前Hang-out间的主播
	 */
	public HangoutRoomStatusItem(String liveRoomId,
								 HangoutAnchorInfoItem[] liveRoomAnchor){
		this.liveRoomId = liveRoomId;
		this.liveRoomAnchor = liveRoomAnchor;

	}
	
	public String liveRoomId = "";
	public HangoutAnchorInfoItem[] liveRoomAnchor;


	@Override
	public String toString() {
		return "HangoutRoomStatusItem[liveRoomId:"+liveRoomId
				+ "]";
	}
}
