package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusProtocol;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.KickOfflineType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkEmfNoticeType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerOtherListener {
	/**
	 * 登录回调
	 * @param errType	错误类型
	 * @param errmsg	错误描述
	 * @param isAutoLogin	自动重登录
	 */
	public void OnLogin(LiveChatErrType errType, String errmsg, boolean isAutoLogin);
	
	/**
	 * 注销/断线回调
	 * @param errType	错误类型
	 * @param errmsg	错误描述
	 * @param isAutoLogin	是否自动登录
	 */
	public void OnLogout(LiveChatErrType errType, String errmsg, boolean isAutoLogin);
	
	/**
	 * 获取在聊及邀请用户列表回调（成功则可调用GetInviteUsers()及GetChatingUsers()获取邀请或在聊的用户列表）
	 * @param errType	错误类型
	 * @param errmsg	错误描述
	 */
	public void OnGetTalkList(LiveChatErrType errType, String errmsg);
	
	/**
	 * 获取单个用户历史聊天记录（包括文本、高级表情、语音、图片）
	 * @param errno		错误代码
	 * @param errmsg	错误描述
	 * @param userItem	用户item
	 */
	public void OnGetHistoryMessage(boolean success, String errno, String errmsg, LCUserItem userItem);
	
	/**
	 * 获取多个用户历史聊天记录（包括文本、高级表情、语音、图片）
	 * @param errno		错误代码
	 * @param errmsg	错误描述
	 * @param userItems	用户items
	 */
	public void OnGetUsersHistoryMessage(boolean success, String errno, String errmsg, LCUserItem[] userItems);
	
	// ---------------- 在线状态相关回调函数(online status) ----------------
	/**
	 * 设置在线状态回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public void OnSetStatus(LiveChatErrType errType, String errmsg);
	
	
	/**
	 * 获取用户在线状态回调
	 * @param errType	错误类型
	 * @param errmsg	错误描述
	 * @param userList	用户列表
	 */
	public void OnGetUserStatus(LiveChatErrType errType, String errmsg, LCUserItem[] userList);
	
	/**
	 * 获取指定女士信息回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param item
	 */
	public void OnGetUserInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item);
	
	/**
	 * 批量获取女士信息回调
	 * @param errType
	 * @param errmsg
	 * @param itemList
	 */
	public void OnGetUsersInfo(LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList);

	/**
	 * LiveChat获取联系人列表
	 * @param errType
	 * @param errmsg
	 * @param list
	 */
	public void OnGetContactList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list);
	
	/**
	 * 接收他人在线状态更新消息回调
	 * @param userItem	用户item
	 */
	public void OnUpdateStatus(LCUserItem userItem);
	
	/**
	 * 他人在线状态更新回调
	 * @param userItem	用户item
	 */
	public void OnChangeOnlineStatus(LCUserItem userItem);
	
	/**
	 * 接收被踢下线消息回调
	 * @param kickType	被踢下线原因
	 */
	public void OnRecvKickOffline(KickOfflineType kickType);
	
	// ---------------- 其它回调函数(Other) ----------------
	/**
	 * 接收邮件更新消息回调
	 * @param fromId		发送者ID
	 * @param noticeType	邮件类型
	 */
	public void OnRecvEMFNotice(String fromId, TalkEmfNoticeType noticeType);
	
	// ---------------- 女士端Cam状态相关回调函数(cam status) ----------------
	
	/**
	 * 获取女士Cam状态回调
	 * @param errType
	 * @param errmsg
	 * @param womanId
	 * @param isCam
	 */
	public void OnGetLadyCamStatus(LiveChatErrType errType, String errmsg, String womanId, boolean isCam);
	
	/**
	 * 批量获取用户Cam状态
	 * @param errType
	 * @param errmsg
	 * @param userIds
	 */
	public void OnGetUsersCamStatus(LiveChatErrType errType, String errmsg, LiveChatUserCamStatus[] userIds);
	
	/**
	 * 女士端Cam状态更新
	 * @param userId
	 * @param statuType
	 */
	public void OnRecvLadyCamStatus(String userId, UserStatusProtocol statuType);
	
	/**
	 * 获取当前会话信息回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param item
	 */
	public void OnGetSessionInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatSessionInfoItem item);
}
