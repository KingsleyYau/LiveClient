package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;

/**
 * IM Client类
 * @author Hunter Mun
 * @since 2017-5-31
 */
public class IMClient {
	
	//视频互动操作类型
	public enum IMVideoInteractiveOperateType{
		Start,		//开始
		Close		//关闭
	}
	
	static {
        try {
            System.loadLibrary("im-interface");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

	/**
	 * 设置日志目录
	 * @param directory		日志目录
	 */
	static public native boolean IMSetLogDirectory(String directory);

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
	 * @param token
	 * @return
	 */
	static public native boolean Login(String token);
	
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
	 * 3.13.观众进入公开直播间
	 * @param reqId
	 * @param anchorId
	 * @return
	 */
	static public native boolean PublicRoomIn(int reqId, String anchorId);
	
	/**
	 * 3.14.观众开始/结束视频互动
	 * @param reqId
	 * @param roomId    	直播间ID
	 * @param operateType   
	 * @return
	 */
	static public boolean ControlManPush(int reqId, String roomId, IMVideoInteractiveOperateType operateType) {
		return ControlManPush(reqId, roomId, operateType.ordinal());
	}
	static public native boolean ControlManPush(int reqId, String roomId, int operateType);
		
	
	/**
	 * 3.15.获取指定立即私密邀请信息
	 * @param reqId
	 * @param invitetionId  邀请ID
	 * @return
	 */
	static public native boolean GetInviteInfo(int reqId, String invitetionId);
	
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
	 * @param isPackage
	 * @param count
	 * @param isMultiClick
	 * @param multiStart
	 * @param multiEnd
	 * @param multiClickId
	 * @return
	 */
	static public native boolean SendGift(int reqId, String roomId, String nickName, String giftId, String giftName, boolean isPackage, int count, 
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
	 * @param logId	主播邀请的记录ID(用于区分主播发起/用户发起)
	 * @param force
	 * @return
	 */
	static public native boolean SendImmediatePrivateInvite(int reqId, String userId, String logId, boolean force);
	
	/**
	 * 7.2.观众取消立即私密邀请
	 * @param reqId
	 * @param inviteId
	 * @return
	 */
	static public native boolean CancelImmediatePrivateInvite(int reqId, String inviteId);

	/**
	 * 7.8.观众端是否显示主播立即私密邀请
	 * @param reqId
	 * @param inviteId
	 * @param isShow
	 * @return
	 */
    static public native boolean InstantInviteUserReport(int reqId, String inviteId, boolean isShow);
	
	/**
	 * 8.1.发送直播间才艺点播邀请
	 * @param reqId
	 * @param roomId
	 * @param talentId
	 * @return
	 */
	static public native boolean SendTalentInvite(int reqId, String roomId, String talentId);

	/**
	 * 10.3.观众新建/进入多人互动直播间
	 * @param reqId
	 * @param roomId		直播间ID（可无，无则表示新建，否则表示进入）
	 * @return
	 */
	static public native boolean EnterHangoutRoom(int reqId, String roomId);

	/**
	 * 10.4.退出多人互动直播间
	 * @param reqId
	 * @param roomId		多人互动直播间ID
	 * @return
	 */
	static public native boolean LeaveHangoutRoom(int reqId, String roomId);

	/**
	 * 10.7. 发送多人互动直播间礼物消息
	 * @param reqId
	 * @param roomId				直播间ID
	 * @param nickName				发送人昵称
	 * @param toUid					接收者ID（可无，无则表示发送给所有人）
	 * @param giftId				礼物ID
	 * @param giftName				礼物名称
	 * @param isBackpack			是否背包礼物（1：是，0：否）
	 * @param isPrivate				是否私密发送（1：是，0：否）
	 * @param giftNum				本次发送礼物的数量
	 * @param isMultiClick			是否连击礼物（1：是，0：否）
	 * @param multiStart			显示的连击起始值（可无，multi_click=0则无）
	 * @param multiEnd				显示的连击结束值（可无，multi_click=0则无）
	 * @param multiClickId			连击ID，相同则表示是同一次连击（生成方式：timestamp秒%10000）（整型）（可无，multi_click=0则无）
	 * @return
	 */
	static public native boolean SendHangoutGift(int reqId, String roomId, String nickName, String toUid, String giftId, String giftName, boolean isBackpack, boolean isPrivate, int giftNum,
										  boolean isMultiClick, int multiStart, int multiEnd, int multiClickId);

	/**
	 * 10.11.多人互动观众开始/结束视频互动
	 * @param reqId
	 * @param roomId    	直播间ID
	 * @param operateType
	 * @return
	 */
	static public boolean ControlManPushHangout(int reqId, String roomId, IMVideoInteractiveOperateType operateType) {
		return ControlManPushHangout(reqId, roomId, operateType.ordinal());
	}
	static public native boolean ControlManPushHangout(int reqId, String roomId, int operateType);

	/**
	 * 10.12.发送多人互动直播间文本消息
	 * @param reqId
	 * @param roomId
	 * @param nickName
	 * @param msg
	 * @param targetIds		用户ID，用于指定接收者（字符串数组）
	 * @return
	 */
	static public native boolean SendHangoutRoomMsg(int reqId, String roomId, String nickName, String msg, String[] targetIds);

	static public native long GetIMClient();

}
