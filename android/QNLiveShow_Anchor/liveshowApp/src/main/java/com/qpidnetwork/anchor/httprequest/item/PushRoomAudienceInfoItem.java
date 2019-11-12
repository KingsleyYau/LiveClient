package com.qpidnetwork.anchor.httprequest.item;

/**
 * 观众信息Item
 * @author Alex
 *
 */
public class PushRoomAudienceInfoItem {

	public PushRoomAudienceInfoItem(){

	}

	/**
	 * 直播间观众信息Item
	 * @param userId			观众ID
	 * @param nickName			观众昵称
	 * @param photoUrl			观众头像url
	 */
	public PushRoomAudienceInfoItem(String userId,
                                    String nickName,
                                    String photoUrl){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;


	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("PushRoomAudienceInfoItem[");
        sb.append("userId:");
        sb.append(userId);
        sb.append(" nickName:");
        sb.append(nickName);
        sb.append(" photoUrl:");
        sb.append(photoUrl);

        sb.append("]");
        return sb.toString();
	}
}
