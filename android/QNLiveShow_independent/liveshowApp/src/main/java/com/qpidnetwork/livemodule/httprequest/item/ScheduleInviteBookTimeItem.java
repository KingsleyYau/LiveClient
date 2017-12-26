package com.qpidnetwork.livemodule.httprequest.item;


import android.support.annotation.NonNull;

public class ScheduleInviteBookTimeItem implements Comparable<ScheduleInviteBookTimeItem> {

	@Override
	public int compareTo(@NonNull ScheduleInviteBookTimeItem o) {
		return (this.time == o.time ? 0 : (this.time > o.time ? 1 : -1));
	}

	public enum BookTimeStatus{
		Bookable,		//可预约
		Invited,		//本人已邀请
		Confirmed,		//本人已确认
		InviteOthe		//本人已邀请其它主播
	}
	
	public ScheduleInviteBookTimeItem(){
		
	}
	
	public ScheduleInviteBookTimeItem(String timeId,
									int time,
									int bookTimeStatus){
		this.timeId = timeId;
		this.time = time;
		
		if( bookTimeStatus < 0 || bookTimeStatus >= BookTimeStatus.values().length ) {
			this.bookTimeStatus = BookTimeStatus.Bookable;
		} else {
			this.bookTimeStatus = BookTimeStatus.values()[bookTimeStatus];
		}
	}
	
	public String timeId;
	public int time;
	public BookTimeStatus bookTimeStatus;
}
