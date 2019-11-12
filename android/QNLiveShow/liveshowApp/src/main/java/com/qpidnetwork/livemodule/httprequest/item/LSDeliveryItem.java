package com.qpidnetwork.livemodule.httprequest.item;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 鲜花礼品Item
 * @author Alex
 *
 */
public class LSDeliveryItem {

	public LSDeliveryItem(){

	}

	/**
	 * 鲜花礼品基本信息Item
	 * @param orderNumber				订单号
	 * @param orderDate					订单时间戳（1970年起的秒数）
	 * @param anchorId					主播ID
	 * @param anchorNickName			主播昵称
	 * @param deliveryStatus			delivery状态
	 * @param deliveryStatusVal			状态文字
	 * @param giftList					产品列表
	 * @param greetingMessage			文本信息
	 * @param specialDeliveryRequest	文本信息
	 * @param anchorAvatar				主播头像
	 */
	public LSDeliveryItem(String orderNumber,
                          long orderDate,
                          String anchorId,
                          String anchorNickName,
                          int deliveryStatus,
						  String deliveryStatusVal,
						  LSFlowerGiftBaseInfoItem[] giftList,
						  String greetingMessage,
						  String specialDeliveryRequest,
						  String anchorAvatar){
		this.orderNumber = orderNumber;
		this.orderDate = orderDate;
		this.anchorId = anchorId;
		this.anchorNickName = anchorNickName;
		if( deliveryStatus < 0 || deliveryStatus >= LSDeliveryStatus.values().length ) {
			this.deliveryStatus = LSDeliveryStatus.Unknown;
		} else {
			this.deliveryStatus = LSDeliveryStatus.values()[deliveryStatus];
		}
		this.deliveryStatusVal = deliveryStatusVal;
		this.giftList = giftList;
		this.greetingMessage = greetingMessage;
		this.specialDeliveryRequest = specialDeliveryRequest;
		this.anchorAvatar = anchorAvatar;
		if(giftList != null){
			this.gifts = Arrays.asList(giftList);
		}else{
			this.gifts = new ArrayList<>();
		}

	}

	public String orderNumber;
	public long orderDate;
	public String anchorId;
	public String anchorNickName;
	public String anchorAvatar;
	public LSDeliveryStatus deliveryStatus;
	public String deliveryStatusVal;
	public LSFlowerGiftBaseInfoItem[] giftList;
	public List<LSFlowerGiftBaseInfoItem> gifts;
	public String greetingMessage;
	public String specialDeliveryRequest;

	@Override
	public String toString() {
		return "LSDeliveryItem[orderNumber:"+orderNumber
				+ " orderDate:"+orderDate
				+ " anchorId:"+anchorId
				+ " anchorNickName:"+anchorNickName
				+ " deliveryStatus:"+deliveryStatus
				+ " deliveryStatusVal:"+deliveryStatusVal
				+ " greetingMessage:"+greetingMessage
				+ " specialDeliveryRequest:"+specialDeliveryRequest
				+ "]";
	}
}
