package com.qpidnetwork.anchor.httprequest.item;

/**
 * 观众信息Item
 * @author Hunter Mun
 *
 */
public class PushRoomInfoItem {

	public PushRoomInfoItem(){

	}

	/**
	 * 直播间观众信息Item
	 * @param anchorId			主播ID
	 * @param roomId			直播间ID
	 * @param roomType			直播间类型
	 * @param userInfo			私密直播间男士信息
	 */
	public PushRoomInfoItem(String anchorId,
                            String roomId,
                            int roomType,
							PushRoomAudienceInfoItem userInfo){
		this.anchorId = anchorId;
		this.roomId = roomId;
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
		this.userInfo = userInfo;
	}
	
	public String anchorId;
	public String roomId;
	public LiveRoomType roomType;
	public PushRoomAudienceInfoItem userInfo;


	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("PushRoomInfoItem[");
        sb.append("anchorId:");
        sb.append(anchorId);
        sb.append(" roomId:");
        sb.append(roomId);
        sb.append(" roomType:");
        sb.append(roomType);
        sb.append("]");
        return sb.toString();
	}
}
