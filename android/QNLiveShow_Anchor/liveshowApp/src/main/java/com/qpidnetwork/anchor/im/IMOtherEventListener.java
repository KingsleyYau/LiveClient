package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.anchor.im.listener.IMPackageUpdateItem;

/**
 * 系统性回调
 * @author Hunter Mun
 * @since 2017.8.21
 */
public interface IMOtherEventListener {
	
	/**
	 * 2.1.登录回调
	 * @param errType
	 * @param errMsg
	 */
	public void OnLogin(LCC_ERR_TYPE errType, String errMsg);
	
	
	/**
	 * 2.2.注销回调
	 * @param errType
	 * @param errMsg
	 */
	public void OnLogout(LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 2.4.用户被挤掉线通知
	 * @param errType
	 * @param errMsg
	 */
	public void OnKickOff(LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 9.3.接收用户立即私密邀请通知
	 * @param userId
	 * @param nickname
	 * @param photoUrl
	 * @param invitationId
	 */
	public abstract void OnRecvAnchoeInviteNotify(String userId, String nickname, String photoUrl, String invitationId);

	/**
	 * 9.4.接收预约开始倒数通知
	 * @param roomId            直播间ID
	 * @param userId          主播ID
	 * @param nickName          主播昵称
	 * @param avatarImg         主播头像url
	 * @param leftSeconds		开播前的倒数秒数
	 */
	public abstract void OnRecvBookingNotice(String roomId, String userId, String nickName, String avatarImg, int leftSeconds);
}
