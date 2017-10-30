package com.qpidnetwork.livemodule.httprequest.item;

public class RideItem {

	public RideItem(){
		
	}
	
	/**
	 * @param rideId			//座驾ID
	 * @param photoUrl			//座驾图片url
	 * @param name				//座驾名称
	 * @param grantedDate		//获取时间（1970年起的秒数）
	 * @param expDate			//过期时间（1970年起的秒数）
	 * @param isRead			//已读状态（0：未读，1：已读）
	 * @param isUsing			//是否使用中（0：否，1：是）
	 */
	public RideItem(String rideId,
					String photoUrl,
					String name,
					int grantedDate,
					int expDate,
					boolean isRead,
					boolean isUsing){
		this.rideId = rideId;
		this.photoUrl = photoUrl;
		this.name = name;
		this.grantedDate = grantedDate;
		this.expDate = expDate;
		this.isRead = isRead;
		this.isUsing = isUsing;
	}
	
	public String rideId;
	public String photoUrl;
	public String name;
	public int grantedDate;
	public int expDate;
	public boolean isRead;
	public boolean isUsing;
}
