package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class HangoutAnchorInfoItem {

	public HangoutAnchorInfoItem(){

	}

	/**
	 * 多人互动的主播信息Item
	 * @param anchorId		主播ID
	 * @param nickName		昵称
	 * @param photoUrl		头像
	 * @param age			年龄
	 * @param country		国家
	 * @param onlineStatus  在线状态（Offline：离线，Online：在线）
	 */
	public HangoutAnchorInfoItem(String anchorId,
                                 String nickName,
                                 String photoUrl,
                                 int    age,
								 String country,
								 int onlineStatus){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.age = age;
		this.country = country;

		if( onlineStatus < 0 || onlineStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlineStatus];
		}

	}
	
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public int age;
	public String country;
	public AnchorOnlineStatus onlineStatus;


	@Override
	public String toString() {
		return "HangoutAnchorInfoItem[anchorId:"+anchorId
				+ " nickName:"+nickName
				+ " photoUrl:"+photoUrl
				+ " age:"+age
				+ " country:"+country
				+ " onlineStatus:"+onlineStatus
				+ "]";
	}
}
