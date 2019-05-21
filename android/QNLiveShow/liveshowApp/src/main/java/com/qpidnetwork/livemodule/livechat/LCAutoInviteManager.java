package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.StatusType;
import com.qpidnetwork.livemodule.livechat.LCUserItem.ChatType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkMsgType;

import java.util.ArrayList;
import java.util.List;

public class LCAutoInviteManager {
	/**
	 * 超时时间间隔 单位（秒）
	 */
	private final long mOverTimeInterval;
	/**
	 * 自动邀请消息列表
	 */
	private List<LCMessageItem> mAutoInviteList;
	/**
	 * 用户管理器
	 */
	private LCUserManager mUserMgr;
	
	public LCAutoInviteManager(LCUserManager userMgr){
		//设置消息超时间隔
		mOverTimeInterval = 3*60;
		//auto invite 消息列表
		mAutoInviteList = new ArrayList<LCMessageItem>();
		//用户管理器
		mUserMgr = userMgr;
	}
	
	/**
	 * 生成消息（未和用户绑定）到消息列表
	 * @param msgId
	 * @param inviteItem
	 * @param message
	 */
	public synchronized void handleAutoInviteMessage(int msgId, LCAutoInviteItem inviteItem, String message){
		if(inviteItem != null){
			LCMessageItem item = new LCMessageItem();
			item.init(msgId
					, SendType.Recv
					, inviteItem.womanId
					, inviteItem.manId
					, ""
					, StatusType.Finish);
			// 生成TextItem
			LCTextItem textItem = new LCTextItem();
			textItem.init(message, SendType.Recv);
			// 把TextItem添加到MessageItem
			item.setTextItem(textItem);
			//设置自动邀请消息关键信息
			item.setAutoInviteItem(inviteItem);
			mAutoInviteList.add(item);
		}
	}
	
	/**
	 * 取出一个Auto Invite Message
	 * @return
	 */
	public synchronized LCMessageItem getAutoInviteMessage(){
		LCMessageItem item = null;
		RemoveOverTimeAutoInvite();
		if(mAutoInviteList.size() > 0){
			int size = mAutoInviteList.size();
			for(int i=size-1; i>=0; i--){
				item = mAutoInviteList.remove(i);
				//检测是否符合
				LCUserItem userItem = mUserMgr.getUserItem(item.fromId);
				if(userItem.chatType == ChatType.Other){
					userItem.setChatTypeWithTalkMsgType(false, TalkMsgType.TMT_FREE);
					userItem.statusType = UserStatusType.USTATUS_ONLINE;
					item.setUserItem(userItem);
					userItem.insertSortMsgList(item);
					break;
				}else{
					item = null;
				}
			}
		}
		return item;
	}
	
	/**
	 * 清除超过3分钟的自动邀请
	 */
	private void RemoveOverTimeAutoInvite(){
		int i = 0;
		while (i < mAutoInviteList.size()) {
			LCMessageItem msgItem = mAutoInviteList.get(i);
			int currentTime = (int)(System.currentTimeMillis() / 1000);
			if (msgItem.createTime + mOverTimeInterval < currentTime) {
				mAutoInviteList.remove(i);
				continue;
			}			
			i++;
		}
	}

	/**
	 * 清除本地缓存
	 */
	public synchronized void clearAutoInviteList(){
		if(mAutoInviteList != null){
			mAutoInviteList.clear();
		}
	}
}
 