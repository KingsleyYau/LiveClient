package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 观众信息Item
 * @author Hunter Mun
 *
 */
public class AudienceInfoItem {

	public AudienceInfoItem(){
		
	}
	
	/**
	 * 直播间观众信息Item
	 * @param userId			观众ID
	 * @param nickName			观众昵称
	 * @param photoUrl			观众头像url
	 * @param mountId			坐驾ID
	 * @param mountUrl			坐驾图片url
	 */
	public AudienceInfoItem(String userId,
	 						String nickName,
	 						String photoUrl,
	 						String mountId,
	 						String mountUrl,
	 						int level){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.mountId = mountId;
		this.mountUrl = mountUrl;
		this.level = level;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;
	public String mountId;
	public String mountUrl;
	public int level;


	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("AudienceInfoItem[");
        sb.append("userId:");
        sb.append(userId);
        sb.append(" nickName:");
        sb.append(nickName);
        sb.append(" photoUrl:");
        sb.append(photoUrl);
        sb.append(" level:");
        sb.append(level);
        sb.append(" mountUrl:");
        sb.append(mountUrl);
        sb.append(" mountId:");
        sb.append(mountId);
        sb.append("]");
        return sb.toString();
	}
}
