package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class ManBaseInfoItem {

	public ManBaseInfoItem(){

	}

	/**
	 * 个人信息
	 * @param userId               观众ID
	 * @param nickName             昵称
	 * @param nickNameStatus       昵称审核状态（0：审核完成，1：审核中）
	 * @param photoUrl             头像url
	 * @param photoStatus          头像审核状态（0：没有头像及审核成功，1：审核中，2：不合格）
	 * @param birthday             生日
	 * @param userlevel            观众等级（整型）
	 */
	public ManBaseInfoItem(String userId,
						   String nickName,
                           int nickNameStatus,
						   String photoUrl,
						   int photoStatus,
                           String birthday,
						   int userlevel){
		this.userId = userId;
		this.nickName = nickName;
		if( nickNameStatus < 0 || nickNameStatus >= NickNameVerifyType.values().length ) {
			this.nickNameStatus = NickNameVerifyType.handleing;
		} else {
			this.nickNameStatus = NickNameVerifyType.values()[nickNameStatus];
		}
		this.photoUrl = photoUrl;
		if( photoStatus < 0 || photoStatus >= PhotoVerifyType.values().length ) {
			this.photoStatus = PhotoVerifyType.handleing;
		} else {
			this.photoStatus = PhotoVerifyType.values()[photoStatus];
		}
		this.birthday = birthday;
		this.userlevel = userlevel;

	}
	
	public String userId;
	public String nickName;
	public NickNameVerifyType nickNameStatus;
	public String photoUrl;
	public PhotoVerifyType photoStatus;
	public String birthday;
	public int userlevel;



	@Override
	public String toString() {
		return "ManBaseInfoItem[userId:"+userId
				+ " nickName:"+nickName
				+ " nickNameStatus:"+nickNameStatus
				+ " photoUrl:"+photoUrl
				+ "]";
	}
}
