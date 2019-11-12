package com.qpidnetwork.livemodule.httprequest.item;


/**
 * 直播间列表通用item数据结构
 * @author Jagger 2018-5-28
 *
 */
public class PageRecommendItem {

	public PageRecommendItem(){

	}

	/**
	 * 热播列表item数据结构
	 * @param userId		主播ID
	 * @param nickName		主播昵称
	 * @param avatarImg		主播头像url
	 * @param coverImg		直播间封面图url
	 * @param onlienStatus	主播在线状态
	 * @param publicRoomId	公开直播间ID（空值，表示不在公开中）
	 * @param isFollow 		是否关注
	 */
	public PageRecommendItem(String userId,
                             String nickName,
                             String avatarImg,
                             String coverImg,
                             int onlienStatus,
                             String publicRoomId,
							 boolean isFollow){
		this.anchorId = userId;
		this.nickName = nickName;
		this.avatarImg = avatarImg;
		this.coverImg = coverImg;
		
		if( onlienStatus < 0 || onlienStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlienStatus];
		}

		this.publicRoomId = publicRoomId;


		this.isFollow = isFollow;

	}
	
	public String anchorId;
	public String nickName;
	public String avatarImg;
	public String coverImg;
	public AnchorOnlineStatus onlineStatus;
	public String publicRoomId;
	public boolean isFollow;

}
