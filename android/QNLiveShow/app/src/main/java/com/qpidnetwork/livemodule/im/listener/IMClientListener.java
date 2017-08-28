package com.qpidnetwork.livemodule.im.listener;

import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem.BookInviteStatus;

/**
 * IM Client事件监听器
 * @author Hunter Mun
 * @since 2017-5-31
 */
public abstract class IMClientListener {
	
	// 处理结果
	public enum LCC_ERR_TYPE{
		LCC_ERR_SUCCESS,					// 成功
		LCC_ERR_FAIL,						// 服务器返回失败结果
		
		// 服务器返回错误

	    
		// 客户端定义的错误
		LCC_ERR_PROTOCOLFAIL,				// 协议解析失败（服务器返回的格式不正确）
		LCC_ERR_CONNECTFAIL,				// 连接服务器失败/断开连接
		LCC_ERR_CHECKVERFAIL,				// 检测版本号失败（可能由于版本过低导致）
		LCC_ERR_LOGINFAIL,					// 登录失败
		LCC_ERR_SVRBREAK,					// 服务器踢下线
		LCC_ERR_SETOFFLINE,					// 不能把在线状态设为"离线"，"离线"请使用Logout()
	    LCC_ERR_INVITETIMEOUT,   			// Camshare邀请已经取消
	    LCC_ERR_NOVIDEOTIMEOUT,   			// Camshare没有收到视频流超时
	    LCC_ERR_BACKGROUNDTIMEOUT    		// Camshare后台超时  
	};
	
	//邀请答复类型
	public enum InviteReplyType{
		Unknown,
		Defined,
		Accepted
	}
	
	/**
	 * 邀请答复类型
	 * @param replyType
	 * @return
	 */
	private InviteReplyType intToInviteReplyType(int replyType){
		InviteReplyType type = InviteReplyType.Unknown;
		if( replyType < 0 || replyType >= InviteReplyType.values().length ) {
			type = InviteReplyType.Unknown;
		} else {
			type = InviteReplyType.values()[replyType];
		}
		return type;
	}
	
	/**
	 * Jni层返回转Java层错误码
	 * @param errIndex
	 * @return
	 */
	private LCC_ERR_TYPE intToErrType(int errIndex){
		return LCC_ERR_TYPE.values()[errIndex];
	}
	
	/**
	 * 2.1.登录回调
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnLogin(LCC_ERR_TYPE errType, String errMsg);
	public void OnLogin(int errType, String errMsg){
		OnLogin(intToErrType(errType), errMsg);
	}
	
	/**
	 * 2.2.注销回调
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnLogout(LCC_ERR_TYPE errType, String errMsg);
	public void OnLogout(int errType, String errMsg){
		OnLogout(intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.1.观众进入直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomInfo
	 */
	public abstract void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo);
	public void OnRoomIn(int reqId, boolean success, int errType, String errMsg, IMRoomInItem roomInfo){
		OnRoomIn(reqId, success, intToErrType(errType), errMsg, roomInfo);
	}
	
	/**
	 * 3.2.观众退出直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnRoomOut(int reqId, boolean success, int errType, String errMsg){
		OnRoomOut(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 4.1.发送消息回调
	 * @param reqId
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnSendRoomMsg(int reqId, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendRoomMsg(int reqId, int errType, String errMsg){
		OnSendRoomMsg(reqId, intToErrType(errType), errMsg);
	}

	/**
	 * 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param credit
	 * @param rebateCredit
	 */
	public abstract void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double credit, double rebateCredit);
	public void OnSendGift(int reqId, boolean success, int errType, String errMsg, double credit, double rebateCredit){
		OnSendGift(reqId, success, intToErrType(errType), errMsg, credit, rebateCredit);
	}

	/**
	 * 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param credit
	 * @param rebateCredit
	 */
	public abstract void OnSendBarrage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double credit, double rebateCredit);
	public void OnSendBarrage(int reqId, boolean success, int errType, String errMsg, double credit, double rebateCredit){
		OnSendBarrage(reqId, success, intToErrType(errType), errMsg, credit, rebateCredit);
	}
	
	/**
	 * 7.1.观众立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param inviteId
	 */
	public abstract void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String inviteId);
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, int errType, String errMsg, String inviteId){
		OnSendImmediatePrivateInvite(reqId, success, intToErrType(errType), errMsg, inviteId);
	}
	
	/**
	 * 7.2.观众取消立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomId
	 */
	public abstract void OnCancelImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String roomId);
	public void OnCancelImmediatePrivateInvite(int reqId, boolean success, int errType, String errMsg, String roomId){
		OnCancelImmediatePrivateInvite(reqId, success, intToErrType(errType), errMsg, roomId);
	}
	
	/************************************   服务器推送相关        **********************************************/

	/**
	 * 2.4.用户被挤掉线通知
	 */
	public abstract void OnKickOff();
	
	/**
	 * 3.3.直播间关闭通知（用户）
	 * @param roomId
	 * @param userId
	 * @param nickName
	 */
	public abstract void OnRecvRoomCloseNotice(String roomId, String userId, String nickName);
	
	
	/**
	 * 3.4.接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
	public abstract void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum);
	
	/**
	 * 3.5.接收观众退出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
	public abstract void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum);
	
	/**
	 * 3.6.接收返点通知
	 * @param roomId
	 * @param item
	 */
	public abstract void OnRecvRebateInfoNotice(String roomId, IMRebateItem item);
	
	/**
	 * 3.7.接收关闭直播间倒数通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
	public abstract void OnRecvLeavingPublicRoomNotice(String roomId, LCC_ERR_TYPE err, String errMsg);
	public void OnRecvLeavingPublicRoomNotice(String roomId, int errType, String errMsg){
		OnRecvLeavingPublicRoomNotice(roomId, intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.8.接收踢出直播间通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 * @param credit
	 */
	public abstract void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg, double credit);
	public void OnRecvRoomKickoffNotice(String roomId, int errType, String errMsg, double credit){
		OnRecvRoomKickoffNotice(roomId, intToErrType(errType), errMsg, credit);
	}
	
	/**
	 * 3.9.接收充值通知
	 * @param roomId
	 * @param message
	 * @param credit
	 */
	public abstract void OnRecvLackOfCreditNotice(String roomId, String message, double credit);
	
	/**
	 * 3.10.接收定时扣费通知
	 * @param roomId
	 * @param credit
	 */
	public abstract void OnRecvCreditNotice(String roomId, double credit);
	
	/**
	 * 3.11.直播间开播通知
	 * @param roomId
	 * @param leftSeconds		开播前的倒数秒数
	 */
	public abstract void OnRecvLiveStart(String roomId, int leftSeconds);
	
	/**
	 * 4.2.观众端/主播端向直播间发送文本消息
	 * @param roomId
	 * @param level
	 * @param fromId
	 * @param nickName
	 * @param msg
	 */
	public abstract void OnRecvRoomMsg(String roomId, int level, String fromId, String nickName, String msg);
	
	/**
	 * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param giftId
	 * @param giftName
	 * @param giftNum
	 * @param multi_click
	 * @param multi_click_start
	 * @param multi_click_end
	 * @param multiClickId
	 */
	public abstract void OnRecvRoomGiftNotice(String roomId, String fromId, String nickName, String giftId, String giftName, int giftNum, 
			boolean multi_click, int multi_click_start, int multi_click_end, int multiClickId);
	
	/**
	 * 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param msg
	 */
	public abstract void OnRecvRoomToastNotice(String roomId, String fromId, String nickName, String msg);
	
	/**
	 * 7.3.接收立即私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 * @param roomId
	 */
	public abstract void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId);
	public void OnRecvInviteReply(String inviteId, int replyType, String roomId){
		OnRecvInviteReply(inviteId, intToInviteReplyType(replyType), roomId);
	}
	
	/**
	 * 7.4.接收主播立即私密邀请通知
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 */
	public abstract void OnRecvAnchoeInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl);
	
	/**
	 * 7.5.接收主播预约私密邀请通知
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 * @param bookTime
	 * @param inviteId
	 */
	public abstract void OnRecvScheduledInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl, int bookTime, String inviteId);
}
