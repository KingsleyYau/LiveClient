package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 免费贺卡Item
 * @author Alex
 *
 */
public class LSGreetingCardItem {

	public LSGreetingCardItem(){

	}

	/**
	 * 免费贺卡信息Item
	 * @param giftId				礼品ID
	 * @param giftName				礼品名称
	 * @param giftNumber			礼品数量
	 */
	public LSGreetingCardItem(String giftId,
                              String giftName,
                              int giftNumber){
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftNumber = giftNumber;

	}

	public String giftId;
	public String giftName;
	public int giftNumber;

	@Override
	public String toString() {
		return "LSGreetingCardItem[giftId:"+giftId
				+ " giftName:"+giftName
				+ " giftNumber:"+giftNumber
				+ "]";
	}
}
