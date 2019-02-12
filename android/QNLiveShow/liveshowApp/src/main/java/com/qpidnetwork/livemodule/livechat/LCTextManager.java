package com.qpidnetwork.livemodule.livechat;

import android.annotation.SuppressLint;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.HashMap;

/**
 * 文本消息管理器
 * @author Samson Fan
 *
 */
@SuppressLint("UseSparseArrays")
public class LCTextManager {
	/**
	 * msgId与Text item的待发送map
	 */
	private HashMap<Integer, LCMessageItem> mTextMap;
	
	public LCTextManager() {
		mTextMap = new HashMap<Integer, LCMessageItem>();
	}
	
	/**
	 * 添加待发送的item
	 * @param msgId	消息ID
	 * @param item	text item
	 * @return
	 */
	public boolean addSendingItem(LCMessageItem item) {
		boolean result = false;
		synchronized (mTextMap)
		{
			if (null == mTextMap.get(item.msgId)) {
				mTextMap.put(item.msgId, item);
				result = true;
			}
			else {
				Log.d("livechat", String.format("%s::%s() msgId:%d is exist.", "LCTextManager", "addSendingItem", item.msgId));
			}
		}
		return result;
	}
	
	/**
	 * 移除待发送的item
	 * @param msgId	消息ID
	 * @return
	 */
	public LCMessageItem getAndRemoveSendingItem(int msgId) {
		LCMessageItem item = null;
		synchronized (mTextMap)
		{
			item = mTextMap.remove(msgId);
			if (null == item) {
				Log.d("livechat", String.format("%s::%s() msgId:%d is not exist.", "LCTextManager", "getAndRemoveSendingItem", msgId));
			}
		}
		return item;
	}
	
	/**
	 * 清除所有待发送的item
	 */
	public void removeAllSendingItems() {
		synchronized (mTextMap)
		{
			mTextMap.clear();
		}
	}
}
