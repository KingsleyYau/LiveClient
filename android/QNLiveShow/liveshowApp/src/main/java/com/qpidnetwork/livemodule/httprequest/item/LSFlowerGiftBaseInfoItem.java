package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 鲜花礼品Item
 * @author Alex
 *
 */
public class LSFlowerGiftBaseInfoItem {

	public LSFlowerGiftBaseInfoItem(){

	}

	/**
	 * 鲜花礼品基本信息Item
	 * @param giftId				礼品ID
	 * @param giftName				礼品名称
	 * @param giftImg				礼品图片
	 * @param giftNumber			礼品数量
	 * @param giftPrice				礼品价格
	 */
	public LSFlowerGiftBaseInfoItem(String giftId,
                                    String giftName,
                                    String giftImg,
                                    int giftNumber,
                                    double giftPrice){
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftImg = giftImg;
		this.giftNumber = giftNumber;
		this.giftPrice = giftPrice;

	}

	public String giftId;
	public String giftName;
	public String giftImg;
	public int giftNumber;
	public double giftPrice;


	@Override
	public String toString() {
		return "LSFlowerGiftBaseInfoItem[giftId:"+giftId
				+ " giftName:"+giftName
				+ " giftImg:"+giftImg
				+ " giftNumber:"+giftNumber
				+ " giftPrice:"+giftPrice
				+ "]";
	}
}
