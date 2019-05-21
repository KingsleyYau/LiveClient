package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.StatusType;
import com.qpidnetwork.livemodule.livechat.LCUserItem.ChatType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.InviteStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserSexType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkMsgType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Random;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 邀请管理器
 * @author Samson Fan
 *
 */
public class LCNormalInviteManager {
	/**
	 * 是否已初始化
	 */
	private boolean mIsInit;
	/**
	 * 用户管理器
	 */
	private LCUserManager mUserMgr;
	/**
	 * 黑名单管理器
	 */
	private LCBlockManager mBlockMgr;
	/**
	 * LiveChat联系人管理器
	 */
	private LCContactManager mContactMgr;
	
	/**
	 * 女士信息本地缓存
	 */
	private LCUserInfoManager mUserInfoManager;
	
	/**
	 * 邀请用户列表
	 */
	private ArrayList<LCUserItem> mInviteUserList;
	
	/**
	 * 超时时间间隔 单位（秒）
	 */
	private final long mOverTimeInterval;
	
	/**
	 * 当前处理次数
	 */
	private int mHandleCount;
	/**
	 * 最大非随机处理数（最多多少次就要有一次随机）
	 */
	private final int mMaxNoRandomCount;
	/**
	 * 随机处理次数（第几次处理是随机的）
	 */
	private int mRandomHandle;
	/**
	 * 随机数生成器
	 */
	private Random mRandom;
	
	public LCNormalInviteManager() 
	{
		mInviteUserList = new ArrayList<LCUserItem>();
		
		//设置消息超时间隔
		mOverTimeInterval = 25;
		// 当前处理次数 
		mHandleCount = 0;
		// 最大非随机处理数
		mMaxNoRandomCount = 10;
		// 随机处理次数（第几次处理是随机的）
		mRandomHandle = 0;
		// 随机数生成器
		mRandom = new Random();
		
		mIsInit = false;
		mUserMgr = null;
		mBlockMgr = null;
		mContactMgr = null;
	}
	
	public boolean init(LCUserManager userMgr
			, LCBlockManager blockMgr
			, LCContactManager contactMgr
			, LCUserInfoManager userInfoManager)
	{
		boolean result = false;
		
		mUserMgr = userMgr;
		mBlockMgr = blockMgr;
		mContactMgr = contactMgr;
		mUserInfoManager = userInfoManager;
		
		if (null != mUserMgr) {
			result = true;
		}
		
		mIsInit = result;
		
		return result;
	}
	
	/**
	 * 邀请消息处理结果类型
	 */
	public enum HandleInviteMsgType
	{
		/**
		 * 丢弃
		 */
		LOST,
		/**
		 * 通过
		 */
		PASS,
		/**
		 * 需要处理
		 */
		HANDLE,
	}
	
	/**
	 * 判断是否需要处理的邀请消息
	 * @param userId	用户ID
	 * @param charge	是否已付费
	 * @param type		消息付费类型
	 * @return
	 */
	public synchronized HandleInviteMsgType IsToHandleInviteMsg(String userId, boolean charge, TalkMsgType type)
	{
		HandleInviteMsgType result = HandleInviteMsgType.PASS;
		if (mIsInit) {
			// 已经完成初始化，可以进行过滤
			if (ChatType.Invite == LCUserItem.getChatTypeWithTalkMsgType(charge, type)) 
			{
				boolean handle = false;
				// 是否黑名单用户
				if (mBlockMgr.IsExist(userId)) {
					result = HandleInviteMsgType.LOST;
					handle = true;
				}
				
				// 是否联系人
				if (!handle) {
					if (mContactMgr.IsExist(userId)) {
						result = HandleInviteMsgType.PASS;
						handle = true;
					}
				}
				
				// 是否最近联系人
				if (!handle) {
//					ContactBean contact = ContactManager.getInstance().getContactById(userId);
//					if (null == contact) {
//						result = HandleInviteMsgType.HANDLE;
//						handle = true;
//					}
				}
			}
		}
		
		return result;
	}
	
//	/**
//	 * 用户是否已存在
//	 * @param userId
//	 * @return
//	 */
//	private boolean IsUserExist(String userId)
//	{
//		boolean result = false;
//		synchronized (mInviteUserList)
//		{
//			for (LCUserItem item : mInviteUserList)
//			{
//				if (null != item.userId
//					&& null != userId
//					&& item.userId.compareTo(userId) == 0)
//				{
//					result = true;
//				}
//			}
//		}
//		return result;
//	}
	
	/**
	 * 获取用户item（不存在不创建）
	 * @param userId	用户ID
	 * @return
	 */
	private LCUserItem GetUserNotCreate(String userId) 
	{
		LCUserItem userItem = null;
		synchronized (mInviteUserList)
		{
			for (LCUserItem item : mInviteUserList)
			{
				if (null != item.userId
					&& null != userId
					&& item.userId.compareTo(userId) == 0)
				{
					userItem = item;
				}
			}
		}
		return userItem;
	}
	
	/**
	 * 获取用户item（不存在则创建）
	 * @param userId
	 * @return
	 */
	private LCUserItem GetUser(String userId) 
	{
		LCUserItem userItem = GetUserNotCreate(userId);
		if (null == userItem) 
		{
			userItem = new LCUserItem();
			userItem.userId = userId;
		}
		return userItem;
	}
	
	/**
	 * 获取邀请比较器
	 * @return
	 */
	static private Comparator<LCUserItem> getInviteUserComparator() {
		Comparator<LCUserItem> comparator = new Comparator<LCUserItem>() {
			@Override
			public int compare(LCUserItem lhs, LCUserItem rhs) {
				int result = -1;
				if (lhs.order == rhs.order) {
					result = 0;
					
					// 消息来得早的优先
					synchronized (lhs.msgList)
					{
						synchronized (rhs.msgList)
						{
							if (!lhs.msgList.isEmpty() && !rhs.msgList.isEmpty()) {
								LCMessageItem lMsgItem = lhs.msgList.get(0);
								LCMessageItem rMsgItem = rhs.msgList.get(0);
								if (lMsgItem.createTime == rMsgItem.createTime) {
									result = 0;
								}
								else if (lMsgItem.createTime > rMsgItem.createTime) {
									result = -1;
								} 
								else if (lMsgItem.createTime < rMsgItem.createTime){
									result = 1;
								}
							}
							else {
								result = lhs.msgList.size() > 0 ? -1 : 1;
							}
						}
					}
				}
				else if (lhs.order > rhs.order) {
					// 排在前面
					result = -1;
				}
				else if (lhs.order < rhs.order) {
					// 排在后面
					result = 1;
				} 

				return result;
			}
		};
		return comparator;
	}
	
	/**
	 * 移除超时邀请
	 */
	private void RemoveOverTimeInvite()
	{
		int i = 0;
		while (i < mInviteUserList.size()) 
		{
			boolean removeFlag = true;
			LCUserItem userItem = mInviteUserList.get(i);
			synchronized (userItem.msgList)
			{
				if (!userItem.msgList.isEmpty()) {
					LCMessageItem item = userItem.msgList.get(0);
					int currentTime = (int)(System.currentTimeMillis() / 1000);
					if (item.createTime + mOverTimeInterval >= currentTime) {
						removeFlag = false;
					}
				}
				else {
					Log.e("livechat", "LCInviteManager::RemoveOverTimeInvite() userItem.msgList.size==0, userId:%s", userItem.userId);
				}
				
				if (removeFlag) {
					mInviteUserList.remove(i);
					continue;
				}
			}
			
			i++;
		}
	}
	
	/**
	 * 对邀请列表排序
	 */
	private void SortInviteList()
	{
		Collections.sort(mInviteUserList, getInviteUserComparator());
	}
	
	/**
	 * 处理邀请消息
	 * @param message
	 */
	public synchronized void HandleInviteMessage(
			AtomicInteger msgIdIndex
			, String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, int ticket
			, TalkMsgType msgType
			, String message
			, InviteStatusType inviteType)
	{
		
		
		// 插入到列表
		{
			// 获取/生成UserItem
			LCUserItem userItem = GetUser(fromId);
			userItem.sexType = UserSexType.USER_SEX_FEMALE;
			userItem.inviteId = inviteId;
			userItem.userName = fromName;
			userItem.setChatTypeWithTalkMsgType(charget, msgType);
			userItem.statusType = UserStatusType.USTATUS_ONLINE;
			// 生成MessageItem
			LCMessageItem item = new LCMessageItem();
			item.initByInvite(msgIdIndex.getAndIncrement()
					, SendType.Recv
					, fromId
					, toId
					, inviteId
					, StatusType.Finish
					, inviteType);
			// 生成TextItem
			LCTextItem textItem = new LCTextItem();
			textItem.init(message, SendType.Recv);
			// 把TextItem添加到MessageItem
			item.setTextItem(textItem);
			// 添加到用户聊天记录中
			if (userItem.insertSortMsgList(item)) {
				// 插入列表
				mInviteUserList.add(userItem);
				
				// 请求获取用户信息（排序分值）
				LiveChatTalkUserListItem ladyInfo = mUserInfoManager.getLadyInfo(fromId);
				if(ladyInfo != null){
					userItem.order = ladyInfo.orderValue;
				}else{
					LiveChatClient.GetUserInfo(fromId);
				}
				
				// 对列表排序
				SortInviteList();
			}
		}
	}
	
	public synchronized LCMessageItem getNoramlInviteMessage(){
		LCMessageItem item = null;
		// 移除超时邀请
		RemoveOverTimeInvite();
		// 从列表中获取
		if (!mInviteUserList.isEmpty()){
			// 生成随机处理次数
			if (mHandleCount == 0) {
				mRandomHandle = mRandom.nextInt(mMaxNoRandomCount);
			}
			
			// 从列表获取邀请用户
			LCUserItem inviteUserItem = null;
			if (mHandleCount == mRandomHandle) {
				// 随机从列表抽出邀请
				int index = mRandom.nextInt(mInviteUserList.size());
				inviteUserItem = mInviteUserList.remove(index);
			}
			else {
				// 获取列表第一个邀请
				inviteUserItem = mInviteUserList.remove(0);
			}
			
			// 获取消息队列是否为空
			boolean isMsgListEmpty = false;
			synchronized (inviteUserItem.msgList)
			{
				isMsgListEmpty = inviteUserItem.msgList.isEmpty();
			}
			
			// 获取邀请消息
			if (null != inviteUserItem
				&& !isMsgListEmpty) 
			{
				// 添加到UserManager
				LCUserItem userItem = mUserMgr.getUserItem(inviteUserItem.userId);
				userItem.inviteId = inviteUserItem.inviteId;
				userItem.userName = inviteUserItem.userName;
				userItem.chatType = inviteUserItem.chatType;
				userItem.statusType = inviteUserItem.statusType;
				for (LCMessageItem msg : inviteUserItem.msgList) {
					userItem.insertSortMsgList(msg);
				}

				// 抛出最后一条消息给外面显示
				if (!userItem.msgList.isEmpty()) { 
					item = userItem.msgList.get(inviteUserItem.msgList.size() - 1);
				}
			}
			else {
				Log.e("livechat", "LCInviteManager::HandleInviteMessage() msgList is empty, userId:%s", inviteUserItem.userId);
			}
		
			// 更新处理次数
			mHandleCount = (mHandleCount + 1) % mMaxNoRandomCount; 
		}
		else {
			item = null;
		}
		return item;
	}
	
	/**
	 * 更新用户排序分值
	 * @param userId		用户ID
	 * @param orderValue	排序分值
	 */
	public synchronized void UpdateUserOrderValue(String userId, int orderValue)
	{
		LCUserItem item = GetUserNotCreate(userId);
		if (null != item) {
			item.order = orderValue;
			SortInviteList();
		}
	}

	/**
	 * 注销时清除本地缓存，防止跳站
	 */
	public synchronized void clearAndResetInviteList(){
		if(mInviteUserList != null){
			mInviteUserList.clear();
		}
	}
}
