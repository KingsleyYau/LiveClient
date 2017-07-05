package com.qpidnetwork.im;

import com.qpidnetwork.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.im.listener.IMRoomInfoItem;

/**
 * IM事件监听器接口
 * @author Hunter Mun
 * @since 2017-6-1
 */
public interface IIMEventListener {
	
	/**
	 * IM登录通知
	 * @param errType
	 * @param errMsg
	 */
    void OnLogin(LCC_ERR_TYPE errType, String errMsg);
	
	/**
	 * IM注销通知
	 * @param errType
	 * @param errMsg
	 */
    void OnLogout(LCC_ERR_TYPE errType, String errMsg);
	
	/**
	 * 观众进入直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomInfo
	 */
    void OnFansRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInfoItem roomInfo);
	
	/**
	 * 观众退出直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
    void OnFansRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	
	/**
	 * 发送消息回调
	 * @param errType
	 * @param errMsg
	 * @param msgItem
	 */
    void OnSendMsg(LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem);

	/**
	 * 获取房间信息回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param fansNum
	 * @param contribute
	 */
    void OnGetRoomInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, int fansNum, int contribute);

	/**
	 * 主播禁言观众回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
    void OnAnchorForbidMessage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);

	/**
	 * 主播踢观众出房间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
    void OnAnchorKickOffAudience(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	
	/**************************************  服务器主动通知    ************************************************/

	/**
	 * 用户被踢通知
	 * @param reason
	 */
    void OnKickOff(String reason);

	/**
	 * 直播间关闭通知（用户）
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param fansNum
	 */
    void OnRecvRoomCloseFans(String roomId, String userId, String nickName, int fansNum);
	
	/**
	 * 主播端接收服务器的直播间关闭通知
	 * @param roomId
	 * @param fansNum
	 * @param inCome
	 * @param newFans
	 * @param shares
	 * @param duration
	 */
    void OnRecvRoomCloseBroad(String roomId, int fansNum, int inCome, int newFans, int shares, int duration);
	
	/**
	 * 观众端/主播端接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 */
    void OnRecvFansRoomIn(String roomId, String userId, String nickName, String photoUrl);

	/**
	 * 接收直播间禁言通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param timeOut
	 */
    void OnRecvShutUpNotice(String roomId, String userId, String nickName, int timeOut);

	/**
	 * 接收观众踢出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 */
    void OnRecvKickOffRoomNotice(String roomId, String userId, String nickName);

	/**
	 * 收到消息推送
	 * @param msgItem
	 */
    void OnRecvMsg(IMMessageItem msgItem);

	/**
	 * 点赞通知
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 */
    void OnRecvPushRoomFav(String roomId, String fromId, String nickName);

	/**
	 * 金币更新
	 * @param coins
	 */
	void OnCoinsUpdate(double coins);
	
}
