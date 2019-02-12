package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.LCNormalInviteManager.HandleInviteMsgType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.InviteStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkMsgType;

import java.util.concurrent.atomic.AtomicInteger;


public class LCInviteManager {
	
	/**
	 * 小助手邀请管理
	 */
	private LCAutoInviteManager mAutoInviteManager;
	/**
	 * 普通邀请管理器
	 */
	private LCNormalInviteManager mNormalInviteManager;
	/**
	 * 上一次处理邀请的时间
	 */
	private long mPreHandleTime;
	/**
	 * 处理邀请时间间隔
	 */
	private final long mHandleTimeInterval;
	
	public LCInviteManager(LCUserManager userMgr
			, LCBlockManager blockMgr
			, LCContactManager contactMgr
			, LCUserInfoManager userInfoManager){
		// 上一次处理邀请时间
		mPreHandleTime = 0;
		// 处理邀请间隔时间
		mHandleTimeInterval = 25 * 1000;	// 25s
		//初始化小助手管理器
		mAutoInviteManager = new LCAutoInviteManager(userMgr);
		//普通邀请管理器
		mNormalInviteManager = new LCNormalInviteManager();
		mNormalInviteManager.init(userMgr, blockMgr, contactMgr, userInfoManager);
	}
	
	/**
	 * 收到普通邀请处理
	 * @param msgIdIndex
	 * @param toId
	 * @param fromId
	 * @param fromName
	 * @param inviteId
	 * @param charget
	 * @param ticket
	 * @param msgType
	 * @param message
	 * @return
	 */
	public void HandleInviteMessage(
			AtomicInteger msgIdIndex
			, String toId
			, String fromId
			, String fromName
			, String inviteId
			, boolean charget
			, int ticket
			, TalkMsgType msgType
			, String message
			, InviteStatusType inviteType){
		if(mNormalInviteManager != null){
			mNormalInviteManager.HandleInviteMessage(msgIdIndex, toId, fromId, fromName, inviteId, charget, ticket, msgType, message, inviteType);
		}
		
	}
	
	/**
	 * 收到自动邀请处理
	 * @param msgId
	 * @param inviteItem
	 * @param message
	 */
	public void handleAutoInviteMessage(int msgId, LCAutoInviteItem inviteItem, String message){
		if(mAutoInviteManager != null){
			mAutoInviteManager.handleAutoInviteMessage(msgId, inviteItem, message);
		}
	}
	
	/**
	 * 选取一条邀请消息
	 * @return
	 */
	public LCMessageItem getInviteMessage(){
		LCMessageItem item = null;
		if(mPreHandleTime == 0
				|| mPreHandleTime + mHandleTimeInterval <= System.currentTimeMillis()){
			item = mAutoInviteManager.getAutoInviteMessage();
			if(item == null){
				item = mNormalInviteManager.getNoramlInviteMessage();
			}
			if(item != null){
				LCAutoInviteItem autoInvite = item.getAutoInviteItem();
				if( autoInvite != null){
					LiveChatClient.UploadPopLadyAutoInvite(autoInvite.womanId, item.getTextItem().message,autoInvite.identifyKey);
				}
				// 更新处理时间
				mPreHandleTime = System.currentTimeMillis();
			}
		}
		return item;
	}
	
	/**
	 * 获取女士分值返回更新
	 * @param userId
	 * @param orderValue
	 */
	public void UpdateUserOrderValue(String userId, int orderValue){
		if(mNormalInviteManager != null){
			mNormalInviteManager.UpdateUserOrderValue(userId, orderValue);
		}
	}
	
	/**
	 * 判断是否普通邀请消息
	 * @param userId
	 * @param charge
	 * @param type
	 * @return
	 */
	public HandleInviteMsgType IsToHandleInviteMsg(String userId, boolean charge, TalkMsgType type){
		HandleInviteMsgType result = HandleInviteMsgType.PASS;
		if(mNormalInviteManager != null){
			result = mNormalInviteManager.IsToHandleInviteMsg(userId, charge, type);
		}
		return result;
	}

	/**
	 * 注销时清除本站邀请即自动邀请缓存，防止跳站
	 */
	public void clearLocalCache(){
		if(mAutoInviteManager != null){
			mAutoInviteManager.clearAutoInviteList();
		}
		if(mNormalInviteManager != null){
			mNormalInviteManager.clearAndResetInviteList();
		}
	}

}
