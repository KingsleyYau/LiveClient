package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;

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
	 * 3.9.接收充值通知
	 * @param roomId
	 * @param message
	 * @param credit
	 */
	public void OnRecvLackOfCreditNotice(String roomId, String message, double credit, LCC_ERR_TYPE err);
	
	/**
	 * 3.10.接收定时扣费通知
	 * @param roomId
	 * @param credit
	 */
	public void OnRecvCreditNotice(String roomId, double credit);

	/**
	 * 7.4.接收主播立即私密邀请通知
	 * @param logId
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 * @param message
	 */
	public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message);

	/**
	 * 7.5.接收主播预约私密邀请通知
	 * @param inviteId
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 * @param message
	 */
	public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message);

	/**
	 * 7.6.接收预约私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 */
	public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType);

	/**
	 * 7.7.接收预约开始倒数通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param leftSeconds
	 */
	public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds);

	/**
	 * 9.1.观众等级升级通知
	 * @param level
	 */
	public void OnRecvLevelUpNotice(int level);

	/**
	 * 9.2.观众亲密度升级通知
	 * @param lovelevelItem
	 */
	public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem);

	/**
	 * 9.3.背包更新通知
	 * @param item
	 */
	public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item);

}
