package com.qpidnetwork.livemodule.httprequest.item;

import java.util.List;

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
	 * @param roomPhotoUrl		直播间封面图url
	 * @param loveLevel			亲密度等级
	 * @param roomType			直播间类型
	 * @param addDate			添加收藏时间
	 * @param interests			兴趣爱好列表
	 */
	public FollowingListItem(String userId,
							String nickName,
							String photoUrl,
							int onlienStatus,
							String roomPhotoUrl,
							int loveLevel,
							int roomType,
							int addDate,
							int[] interests,
							int anchorType,
							ProgramInfoItem showInfo){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		
		if( onlienStatus < 0 || onlienStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlienStatus];
		}
		
		this.roomPhotoUrl = roomPhotoUrl;
		this.loveLevel = loveLevel;
		
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
		
		this.addDate = addDate;

		//兴趣爱好
		this.interests = IntToEnumUtils.intArrayToInterestTypeList(interests);
		
		if( anchorType < 0 || anchorType >= AnchorLevelType.values().length ) {
			this.anchorType = AnchorLevelType.Unknown;
		} else {
			this.anchorType = AnchorLevelType.values()[anchorType];
		}
		this.showInfo = showInfo;
	}
	
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public AnchorOnlineStatus onlineStatus;
	public String roomPhotoUrl;
	public LiveRoomType roomType;
	public int loveLevel;
	public int addDate;
	public List<InterestType> interests;
	public AnchorLevelType anchorType;
	public ProgramInfoItem showInfo;
}
