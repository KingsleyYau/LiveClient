package com.qpidnetwork.livemodule.livemessage;

import com.qpidnetwork.livemodule.livemessage.item.LMClientListener;
import com.qpidnetwork.livemodule.livemessage.item.LMPrivateMsgContactItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;

/**
 * LM Client类
 * @author Hunter Mun
 * @since 2017-5-31
 */
public class LMClient {

	// 直播私信支持类型
	public enum LMPrivateMsgSupportType{
		Unkown,				// 未知
		PrivateText,		// 私信文本
		Dynamic				// 动态
	}

	static {
        try {
            System.loadLibrary("livemessagemanmanager-interface");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

	/**
	 * 设置日志目录
	 * @param directory		日志目录
	 */
	static public native boolean LMSetLogDirectory(String directory);

	/**
	 * LM 消息管理器 创建（在http 登录前创建，Init是http登录成功才创建的，导致没有调用onloginhandle那时管理器是null的）
	 * @return
	 */

	static public boolean InitLMManager(String userId, LMPrivateMsgSupportType[] supportList, long imClient, LMClientListener listener, String privateStartNotice) {
		int[] supArray = new int[supportList.length];
		for (int i = 0; i < supportList.length; i++) {
			supArray[i] = supportList[i].ordinal();
		}
		return InitLMManager(userId, supArray, imClient, listener, privateStartNotice);
	}
	static protected native boolean InitLMManager(String userId, int[] supportList, long imClient, LMClientListener listener, String privateStartNotice);
	/**
	 * LM 消息管理器 参数初始化 （这个要在imClient有的时候创建，就是IMClient.init()后面创建）
	 * @param imClient						im的JNI里面的ImClient（指针转为long）
	 * @param listemer
	 * @return
	 */
//	static public boolean Init(long imClient, LMClientListener listemer, LMPrivateMsgSupportType[] supportList) {
//		int[] supArray = new int[supportList.length];
//		for (int i = 0; i < supportList.length; i++) {
//			supArray[i] = supportList[i].ordinal();
//		}
//		return Init(imClient, listemer, supArray);
//	}
//	static public native boolean Init(long imClient, LMClientListener listemer);

	/**
	 * LM 消息管理器 释放LM管理器（用于登出）
	 * @return
	 */
	static public native boolean ReleaseLMManager(long imClient);


	/**
	 * LM 消息管理器 获取本地私信联系人列表
	 * @return
	 */
	static public native LMPrivateMsgContactItem[] GetLocalPrivateMsgFriendList();

	/**
	 * LM 消息管理器 获取私信联系人列表
	 * @return
	 */
	static public native boolean GetPrivateMsgFriendList();

	/**
	 * LM 消息管理器 获取本地私信关注联系人列表
	 * @return
	 */
	static public native LMPrivateMsgContactItem[] GetLocalFollowPrivateMsgFriendList();

	/**
	 * LM 消息管理器 获取私信关注联系人列表
	 * @return
	 */
	static public native boolean GetFollowPrivateMsgFriendList(OnGetPrivateMsgFriendListCallback callback);

	/**
	 * LM 消息管理器 添加私信在聊列表在聊用户
	 * @return ture： 添加成功， false：失败（可能已经增加过了，或userId为""）
	 */
	static public native boolean AddPrivateMsgLiveChatList(String userId);

	/**
	 * LM 消息管理器 移除私信在聊列表在聊用户
	 * @return ture： 移除成功， false：失败（可能列表没有这个用户，或userId为""）
	 */
	static public native boolean RemovePrivateMsgLiveChatList(String userId);

	/**
	 * LM 消息管理器 获取本地私信消息
	 * @param userId			对方的userId
	 * @return 私信消息队列
	 */
	static public native LiveMessageItem[] GetLocalPrivateMsgWithUserId(String userId);

	/**
	 * LM 消息管理器 刷新用户私信消息
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	static public native int RefreshPrivateMsgWithUserId(String userId);

	/**
	 * LM 消息管理器 获取更多私信消息
	 * @param userId			对方的userId
	 * @return 返回请求Id
	 */
	static public native int GetMorePrivateMsgWithUserId(String userId);

	/**
	 * LM 消息管理器 提交阅读私信（用于私信聊天间，向服务器提交已读私信）
	 * @param userId			对方的userId
	 * @return
	 */
	static public native boolean SetPrivateMsgReaded(String userId, OnSetPrivatemsgReadedCallback callback);

	/**
	 * LM 消息管理器 		发送私信消息
	 * @param userId			对方的userId
	 * @param message			发送内容
	 * @return
	 */
	static public native boolean SendPrivateMessage(String userId, String message);

	/**
	 * LM 消息管理器 		        重新发送私信消息
	 * @param userId			对方的userId
	 * @param sendMsgId			msgId消息的唯一标识位
	 * @return
	 */
	static public native boolean RepeatSendPrivateMsg(String userId, int sendMsgId);

}
