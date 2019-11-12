package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 礼物列表item信息
 * @author Hunter Mun
 *
 */
public class SendableGiftItem {
	
	public SendableGiftItem(){
		
	}
	
	/**
	 * @param giftId
	 * @param isVisible
	 * @param isPromo
	 * @param isFree		是否免费
	 * @param typeList		分类ID
	 */
	public SendableGiftItem(String giftId,
							boolean isVisible,
							boolean isPromo,
							boolean isFree,
							String[] typeList){
		this.giftId = giftId;
		this.isVisible = isVisible;
		this.isPromo = isPromo;
		this.isFree = isFree;
		this.typeIdList = typeList;
	}
	
	public String giftId;
	public boolean isVisible;
	public boolean isPromo;
	public boolean isFree;
	public String[] typeIdList;

}
