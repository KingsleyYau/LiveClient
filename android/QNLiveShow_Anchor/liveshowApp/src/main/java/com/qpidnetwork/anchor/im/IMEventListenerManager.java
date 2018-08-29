package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener.InviteReplyType;
import com.qpidnetwork.anchor.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * 管理监听消息分发
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMEventListenerManager implements IMInviteLaunchEventListener, IMLiveRoomEventListener,
										IMOtherEventListener,IMHangOutRoomEventListener,IMHangOutInviteEventListener{
	
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

	/**
	 * 其他事件Listener列表
	 */
	private ArrayList<IMHangOutRoomEventListener> mIMHangOutEventListener;
	private ArrayList<IMHangOutInviteEventListener> mIMHangOutInviteEventListener;

	public IMEventListenerManager(){
		mIMInviteLaunchListeners = new ArrayList<IMInviteLaunchEventListener>();
		mIMLiveRoomListeners = new ArrayList<IMLiveRoomEventListener>();
		mIMOtherListener = new ArrayList<IMOtherEventListener>();
		mIMHangOutEventListener = new ArrayList<IMHangOutRoomEventListener>();
		mIMHangOutInviteEventListener = new ArrayList<IMHangOutInviteEventListener>();
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

	/**
	 * 注册HangOut直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMHangOutRoomEventListener(IMHangOutRoomEventListener listener){
		boolean result = false;
		synchronized(mIMHangOutEventListener)
		{
			if (null != listener) {
				boolean isExist = false;

				for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
					IMHangOutRoomEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}

				if (!isExist) {
					result = mIMHangOutEventListener.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerIMHangOutRoomEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMHangOutRoomEventListener"));
			}
		}
		return result;
	}

	/**
	 * 注销HangOut直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMHangOutRoomEventListener(IMHangOutRoomEventListener listener) {
		boolean result = false;
		synchronized(mIMHangOutEventListener)
		{
			result = mIMHangOutEventListener.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMHangOutRoomEventListener", listener.getClass().getSimpleName()));
		}
		return result;
	}

	/**
	 * 注册HangOut直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMHangOutInviteEventListener(IMHangOutInviteEventListener listener){
		boolean result = false;
		synchronized(mIMHangOutInviteEventListener)
		{
			if (null != listener) {
				boolean isExist = false;

				for (Iterator<IMHangOutInviteEventListener> iter = mIMHangOutInviteEventListener.iterator(); iter.hasNext(); ) {
					IMHangOutInviteEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}

				if (!isExist) {
					result = mIMHangOutInviteEventListener.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerIMHangOutInviteEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMHangOutInviteEventListener"));
			}
		}
		return result;
	}

	/**
	 * 注销HangOut直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMHangOutInviteEventListener(IMHangOutInviteEventListener listener) {
		boolean result = false;
		synchronized(mIMHangOutInviteEventListener)
		{
			result = mIMHangOutInviteEventListener.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMHangOutInviteEventListener", listener.getClass().getSimpleName()));
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
	public void OnRecvAnchoeInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl, String invitationId) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvAnchoeInviteNotify(anchorId, anchorName, anchorPhotoUrl, invitationId);
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
	public void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomCloseNotice(roomId, errType, errMsg);
			}
		}
	}

	@Override
	public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum,isHasTicket);
			}
		}
	}

	@Override
	public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvAnchorLeaveRoomNotice(roomId, anchorId);
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
	public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg);
			}
		}
	}

	@Override
	public void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomKickoffNotice(roomId, err, errMsg);
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
			String errMsg, IMMessageItem msgItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendGift(success, errType, errMsg, msgItem);
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
	public void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvTalentRequestNotice(talentInvitationId, name, userId, nickName);
			}
		}
	}

	@Override
	public void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvInteractiveVideoNotice(roomId, userId, nickname, avatarImg, operateType, pushUrls);
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
	public void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMRoomInItem roomInfo) {

		//统一豪华私密直播间和普通私密直播间
		if(roomInfo != null){
			if(roomInfo.roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom){
				roomInfo.roomType = IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom;
			}
		}

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
	public void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String userId,
								  String nickName, String avatarImg) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvInviteReply(inviteId, replyType, roomId, roomType, userId, nickName, avatarImg);
			}
		}
	}

	@Override
	public void OnEnterHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem hangoutRoomItem, int expire) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnEnterHangoutRoom(reqId, success, errType, errMsg, hangoutRoomItem, expire);
			}
		}
	}

	@Override
	public void OnLeaveHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnLeaveHangoutRoom(reqId, success, errType, errMsg);
			}
		}
	}

	@Override
	public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorRecommendHangoutNotice(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorDealKnockRequestNotice(IMKnockRequestItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorDealKnockRequestNotice(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorOtherInviteNotice(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorDealInviteNotice(IMDealInviteItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorDealInviteNotice(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorEnterRoomNotice(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorLeaveRoomNotice(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorChangeVideoUrl(roomId,isAnchor,userId,playUrl);
			}
		}
	}

	@Override
	public void OnSendHangoutGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnSendHangoutGift(reqId,success,errType,errMsg);
			}
		}
	}

	@Override
	public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorGiftNotice(item);
			}
		}
	}

	@Override
	public void OnRecvInvitationHangoutNotice(IMHangoutInviteItem item) {
		synchronized(mIMHangOutInviteEventListener){
			for (Iterator<IMHangOutInviteEventListener> iter = mIMHangOutInviteEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutInviteEventListener listener = iter.next();
				listener.OnRecvInvitationHangoutNotice(item);
			}
		}
	}


	@Override
	public void OnSendHangoutMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnSendHangoutMsg(reqId,success,errType,errMsg);
			}
		}
	}

	@Override
	public void OnRecvHangoutMsg(IMMessageItem imMessageItem) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvHangoutMsg(imMessageItem);
			}
		}
	}

	@Override
	public void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond) {
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvAnchorCountDownEnterRoomNotice(roomId,anchorId,leftSecond);
			}
		}
	}

	/**
	 * 10.13.接收多人互动直播间观众启动/关闭视频互动通知
	 * @param roomId
	 * @param userId
	 * @param nickname
	 * @param avatarImg
	 * @param operateType
	 * @param pushUrls
	 */
	public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname,
													String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType,
													String[] pushUrls){
		synchronized(mIMHangOutEventListener){
			for (Iterator<IMHangOutRoomEventListener> iter = mIMHangOutEventListener.iterator(); iter.hasNext(); ) {
				IMHangOutRoomEventListener listener = iter.next();
				listener.OnRecvHangoutInteractiveVideoNotice(roomId,userId,nickname,avatarImg,operateType,pushUrls);
			}
		}
	}
}
