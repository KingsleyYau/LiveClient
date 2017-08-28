package com.qpidnetwork.livemodule.httprequest.item;


/**
 * 热播列表item数据结构
 * @author Hunter Mun
 *
 */
public class HotListItem {

	public HotListItem(){
		
	}
	
	/**
	 * 热播列表item数据结构
	 * @param userId		主播ID
	 * @param nickName		主播昵称
	 * @param photoUrl		主播头像url
	 * @param onlienStatus	主播在线状态
	 * @param roomId		直播间ID
	 * @param roomName		直播间名称
	 * @param roomPhotoUrl	直播间封面图url
	 * @param roomType 		直播间类型
	 */
	public HotListItem(String userId,
					String nickName,
					String photoUrl,
					int onlienStatus,
					String roomId,
					String roomName,
					String roomPhotoUrl,
					int roomType){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		
		if( onlienStatus < 0 || onlienStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlienStatus];
		}
		
		this.roomId = roomId;
		this.roomName = roomName;
		this.roomPhotoUrl = roomPhotoUrl;
		
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public AnchorOnlineStatus onlineStatus;
	public String roomId;
	public String roomName;
	public String roomPhotoUrl;
	public LiveRoomType roomType;
}
