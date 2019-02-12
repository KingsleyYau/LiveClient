package com.qpidnetwork.livemodule.livemessage;


import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * 管理监听消息分发
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class LMEventListenerManager implements LMLiveRoomEventListener {
	
	private static final String TAG = LMEventListenerManager.class.getName();


	/**
	 * 直播间事件listener列表
	 */
	private ArrayList<LMLiveRoomEventListener> mLMLiveRoomListeners;

	
	public LMEventListenerManager(){
		mLMLiveRoomListeners = new ArrayList<LMLiveRoomEventListener>();
	}

	/**
	 * 注册直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerLMLiveRoomEventListener(LMLiveRoomEventListener listener){
		boolean result = false;
		synchronized(mLMLiveRoomListeners)
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext(); ) {
					LMLiveRoomEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mLMLiveRoomListeners.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerLMLiveRoomEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerLMLiveRoomEventListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterLMLiveRoomEventListener(LMLiveRoomEventListener listener) {
		boolean result = false;
		synchronized(mLMLiveRoomListeners)
		{
			result = mLMLiveRoomListeners.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterLMLiveRoomEventListener", listener.getClass().getSimpleName()));
		}
		return result;
	}

	@Override
	public void OnUpdateFriendListNotice(boolean success, HttpLccErrType errType, String errMsg) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnUpdateFriendListNotice(success, errType, errMsg);
			}
		}
	}
//
//	@Override
//	public void OnGetFollowPrivateMsgFriendList(boolean success, HttpLccErrType errType, String errMsg, LMPrivateMsgContactItem[] contactList) {
//		synchronized (mLMLiveRoomListeners) {
//			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
//				LMLiveRoomEventListener listener = iter.next();
//				listener.OnGetFollowPrivateMsgFriendList(success, errType, errMsg, contactList);
//			}
//		}
//	}

	@Override
	public void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnRefreshPrivateMsgWithUserId(success, errType, errMsg, userId, messageList, reqId);
			}
		}
	}

	@Override
	public void OnGetMorePrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean isMuchMore) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnGetMorePrivateMsgWithUserId(success, errType, errMsg, userId, messageList, reqId, isMuchMore);
			}
		}
	}

	@Override
	public void OnUpdatePrivateMsgWithUserId(String userId, LiveMessageItem[] messageList) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnUpdatePrivateMsgWithUserId(userId, messageList);
			}
		}
	}

	@Override
	public void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, LiveMessageItem messageItem) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnSendPrivateMessage(success, errType, errMsg, userId, messageItem);
			}
		}
	}

	@Override
	public void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnRecvUnReadPrivateMsg(messageItem);
			}
		}
	}

	@Override
	public void OnRepeatSendPrivateMsgNotice(String userId, LiveMessageItem[] messageList) {
		synchronized (mLMLiveRoomListeners) {
			for (Iterator<LMLiveRoomEventListener> iter = mLMLiveRoomListeners.iterator(); iter.hasNext();) {
				LMLiveRoomEventListener listener = iter.next();
				listener.OnRepeatSendPrivateMsgNotice(userId, messageList);
			}
		}
	}
}
