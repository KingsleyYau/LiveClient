package com.qpidnetwork.livemodule.httprequest.item;


public class ScheduleInviteBookPhoneItem {
	
	
	public ScheduleInviteBookPhoneItem(){
		
	}
	
	public ScheduleInviteBookPhoneItem(String country,
										String areaCode,
										String phoneNo){
		this.country = country;
		this.areaCode = areaCode;
		this.phoneNo = phoneNo;

	}
	
	public String country;
	public String areaCode;
	public String phoneNo;
}
