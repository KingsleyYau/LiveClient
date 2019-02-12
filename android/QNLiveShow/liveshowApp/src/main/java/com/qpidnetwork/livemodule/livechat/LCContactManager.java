package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;

import java.util.ArrayList;

/**
 * 联系人管理器
 * @author Samson Fan
 *
 */
public class LCContactManager {
	/**
	 * 黑名单列表
	 */
	private ArrayList<LiveChatTalkUserListItem> mContactList;
	
	public LCContactManager()
	{
		mContactList = new ArrayList<LiveChatTalkUserListItem>();
	}
	
	/**
	 * 更新联系人列表
	 * @param array	联系人列表
	 */
	public void UpdateWithContactList(LiveChatTalkUserListItem[] array)
	{
		mContactList.clear();
		for (int i = 0; i < array.length; i++)
		{
			mContactList.add(array[i]);
		}
	}
	
	/**
	 * 用户是否存在于联系人列表
	 * @param userId	用户ID
	 * @return
	 */
	public boolean IsExist(String userId)
	{
		boolean result = false;
		for (LiveChatTalkUserListItem item : mContactList)
		{
			if (item.userId.compareTo(userId) == 0) {
				result = true;
			}
		}
		return result;
	}
}
