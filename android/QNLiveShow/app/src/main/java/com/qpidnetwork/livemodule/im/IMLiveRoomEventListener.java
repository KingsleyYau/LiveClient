package com.qpidnetwork.livemodule.im;

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
	 * 3.2. 观众退出直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	
	/**
	 * 4.1.发送消息回调
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 */
	public void OnSendRoomMsg(LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem);
	
	/**
	 * 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 * @param credit
	 * @param rebateCredit
	 */
	public void OnSendGift(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit);
	
	/**
	 * 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 * @param credit
	 * @param rebateCredit
	 */
	public void OnSendBarrage(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit);
	
	/**
	 * 3.3.直播间关闭通知（用户）
	 * @param roomId
	 * @param userId
	 * @param nickName
	 */
	public void OnRecvRoomCloseNotice(String roomId, String userId, String nickName);

	/**
	 * 3.4.接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param riderId
	 * @param riderName
	 * @param riderUrl
	 * @param fansNum
	 */
	public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum);
	
	/**
	 * 3.5.接收观众退出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
	public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum);
	
	/**
	 * 3.6.接收返点通知
	 * @param roomId
	 * @param item
	 */
	public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item);

	/**
	 * 3.7.接收关闭直播间倒数通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
	public void OnRecvLeavingPublicRoomNotice(String roomId, LCC_ERR_TYPE err, String errMsg);
	
	/**
	 * 3.8.接收踢出直播间通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 * @param credit
	 */
	public void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg, double credit);

	/**
	 * 4.2.观众端/主播端向直播间发送文本消息
	 * @param msgItem
	 */
	public void OnRecvRoomMsg(IMMessageItem msgItem);

	/**
	 * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
	 * @param msgItem
	 */
	public void OnRecvRoomGiftNotice(IMMessageItem msgItem);

	/**
	 * 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param msgItem
	 */
	public void OnRecvRoomToastNotice(IMMessageItem msgItem);
}
