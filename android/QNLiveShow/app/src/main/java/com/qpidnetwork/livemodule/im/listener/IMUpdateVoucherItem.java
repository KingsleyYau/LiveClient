package com.qpidnetwork.livemodule.im.listener;

public class IMUpdateVoucherItem {
	
	public IMUpdateVoucherItem(){
		
	}
	
	public IMUpdateVoucherItem(String id,
							String photoUrl,
							String desc){
		this.id = id;
		this.photoUrl = photoUrl;
		this.desc = desc;
	}
	
	public String id;
	public String photoUrl;
	public String desc;
}
