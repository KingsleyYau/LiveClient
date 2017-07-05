package com.qpidnetwork.httprequest.item;

/**
 * 直播房间信息
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class LiveRoomInfoItem {
	
	/**
	 * 直播间状态
	 */
	public enum LiveRoomStatus{
		Unknown,
		offline,
		live
	}
	
	public LiveRoomInfoItem(){
		
	}
	
	/**
	 * 直播间信息
	 * @param userId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像
	 * @param roomId			直播间ID
	 * @param roomName			直播间名称
	 * @param roomPhotoUrl		直播间封面Url
	 * @param status			直播间状态
	 * @param fansnum			观众人数
	 * @param country			国家地区
	 */
	public LiveRoomInfoItem(String userId,
							String nickName,
							String photoUrl,
							String roomId,
							String roomName,
							String roomPhotoUrl,
							int status,
							int fansnum,
							String country){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.roomId = roomId;
		this.roomName = roomName;
		this.roomPhotoUrl = roomPhotoUrl;
		
		if( status < 0 || status >= LiveRoomStatus.values().length ) {
			this.status = LiveRoomStatus.live;
		} else {
			this.status = LiveRoomStatus.values()[status];
		}
		this.fansnum = fansnum;
		this.country = country;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public String roomId;
	public String roomName;
	public String roomPhotoUrl;
	public LiveRoomStatus status;
	public int fansnum;
	public String country;
}
