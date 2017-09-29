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
							boolean isVisible,
							boolean isPromo){
		this.giftId = giftId;
		this.isVisible = isVisible;
		this.isPromo = isPromo;
	}
	
	public String giftId;
	public boolean isVisible;
	public boolean isPromo;

}
