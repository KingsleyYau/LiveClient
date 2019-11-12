package com.qpidnetwork.livemodule.httprequest.item;

import java.util.Arrays;
import java.util.List;

/**
 * 鲜花礼品Item
 * @author Alex
 *
 */
public class LSMyCartItem {

	public LSMyCartItem(){

	}

	/**
	 * 鲜花礼品基本信息Item
	 * @param anchorItem				主播item
	 * @param giftList					产品列表）
	 */
	public LSMyCartItem(LSRecipientAnchorGiftItem anchorItem,
						LSFlowerGiftBaseInfoItem[] giftList){
		this.anchorItem = anchorItem;
		this.giftList = giftList;
		this.LSFlowerGiftBaseInfoItems = Arrays.asList(giftList);
	}

	public LSRecipientAnchorGiftItem anchorItem;
	public LSFlowerGiftBaseInfoItem[] giftList;
	private List<LSFlowerGiftBaseInfoItem> LSFlowerGiftBaseInfoItems;

	public List<LSFlowerGiftBaseInfoItem> getLSFlowerGiftBaseInfoItemList(){
 		return LSFlowerGiftBaseInfoItems;
	}

	@Override
	public String toString() {
		return "LSMyCartItem[orderNumber:"
				+ "]";
	}
}
