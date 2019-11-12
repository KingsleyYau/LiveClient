package com.qpidnetwork.livemodule.httprequest.item;


import com.qpidnetwork.livemodule.im.listener.IMClientListener;

import java.util.List;

/**
 * 直播间列表通用item数据结构
 * @author Jagger 2018-5-28
 *
 */
public class LiveRoomListItem {

	public enum Type{
		ANCHOR,		//主播
		ADVERT		//广告
	}

	public LiveRoomListItem(){}

	/**
	 * 热播列表item数据结构
	 * @param userId		主播ID
	 * @param nickName		主播昵称
	 * @param photoUrl		主播头像url
	 * @param onlienStatus	主播在线状态
	 * @param roomPhotoUrl	直播间封面图url
	 * @param roomType 		直播间类型
	 * @param interests		爱好列表
	 * @param priv 			权限
	 */
	public LiveRoomListItem(String userId,
                            String nickName,
                            String photoUrl,
                            int onlienStatus,
                            String roomPhotoUrl,
                            int roomType,
                            int[] interests,
                            int anchorType,
                            ProgramInfoItem showInfo,
                            HttpAuthorityItem priv,
                            int chatOnlineStatus,
							boolean isFollow){
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
		this.showInfo = showInfo;
		this.priv = priv;
		if( chatOnlineStatus < 0 || chatOnlineStatus >= IMClientListener.IMChatOnlineStatus.values().length ) {
			this.chatOnlineStatus = IMClientListener.IMChatOnlineStatus.Unknown;
		} else {
			this.chatOnlineStatus = IMClientListener.IMChatOnlineStatus.values()[chatOnlineStatus];
		}

		this.isFollow = isFollow;
	}

	public Type itemType = Type.ANCHOR;	//类型(主播/广告)
	//主播数据
	public String userId;
	public String nickName;
	public String photoUrl;
	public AnchorOnlineStatus onlineStatus;
	public String roomPhotoUrl;
	public LiveRoomType roomType;
	public List<InterestType> interests;
	public AnchorLevelType anchorType;
	public ProgramInfoItem showInfo;
	public boolean isHasPublicVoucherFree;	//是否有公开试聊卷
	public boolean isHasPrivateVoucherFree;	//是否有私密试聊卷
	public HttpAuthorityItem priv;
	public IMClientListener.IMChatOnlineStatus chatOnlineStatus;
	public boolean isFollow;
	//广告数据
	public LSAdWomanListAdvertItem advertItem;
}
