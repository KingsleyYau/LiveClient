package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;

/**
 * 直播间仅有相关事件
 * @author Hunter Mun
 * @since 2018.8.21
 */
public interface IMLiveRoomEventListener {
	/**
	 * 3.4.直播间关闭通知（用户）
	 * @param roomId
	 */
    void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 3.5.接收踢出直播间通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
	void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg);

	/**
	 * 3.6.接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 * @param isHasTicket 是否已购票
	 */
    void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket);

	/**
	 * 3.7.接收观众退出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
    void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum);

	/**
	 * 3.8.接收关闭直播间倒数通知
	 * @param roomId
	 * @param leftSeconds
	 * @param err
	 * @param errMsg
	 */
    void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg);

	/**
	 * 3.9.接收观众退出直播间通知
	 * @param roomId				 直播间ID
	 * @param anchorId				 退出直播间的主播ID
	 */
	void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId);

	/**
	 * 4.1.发送消息回调
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 */
    void OnSendRoomMsg(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem);

	/**
	 * 4.2.观众端/主播端向直播间发送文本消息
	 * @param msgItem
	 */
    void OnRecvRoomMsg(IMMessageItem msgItem);

	/**
	 * 4.3 (观众端/主播端)接受直播间公告消息
	 * @param msgItem
	 */
	void OnRecvSendSystemNotice(IMMessageItem msgItem);

	/**
	 * 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 */
    void OnSendGift(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem);

	/**
	 * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
	 * @param msgItem
	 */
    void OnRecvRoomGiftNotice(IMMessageItem msgItem);

	/**
	 * 6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param msgItem
	 */
    void OnRecvRoomToastNotice(IMMessageItem msgItem);

	/**
	 * 7.1.接收直播间才艺点播邀请通知
	 * @param talentInvitationId
	 * @param name
	 * @param userId
	 * @param nickName
	 */
	void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName);

	/**
	 * 8.1.接收观众启动/关闭视频互动通知
	 * @param roomId
	 * @param userId
	 * @param nickname
	 * @param avatarImg
	 * @param operateType
	 * @param pushUrls
	 */
	void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls);
}
