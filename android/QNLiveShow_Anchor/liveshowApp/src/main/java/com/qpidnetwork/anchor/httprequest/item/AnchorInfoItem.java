package com.qpidnetwork.anchor.httprequest.item;

/**
 * 6.1.主播信息Item / 6.10.好友关系信
 *
 * @author Hunter Mun
 *
 */
public class AnchorInfoItem {

	public AnchorInfoItem(){

	}

	/**
	 * 主播信息Item
	 * @param anchorId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像url
	 * @param age				年龄
	 * @param country			国家
	 * @param friendType		是否好友（NO：否，Requesting：请求中，YES：是）(ps:6.1.在获取可推荐的主播列表，没有这个字段，默认是NO)
	 * @param onlineStatus			在线状态（Off：离线，On：在线）(ps:6.10.获取好友关系信息 没有这个字段 默认是Unknown)

	 */
	public AnchorInfoItem(String anchorId,
                          String nickName,
                          String photoUrl,
                          int age,
                          String country,
						  int friendType,
						  int onlineStatus){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.age = age;
		this.country  = country;
		if( friendType < 0 || friendType >= HangoutFriendType.values().length ) {
			this.friendType = HangoutFriendType.No;
		} else {
			this.friendType = HangoutFriendType.values()[friendType];
		}
		if( onlineStatus < 0 || onlineStatus >= OnlineStatus.values().length ) {
			this.onlineStatus = OnlineStatus.Unknown;
		} else {
			this.onlineStatus = OnlineStatus.values()[onlineStatus];
		}
	}
	
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public int age;
	public String country;
	public HangoutFriendType friendType;
	public OnlineStatus onlineStatus;

	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("AnchorInfoItem[");
        sb.append("anchorId:");
        sb.append(anchorId);
        sb.append(" nickName:");
        sb.append(nickName);
        sb.append(" photoUrl:");
        sb.append(photoUrl);
        sb.append(" age:");
        sb.append(age);
        sb.append(" country:");
        sb.append(country);
		sb.append(" friendType:");
		sb.append(friendType);
		sb.append(" onlineStatus:");
		sb.append(onlineStatus);
        sb.append("]");
        return sb.toString();
	}
}
