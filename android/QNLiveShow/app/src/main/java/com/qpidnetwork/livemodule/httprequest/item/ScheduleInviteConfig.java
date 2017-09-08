package com.qpidnetwork.livemodule.httprequest.item;

public class ScheduleInviteConfig {

	public ScheduleInviteConfig(){
		
	}
	
	public ScheduleInviteConfig(double bookDeposit,
								ScheduleInviteBookTimeItem[] bookTimeList,
								ScheduleInviteGiftItem[] bookGiftList){
		this.bookDeposit = bookDeposit;
		this.bookTimeList = bookTimeList;
		this.bookGiftList = bookGiftList;
	}
	
	public double bookDeposit;
	public ScheduleInviteBookTimeItem[] bookTimeList;
	public ScheduleInviteGiftItem[] bookGiftList;
}
