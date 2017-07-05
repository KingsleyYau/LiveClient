package com.qpidnetwork.im.listener;

public class IMRoomInfoItem {
	
	public IMRoomInfoItem(){
		
	}
	
	/**
	 * 进入房间返回房间信息详情
	 * @param userId		主播ID
	 * @param nickName      主播昵称
	 * @param photoUrl		主播头像url
	 * @param country		主播国家/地区
	 * @param videoUrls		视频流url
	 * @param fansNum		观众人数
	 * @param contribute	贡献值
	 * @param fansList		前n个观众信息
	 */
	public IMRoomInfoItem(String userId,
						String nickName,
						String photoUrl,
						String country,
						String[] videoUrls,
						int fansNum,
						int contribute,
						IMUserBaseInfoItem[] fansList){
		
	}
	
	public String userId; 
	public String nickName;
	public String photoUrl;
	public String country;
	public String[] videoUrls;
	public int fansNum;
	public int contribute;
	public IMUserBaseInfoItem[] fansList;
}
