package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 鲜花礼品Item
 * @author Alex
 *
 */
public class LSRecipientAnchorGiftItem {

	public LSRecipientAnchorGiftItem(){

	}

	/**
	 * Recipient主播列表Item
	 * @param anchorId				主播ID
	 * @param anchorNickName		主播昵称
	 * @param anchorAvatarImg		主播头像
	 * @param anchorAge				主播年龄
	 */
	public LSRecipientAnchorGiftItem(String anchorId,
                                     String anchorNickName,
									 String anchorAvatarImg,
									 int anchorAge){
		this.anchorId = anchorId;
		this.anchorNickName = anchorNickName;
		this.anchorAvatarImg = anchorAvatarImg;
		this.anchorAge = anchorAge;

	}
	
	public String anchorId;
	public String anchorNickName;
	public String anchorAvatarImg;
	public int anchorAge;

	@Override
	public String toString() {
		return "LSRecipientAnchorGiftItem[anchorId:"+anchorId
				+ " anchorNickName:"+anchorNickName
				+ " anchorAvatarImg:"+anchorAvatarImg
				+ " anchorAge:"+anchorAge
				+ "]";
	}
}
