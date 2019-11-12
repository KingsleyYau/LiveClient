package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMSendInviteInfoItem implements Serializable{

	/**
	 * 主播邀请返回信息
	 * @author Alex
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMSendInviteInfoItem(){

	}

	/**
	 * @param inviteId			邀请ID
	 * @param roomId			直播间ID
	 * @param timeOut			邀请剩余有效时间
	 * @param deviceType		推流设备类型
	 * @param userId			邀请私密男士ID
	 * @param userName			邀请私密男士名字
	 * @param userPhotoUrl		邀请私密男士头像
	 */
	public IMSendInviteInfoItem(String inviteId,
                                String roomId,
                                int timeOut,
                                int deviceType,
                                String userId,
                                String userName,
                                String userPhotoUrl){
		this.inviteId = inviteId;
		this.roomId = roomId;
		this.timeOut = timeOut;
		if( deviceType < 0 || deviceType >= IMClientListener.IMDeviceType.values().length ) {
			this.deviceType = IMClientListener.IMDeviceType.Unknown;
		} else {
			this.deviceType = IMClientListener.IMDeviceType.values()[deviceType];
		}
		this.userId = userId;
		this.userName = userName;
		this.userPhotoUrl = userPhotoUrl;
	}
	public String inviteId;
	public String roomId;
	public int timeOut;
	public IMClientListener.IMDeviceType deviceType;
	public String userId;
	public String userName;
	public String userPhotoUrl;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMSendInviteInfoItem[");
		sb.append("inviteId:");
		sb.append(inviteId);
		sb.append(" roomId:");
		sb.append(roomId);
		sb.append(" timeOut:");
		sb.append(timeOut);
		sb.append(" deviceType:");
		sb.append(deviceType);
		sb.append(" userId:");
		sb.append(userId);
		sb.append(" userName:");
		sb.append(userName);
		sb.append(" userPhotoUrl:");
		sb.append(userPhotoUrl);
		sb.append("]");
		return sb.toString();
	}
}
