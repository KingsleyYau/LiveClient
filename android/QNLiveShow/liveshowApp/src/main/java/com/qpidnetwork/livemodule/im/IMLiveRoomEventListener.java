package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;

/**
 * 直播间仅有相关事件
 * @author Hunter Mun
 * @since 2018.8.21
 */
public interface IMLiveRoomEventListener {
	/**
	 * 3.3.直播间关闭通知（用户）
	 * @param roomId
	 */
    void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 3.4.接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
    void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum);


	/**
	 * 3.5.接收观众退出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
    void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum);

	/**
	 * 3.6.接收返点通知
	 * @param roomId
	 * @param item
	 */
    void OnRecvRebateInfoNotice(String roomId, IMRebateItem item);

	/**
	 * 3.7.接收关闭直播间倒数通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
    void OnRecvLeavingPublicRoomNotice(String roomId, LCC_ERR_TYPE err, String errMsg);

	/**
	 * 3.8.接收踢出直播间通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 * @param credit
	 */
    void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg, double credit);

	/**
	 * 3.12.接收观众/主播切换视频流通知接口
	 * @param roomId
	 * @param isAnchor
	 * @param playUrl
	 */
    void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String playUrl);

	/**
	 * 3.14.观众开始／结束视频互动接口
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param manPushUrl
	 */
	void OnControlManPush(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl);

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
	 * @param credit
	 * @param rebateCredit
	 */
    void OnSendGift(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit);

	/**
	 * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
	 * @param msgItem
	 */
    void OnRecvRoomGiftNotice(IMMessageItem msgItem);

	/**
	 * 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 * @param credit
	 * @param rebateCredit
	 */
    void OnSendBarrage(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit);

	/**
	 * 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param msgItem
	 */
    void OnRecvRoomToastNotice(IMMessageItem msgItem);

	/**
	 * 8.1.发送直播间才艺点播邀请回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
    void OnSendTalent(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 8.2.接收直播间才艺点播回复通知
	 * @param roomId
	 * @param talentInviteId
	 * @param talentId
	 * @param name
	 * @param credit
	 * @param status
	 * @param rebateCredit
	 */
    void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, IMClientListener.TalentInviteStatus status, double rebateCredit);
}
