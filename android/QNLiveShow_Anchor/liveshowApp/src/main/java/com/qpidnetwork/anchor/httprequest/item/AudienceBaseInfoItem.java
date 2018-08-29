package com.qpidnetwork.anchor.httprequest.item;

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
	 * @param level             用户等级
	 *
	 */
	public AudienceBaseInfoItem(
							String userId,
	 						String nickName,
	 						String photoUrl,
	 						String riderId,
	 						String riderName,
	 						String riderUrl,
							int level){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.riderId = riderId;
		this.riderName = riderName;
		this.riderUrl = riderUrl;
		this.level = level;
	}

	public String userId;
	public String nickName;
	public String photoUrl;
	public String riderId;
	public String riderName;
	public String riderUrl;
	public int level;

    @Override
	public String toString() {
        StringBuilder sb = new StringBuilder("AudienceBaseInfoItem[");
        sb.append("userId:");
        sb.append(userId);
        sb.append(" nickName:");
        sb.append(nickName);
        sb.append(" photoUrl:");
        sb.append(photoUrl);
        sb.append(" riderId:");
        sb.append(riderId);
        sb.append(" riderName:");
        sb.append(riderName);
        sb.append(" riderUrl:");
        sb.append(riderUrl);
		sb.append(" level:");
		sb.append(level);
        sb.append("]");
        return sb.toString();
	}
}
