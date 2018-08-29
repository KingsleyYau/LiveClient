package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMOtherInviteItem implements Serializable{


	/**
	 * 观众邀请其它主播加入信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMOtherInviteItem(){

	}

	/**
	 * @param inviteId			邀请ID
	 * @param roomId			多人互动直播间ID
	 * @param anchorId			被邀请的主播ID
	 * @param nickName			被邀请的主播昵称
	 * @param photoUrl   		被邀请的主播头像
	 * @param expire	 		邀请有效的剩余秒数
	 */
	public IMOtherInviteItem(String inviteId,
                             String roomId,
                             String anchorId,
                             String nickName,
                             String photoUrl,
                             int expire){
		this.inviteId = inviteId;
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.expire = expire;

	}
	
	public String inviteId;
	public String roomId;
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public int expire;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMOtherInviteItem[");
		sb.append("inviteId:");
		sb.append(inviteId);
		sb.append(" roomId:");
		sb.append(roomId);
		sb.append(" anchorId:");
		sb.append(anchorId);
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
