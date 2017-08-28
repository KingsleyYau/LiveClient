package com.qpidnetwork.livemodule.im;

import java.util.ArrayList;
import java.util.Iterator;

import com.qpidnetwork.livemodule.im.listener.IMClientListener.InviteReplyType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * 管理监听消息分发
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMEventListenerManager implements IMInviteLaunchEventListener, IMLiveRoomEventListener,
										IMOtherEventListener{
	
	private static final String TAG = IMEventListenerManager.class.getName();
	
	/**
	 * 邀请启动listener列表
	 */
	private ArrayList<IMInviteLaunchEventListener> mIMInviteLaunchListeners;
	
	/**
	 * 直播间事件listener列表
	 */
	private ArrayList<IMLiveRoomEventListener> mIMLiveRoomListeners;
	
	/**
	 * 其他事件Listener列表
	 */
	private ArrayList<IMOtherEventListener> mIMOtherListener;
	
	public IMEventListenerManager(){
		mIMInviteLaunchListeners = new ArrayList<IMInviteLaunchEventListener>();
		mIMLiveRoomListeners = new ArrayList<IMLiveRoomEventListener>();
		mIMOtherListener = new ArrayList<IMOtherEventListener>();
	}
	
	/**
	 * 注册邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMInviteLaunchEventListener(IMInviteLaunchEventListener listener){
		boolean result = false;
		synchronized(mIMInviteLaunchListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
					IMInviteLaunchEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mIMInviteLaunchListeners.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerIMInviteLaunchEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMInviteLaunchEventListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMInviteLaunchEventListener(IMInviteLaunchEventListener listener) {
		boolean result = false;
		synchronized(mIMInviteLaunchListeners)
		{
			result = mIMInviteLaunchListeners.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMInviteLaunchEventListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	
	/**
	 * 注册直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMLiveRoomEventListener(IMLiveRoomEventListener listener){
		boolean result = false;
		synchronized(mIMLiveRoomListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
					IMLiveRoomEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mIMLiveRoomListeners.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerIMLiveRoomEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMLiveRoomEventListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMLiveRoomEventListener(IMLiveRoomEventListener listener) {
		boolean result = false;
		synchronized(mIMLiveRoomListeners)
		{
			result = mIMLiveRoomListeners.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMLiveRoomEventListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册其他事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMOtherEventListener(IMOtherEventListener listener){
		boolean result = false;
		synchronized(mIMOtherListener) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
					IMOtherEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mIMOtherListener.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerIMOtherEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMOtherEventListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销其他事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMOtherEventListener(IMOtherEventListener listener) {
		boolean result = false;
		synchronized(mIMOtherListener)
		{
			result = mIMOtherListener.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMOtherEventListener", listener.getClass().getSimpleName()));
		}
		return result;
	}

	@Override
	public void OnLogin(LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnLogin(errType, errMsg);
			}
		}			
	}

	@Override
	public void OnLogout(LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnLogout(errType, errMsg);
			}
		}			
	}

	@Override
	public void OnKickOff() {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnKickOff();
			}
		}		
	}

	@Override
	public void OnRecvLackOfCreditNotice(String roomId, String message,
			double credit) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvLackOfCreditNotice(roomId, message, credit);
			}
		}		
	}

	@Override
	public void OnRecvCreditNotice(String roomId, double credit) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvCreditNotice(roomId, credit);
			}
		}		
	}

	@Override
	public void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRoomOut(reqId, success, errType, errMsg);
			}
		}			
	}

	@Override
	public void OnSendRoomMsg(LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendRoomMsg(errType, errMsg, msgItem);
			}
		}		
	}

	@Override
	public void OnSendGift(boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendGift(success, errType, errMsg, msgItem, credit, rebateCredit);
			}
		}			
	}

	@Override
	public void OnSendBarrage(boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendBarrage(success, errType, errMsg, msgItem, credit, rebateCredit);
			}
		}		
	}

	@Override
	public void OnRecvRoomCloseNotice(String roomId, String userId, String nickName) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomCloseNotice(roomId, userId, nickName);
			}
		}		
	}

	@Override
	public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum);
			}
		}			
	}

	@Override
	public void OnRecvLeaveRoomNotice(String roomId, String userId,
			String nickName, String photoUrl, int fansNum) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvLeaveRoomNotice(roomId, userId, nickName, photoUrl, fansNum);
			}
		}		
	}

	@Override
	public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRebateInfoNotice(roomId, item);
			}
		}		
	}

	@Override
	public void OnRecvLeavingPublicRoomNotice(String roomId, LCC_ERR_TYPE err, String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvLeavingPublicRoomNotice(roomId, err, errMsg);
			}
		}		
	}

	@Override
	public void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err,
			String errMsg, double credit) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomKickoffNotice(roomId, err, errMsg, credit);
			}
		}		
	}

	@Override
	public void OnRecvRoomMsg(IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomMsg(msgItem);
			}
		}			
	}

	@Override
	public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomGiftNotice(msgItem);
			}
		}		
	}

	@Override
	public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomToastNotice(msgItem);
			}
		}		
	}

	@Override
	public void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMRoomInItem roomInfo) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRoomIn(reqId, success, errType, errMsg, roomInfo);
			}
		}		
	}

	@Override
	public void OnRecvLiveStart(String roomId, int leftSeconds) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvLiveStart(roomId, leftSeconds);
			}
		}		
	}

	@Override
	public void OnSendImmediatePrivateInvite(int reqId, boolean success,
			LCC_ERR_TYPE errType, String errMsg, String inviteId) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnSendImmediatePrivateInvite(reqId, success, errType, errMsg, inviteId);
			}
		}		
	}

	@Override
	public void OnCancelImmediatePrivateInvite(int reqId, boolean success,
			LCC_ERR_TYPE errType, String errMsg, String roomId) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnCancelImmediatePrivateInvite(reqId, success, errType, errMsg, roomId);
			}
		}		
	}

	@Override
	public void OnRecvInviteReply(String inviteId, InviteReplyType replyType,
			String roomId) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvInviteReply(inviteId, replyType, roomId);
			}
		}
	}

	@Override
	public void OnRecvAnchoeInviteNotify(String anchorId, String anchorName,
			String anchorPhotoUrl) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvAnchoeInviteNotify(anchorId, anchorName, anchorPhotoUrl);
			}
		}		
	}

	@Override
	public void OnRecvScheduledInviteNotify(String anchorId, String anchorName,
			String anchorPhotoUrl, int bookTime, String inviteId) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvScheduledInviteNotify(anchorId, anchorName, anchorPhotoUrl, bookTime, inviteId);
			}
		}		
	}

}
