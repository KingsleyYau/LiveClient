package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMRecvKnockRequestItem{

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


	public IMRecvKnockRequestItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param anchorId			敲门的主播ID
	 * @param nickName			敲门的主播昵称
	 * @param photoUrl			敲门的主播头像
	 * @param age				年龄
	 * @param country			国家
	 * @param knockId   		敲门ID
	 * @param expire	 		敲门请求的有效剩余秒数
	 */
	public IMRecvKnockRequestItem(String roomId,
                              String anchorId,
                              String nickName,
                              String photoUrl,
							  int age,
							  String country,
                              String knockId,
							  int expire){
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.age = age;
		this.country = country;
		this.knockId = knockId;
		this.expire = expire;


	}
	
	public String roomId;
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public int age;
	public String country;
	public String knockId;
	public int expire;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRecvKnockRequestItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" anchorId:");
		sb.append(anchorId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" age:");
		sb.append(age);
		sb.append(" country:");
		sb.append(country);
		sb.append(" knockId:");
		sb.append(knockId);
		sb.append(" expire:");
		sb.append(expire);
		sb.append("]");
		return sb.toString();
	}
}
