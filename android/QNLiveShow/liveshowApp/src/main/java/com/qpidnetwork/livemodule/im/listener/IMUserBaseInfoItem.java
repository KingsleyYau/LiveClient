package com.qpidnetwork.livemodule.im.listener;

public class IMUserBaseInfoItem {
	
	public IMUserBaseInfoItem(){
		
	}
	
	/**
	 * 粉丝基础信息
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 */
	public IMUserBaseInfoItem(String userId,
						String nickName,
						String photoUrl){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
	}

	/**
	 * 粉丝基础信息
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param isHasTicket
	 */
	public IMUserBaseInfoItem(String userId,
							  String nickName,
							  String photoUrl,
							  boolean isHasTicket){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.isHasTicket = isHasTicket;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;				//用于显示的其他用户小头像
	public boolean isHasTicket = false;	//是否已购票
}
