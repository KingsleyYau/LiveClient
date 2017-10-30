package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.InviteReplyType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * 管理监听消息分发
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMEventListenerManager implements IMInviteLaunchEventListener, IMLiveRoomEventListener,
										IMOtherEventListener,IMLoginStatusListener{
	
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
	public void OnKickOff(LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnKickOff(errType, errMsg);
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
	public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvAnchoeInviteNotify(logId, anchorId, anchorName, anchorPhotoUrl, message);
			}
		}
	}

	@Override
	public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvScheduledInviteNotify(inviteId, anchorId, anchorName, anchorPhotoUrl, message);
			}
		}
	}

	@Override
	public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvSendBookingReplyNotice(inviteId, replyType);
			}
		}
	}

	@Override
	public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvBookingNotice(roomId, userId, nickName, photoUrl, leftSeconds);
			}
		}
	}

	@Override
	public void OnRecvLevelUpNotice(int level) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvLevelUpNotice(level);
			}
		}
	}

	@Override
	public void OnRecvLoveLevelUpNotice(int lovelevel) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvLoveLevelUpNotice(lovelevel);
			}
		}
	}

	@Override
	public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvBackpackUpdateNotice(item);
			}
		}
	}

	@Override
	public void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomCloseNotice(roomId, errType, errMsg);
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
	public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String playUrl) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvChangeVideoUrl(roomId, isAnchor, playUrl);
			}
		}
	}

	@Override
	public void OnControlManPush(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnControlManPush(reqId, success, errType, errMsg, manPushUrl);
			}
		}
	}

	@Override
	public void OnSendRoomMsg(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendRoomMsg(success, errType, errMsg, msgItem);
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
	public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomGiftNotice(msgItem);
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
	public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomToastNotice(msgItem);
			}
		}		
	}

	@Override
	public void OnRecvSendSystemNotice(IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvSendSystemNotice(msgItem);
			}
		}
	}

	@Override
	public void OnSendTalent(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendTalent(reqId, success, errType, errMsg);
			}
		}
	}

	@Override
	public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit,
									   IMClientListener.TalentInviteStatus status, double rebateCredit) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, status, rebateCredit);
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
	public void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRoomOut(reqId, success, errType, errMsg);
			}
		}
	}

	@Override
	public void OnRecvLiveStart(String roomId, int leftSeconds, String[] playUrls) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvLiveStart(roomId, leftSeconds, playUrls);
			}
		}		
	}

	@Override
	public void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnGetInviteInfo(reqId, success, errType, errMsg, inviteItem);
			}
		}
	}

	@Override
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnSendImmediatePrivateInvite(reqId, success, errType, errMsg, invitationId, timeout, roomId);
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
	public void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId,
								  String nickName, String avatarImg, String message) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvInviteReply(inviteId, replyType, roomId, roomType, anchorId, nickName, avatarImg, message);
			}
		}
	}


	//------------------------断线重连-----------------------------------------
	/**
	 * 断线重登录事件监听listener列表
	 */
	private ArrayList<IMLoginStatusListener> mIMLoginStatusListeners = new ArrayList<>();

	/**
	 * 注册IM断线重连成功事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMLoginStatusListener(IMLoginStatusListener listener){
		boolean result = false;
		synchronized(mIMLoginStatusListeners) {
			if (null != listener) {
				boolean isExist = false;
				for (Iterator<IMLoginStatusListener> iter = mIMLoginStatusListeners.iterator(); iter.hasNext(); ) {
					IMLoginStatusListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}

				if (!isExist) {
					result = mIMLoginStatusListeners.add(listener);
				}
			}
		}
		return result;
	}

	/**
	 * 注销断线重登录事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMLoginStatusListener(IMLoginStatusListener listener) {
		boolean result = false;
		synchronized(mIMLoginStatusListeners) {
			result = mIMLoginStatusListeners.remove(listener);
		}
		return result;
	}

	@Override
	public void onIMAutoReLogined() {
		synchronized(mIMLoginStatusListeners){
			for (Iterator<IMLoginStatusListener> iter = mIMLoginStatusListeners.iterator(); iter.hasNext(); ) {
				IMLoginStatusListener listener = iter.next();
				listener.onIMAutoReLogined();
			}
		}
	}
}
