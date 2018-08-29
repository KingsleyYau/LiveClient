package com.qpidnetwork.anchor.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class AnchorBaseInfoItem {

	public AnchorBaseInfoItem(){

	}

	/**
	 * 直播间观众信息Item
	 * @param anchorId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像url

	 */
	public AnchorBaseInfoItem(String anchorId,
                              String nickName,
                              String photoUrl){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
	}
	
	public String anchorId;
	public String nickName;
	public String photoUrl;


	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("AnchorBaseInfoItem[");
        sb.append("anchorId:");
        sb.append(anchorId);
        sb.append(" nickName:");
        sb.append(nickName);
        sb.append(" photoUrl:");
        sb.append(photoUrl);
        sb.append("]");
        return sb.toString();
	}
}
