package com.qpidnetwork.livemodule.im.listener;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;

import java.io.Serializable;

public class IMInviteErrItem implements Serializable {


	private static final long serialVersionUID = -541129103180121046L;

	public IMInviteErrItem(){

	}

	/**
	 *  邀请错误
	 *  @param status  Chat在线状态（IMCHATONLINESTATUS_OFF：离线，IMCHATONLINESTATUS_ONLINE：在线）
	 *  @param priv         权限
	 */
	public IMInviteErrItem(
                           int status,
                           IMAuthorityItem priv){

		if( status < 0 || status >= IMClientListener.IMChatOnlineStatus.values().length ) {
			this.status = IMClientListener.IMChatOnlineStatus.Unknown;
		} else {
			this.status = IMClientListener.IMChatOnlineStatus.values()[status];
		}
		this.priv = priv;
	}
	

	public IMClientListener.IMChatOnlineStatus status;
	public IMAuthorityItem priv;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMInviteReplyItem[");
		sb.append(" priv:");
		sb.append(priv);
		sb.append(" status:");
		sb.append(status);
		sb.append("]");
		return sb.toString();
	}
}
