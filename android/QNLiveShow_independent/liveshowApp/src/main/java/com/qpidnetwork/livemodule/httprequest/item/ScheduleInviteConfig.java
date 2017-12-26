package com.qpidnetwork.livemodule.httprequest.item;

public class ScheduleInviteConfig {

	public ScheduleInviteConfig(){
		
	}
	
	public ScheduleInviteConfig(double bookDeposit,
								ScheduleInviteBookTimeItem[] bookTimeList,
								ScheduleInviteGiftItem[] bookGiftList,
								ScheduleInviteBookPhoneItem bookPhone){
		this.bookDeposit = bookDeposit;
		this.bookTimeList = bookTimeList;
		this.bookGiftList = bookGiftList;
		this.bookPhone = bookPhone;
	}
	
	public double bookDeposit;
	public ScheduleInviteBookTimeItem[] bookTimeList;
	public ScheduleInviteGiftItem[] bookGiftList;
	public ScheduleInviteBookPhoneItem bookPhone;
}
