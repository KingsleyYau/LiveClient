package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMHangoutInviteItem implements Serializable{

	/**
	 * 互动直播间邀请信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMHangoutInviteItem(){

	}

	/**
	 * @param inviteId			邀请ID
	 * @param userId			观众ID
	 * @param nickName			观众昵称
	 * @param photoUrl			观众头像url
	 * @param anchorList   		已在直播间的主播列表
	 * @param expire	 		邀请有效的剩余秒数
	 */
	public IMHangoutInviteItem(String inviteId,
                               String userId,
                               String nickName,
                               String photoUrl,
							   IMAnchorItem[] anchorList,
							   int expire){
		this.inviteId = inviteId;
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.anchorList = anchorList;
		this.expire = expire;

	}
	
	public String inviteId;
	public String userId;
	public String nickName;
	public String photoUrl;
	public IMAnchorItem [] anchorList;
	public int expire;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutInviteItem[");
		sb.append("inviteId:");
		sb.append(inviteId);
		sb.append(" userId:");
		sb.append(userId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" expire:");
		sb.append(expire);
		sb.append("]");
		return sb.toString();
	}
}
