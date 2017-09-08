package com.qpidnetwork.livemodule.im.listener;

public class IMUpdateRideItem {
	
	public IMUpdateRideItem(){
		
	}
	
	public IMUpdateRideItem(String rideId,
							String photoUrl,
							String name){
		this.rideId = rideId;
		this.photoUrl = photoUrl;
		this.name = name;
	}
	
	public String rideId;
	public String photoUrl;
	public String name;
}
