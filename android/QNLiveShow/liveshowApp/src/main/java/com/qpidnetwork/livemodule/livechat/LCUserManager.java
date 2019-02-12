package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.LCUserItem.ChatType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserSexType;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map.Entry;

/**
 * 在聊用户管理类
 * @author Samson Fan
 *
 */
public class LCUserManager {
	/**
	 * userId与UserItem的map
	 */
	private HashMap<String, LCUserItem> mUserMap;
	
	public LCUserManager() {
		mUserMap = new HashMap<String, LCUserItem>();
	}
	
	/**
	 * 用户是否已存在
	 * @param userId	用户ID
	 * @return
	 */
	public boolean isUserExists(String userId)
	{
		boolean result = false;
		synchronized (mUserMap) {
			LCUserItem item = mUserMap.get(userId);
			if (null != item) {
				result = true;
			}
		}
		return result;
	}
	
	/**
	 * 获取在聊用户item
	 * @param userId
	 */
	public LCUserItem getUserItem(String userId) {
		if (userId.isEmpty()) {
			Log.d("livechat", String.format("%s::%s() userId:%s is null", "LCUserManager", "getUserItem", userId));
			return null;
		}
		
		LCUserItem item = null;
		synchronized(mUserMap)
		{
			item = mUserMap.get(userId);
			if (null == item) {
				item = new LCUserItem();
				item.userId = userId;
				item.sexType = UserSexType.USER_SEX_FEMALE;
				if (!addUserItem(item)) {
					item = null;
				}
			}
		}
		return item;
	}
	
	/**
	 * 添加在聊用户
	 * @param item
	 * @return
	 */
	public boolean addUserItem(LCUserItem item) {
		boolean result = false;
		if (!item.userId.isEmpty()) 
		{
			synchronized(mUserMap) 
			{
				LCUserItem old = mUserMap.get(item.userId);
				if (null == old) {
					mUserMap.put(item.userId, item);
					result = true;
				}
				else {
					Log.d("livechat", String.format("%s::%s() userId:%s, is exist", "LCUserManager", "addUserItem", item.userId));
				}
			}
		}
		return result;
	}
	
	/**
	 * 移除指定用户
	 * @param userId
	 * @return
	 */
	public boolean removeUserItem(String userId) {
		synchronized(mUserMap) 
		{
			LCUserItem item = mUserMap.remove(userId);
			if (null == item) {
				Log.d("livechat", String.format("%s::%s() userId:%s, is not exist", "LCUserManager", "removeUserItem", userId));
			}
			else {
				item.clearMsgList();
			}
		}
		return true;
	}
	
	/**
	 * 移除所有用户
	 * @return
	 */
	public boolean removeAllUserItem() {
		synchronized(mUserMap) 
		{
			// 清除所有用户的聊天记录
//			for (Entry<String, LCUserItem> entry: mUserMap.entrySet()) {
//				LCUserItem item = entry.getValue();
//				item.clearMsgList();
//			}
			mUserMap.clear();
		}
		return true;
	}
	
	/**
	 * 查找指定邀请ID的userItem
	 * @param inviteId	邀请ID
	 * @return
	 */
	public LCUserItem getUserItemWithInviteId(String inviteId) {
		LCUserItem userItem = null; 
		synchronized(mUserMap) {
			for (Entry<String, LCUserItem> entry: mUserMap.entrySet()) {
				LCUserItem item = entry.getValue();
				if (null != item.inviteId && item.inviteId.equals(inviteId)) {
					userItem = item;
					break;
				}
			}
		}
		return userItem;
	}
	
	/**
	 * 获取邀请的用户item
	 * @return
	 */
	public ArrayList<LCUserItem> getInviteUsers() {
		ArrayList<LCUserItem> list = new ArrayList<LCUserItem>(); 
		synchronized(mUserMap) {
			for (Entry<String, LCUserItem> entry: mUserMap.entrySet()) {
				LCUserItem item = entry.getValue();
				synchronized (item.msgList)
				{
					if (item.chatType == ChatType.Invite
						&& !item.msgList.isEmpty()) 
					{
						list.add(item);
					}
				}
			}
			try{
				Collections.sort(list, LCUserItem.getComparator());
			}catch(Exception e){
				
			}
		}
		
		return list;
	}
	
	/**
	 * 获取在聊的用户item（包括付费和试聊券）
	 * @return
	 */
	public ArrayList<LCUserItem> getChatingUsers() {
		ArrayList<LCUserItem> list = new ArrayList<LCUserItem>(); 
		synchronized(mUserMap) {
			for (Entry<String, LCUserItem> entry: mUserMap.entrySet()) {
				LCUserItem item = entry.getValue();
				if (item.isInSession()) 
				{
					list.add(item);
				}
			}
		}
		return list;
	}

	/**
	 * 获取在聊的用户item（包括付费和试聊券）和 男士主动邀请用户列表
	 * @return
	 */
	public ArrayList<LCUserItem> getChatingAndManInviteUsers() {
		ArrayList<LCUserItem> list = new ArrayList<LCUserItem>();
		synchronized(mUserMap) {
			for (Entry<String, LCUserItem> entry: mUserMap.entrySet()) {
				LCUserItem item = entry.getValue();
				if (item.isInSession() || item.chatType == ChatType.ManInvite)
				{
					list.add(item);
				}
			}
		}
		return list;
	}

	/**
	 * 获取有待发消息的用户队列
	 * @return
	 */
	public ArrayList<LCUserItem> getToSendUsers()
	{
		ArrayList<LCUserItem> list = new ArrayList<LCUserItem>();
		synchronized(mUserMap) {
			for (Entry<String, LCUserItem> entry: mUserMap.entrySet()) {
				LCUserItem item = entry.getValue();
				synchronized (item.sendMsgList)
				{
					if (!item.sendMsgList.isEmpty()) 
					{
						list.add(item);
					}
				}
			}
		}
		return list;
	}
}
