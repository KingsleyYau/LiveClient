package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Checkout商品Item
 * @author Alex
 *
 */
public class LSCheckoutItem {

	public LSCheckoutItem(){

	}

	/**
	 * Checkout商品Item
	 * @param giftList					礼品列表
	 * @param greetingCard				免费贺卡
	 * @param deliveryPrice				邮费价格
	 * @param holidayPrice				优惠价格
	 * @param totalPrice				总额
	 * @param greetingMessage			文本信息
	 * @param specialDeliveryRequest	文本信息
	 */
	public LSCheckoutItem(LSCheckoutGiftItem[] giftList,
                          LSGreetingCardItem greetingCard,
                          double deliveryPrice,
						  double holidayPrice,
						  double totalPrice,
						  String greetingMessage,
						  String specialDeliveryRequest){
		this.giftList = giftList;
		this.greetingCard = greetingCard;
		this.deliveryPrice = deliveryPrice;
		this.holidayPrice = holidayPrice;
		this.totalPrice = totalPrice;
		this.greetingMessage = greetingMessage;
		this.specialDeliveryRequest = specialDeliveryRequest;
	}

	public LSCheckoutGiftItem[] giftList;
	public LSGreetingCardItem greetingCard;
	public double deliveryPrice;
	public double holidayPrice;
	public double totalPrice;
	public String greetingMessage;
	public String specialDeliveryRequest;

	@Override
	public String toString() {
		return "LSCheckoutItem[deliveryPrice:"+deliveryPrice
				+ " holidayPrice:"+holidayPrice
				+ " totalPrice:"+totalPrice
				+ " greetingMessage:"+greetingMessage
				+ " specialDeliveryRequest:"+specialDeliveryRequest
				+ "]";
	}
}
