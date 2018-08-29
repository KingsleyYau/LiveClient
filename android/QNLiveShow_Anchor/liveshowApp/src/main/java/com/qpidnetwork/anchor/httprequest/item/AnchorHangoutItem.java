package com.qpidnetwork.anchor.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class AnchorHangoutItem {

	public AnchorHangoutItem(){

	}

	/**
	 * 多人互动直播间列表Item
	 * @param userId			用户Id
	 * @param nickName			用户昵称
	 * @param photoUrl			用户头像
	 * @param anchorList		主播列表
	 * @param roomId			直播间ID
	 */
	public AnchorHangoutItem(String userId,
                             String nickName,
                             String photoUrl,
							 AnchorBaseInfoItem[] anchorList,
							 String roomId){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.anchorList = anchorList;
		this.roomId = roomId;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public AnchorBaseInfoItem[] anchorList;
	public String roomId;


	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("AnchorHangoutItem[");
        sb.append("userId:");
        sb.append(userId);
        sb.append(" nickName:");
        sb.append(nickName);
        sb.append(" photoUrl:");
        sb.append(photoUrl);
        sb.append(" roomId:");
		sb.append(roomId);
        sb.append("]");
        return sb.toString();
	}
}
