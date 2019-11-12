package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.InviteReplyType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutMsgItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteErrItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteReplyItem;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMProgramInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * 管理监听消息分发
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMEventListenerManager implements IMInviteLaunchEventListener, IMLiveRoomEventListener,
										IMOtherEventListener,IMLoginStatusListener, IMShowEventListener,
										IMHangoutEventListener{
	
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
	 * hangout事件Listener列表
	 */
	private ArrayList<IMHangoutEventListener> mIMHangoutEventListener;
	
	public IMEventListenerManager(){
		mIMInviteLaunchListeners = new ArrayList<IMInviteLaunchEventListener>();
		mIMLiveRoomListeners = new ArrayList<IMLiveRoomEventListener>();
		mIMOtherListener = new ArrayList<IMOtherEventListener>();
		mIMHangoutEventListener = new ArrayList<IMHangoutEventListener>();
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
	 * 注册hangout事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMHangoutEventListener(IMHangoutEventListener listener){
		boolean result = false;
		synchronized(mIMHangoutEventListener)
		{
			if (null != listener) {
				boolean isExist = false;

				for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
					IMHangoutEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}

				if (!isExist) {
					result = mIMHangoutEventListener.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerIMHangoutEventListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerIMHangoutEventListener"));
			}
		}
		return result;
	}

	/**
	 * 注销hangout事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMHangoutEventListener(IMHangoutEventListener listener) {
		boolean result = false;
		synchronized(mIMHangoutEventListener)
		{
			result = mIMHangoutEventListener.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterIMHangoutEventListener", listener.getClass().getSimpleName()));
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
			double credit, LCC_ERR_TYPE err) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvLackOfCreditNotice(roomId, message, credit, err);
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
	public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {
		synchronized(mIMOtherListener){
			for (Iterator<IMOtherEventListener> iter = mIMOtherListener.iterator(); iter.hasNext(); ) {
				IMOtherEventListener listener = iter.next();
				listener.OnRecvLoveLevelUpNotice(lovelevelItem);
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
	public void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg, IMAuthorityItem privItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomCloseNotice(roomId, errType, errMsg, privItem);
			}
		}
	}

	@Override
	public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, String honorImg, boolean isHasTicket) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum, honorImg, isHasTicket);
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
	public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg, IMAuthorityItem privItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg, privItem);
			}
		}
	}

	@Override
	public void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err,
										String errMsg, double credit, IMAuthorityItem privItem) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvRoomKickoffNotice(roomId, err, errMsg, credit, privItem);
			}
		}
	}

	@Override
	public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String[] playUrls, String userId) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvChangeVideoUrl(roomId, isAnchor, playUrls, userId);
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
	public void OnSendTalent(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String talentInviteId, String talentId) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnSendTalent(reqId, success, errType, errMsg, talentInviteId, talentId);
			}
		}
	}

	@Override
	public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit,
									   IMClientListener.TalentInviteStatus status, double rebateCredit, String giftId, String giftName, int giftNum) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, status, rebateCredit, giftId, giftName, giftNum);
			}
		}
	}

	@Override
	public void OnRecvTalentPromptNotice(String roomId, String introduction) {
		synchronized(mIMLiveRoomListeners){
			for (Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext(); ) {
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvTalentPromptNotice(roomId, introduction);
			}
		}
	}

	@Override
	public void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMRoomInItem roomInfo, IMAuthorityItem authorityItem) {

		//统一豪华私密直播间和普通私密直播间
		if(roomInfo != null){
			if(roomInfo.roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom){
				roomInfo.roomType = IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom;
			}
		}

		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRoomIn(reqId, success, errType, errMsg, roomInfo, authorityItem);
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
	public void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem, IMAuthorityItem priv) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnGetInviteInfo(reqId, success, errType, errMsg, inviteItem, priv);
			}
		}
	}


	@Override
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId, IMInviteErrItem errItem) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnSendImmediatePrivateInvite(reqId, success, errType, errMsg, invitationId, timeout, roomId, errItem);
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
	public void OnRecvInviteReply(IMInviteReplyItem replyItem) {
		synchronized(mIMInviteLaunchListeners){
			for (Iterator<IMInviteLaunchEventListener> iter = mIMInviteLaunchListeners.iterator(); iter.hasNext(); ) {
				IMInviteLaunchEventListener listener = iter.next();
				listener.OnRecvInviteReply(replyItem);
			}
		}
	}

	@Override
	public void OnRecvHonorNotice(String honorId, String honorUrl) {
		synchronized (mIMLiveRoomListeners){
			for(Iterator<IMLiveRoomEventListener> iter = mIMLiveRoomListeners.iterator(); iter.hasNext();){
				IMLiveRoomEventListener listener = iter.next();
				listener.OnRecvHonorNotice(honorId, honorUrl);
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

	/************************************ 节目相关回调  *******************************************/

	/**
	 * 节目事件监听listener列表
	 */
	private ArrayList<IMShowEventListener>  mIMShowEventListeners = new ArrayList<IMShowEventListener>();

	/**
	 * 注册节目事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMShowEventListener(IMShowEventListener listener){
		boolean result = false;
		synchronized(mIMShowEventListeners) {
			if (null != listener) {
				boolean isExist = false;
				for (Iterator<IMShowEventListener> iter = mIMShowEventListeners.iterator(); iter.hasNext(); ) {
					IMShowEventListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}

				if (!isExist) {
					result = mIMShowEventListeners.add(listener);
				}
			}
		}
		return result;
	}

	/**
	 * 注销节目事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMShowEventListener(IMShowEventListener listener) {
		boolean result = false;
		synchronized(mIMShowEventListeners) {
			result = mIMShowEventListeners.remove(listener);
		}
		return result;
	}

	@Override
	public void OnRecvProgramPlayNotice(IMProgramInfoItem showinfo, IMClientListener.IMProgramPlayType type, String msg) {
		synchronized(mIMShowEventListeners){
			for (Iterator<IMShowEventListener> iter = mIMShowEventListeners.iterator(); iter.hasNext(); ) {
				IMShowEventListener listener = iter.next();
				listener.OnRecvProgramPlayNotice(showinfo, type, msg);
			}
		}
	}

	@Override
	public void OnRecvCancelProgramNotice(IMProgramInfoItem showinfo) {
		synchronized(mIMShowEventListeners){
			for (Iterator<IMShowEventListener> iter = mIMShowEventListeners.iterator(); iter.hasNext(); ) {
				IMShowEventListener listener = iter.next();
				listener.OnRecvCancelProgramNotice(showinfo);
			}
		}
	}

	@Override
	public void OnRecvRetTicketNotice(IMProgramInfoItem showinfo, double leftCredit) {
		synchronized(mIMShowEventListeners){
			for (Iterator<IMShowEventListener> iter = mIMShowEventListeners.iterator(); iter.hasNext(); ) {
				IMShowEventListener listener = iter.next();
				listener.OnRecvRetTicketNotice(showinfo, leftCredit);
			}
		}
	}

	/************************************ 多人互动相关  *******************************************/
	@Override
	public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvRecommendHangoutNotice(item);
			}
		}
	}

	@Override
	public void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvDealInvitationHangoutNotice(item);
			}
		}
	}

	@Override
	public void OnEnterHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnEnterHangoutRoom(reqId, success, errType, errMsg, item);
			}
		}
	}

	@Override
	public void OnLeaveHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnLeaveHangoutRoom(reqId, success, errType, errMsg);
			}
		}
	}

	@Override
	public void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvEnterHangoutRoomNotice(item);
			}
		}
	}

	@Override
	public void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvLeaveHangoutRoomNotice(item);
			}
		}
	}

	@Override
	public void OnSendHangoutGift(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnSendHangoutGift(success, errType, errMsg, msgItem, credit);
			}
		}
	}

	@Override
	public void OnRecvHangoutGiftNotice(IMMessageItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvHangoutGiftNotice(item);
			}
		}
	}

	@Override
	public void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvKnockRequestNotice(item);
			}
		}
	}

	@Override
	public void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvLackCreditHangoutNotice(item);
			}
		}
	}

	@Override
	public void OnControlManPushHangout(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnControlManPushHangout(reqId, success, errType, errMsg, manPushUrl);
			}
		}
	}

	@Override
	public void OnSendHangoutRoomMsg(boolean success, LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnSendHangoutRoomMsg(success, errType, errMsg, msgItem);
			}
		}
	}

	@Override
	public void OnRecvHangoutRoomMsg(IMMessageItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvHangoutRoomMsg(item);
			}
		}
	}

	@Override
	public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvAnchorCountDownEnterHangoutRoomNotice(item);
			}
		}
	}

	@Override
	public void OnRecvHandoutInviteNotice(IMHangoutInviteItem item) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvHandoutInviteNotice(item);
			}
		}
	}

	@Override
	public void OnRecvHangoutCreditRunningOutNotice(String roomId, LCC_ERR_TYPE errType, String errMsg) {
		synchronized(mIMHangoutEventListener){
			for (Iterator<IMHangoutEventListener> iter = mIMHangoutEventListener.iterator(); iter.hasNext(); ) {
				IMHangoutEventListener listener = iter.next();
				listener.OnRecvHangoutCreditRunningOutNotice(roomId, errType, errMsg);
			}
		}
	}
}
