package com.qpidnetwork.im;

import java.util.ArrayList;
import java.util.Iterator;

import com.qpidnetwork.im.listener.IMClientListener;
import com.qpidnetwork.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.im.listener.IMRoomInfoItem;
import com.qpidnetwork.utils.Log;

/**
 * 管理监听消息分发
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMEventListenerManager implements IIMEventListener{
	private static final String TAG = IMEventListenerManager.class.getName();
	/**
	 * 监听者列表
	 */
	private ArrayList<IIMEventListener> mIMListeners;
	
	public IMEventListenerManager(){
		mIMListeners = new ArrayList<IIMEventListener>();
	}
	
	/**
	 * 注册监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMEventListener(IIMEventListener listener){
		boolean result = false;
		synchronized(mIMListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
					IIMEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mIMListeners.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "RegisterListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMEventListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销Other回调
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMEventListener(IIMEventListener listener) {
		boolean result = false;
		synchronized(mIMListeners)
		{
			result = mIMListeners.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMEventListener", listener.getClass().getSimpleName()));
		}
		return result;
	}

	@Override
	public void OnLogin(LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnLogin(errType, errMsg);
			}
		}		
	}

	@Override
	public void OnLogout(LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnLogout(errType, errMsg);
			}
		}		
	}

	@Override
	public void OnRecvRoomCloseFans(String roomId, String userId,
			String nickName, int fansNum) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvRoomCloseFans(roomId, userId, nickName, fansNum);
			}
		}		
	}

	@Override
	public void OnRecvRoomCloseBroad(String roomId, int fansNum, int inCome,
			int newFans, int shares, int duration) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvRoomCloseBroad(roomId, fansNum, inCome, newFans, shares, duration);
			}
		}		
	}

	@Override
	public void OnRecvFansRoomIn(String roomId, String userId, String nickName,
			String photoUrl) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvFansRoomIn(roomId, userId, nickName, photoUrl);
			}
		}		
	}

	@Override
	public void OnRecvShutUpNotice(String roomId, String userId, String nickName, int timeOut) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvShutUpNotice(roomId, userId, nickName, timeOut);
			}
		}
	}

	@Override
	public void OnRecvKickOffRoomNotice(String roomId, String userId, String nickName) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvKickOffRoomNotice(roomId, userId, nickName);
			}
		}
	}

	@Override
	public void OnRecvMsg(IMMessageItem msgItem) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvMsg(msgItem);
			}
		}		
	}

	@Override
	public void OnFansRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMRoomInfoItem roomInfo) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnFansRoomIn(reqId, success, errType, errMsg, roomInfo);
			}
		}		
	}

	@Override
	public void OnFansRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnFansRoomOut(reqId, success, errType, errMsg);
			}
		}		
	}

	@Override
	public void OnSendMsg(LCC_ERR_TYPE errType, String errMsg,
			IMMessageItem msgItem) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnSendMsg(errType, errMsg, msgItem);
			}
		}		
	}

	@Override
	public void OnGetRoomInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, int fansNum, int contribute) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnGetRoomInfo(reqId, success, errType, errMsg, fansNum, contribute);
			}
		}
	}

	@Override
	public void OnAnchorForbidMessage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnAnchorForbidMessage(reqId, success, errType, errMsg);
			}
		}
	}

	@Override
	public void OnAnchorKickOffAudience(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnAnchorKickOffAudience(reqId, success, errType, errMsg);
			}
		}
	}

	@Override
	public void OnKickOff(String reason) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnKickOff(reason);
			}
		}
	}

	@Override
	public void OnRecvPushRoomFav(String roomId, String fromId, String nickName) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnRecvPushRoomFav(roomId, fromId, nickName);
			}
		}
	}

	@Override
	public void OnCoinsUpdate(double coins) {
		synchronized(mIMListeners){
			for (Iterator<IIMEventListener> iter = mIMListeners.iterator(); iter.hasNext(); ) {
				IIMEventListener listener = iter.next();
				listener.OnCoinsUpdate(coins);
			}
		}
	}
}
