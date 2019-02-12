package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;

import java.util.HashMap;

public class LCUserInfoManager {
	
	/**
	 * 存放女士资料
	 */
	private HashMap<String, LiveChatTalkUserListItem> mWomanInfoMap;
		
	public LCUserInfoManager(){
		mWomanInfoMap = new HashMap<String, LiveChatTalkUserListItem>();
	}
	
	/**
	 * 临时存储女士资料
	 * @param item
	 */
	private void saveLadyInfo(LiveChatTalkUserListItem item){
		synchronized (mWomanInfoMap) {
			mWomanInfoMap.put(item.userId, item);
		}
	}
	
	/**
	 * 临时存储女士资料列表
	 * @param itemArray
	 */
	private void saveLadyInfos(LiveChatTalkUserListItem[] itemArray){
		synchronized (mWomanInfoMap) {
			for(LiveChatTalkUserListItem item : itemArray){
				mWomanInfoMap.put(item.userId, item);
			}
		}
	}
	
	/**
	 * 删除女士本地缓存
	 * @param userId
	 */
	private void removeLadyInfo(String userId){
		synchronized (mWomanInfoMap) {
			mWomanInfoMap.remove(userId);
		}
	}
	
	/**
	 * 获取女士信息
	 * @param userId
	 * @return
	 */
	public LiveChatTalkUserListItem getLadyInfo(String userId){
		LiveChatTalkUserListItem item = null;
		synchronized (mWomanInfoMap) {
			if(mWomanInfoMap.containsKey(userId)){
				item = mWomanInfoMap.get(userId);
			}
		}
		return item;
	}
	
	/**
	 * GetUserInfo 回调刷新
	 * @param item
	 */
	public void OnGetUserInfoUpdate(LiveChatTalkUserListItem item){
			saveLadyInfo(item);
	}
	
	/**
	 * GetUserInfo 回调刷新
	 * @param itemList
	 */
	public void OnGetUersInfoUpdate(LiveChatTalkUserListItem[] itemList){
		saveLadyInfos(itemList);
	}
	
	/**
	 * 上下线换端刷新
	 * @param userId
	 */
	public void OnUpdateStatus(String userId){
		removeLadyInfo(userId);
	}

}
