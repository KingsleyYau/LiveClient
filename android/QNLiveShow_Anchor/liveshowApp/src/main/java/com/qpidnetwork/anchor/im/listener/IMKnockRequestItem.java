package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMKnockRequestItem implements Serializable{

	/**
	 * 互动直播间
	 * @author Hunter Mun
	 *
	 */
	public enum IMAnchorKnockType {
		Unknown,				//未知
		Agree,					//接受
		Reject,					//拒绝
		OutTime,				//邀请超时
		Cancel,					//主播取消邀请
	}

	/**
	 * 敲门回复信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMKnockRequestItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param userId			敲门的主播ID
	 * @param nickName			敲门的主播昵称
	 * @param photoUrl			敲门的主播头像
	 * @param knockId   		敲门ID
	 * @param type	 			敲门回复（Agree：接受，Reject：拒绝，OutTime：邀请超时，Cancel：主播取消邀请）
	 */
	public IMKnockRequestItem(String roomId,
                              String userId,
                              String nickName,
                              String photoUrl,
                              String knockId,
							  int type){
		this.roomId = roomId;
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.knockId = knockId;
		if( type < 0 || type >= IMAnchorKnockType.values().length ) {
			this.type = IMAnchorKnockType.Unknown;
		} else {
			this.type = IMAnchorKnockType.values()[type];
		}

	}
	
	public String roomId;
	public String userId;
	public String nickName;
	public String photoUrl;
	public String knockId;
	public IMAnchorKnockType type;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMKnockRequestItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" userId:");
		sb.append(userId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" knockId:");
		sb.append(knockId);
		sb.append(" type:");
		sb.append(type);
		sb.append("]");
		return sb.toString();
	}
}
