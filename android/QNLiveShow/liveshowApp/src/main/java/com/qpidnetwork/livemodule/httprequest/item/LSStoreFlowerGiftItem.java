package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 鲜花礼品Item
 * @author Alex
 *
 */
public class LSStoreFlowerGiftItem {

	public LSStoreFlowerGiftItem(){

	}

	/**
	 * 鲜花礼品Item
	 * @param typeId				类型ID
	 * @param typeName				类型名称
	 * @param isHasGreeting			是否有免费贺卡
	 * @param giftList				礼品列表
	 */
	public LSStoreFlowerGiftItem(String typeId,
                                 String typeName,
                                 boolean isHasGreeting,
								 LSFlowerGiftItem[] giftList){
		this.typeId = typeId;
		this.typeName = typeName;
		this.isHasGreeting = isHasGreeting;
		this.giftList = giftList;

	}
	
	public String typeId;
	public String typeName;
	public boolean isHasGreeting;
	public LSFlowerGiftItem[] giftList;

	@Override
	public String toString() {
		return "LSStoreFlowerGiftItem[typeId:"+typeId
				+ " typeName:"+typeName
				+ " isHasGreeting:"+isHasGreeting

				+ "]";
	}
}
