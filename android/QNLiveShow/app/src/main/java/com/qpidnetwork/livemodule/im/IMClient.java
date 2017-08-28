package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;

/**
 * IM Client类
 * @author Hunter Mun
 * @since 2017-5-31
 */
public class IMClient {
	
	static {
        try {
            System.loadLibrary("im-interface");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
	
	/**
	 * IM Client 参数初始化
	 * @param urlList
	 * @param listemer
	 * @return
	 */
	static public native boolean init(String[] urlList, IMClientListener listemer);
	
	/**
	 * 由底层控制生成请求唯一Seq Id，上层传入（用于区分不同请求）
	 * 	reqId<0为无效Id
	 * @return
	 */
	static public native int GetReqId();
	
	/**
	 * 检测seq有效性
	 * @param reqId
	 * @return
	 */
	static public native boolean IsInvalidReqId(int reqId);
	
	/**
	 * 登录
	 * @param userId
	 * @param token
	 * @return
	 */
	static public native boolean Login(String userId, String token);
	
	/**
	 * 注销断开连接
	 * @return
	 */
	static public native boolean Logout();
	
	/**
	 * 3.1. 观众进入直播间
	 * @param reqId			seqenceId
	 * @param roomId		房间Id
	 * @return
	 */
	static public native boolean RoomIn(int reqId, String roomId);
	
	/**
	 * 3.2. 观众退出直播间
	 * @param reqId
	 * @param roomId
	 * @return
	 */
	static public native boolean RoomOut(int reqId, String roomId);
	
	/**
	 * 4.1. 发送聊天消息
	 * @param reqId
	 * @param roomId
	 * @param nickName
	 * @param msg
	 * @param targetIds		用户ID，用于指定接收者（字符串数组）
	 * @return
	 */
	static public native boolean SendRoomMsg(int reqId, String roomId, String nickName, String msg, String[] targetIds);
	
	/**
	 * 5.1. 发送直播间礼物消息
	 * @param reqId
	 * @param roomId
	 * @param nickName
	 * @param giftId
	 * @param giftName
	 * @param count
	 * @param isMultiClick
	 * @param multiStart
	 * @param multiEnd
	 * @param multiClickId
	 * @return
	 */
	static public native boolean SendGift(int reqId, String roomId, String nickName, String giftId, String giftName, int count, 
			boolean isMultiClick, int multiStart, int multiEnd, int multiClickId);
	
	/**
	 * 6.1. 发送直播间弹幕消息
	 * @param reqId
	 * @param roomId
	 * @param nickName
	 * @param message
	 * @return
	 */
	static public native boolean SendBarrage(int reqId, String roomId, String nickName, String message);
	
	/**
	 * 7.1.观众立即私密邀请
	 * @param reqId
	 * @param userId
	 * @param isInitiative	主动发起/收到主播端通知后发起
	 * @return
	 */
	static public native boolean SendImmediatePrivateInvite(int reqId, String userId, boolean isInitiative);
	
	/**
	 * 7.2.观众取消立即私密邀请
	 * @param reqId
	 * @param inviteId
	 * @return
	 */
	static public native boolean CancelImmediatePrivateInvite(int reqId, String inviteId);
}
