package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 观众信息Item
 * @author Hunter Mun
 *
 */
public class UserInfoItem {

	public UserInfoItem(){
		
	}
	
	/**
	 * 指定观众/主播信息Item
	 * @param userId			观众ID/主播ID
	 * @param nickName			昵称
	 * @param photoUrl			头像url
	 * @param age				年龄
	 * @param country			国籍
	 * @param userLevel         观众/主播等级
	 * @param isOnline 			是否在线     
	 * @param isAnchor			是否主播
	 * @param leftCredit		观众剩余信用点
	 * @param anchorInfo        主播信息   
	 */
	public UserInfoItem(String userId,
	 						String nickName,
	 						String photoUrl,
	 						int age,
	 						String country,
						    int userLevel,
	 						boolean isOnline,
	 						boolean isAnchor,
	 						double leftCredit,
	 						AnchorInfoItem anchorInfo){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.age = age;
		this.country = country;
		this.userLevel = userLevel;
		this.isOnline = isOnline;
		this.isAnchor = isAnchor;
		this.anchorInfo = anchorInfo;
		
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public int age;
	public String country;
	public int userLevel;
	public boolean isOnline;
	public boolean isAnchor;
	public double leftCredit;
	public AnchorInfoItem anchorInfo;


	@Override
	public String toString() {
		return "UserInfoItem[userId:"+userId
				+ " nickName:"+nickName
				+ " photoUrl:"+photoUrl
				+ " age:"+age
				+ " country:"+country
				+ " userLevel:"+userLevel
				+ " isOnline:"+isOnline
				+ " isAnchor:"+isAnchor
				+ " leftCredit:"+leftCredit
				+ "]";
	}
}
