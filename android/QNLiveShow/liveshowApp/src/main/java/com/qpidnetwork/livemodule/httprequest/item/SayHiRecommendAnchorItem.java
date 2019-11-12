package com.qpidnetwork.livemodule.httprequest.item;

/**
 * SayHi推荐主播Item
 * @author Alex
 *
 */
public class SayHiRecommendAnchorItem {

	public SayHiRecommendAnchorItem(){

	}

	/**
	 * SayHi推荐主播Item
	 * @param anchorId		主题ID
	 * @param nickName		主题名称
	 * @param coverImg		小图
	 * @param onlineStatus		大图
	 * @param roomType		大图
	 */
	public SayHiRecommendAnchorItem(
                         String anchorId,
                         String nickName,
						 String coverImg,
						 int onlineStatus,
						 int roomType){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.coverImg = coverImg;
		if( onlineStatus < 0 || onlineStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlineStatus];
		}
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
	}
	
	public String anchorId;
	public String nickName;
	public String coverImg;
	public AnchorOnlineStatus onlineStatus;
	public LiveRoomType roomType;

	@Override
	public String toString() {
		return "SayHiRecommendAnchorItem[anchorId:"+anchorId
				+ " nickName:"+nickName
				+ " coverImg:"+coverImg
				+ " onlineStatus:"+onlineStatus
				+ " roomType:"+roomType
				+ "]";
	}
}
