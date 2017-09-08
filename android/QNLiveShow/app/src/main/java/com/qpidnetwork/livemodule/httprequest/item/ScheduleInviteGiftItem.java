package com.qpidnetwork.livemodule.httprequest.item;

public class ScheduleInviteGiftItem {
	
	public ScheduleInviteGiftItem(){
		
	}
	
	public ScheduleInviteGiftItem(String giftId,
								int[] giftChooser,
								int defaultChoose){
		this.giftId = giftId;
		this.giftChooser = giftChooser;
		this.defaultChoose = defaultChoose;
	}
	
	public String giftId;
	public int[] giftChooser;
	public int defaultChoose;
}
