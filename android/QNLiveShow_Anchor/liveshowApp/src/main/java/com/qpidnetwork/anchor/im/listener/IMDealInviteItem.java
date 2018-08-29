package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMDealInviteItem implements Serializable{

	/**
	 * 邀请回复
	 * @author Hunter Mun
	 *
	 */
	public enum IMAnchorReplyInviteType {
		Unknown,				//未知
		Agree,					//接受
		Reject,					//拒绝
		OutTime,				//邀请超时
		Cancel,					//观众取消邀请
	}

	/**
	 * 主播回复观众多人互动邀请信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMDealInviteItem(){

	}

	/**
	 * @param inviteId			邀请ID
	 * @param roomId			直播间ID
	 * @param anchorId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl   		主播头像
	 * @param type	 			邀请回复（Agree：接受，Reject：拒绝，OutTime：邀请超时，Cancel：观众取消邀请）
	 */
	public IMDealInviteItem(String inviteId,
                            String roomId,
                            String anchorId,
                            String nickName,
                            String photoUrl,
                            int type){
		this.inviteId = inviteId;
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		if( type < 0 || type >= IMAnchorReplyInviteType.values().length ) {
			this.type = IMAnchorReplyInviteType.Unknown;
		} else {
			this.type = IMAnchorReplyInviteType.values()[type];
		}
	}
	
	public String inviteId;
	public String roomId;
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public IMAnchorReplyInviteType type;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMAnchorReplyInviteType[");
		sb.append("inviteId:");
		sb.append(inviteId);
		sb.append(" roomId:");
		sb.append(roomId);
		sb.append(" anchorId:");
		sb.append(anchorId);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" type:");
		sb.append(type);
		sb.append("]");
		return sb.toString();
	}
}
