package com.qpidnetwork.im.listener;

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
	
	public String userId;
	public String nickName;
	public String photoUrl;		//用于显示的其他用户小头像
}
