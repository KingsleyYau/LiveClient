package com.qpidnetwork.im;

import com.qpidnetwork.im.listener.IMClientListener;

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
	 * 获取当前用户账号
	 * @return
	 */
	static public native String GetUser();
	
	/**
	 * 3.1. 观众进入直播间
	 * @param reqId
	 * @param token
	 * @param roomId
	 * @return
	 */
	static public native boolean FansRoomIn(int reqId, String token, String roomId);
	
	/**
	 * 3.2. 观众退出直播间
	 * @param reqId
	 * @param token
	 * @param roomId
	 * @return
	 */
	static public native boolean FansRoomOut(int reqId, String token, String roomId);
	
	/**
	 * 3.6. 获取直播间信息
	 * @param reqId
	 * @param token
	 * @param roomId
	 * @return
	 */
	static public native boolean GetRoomInfo(int reqId, String token, String roomId);
	
	/**
	 * 3.7. 主播禁言观众
	 * @param reqId
	 * @param roomId
	 * @param userId
	 * @param timeout
	 * @return
	 */
	static public native boolean AnchorForbidMessage(int reqId, String roomId, String userId, int timeout);
	
	/**
	 * 3.9. 主播踢观众出直播间
	 * @param reqId
	 * @param roomId
	 * @param userId
	 * @return
	 */
	static public native boolean AnchorKickOffAudience(int reqId, String roomId, String userId);
	
	/**
	 * 4.1. 发送聊天消息
	 * @param reqId
	 * @param token
	 * @param roomId
	 * @param nickName
	 * @param msg
	 * @return
	 */
	static public native boolean SendRoomMsg(int reqId, String token, String roomId, String nickName, String msg);
	
	/**
	 * 5.1. 发送直播间点赞消息
	 * @param reqId
	 * @param roomId
	 * @param token
	 * @return
	 */
	static public native boolean SendLikeEvent(int reqId, String roomId, String token, String nickName);
	
	/**
	 * 6.1. 发送直播间礼物消息
	 * @param reqId
	 * @param roomId
	 * @param token
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
	static public native boolean SendGift(int reqId, String roomId, String token, String nickName, String giftId, String giftName, int count, 
			boolean isMultiClick, int multiStart, int multiEnd, int multiClickId);
	
	/**
	 * 7.1. 发送直播间弹幕消息
	 * @param reqId
	 * @param roomId
	 * @param token
	 * @param nickName
	 * @param message
	 * @return
	 */
	static public native boolean SendBarrage(int reqId, String roomId, String token, String nickName, String message);
	
}
