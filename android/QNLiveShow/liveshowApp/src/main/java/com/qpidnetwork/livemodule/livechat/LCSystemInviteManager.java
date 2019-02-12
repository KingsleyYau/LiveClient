package com.qpidnetwork.livemodule.livechat;

public class LCSystemInviteManager {
	
	public LCSystemInviteManager(){
		
	}
	
	public boolean init(){
		boolean result = false;
		return result;
	}
	
	public synchronized LCMessageItem getInviteMessage(){
		LCMessageItem item = null;
		return item;
	}
	
	/**
	 * 更新用户排序分值
	 * @param userId		用户ID
	 * @param orderValue	排序分值
	 */
	public synchronized void UpdateUserOrderValue(String userId, int orderValue)
	{
//		LCUserItem item = GetUserNotCreate(userId);
//		if (null != item) {
//			item.order = orderValue;
//			SortInviteList();
//		}
	}

}
