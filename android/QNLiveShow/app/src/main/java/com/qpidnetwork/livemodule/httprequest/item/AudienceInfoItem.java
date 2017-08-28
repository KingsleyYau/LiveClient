package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 观众信息Item
 * @author Hunter Mun
 *
 */
public class AudienceInfoItem {

	public AudienceInfoItem(){
		
	}
	
	/**
	 * 直播间观众信息Item
	 * @param userId			观众ID
	 * @param nickName			观众昵称
	 * @param photoUrl			观众头像url
	 * @param mountId			坐驾ID
	 * @param mountUrl			坐驾图片url
	 */
	public AudienceInfoItem(String userId,
	 						String nickName,
	 						String photoUrl,
	 						String mountId,
	 						String mountUrl){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.mountId = mountId;
		this.mountUrl = mountUrl;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public String mountId;
	public String mountUrl;
}
