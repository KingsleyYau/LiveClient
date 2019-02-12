package com.qpidnetwork.livemodule.im.listener;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;

public class IMInviteReplyItem {


	/**
	 * 主播回复观众多人互动邀请信息
	 * @author Hunter Mun
	 *
	 */

	public IMInviteReplyItem(){

	}

	/**
	 * 立即私密邀请回复
	 *  @param inviteId      邀请ID
	 *  @param replyType     主播回复 （0:拒绝 1:同意）
	 *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
	 *  @param roomType      直播间类型
	 *  @param anchorId      主播ID
	 *  @param nickName      主播昵称
	 *  @param avatarImg     主播头像
	 *  @param message           提示文字
	 *  @param status  Chat在线状态（IMCHATONLINESTATUS_OFF：离线，IMCHATONLINESTATUS_ONLINE：在线）
	 *  @param priv         权限
	 */
	public IMInviteReplyItem(String inviteId,
							 int replyType,
                             String roomId,
							 int roomType,
                             String anchorId,
                             String nickName,
                             String avatarImg,
							 String message,
                             int status,
							 IMAuthorityItem priv){
		this.inviteId = inviteId;
		if( replyType < 0 || replyType >= IMClientListener.InviteReplyType.values().length ) {
			this.replyType = IMClientListener.InviteReplyType.Unknown;
		} else {
			this.replyType = IMClientListener.InviteReplyType.values()[replyType];
		}
		this.roomId = roomId;
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.avatarImg = avatarImg;
		this.message = message;
		if( status < 0 || status >= IMClientListener.IMChatOnlineStatus.values().length ) {
			this.status = IMClientListener.IMChatOnlineStatus.Unknown;
		} else {
			this.status = IMClientListener.IMChatOnlineStatus.values()[status];
		}
		this.priv = priv;
	}
	
	public String inviteId;
	public IMClientListener.InviteReplyType replyType;
	public String roomId;
	public LiveRoomType roomType;
	public String anchorId;
	public String nickName;
	public String avatarImg;
	public String message;
	public IMClientListener.IMChatOnlineStatus status;
	public IMAuthorityItem priv;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMInviteReplyItem[");
		sb.append("inviteId:");
		sb.append(inviteId);
		sb.append(" roomId:");
		sb.append(roomId);
		sb.append(" anchorId:");
		sb.append(anchorId);
		sb.append(" avatarImg:");
		sb.append(avatarImg);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" status:");
		sb.append(status);
		sb.append("]");
		return sb.toString();
	}
}
