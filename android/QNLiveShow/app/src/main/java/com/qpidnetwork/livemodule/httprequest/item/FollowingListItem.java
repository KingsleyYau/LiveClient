package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 关注的主播列表Item
 * @author Hunter Mun
 *
 */
public class FollowingListItem {
	
	public FollowingListItem(){
		
	}
	
	/**
	 * 关注的主播列表Item
	 * @param userId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像url
	 * @param onlienStatus		主播在线状态
	 * @param roomId			直播间ID
	 * @param roomName			直播间名称
	 * @param roomPhotoUrl		直播间封面图url
	 * @param loveLevel			亲密度等级
	 * @param roomType			直播间类型
	 * @param addDate			添加收藏时间
	 */
	public FollowingListItem(String userId,
							String nickName,
							String photoUrl,
							int onlienStatus,
							String roomId,
							String roomName,
							String roomPhotoUrl,
							int loveLevel,
							int roomType,
							int addDate){
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
		this.loveLevel = loveLevel;
		
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
		
		this.addDate = addDate;
	}
	
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public AnchorOnlineStatus onlineStatus;
	public String roomId;
	public String roomName;
	public String roomPhotoUrl;
	public LiveRoomType roomType;
	public int loveLevel;
	public int addDate;
}
