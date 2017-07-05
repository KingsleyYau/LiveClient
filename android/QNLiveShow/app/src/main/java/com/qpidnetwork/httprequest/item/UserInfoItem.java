package com.qpidnetwork.httprequest.item;

import com.qpidnetwork.httprequest.RequestJniUserInfo.Gender;


/**
 * 用户信息
 * @author Hunter Mun
 * @since 2017.5.25
 */
public class UserInfoItem {
	
	public UserInfoItem(){
		gender = Gender.Unknown;
	}
	
	/**
	 * 用户信息初始化
	 * @param photoId
	 * @param photoUrl
	 * @param nickName
	 * @param gender
	 * @param birthday
	 */
	public UserInfoItem(String photoId,
						String photoUrl,
						String nickName,
						int gender,
						String birthday){
		this.photoId = photoId;
		this.photoUrl = photoUrl;
		this.nickName = nickName;
		if( gender < 0 || gender >= Gender.values().length ) {
			this.gender = Gender.Unknown;
		} else {
			this.gender = Gender.values()[gender];
		}
		this.birthday = birthday;
	}
	
	public String photoId;
	public String photoUrl;
	public String nickName;
	public Gender gender;
	public String birthday;		//datetime格式字符串
}
