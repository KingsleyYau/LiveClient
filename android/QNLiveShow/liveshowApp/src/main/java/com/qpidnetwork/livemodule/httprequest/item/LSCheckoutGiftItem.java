package com.qpidnetwork.livemodule.httprequest.item;

/**
 * checkout鲜花礼品Item
 * @author Alex
 *
 */
public class LSCheckoutGiftItem {

	public LSCheckoutGiftItem(){

	}

	/**
	 * checkout鲜花礼品Item
	 * @param giftId				礼品ID
	 * @param giftName				礼品名称
	 * @param giftImg				礼品图片
	 * @param giftNumber			礼品数量
	 * @param giftPrice				礼品价格
	 * @param giftstatus			是否可用
	 * @param isGreetingCard		是否是贺卡
	 */
	public LSCheckoutGiftItem(String giftId,
                              String giftName,
                              String giftImg,
                              int giftNumber,
                              double giftPrice,
                              boolean giftstatus,
                              boolean isGreetingCard){
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftImg = giftImg;
		this.giftNumber = giftNumber;
		this.giftPrice = giftPrice;
		this.giftstatus = giftstatus;
		this.isGreetingCard = isGreetingCard;

	}

	public String giftId;
	public String giftName;
	public String giftImg;
	public int giftNumber;
	public double giftPrice;
	public boolean giftstatus;
	public boolean isGreetingCard;

	@Override
	public String toString() {
		return "LSCheckoutGiftItem[giftId:"+giftId
				+ " giftName:"+giftName
				+ " giftImg:"+giftImg
				+ " giftNumber:"+giftNumber
				+ " giftPrice:"+giftPrice
				+ " giftstatus:"+giftstatus
				+ " isGreetingCard:"+isGreetingCard
				+ "]";
	}
}
