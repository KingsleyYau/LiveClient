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
	 * @param giftId	礼物Id
	 * @param isShow	是否可见
	 */
	public SendableGiftItem(String giftId,
							boolean isShow){
		this.giftId = giftId;
		this.isShow = isShow;
	}
	
	public String giftId;
	public boolean isShow;

}
