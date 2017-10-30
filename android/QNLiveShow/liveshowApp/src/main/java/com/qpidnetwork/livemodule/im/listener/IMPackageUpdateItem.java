package com.qpidnetwork.livemodule.im.listener;

public class IMPackageUpdateItem {
	
	public IMPackageUpdateItem(){
		
	}
	
	public IMPackageUpdateItem(IMUpdateGiftItem giftItem,
							IMUpdateVoucherItem voucherItem,
							IMUpdateRideItem rideItem){
		this.giftItem = giftItem;
		this.voucherItem = voucherItem;
		this.rideItem = rideItem;
	}
	
	public IMUpdateGiftItem giftItem;
	public IMUpdateVoucherItem voucherItem;
	public IMUpdateRideItem rideItem;
}
