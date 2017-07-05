package com.qpidnetwork.httprequest.item;

/**
 * 观众信息对象
 * @author Hunter Mun
 * @since 2017-522
 */
public class AudienceInfoItem {
	
	public AudienceInfoItem(){
		
	}
	
	/**
	 * 观众信息列表
	 * @param userId		观众ID
	 * @param nickName		观众昵称
	 * @param photoUrl		观众头像信息
	 */
	public AudienceInfoItem(String userId,
						String nickName,
						String photoUrl){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
}
