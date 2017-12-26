package com.qpidnetwork.livemodule.httprequest.item;

public class PackageGiftItem {

	public PackageGiftItem(){
		
	}
	
	/**
	 * 背包礼物Item
	 * @param giftId			礼物Id
	 * @param num				礼物数量
	 * @param grantedDate		礼物获取时间
	 * @param expiredDate		礼物过期时间
	 * @param isRead      		是否已读
	 */
	public PackageGiftItem(String giftId,
							int num,
							int grantedDate,
						    int startValidDate,
							int expiredDate,
							boolean isRead){
		this.giftId = giftId;
		this.num = num;
		this.grantedDate = grantedDate;
		this.startValidDate = startValidDate;
		this.expiredDate = expiredDate;
		this.isRead = isRead;
	}
	
	public String giftId;
	public int num;
	public int grantedDate;
	public int startValidDate;
	public int expiredDate;
	public boolean isRead;
}
