package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;

import java.util.ArrayList;

/**
 * 黑名单管理器
 * @author Samson Fan
 *
 */
public class LCBlockManager {
	/**
	 * 黑名单列表
	 */
	private ArrayList<LiveChatTalkUserListItem> mBlockList;
	/**
	 * 被屏蔽女士列表
	 */
	private ArrayList<String> mBlockUsers;
	
	public LCBlockManager() 
	{
		mBlockList = new ArrayList<LiveChatTalkUserListItem>();
		mBlockUsers = new ArrayList<String>();
	}
	
	/**
	 * 更新黑名单列表
	 * @param array	黑名单列表
	 */
	public synchronized void UpdateWithBlockList(LiveChatTalkUserListItem[] array)
	{
		mBlockList.clear();
		for (int i = 0; i < array.length; i++)
		{
			mBlockList.add(array[i]);
		}
	}
	
	/**
	 * 更新被屏蔽女士列表
	 * @param array	黑名单列表
	 */
	public synchronized void UpdateWithBlockUsers(String[] array)
	{
		mBlockUsers.clear();
		for (int i = 0; i < array.length; i++)
		{
			mBlockUsers.add(array[i]);
		}
	}
	
	/**
	 * 用户是否存在于黑名单
	 * @param userId	用户ID
	 * @return
	 */
	public synchronized boolean IsExist(String userId)
	{
		boolean result = false;
		// 判断黑名单
		for (LiveChatTalkUserListItem item : mBlockList)
		{
			if (item.userId.compareTo(userId) == 0) {
				result = true;
			}
		}
		
		// 判断被屏蔽女士列表
		if (!result ) {
			for (String blockUserId : mBlockUsers)
			{
				if (blockUserId.compareTo(userId) == 0) {
					result = true;
				}
			}
		}
		return result;
	}
}
