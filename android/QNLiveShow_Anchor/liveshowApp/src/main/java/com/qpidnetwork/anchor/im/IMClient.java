package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.im.listener.IMClientListener;

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
	 * 2.1.登录
	 * @param token
	 * @return
	 */
	static public native boolean Login(String token);
	
	/**
	 * 2.2.注销断开连接
	 * @return
	 */
	static public native boolean Logout();


	/**
	 * 3.1.新建/进入公开直播间
	 * @param reqId
	 * @return
	 */
	static public native boolean PublicRoomIn(int reqId);
	
	/**
	 * 3.2. 主播进入指定直播间
	 * @param reqId			seqenceId
	 * @param roomId		房间Id
	 * @return
	 */
	static public native boolean RoomIn(int reqId, String roomId);
	
	/**
	 * 3.3. 主播退出直播间
	 * @param reqId
	 * @param roomId
	 * @return
	 */
	static public native boolean RoomOut(int reqId, String roomId);

	/**
	 * 4.1. 发送直播间文本消息
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
	 * 9.1.主播发送立即私密邀请
	 * @param reqId
	 * @param userId
	 * @return
	 */
	static public native boolean SendImmediatePrivateInvite(int reqId, String userId);

	/**
	 * 9.5.获取指定立即私密邀请信息
	 * @param reqId
	 * @param invitetionId  邀请ID
	 * @return
	 */
	static public native boolean GetInviteInfo(int reqId, String invitetionId);

	/**
	 * 10.1.进入多人互动直播间
	 * @param reqId
	 * @param roomId  直播间ID
	 * @return
	 */
	static public native boolean EnterHangoutRoom(int reqId, String roomId);

	/**
	 * 10.2.退出多人互动直播间
	 * @param reqId
	 * @param roomId  直播间ID
	 * @return
	 */
	static public native boolean LeaveHangoutRoom(int reqId, String roomId);

	/**
	 * 10.11.发送多人互动礼物消息
	 * @param reqId         请求序列号
	 * @param roomId              直播间ID
	 * @param nickName            发送人昵称
	 * @param toUid               接收者ID
	 * @param giftId              礼物ID
	 * @param giftName            礼物名称
	 * @param isBackPack          是否背包礼物（1：是，0：否）
	 * @param giftNum             本次发送礼物的数量
	 * @param isMultiClick        是否连击礼物（1：是，0：否）
	 * @param multiClickStart     连击起始数（整型）（可无，multi_click=0则无）
	 * @param multiClickEnd       连击结束数（整型）（可无，multi_click=0则无）
	 * @param multiClickId        连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则无）
	 * @param isPrivate           是否私密发送（1：是，0：否）
	 * @return
	 */
	static public native boolean SendHangoutGift(int reqId, String roomId, String nickName, String toUid, String giftId, String giftName, boolean isBackPack, int giftNum, boolean isMultiClick, int multiClickStart, int multiClickEnd, int multiClickId, boolean isPrivate);

	/**
	 * 10.14.发送多人互动直播间文本消息
	 * @param reqId
	 * @param roomId
	 * @param nickName
	 * @param msg
	 * @param targetIds		用户ID，用于指定接收者（字符串数组）
	 * @return
	 */
	static public native boolean SendHangoutMsg(int reqId, String roomId, String nickName, String msg, String[] targetIds);

}
