package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMRecvEnterRoomItem implements Serializable{

	/**
	 * 观众/主播进入多人互动直播间信息
	 * @author Hunter Mun
	 *
	 */

	public enum IMLiveStatus {
		Unknown,					// 未知
		Init,						// 初始
		ReciprocalStart,			// 开始倒数中
		Online,						// 在线
		Arrearage,					// 欠费中
		ReciprocalEnd,				// 结束倒数中
		Close						// 关闭
	}

	private static final long serialVersionUID = -2781675685594191161L;

	public IMRecvEnterRoomItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param isAnchor			是否主播（0：否，1：是）
	 * @param userId			观众/主播ID
	 * @param nickName			观众/主播昵称
	 * @param photoUrl			观众/主播头像url
	 * @param userInfo			观众信息
	 * @param pullUrl      		视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
	 * @param bugForList      	已收吧台礼物列表
	 */
	public IMRecvEnterRoomItem(String roomId,
                               boolean isAnchor,
							   String userId,
							   String nickName,
							   String photoUrl,
							   IMUserInfoItem userInfo,
							   String[] pullUrl,
							   IMGiftNumItem[] bugForList){
		this.roomId = roomId;
		this.isAnchor = isAnchor;
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.userInfo = userInfo;
		this.pullUrl = pullUrl;
		this.bugForList = bugForList;

	}

	public String roomId;
	public boolean isAnchor;
	public String userId;
	public String nickName;
	public String photoUrl;
	public IMUserInfoItem userInfo;
	public String [] pullUrl;
	public IMGiftNumItem [] bugForList;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRecvEnterRoomItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" isAnchor:");
		sb.append(isAnchor);
		sb.append(" userId:");
		sb.append(userId);
		sb.append("]");
		return sb.toString();
	}
}
