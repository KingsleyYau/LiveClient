package com.qpidnetwork.anchor.im.listener;

public class IMUpdateGiftItem {
	
	public IMUpdateGiftItem(){
		
	}
	
	public IMUpdateGiftItem(String giftId,
							String name,
							int num){
		this.giftId = giftId;
		this.name = name;
		this.num = num;
	}
	
	public String giftId;
	public String name;
	public int num;
}
