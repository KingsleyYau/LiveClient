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
	 */
	public SendableGiftItem(String giftId,
							boolean isVisible){
		this.giftId = giftId;
		this.isVisible = isVisible;
	}
	
	public String giftId;
	public boolean isVisible;

}
