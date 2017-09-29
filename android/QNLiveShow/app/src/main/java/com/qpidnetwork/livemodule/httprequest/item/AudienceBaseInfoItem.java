package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 观众信息Item
 * @author Hunter Mun
 *
 */
public class AudienceBaseInfoItem {

	public AudienceBaseInfoItem(){
		
	}
	
	/**
	 * 指定观众信息Item
	 * @param userId			观众Id
	 * @param nickName			观众昵称
	 * @param photoUrl			观众头像url
	 * @param riderId			座驾ID
	 * @param riderName			座驾名称
	 * @param riderUrl			座驾图片url
	 */
	public AudienceBaseInfoItem(
							String userId,
	 						String nickName,
	 						String photoUrl,
	 						String riderId,
	 						String riderName,
	 						String riderUrl){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.riderId = riderId;
		this.riderName = riderName;
		this.riderUrl = riderUrl;
	}

	public String userId;
	public String nickName;
	public String photoUrl;
	public String riderId;
	public String riderName;
	public String riderUrl;;

	@Override
	public String toString() {
		return "AudienceBaseInfoItem[userId:"+userId
				+" nickName:"+nickName
				+" photoUrl:"+photoUrl
				+" riderId:"+riderId
				+" riderName:"+riderName
				+" riderUrl:"+riderUrl
				+"]";
	}
}
