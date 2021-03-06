package com.qpidnetwork.livemodule.httprequest.item;


import com.qpidnetwork.livemodule.im.listener.IMClientListener;

import java.util.List;

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
	 * @param roomPhotoUrl	直播间封面图url
	 * @param roomType 		直播间类型
	 * @param interests		爱好列表
	 */
	public HotListItem(String userId,
					String nickName,
					String photoUrl,
					int onlienStatus,
					String roomPhotoUrl,
					int roomType,
					int[] interests,
					int anchorType){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		
		if( onlienStatus < 0 || onlienStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlienStatus];
		}
		
		this.roomPhotoUrl = roomPhotoUrl;
		
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}

		//兴趣爱好
		this.interests = IntToEnumUtils.intArrayToInterestTypeList(interests);
		
		if( anchorType < 0 || anchorType >= AnchorLevelType.values().length ) {
			this.anchorType = AnchorLevelType.Unknown;
		} else {
			this.anchorType = AnchorLevelType.values()[anchorType];
		}
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public AnchorOnlineStatus onlineStatus;
	public String roomPhotoUrl;
	public LiveRoomType roomType;
	public List<InterestType> interests;
	public AnchorLevelType anchorType;
	
}
