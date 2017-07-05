package com.qpidnetwork.im.listener;

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
	public abstract void OnFansRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInfoItem roomInfo);
	public void OnFansRoomIn(int reqId, boolean success, int errType, String errMsg, IMRoomInfoItem roomInfo){
		OnFansRoomIn(reqId, success, intToErrType(errType), errMsg, roomInfo);
	}
	
	/**
	 * 3.2.观众退出直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnFansRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnFansRoomOut(int reqId, boolean success, int errType, String errMsg){
		OnFansRoomOut(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.6.获取直播间信息
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param fansNum
	 * @param contribute
	 */
	public abstract void OnGetRoomInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, int fansNum, int contribute);
	public void OnGetRoomInfo(int reqId, boolean success, int errType, String errMsg, int fansNum, int contribute){
		OnGetRoomInfo(reqId, success, intToErrType(errType), errMsg, fansNum, contribute);
	}
	
	/**
	 * 3.7.主播禁言观众（直播端把制定观众禁言）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnAnchorForbidMessage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnAnchorForbidMessage(int reqId, boolean success, int errType, String errMsg){
		OnAnchorForbidMessage(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnAnchorKickOffAudience(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnAnchorKickOffAudience(int reqId, boolean success, int errType, String errMsg){
		OnAnchorKickOffAudience(reqId, success, intToErrType(errType), errMsg);
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
	 * 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnSendLikeEvent(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendLikeEvent(int reqId, boolean success, int errType, String errMsg){
		OnSendLikeEvent(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param coins
	 */
	public abstract void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double coins);
	public void OnSendGift(int reqId, boolean success, int errType, String errMsg, double coins){
		OnSendGift(reqId, success, intToErrType(errType), errMsg, coins);
	}
	
	/**
	 * 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param coins
	 */
	public abstract void OnSendBarrage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double coins);
	public void OnSendBarrage(int reqId, boolean success, int errType, String errMsg, double coins){
		OnSendBarrage(reqId, success, intToErrType(errType), errMsg, coins);
	}
	
	/************************************   服务器推送相关        **********************************************/
	
	/**
	 * 2.4.用户被挤掉线通知
	 * @param reason
	 */
	public abstract void OnKickOff(String reason);
	
	/**
	 * 3.3.直播间关闭通知（用户）
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param fansNum
	 */
	public abstract void OnRecvRoomCloseFans(String roomId, String userId, String nickName, int fansNum);
	
	/**
	 * 3.4.主播端接收服务器的直播间关闭通知
	 * @param roomId
	 * @param fansNum
	 * @param inCome
	 * @param newFans
	 * @param shares
	 * @param duration
	 */
	public abstract void OnRecvRoomCloseBroad(String roomId, int fansNum, int inCome, int newFans, int shares, int duration);
	
	/**
	 * 3.5.观众端/主播端接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 */
	public abstract void OnRecvFansRoomIn(String roomId, String userId, String nickName, String photoUrl);
	
	/**
	 * 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param timeOut
	 */
	public abstract void OnRecvShutUpNotice(String roomId, String userId, String nickName, int timeOut);
	
	/**
	 * 3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）
	 * @param roomId
	 * @param userId
	 * @param nickName
	 */
	public abstract void OnRecvKickOffRoomNotice(String roomId, String userId, String nickName);
	
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
	 * 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param isFirst
	 */
	public abstract void OnRecvPushRoomFav(String roomId, String fromId, String nickName, boolean isFirst);
	
	/**
	 * 6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
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
	 * 7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param msg
	 */
	public abstract void OnRecvRoomToastNotice(String roomId, String fromId, String nickName, String msg);
	
}
