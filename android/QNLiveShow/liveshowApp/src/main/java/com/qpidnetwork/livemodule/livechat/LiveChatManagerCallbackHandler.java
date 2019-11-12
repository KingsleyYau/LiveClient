package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LCPaidThemeInfo;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadyInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusProtocol;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.KickOfflineType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkEmfNoticeType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TryTicketEventType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoPhotoType;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * LiveChatManager回调处理类
 * @author Samson Fan
 *
 */
public class LiveChatManagerCallbackHandler implements LiveChatManagerOtherListener
													 , LiveChatManagerTryTicketListener
													 , LiveChatManagerMessageListener
													 , LiveChatManagerEmotionListener
													 , LiveChatManagerPhotoListener
													 , LiveChatManagerVideoListener
													 , LiveChatManagerVoiceListener
													 , LiveChatManagerThemeListener
													 , LiveChatManagerCamShareListener
{
	/**
	 * 回调OtherListener的object列表
	 */
	private ArrayList<LiveChatManagerOtherListener> mOtherListeners;
	/**
	 * 回调TryTicketListener的object列表
	 */
	private ArrayList<LiveChatManagerTryTicketListener> mTryTicketListeners;
	/**
	 * 回调MessageListener的object列表
	 */
	private ArrayList<LiveChatManagerMessageListener> mMessageListeners;
	/**
	 * 回调EmotionListener的object列表
	 */
	private ArrayList<LiveChatManagerEmotionListener> mEmotionListeners;
	/**
	 * 回调MagicIconListener的object列表
	 */
	private ArrayList<LiveChatManagerMagicIconListener> mMagicIconListeners;
	/**
	 * 回调PhotoListener的object列表
	 */
	private ArrayList<LiveChatManagerPhotoListener> mPhotoListeners;
	/**
	 * 回调VideoListener的object列表
	 */
	private ArrayList<LiveChatManagerVideoListener> mVideoListeners;
	/**
	 * 回调VoiceListener的object列表
	 */
	private ArrayList<LiveChatManagerVoiceListener> mVoiceListeners;
	/**
	 * 回调ThemeListener的object列表
	 */
	private ArrayList<LiveChatManagerThemeListener> mThemeListeners;
	/**
	 * 回调ThemeListener的object列表
	 */
	private ArrayList<LiveChatManagerCamShareListener> mCamShareListeners;
	
	
	public LiveChatManagerCallbackHandler() {
		mOtherListeners = new ArrayList<LiveChatManagerOtherListener>();
		mTryTicketListeners = new ArrayList<LiveChatManagerTryTicketListener>();
		mMessageListeners = new ArrayList<LiveChatManagerMessageListener>();
		mEmotionListeners = new ArrayList<LiveChatManagerEmotionListener>();
		mMagicIconListeners = new ArrayList<LiveChatManagerMagicIconListener>();
		mPhotoListeners = new ArrayList<LiveChatManagerPhotoListener>();
		mVideoListeners = new ArrayList<LiveChatManagerVideoListener>();
		mVoiceListeners = new ArrayList<LiveChatManagerVoiceListener>();
		mThemeListeners = new ArrayList<LiveChatManagerThemeListener>();
		mCamShareListeners = new ArrayList<LiveChatManagerCamShareListener>();
	}
	
	// ----------------------- 注册/注销回调 -----------------------
	/**
	 * 注册Other回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterOtherListener(LiveChatManagerOtherListener listener)
	{
		boolean result = false;
		synchronized(mOtherListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerOtherListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mOtherListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterOtherListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销Other回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterOtherListener(LiveChatManagerOtherListener listener)
	{
		boolean result = false;
		synchronized(mOtherListeners)
		{
			result = mOtherListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterOtherListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册试聊券(TryTicket)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterTryTicketListener(LiveChatManagerTryTicketListener listener) 
	{
		boolean result = false;
		synchronized(mTryTicketListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerTryTicketListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mTryTicketListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterTryTicketListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销试聊券(TryTicket)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterTryTicketListener(LiveChatManagerTryTicketListener listener) 
	{
		boolean result = false;
		synchronized(mTryTicketListeners)
		{
			result = mTryTicketListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterTryTicketListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册文本消息(Message)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterMessageListener(LiveChatManagerMessageListener listener)
	{
		boolean result = false;
		synchronized(mMessageListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerMessageListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mMessageListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterMessageListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销文本消息(Message)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterMessageListener(LiveChatManagerMessageListener listener)
	{
		boolean result = false;
		synchronized(mMessageListeners)
		{
			result = mMessageListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterMessageListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册高级表情(Emotion)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterEmotionListener(LiveChatManagerEmotionListener listener) 
	{
		boolean result = false;
		synchronized(mEmotionListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerEmotionListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mEmotionListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterEmotionListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销高级表情(Emotion)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterEmotionListener(LiveChatManagerEmotionListener listener) 
	{
		boolean result = false;
		synchronized(mEmotionListeners)
		{
			result = mEmotionListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterEmotionListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册小高级表情(MagicIcon)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterMagicIconListener(LiveChatManagerMagicIconListener listener)
	{
		boolean result = false;
		synchronized(mMagicIconListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerMagicIconListener> iter = mMagicIconListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerMagicIconListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mMagicIconListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterMagicIconListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销小高级表情(MagicIcon)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterMagicIconListener(LiveChatManagerMagicIconListener listener)
	{
		boolean result = false;
		synchronized(mMagicIconListeners)
		{
			result = mMagicIconListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterMagicIconListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册私密照(Photo)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterPhotoListener(LiveChatManagerPhotoListener listener)
	{
		boolean result = false;
		synchronized(mPhotoListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerPhotoListener> iter = mPhotoListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerPhotoListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mPhotoListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterPhotoListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销私密照(Photo)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterPhotoListener(LiveChatManagerPhotoListener listener)
	{
		boolean result = false;
		synchronized(mPhotoListeners)
		{
			result = mPhotoListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterPhotoListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册微视频(Video)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterVideoListener(LiveChatManagerVideoListener listener) 
	{
		boolean result = false;
		synchronized(mVideoListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerVideoListener> iter = mVideoListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerVideoListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mVideoListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterVideoListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销私密照(Video)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterVideoListener(LiveChatManagerVideoListener listener) 
	{
		boolean result = false;
		synchronized(mVideoListeners)
		{
			result = mVideoListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterVideoListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册语音(Voice)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterVoiceListener(LiveChatManagerVoiceListener listener)
	{
		boolean result = false;
		synchronized(mVoiceListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerVoiceListener> iter = mVoiceListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerVoiceListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mVoiceListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterVoiceListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销语音(Voice)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterVoiceListener(LiveChatManagerVoiceListener listener)
	{
		boolean result = false;
		synchronized(mVoiceListeners)
		{
			result = mVoiceListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterVoiceListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册主题(Theme)回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterThemeListener(LiveChatManagerThemeListener listener)
	{
		boolean result = false;
		synchronized(mCamShareListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerThemeListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mThemeListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterThemeListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销主题(Theme)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterThemeListener(LiveChatManagerThemeListener listener)
	{
		boolean result = false;
		synchronized(mThemeListeners)
		{
			result = mThemeListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterThemeListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 注册CamShare回调
	 * @param listener
	 * @return
	 */
	public boolean RegisterCamShareListener(LiveChatManagerCamShareListener listener) 
	{
		boolean result = false;
		synchronized(mCamShareListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<LiveChatManagerCamShareListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
					LiveChatManagerCamShareListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mCamShareListeners.add(listener);
				}
				else {
					Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "LiveChatManagerCallbackHandler", "RegisterCamShareListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail, listener is null", "LiveChatManagerCallbackHandler", "RegisterListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销主题(Theme)回调
	 * @param listener
	 * @return
	 */
	public boolean UnregisterCamShareListener(LiveChatManagerCamShareListener listener) 
	{
		boolean result = false;
		synchronized(mCamShareListeners)
		{
			result = mCamShareListeners.remove(listener);
		}

		if (!result) {
			Log.e("livechat", String.format("%s::%s() fail, listener:%s", "LiveChatManagerCallbackHandler", "UnregisterCamShareListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	// ---------------------------- Other ----------------------------
	/**
	 * 登录回调
	 * @param errType	错误类型
	 * @param errmsg	错误代码
	 * @param isAutoLogin	自动重登录
	 */
	public void OnLogin(LiveChatErrType errType, String errmsg, boolean isAutoLogin)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnLogin(errType, errmsg, isAutoLogin);
			}
		}
	}
	
	/**
	 * 注销/断线回调
	 * @param errType	错误类型
	 * @param errmsg	错误代码
	 * @param isAutoLogin	是否自动重新登录
	 */
	public void OnLogout(LiveChatErrType errType, String errmsg, boolean isAutoLogin)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnLogout(errType, errmsg, isAutoLogin);
			}
		}		
	}
	
	/**
	 * 获取在聊及邀请用户列表回调
	 * @param errType	错误类型
	 * @param errmsg	错误代码
	 */
	public void OnGetTalkList(LiveChatErrType errType, String errmsg)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetTalkList(errType, errmsg);
			}
		}
	}
	
	/**
	 * 获取单个用户历史聊天记录（包括文本、高级表情、语音、图片）
	 * @param success	是否成功
	 * @param errno		错误代码
	 * @param errmsg	错误描述
	 * @param userItem	用户item
	 */
	public void OnGetHistoryMessage(boolean success, String errno, String errmsg, LCUserItem userItem)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetHistoryMessage(success, errno, errmsg, userItem);
			}
		}
	}
	
	/**
	 * 获取多个用户历史聊天记录（包括文本、高级表情、语音、图片）
	 * @param success 	是否成功
	 * @param errno		错误代码
	 * @param errmsg	错误描述
	 * @param userItems	用户item
	 */
	public void OnGetUsersHistoryMessage(boolean success, String errno, String errmsg, LCUserItem[] userItems)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetUsersHistoryMessage(success, errno, errmsg, userItems);
			}
		}
	}
	
	// ---------------- 在线状态相关回调函数(online status) ----------------
	/**
	 * 设置在线状态回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 */
	public void OnSetStatus(LiveChatErrType errType, String errmsg)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnSetStatus(errType, errmsg);
			}
		}
	}
	
	
	/**
	 * 获取用户在线状态回调
	 * @param errType	错误类型
	 * @param errmsg	错误代码
	 * @param userList	用户在线状态数组
	 */
	public void OnGetUserStatus(LiveChatErrType errType, String errmsg, LCUserItem[] userList)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetUserStatus(errType, errmsg, userList);
			}
		}
	}
	
	/**
	 * 获取指定女士信息回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param item
	 */
	public void OnGetUserInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item){
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetUserInfo(errType, errmsg, userId, item);
			}
		}
	}
	
	/**
	 * 批量获取女士信息回调
	 */
	public void OnGetUsersInfo(LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetUsersInfo(errType, errmsg, userIds, itemList);
			}
		}
	}

	/**
	 * LiveChat获取联系人列表
	 * @param errType
	 * @param errmsg
	 * @param list
	 */
	public void OnGetContactList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list){
		synchronized(mOtherListeners)
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetContactList(errType, errmsg, list);
			}
		}
	}
	
	/**
	 * 接收他人在线状态更新消息回调
	 * @param userItem	用户item
	 */
	public void OnUpdateStatus(LCUserItem userItem)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnUpdateStatus(userItem);
			}
		}
	}
	
	/**
	 * 他人在线状态更新回调
	 * @param userItem	用户item
	 */
	public void OnChangeOnlineStatus(LCUserItem userItem)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnChangeOnlineStatus(userItem);
			}
		}
	}
	
	/**
	 * 接收被踢下线消息回调
	 * @param kickType	被踢下线原因
	 */
	public void OnRecvKickOffline(KickOfflineType kickType)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnRecvKickOffline(kickType);
			}
		}
	}
	
	// ---------------- 试聊券相关回调函数(Try Ticket) ----------------
	/**
	 * 使用试聊券回调
	 * @param errType	处理结果类型
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param eventType	试聊券使用情况
	 */
	public void OnUseTryTicket(
			LiveChatErrType errType
			, String errno
			, String errmsg
			, String userId
			, TryTicketEventType eventType)
	{
		synchronized(mTryTicketListeners) 
		{
			for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerTryTicketListener listener = iter.next();
				listener.OnUseTryTicket(errType, errno, errmsg, userId, eventType);
			}
		}
	}
	
	/**
	 * 接收试聊开始消息回调
	 * @param time		试聊时长
	 */
	public void OnRecvTryTalkBegin(LCUserItem userItem, int time)
	{
		synchronized(mTryTicketListeners) 
		{
			for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerTryTicketListener listener = iter.next();
				listener.OnRecvTryTalkBegin(userItem, time);
			}
		}
	}
	
	/**
	 * 接收试聊结束消息回调
	 * @param userItem	聊天对象
	 */
	public void OnRecvTryTalkEnd(LCUserItem userItem)
	{
		synchronized(mTryTicketListeners) 
		{
			for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerTryTicketListener listener = iter.next();
				listener.OnRecvTryTalkEnd(userItem);
			}
		}
	}
	
	/**
	 * 查询是否能使用试聊券回调
	 * @param success	是否成功
	 * @param errno		错误代码
	 * @param errmsg	错误描述
	 * @param item		查询结果
	 */
	public void OnCheckCoupon(boolean success, String errno, String errmsg, Coupon item)
	{
		synchronized(mTryTicketListeners) 
		{
			for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerTryTicketListener listener = iter.next();
				listener.OnCheckCoupon(success, errno, errmsg, item);
			}
		}
	}
	
	// ---------------- 对话状态改变或对话操作回调函数(try ticket) ----------------
	/**
	 * 结束对话回调
	 * @param errType	错误类型
	 * @param errmsg	错误代码
	 * @param userItem	用户item
	 */
	public void OnEndTalk(LiveChatErrType errType, String errmsg, LCUserItem userItem)
	{
		synchronized(mTryTicketListeners) 
		{
			for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerTryTicketListener listener = iter.next();
				listener.OnEndTalk(errType, errmsg, userItem);
			}
		}
	}
	
	/**
	 * 接收聊天事件消息回调
	 * @param item	用户item
	 */
	public void OnRecvTalkEvent(LCUserItem item)
	{
		synchronized(mTryTicketListeners) 
		{
			for (Iterator<LiveChatManagerTryTicketListener> iter = mTryTicketListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerTryTicketListener listener = iter.next();
				listener.OnRecvTalkEvent(item);
			}
		}
	}
	
	// ---------------- 文字聊天回调函数(message) ----------------
	/**
	 * 发送文本聊天消息回调
	 * @param errType	错误代码
	 * @param errmsg	错误描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendMessage(LiveChatErrType errType, String errmsg, LCMessageItem item)
	{
		if(errType != LiveChatErrType.Success){
			item.sendErrorNo = new LCSendMessageErrorItem(errType, "", errmsg);
		}
		synchronized(mMessageListeners) 
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnSendMessage(errType, errmsg, item);
			}
		}
	}
	
	/**
	 * 接收聊天文本消息回调
	 * @param item		消息item
	 */
	public void OnRecvMessage(LCMessageItem item)
	{
		synchronized(mMessageListeners) 
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnRecvMessage(item);
			}
		}
	}

	/**
	 * 发送邀请消息回调
	 * @param item
	 */
	public void OnSendInviteMessage(LCMessageItem item)
	{
		synchronized(mMessageListeners)
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnSendInviteMessage(item);
			}
		}
	}
	
	/**
	 * 接收警告消息回调
	 * @param item		消息item
	 */
	public void OnRecvWarning(LCMessageItem item)
	{
		synchronized(mMessageListeners) 
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnRecvWarning(item);
			}
		}
	}
	
	/**
	 * 接收用户正在编辑消息回调 
	 * @param fromId	用户ID
	 */
	public void OnRecvEditMsg(String fromId)
	{
		synchronized(mMessageListeners) 
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext();) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnRecvEditMsg(fromId);
			}
		}
	}
	
	/**
	 * 接收系统消息回调
	 * @param item		消息item
	 */
	public void OnRecvSystemMsg(LCMessageItem item) 
	{
		synchronized(mMessageListeners) 
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext();) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnRecvSystemMsg(item);
			}
		}
	}
	
	/**
	 * 接收发送待发列表不成功消息
	 * @param errType	不成功原因
	 * @param msgList	待发列表
	 */
	public void OnSendMessageListFail(LiveChatErrType errType, ArrayList<LCMessageItem> msgList)
	{
		synchronized(mMessageListeners) 
		{
			for (Iterator<LiveChatManagerMessageListener> iter = mMessageListeners.iterator(); iter.hasNext();) {
				LiveChatManagerMessageListener listener = iter.next();
				listener.OnSendMessageListFail(errType, msgList);
			}
		}
	}
	
	// ---------------- 高级表情回调函数(Emotion) ----------------
	/**
	 * 获取高级表情配置回调
	 * @param success	是否成功
	 * @param errno	处理结果错误代码
	 * @param errmsg	处理结果描述
	 */
	public void OnGetEmotionConfig(boolean success, String errno, String errmsg, OtherEmotionConfigItem item)
	{
		synchronized(mEmotionListeners) 
		{
			for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerEmotionListener listener = iter.next();
				listener.OnGetEmotionConfig(success,errno, errmsg, item);
			}
		}
	}
	
	
	/**
	 * 发送高级表情回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendEmotion(LiveChatErrType errType, String errmsg, LCMessageItem item)
	{
		if(errType != LiveChatErrType.Success){
			item.sendErrorNo = new LCSendMessageErrorItem(errType, "", errmsg);
		}
		synchronized(mEmotionListeners) 
		{
			for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerEmotionListener listener = iter.next();
				listener.OnSendEmotion(errType, errmsg, item);
			}
		}
	}
	
	/**
	 * 接收高级表情消息回调
	 * @param item		消息item
	 */
	public void OnRecvEmotion(LCMessageItem item)
	{
		synchronized(mEmotionListeners) 
		{
			for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerEmotionListener listener = iter.next();
				listener.OnRecvEmotion(item);
			}
		}
	}
	
	/**
	 * 下载高级表情图片成功回调
	 * @param emotionItem	高级Item
	 */
	public void OnGetEmotionImage(boolean success, LCEmotionItem emotionItem)
	{
		synchronized(mEmotionListeners) 
		{
			for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerEmotionListener listener = iter.next();
				listener.OnGetEmotionImage(success, emotionItem);
			}
		}
	}
	
	/**
	 * 下载高级表情播放图片成功回调
	 * @param emotionItem	高级表情Item
	 */
	public void OnGetEmotionPlayImage(boolean success, LCEmotionItem emotionItem)
	{
		synchronized(mEmotionListeners) 
		{
			for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerEmotionListener listener = iter.next();
				listener.OnGetEmotionPlayImage(success, emotionItem);
			}
		}
	}
	
	/**
	 * 下载高级表情3gp文件成功回调
	 * @param emotionItem	高级表情Item
	 */
	public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem)
	{
		synchronized(mEmotionListeners) 
		{
			for (Iterator<LiveChatManagerEmotionListener> iter = mEmotionListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerEmotionListener listener = iter.next();
				listener.OnGetEmotion3gp(success, emotionItem);
			}
		}
	}
	
	// ---------------- 图片回调函数(Private Album) ----------------
	/**
	 * 发送图片（包括上传图片文件(php)、发送图片(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendPhoto(LiveChatErrType errType, String errno, String errmsg, LCMessageItem item)
	{
		if(errType != LiveChatErrType.Success){
			item.sendErrorNo = new LCSendMessageErrorItem(errType, errno, errmsg);
		}
		synchronized(mPhotoListeners) 
		{
			for (Iterator<LiveChatManagerPhotoListener> iter = mPhotoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerPhotoListener listener = iter.next();
				listener.OnSendPhoto(errType, errno, errmsg, item);
			}
		}
	}
	
	/**
	 * 购买图片（包括付费购买图片(php)）
	 * @param success	是否成功
	 * @param errno		请求错误代码
	 * @param errmsg	错误描述
	 * @param item		消息item
	 */
	public void OnPhotoFee(boolean success, String errno, String errmsg, LCMessageItem item)
	{
		synchronized(mPhotoListeners) 
		{
			for (Iterator<LiveChatManagerPhotoListener> iter = mPhotoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerPhotoListener listener = iter.next();
				listener.OnPhotoFee(success, errno, errmsg, item);
			}
		}
	}
	
	/**
	 * 获取/购买图片（包括付费购买图片(php)、获取对方私密照片(php)、显示图片(livechat)）回调
	 * @param isSuccess	是否成功
	 * @param errno		购买/下载请求失败的错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnGetPhoto(boolean isSuccess, String errno, String errmsg, LCMessageItem item)
	{
		synchronized(mPhotoListeners) 
		{
			for (Iterator<LiveChatManagerPhotoListener> iter = mPhotoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerPhotoListener listener = iter.next();
				listener.OnGetPhoto(isSuccess, errno, errmsg, item);
			}
		}
	}
	
	/**
	 * 接收图片消息回调
	 * @param item		消息item
	 */
	public void OnRecvPhoto(LCMessageItem item)
	{
		synchronized(mPhotoListeners) 
		{
			for (Iterator<LiveChatManagerPhotoListener> iter = mPhotoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerPhotoListener listener = iter.next();
				listener.OnRecvPhoto(item);
			}
		}
	}
	
	// ---------------- 语音回调函数(Voice) ----------------
	/**
	 * 发送语音（包括获取语音验证码(livechat)、上传语音文件(livechat)、发送语音(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendVoice(LiveChatErrType errType, String errno, String errmsg, LCMessageItem item)
	{
		if(errType != LiveChatErrType.Success){
			item.sendErrorNo = new LCSendMessageErrorItem(errType, errno, errmsg);
		}
		synchronized(mVoiceListeners) 
		{
			for (Iterator<LiveChatManagerVoiceListener> iter = mVoiceListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVoiceListener listener = iter.next();
				listener.OnSendVoice(errType, errno, errmsg, item);
			}
		}
	}
	
	/**
	 * 获取语音（包括下载语音(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnGetVoice(LiveChatErrType errType, String errmsg, LCMessageItem item)
	{
		synchronized(mVoiceListeners) 
		{
			for (Iterator<LiveChatManagerVoiceListener> iter = mVoiceListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVoiceListener listener = iter.next();
				listener.OnGetVoice(errType, errmsg, item);
			}
		}
	}
	
	/**
	 * 接收语音消息回调
	 * @param item		消息item
	 */
	public void OnRecvVoice(LCMessageItem item)
	{
		synchronized(mVoiceListeners) 
		{
			for (Iterator<LiveChatManagerVoiceListener> iter = mVoiceListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVoiceListener listener = iter.next();
				listener.OnRecvVoice(item);
			}
		}
	}
	
	// ---------------- 小高表回调函数（Magic Icon） ----------------
	/**
	 * 获取小高级表情配置回调
	 * @param success	是否成功
	 * @param errno	处理结果错误代码
	 * @param errmsg	处理结果描述
	 */
	public void OnGetMagicIconConfig(boolean success, String errno, String errmsg, MagicIconConfig item)
	{
		synchronized(mMagicIconListeners) 
		{
			for (Iterator<LiveChatManagerMagicIconListener> iter = mMagicIconListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMagicIconListener listener = iter.next();
				listener.OnGetMagicIconConfig(success,errno, errmsg, item);
			}
		}
	}
	
	/**
	 * 发送小高级表情回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendMagicIcon(LiveChatErrType errType, String errmsg, LCMessageItem item)
	{
		if(errType != LiveChatErrType.Success){
			item.sendErrorNo = new LCSendMessageErrorItem(errType, "", errmsg);
		}
		synchronized(mMagicIconListeners) 
		{
			for (Iterator<LiveChatManagerMagicIconListener> iter = mMagicIconListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMagicIconListener listener = iter.next();
				listener.OnSendMagicIcon(errType, errmsg, item);
			}
		}
	}
	
	/**
	 * 接收小高级表情消息回调
	 * @param item		消息item
	 */
	public void OnRecvMagicIcon(LCMessageItem item)
	{
		synchronized(mMagicIconListeners) 
		{
			for (Iterator<LiveChatManagerMagicIconListener> iter = mMagicIconListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMagicIconListener listener = iter.next();
				listener.OnRecvMagicIcon(item);
			}
		}
	}
	
	/**
	 * 下载小高级表情图片原图成功回调
	 * @param success
	 * @param magicIconItem
	 */
	public void OnGetMagicIconSrcImage(boolean success, LCMagicIconItem magicIconItem)
	{
		synchronized(mMagicIconListeners) 
		{
			for (Iterator<LiveChatManagerMagicIconListener> iter = mMagicIconListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMagicIconListener listener = iter.next();
				listener.OnGetMagicIconSrcImage(success, magicIconItem);
			}
		}
	}
	
	/**
	 * 下载小高级表情拇子图成功回调
	 * @param success
	 * @param magicIconItem
	 */
	public void OnGetMagicIconThumbImage(boolean success, LCMagicIconItem magicIconItem)
	{
		synchronized(mMagicIconListeners) 
		{
			for (Iterator<LiveChatManagerMagicIconListener> iter = mMagicIconListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerMagicIconListener listener = iter.next();
				listener.OnGetMagicIconThumbImage(success, magicIconItem);
			}
		}
	}
	
	
	// ---------------- 微视频回调函数(Video) ----------------
	/**
	 * 获取视频图片文件回调
	 * @param errType	处理结果错误代码
	 * @param errno		下载请求失败的错误代码
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param inviteId	邀请ID
	 * @param videoId	视频ID
	 * @param type		视频图片类型
	 * @param filePath	视频图片文件路径
	 * @param msgList	视频相关的聊天消息列表
	 * @return
	 */
	public void OnGetVideoPhoto(LiveChatErrType errType
									, String errno
									, String errmsg
									, String userId
									, String inviteId
									, String videoId
									, VideoPhotoType type
									, String filePath
									, ArrayList<LCMessageItem> msgList)
	{
		synchronized(mVideoListeners) 
		{
			for (Iterator<LiveChatManagerVideoListener> iter = mVideoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVideoListener listener = iter.next();
				listener.OnGetVideoPhoto(errType, errno, errmsg, userId, inviteId, videoId, type, filePath, msgList);
			}
		}
	}
	
	/**
	 * 购买视频（包括付费购买视频(php)）
	 * @param errno		请求错误代码
	 * @param errmsg	错误描述
	 * @param item		消息item
	 */
	public void OnVideoFee(boolean success, String errno, String errmsg, LCMessageItem item)
	{
		synchronized(mVideoListeners) 
		{
			for (Iterator<LiveChatManagerVideoListener> iter = mVideoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVideoListener listener = iter.next();
				listener.OnVideoFee(success, errno, errmsg, item);
			}
		}
	}
	
	/**
	 * 开始获取视频文件回调
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param videoPath	视频文件路径
	 * @param msgList	视频相关的聊天消息列表
	 */
	public void OnStartGetVideo(String userId
							, String videoId
							, String inviteId
							, String videoPath
							, ArrayList<LCMessageItem> msgList)
	{
		synchronized(mVideoListeners) 
		{
			for (Iterator<LiveChatManagerVideoListener> iter = mVideoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVideoListener listener = iter.next();
				listener.OnStartGetVideo(userId, videoId, inviteId, videoPath, msgList);
			}
		}
	}
	
	/**
	 * 获取视频文件回调
	 * @param errType	处理结果错误代码
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param videoPath	视频文件路径
	 * @param msgList	视频相关的聊天消息列表
	 */
	public void OnGetVideo(LiveChatErrType errType
							, String userId
							, String videoId
							, String inviteId
							, String videoPath
							, ArrayList<LCMessageItem> msgList)
	{
		synchronized(mVideoListeners) 
		{
			for (Iterator<LiveChatManagerVideoListener> iter = mVideoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVideoListener listener = iter.next();
				listener.OnGetVideo(errType, userId, videoId, inviteId, videoPath, msgList);
			}
		}
	}
	
	/**
	 * 接收图片消息回调
	 * @param item		消息item
	 */
	public void OnRecvVideo(LCMessageItem item)
	{
		synchronized(mVideoListeners) 
		{
			for (Iterator<LiveChatManagerVideoListener> iter = mVideoListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerVideoListener listener = iter.next();
				listener.OnRecvVideo(item);
			}
		}
	}
	
	// ---------------- 其它回调函数(Other) ----------------
	/**
	 * 接收邮件更新消息回调
	 * @param fromId		发送者ID
	 * @param noticeType	邮件类型
	 */
	public void OnRecvEMFNotice(String fromId, TalkEmfNoticeType noticeType)
	{
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnRecvEMFNotice(fromId, noticeType);
			}
		}
	}
	
	// ---------------- 女士端Cam状态相关回调函数(cam status) ----------------
	@Override
	public void OnGetLadyCamStatus(LiveChatErrType errType, String errmsg,
                                   String womanId, boolean isCam) {
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetLadyCamStatus(errType, errmsg, womanId, isCam);
			}
		}		
	}
	
	@Override
	public void OnGetUsersCamStatus(LiveChatErrType errType, String errmsg,
                                    LiveChatUserCamStatus[] userIds) {
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetUsersCamStatus(errType, errmsg, userIds);
			}
		}			
	}

	@Override
	public void OnRecvLadyCamStatus(String userId, UserStatusProtocol statuType) {
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnRecvLadyCamStatus(userId, statuType);
			}
		}			
	}
	
	@Override
	public void OnGetSessionInfo(LiveChatErrType errType, String errmsg, String userId, LiveChatSessionInfoItem item){
		synchronized(mOtherListeners) 
		{
			for (Iterator<LiveChatManagerOtherListener> iter = mOtherListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerOtherListener listener = iter.next();
				listener.OnGetSessionInfo(errType, errmsg, userId, item);
			}
		}	
	}

	// ---------------- LiveChat主题回调函数(Other) ----------------
	@Override
	public void OnGetPaidTheme(LiveChatErrType errType, String errmsg,
                               String userId, LCPaidThemeInfo[] paidThemeList) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnGetPaidTheme(errType, errmsg, userId, paidThemeList);
			}
		}		
	}

	@Override
	public void OnGetAllPaidTheme(boolean isSuccess, String errmsg, LCPaidThemeInfo[] paidThemeList, ThemeItem[] themeList) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnGetAllPaidTheme(isSuccess, errmsg, paidThemeList, themeList);
			}
		}		
	}

	@Override
	public void OnManFeeTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg,
                              LCPaidThemeInfo paidThemeInfo) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnManFeeTheme(errType, womanId, themeId, errmsg, paidThemeInfo);
			}
		}			
	}

	@Override
	public void OnManApplyTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg,
                                LCPaidThemeInfo paidThemeInfo) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnManApplyTheme(errType, womanId, themeId, errmsg, paidThemeInfo);
			}
		}
	}

	@Override
	public void OnPlayThemeMotion(LiveChatErrType errType, String errmsg,
                                  String womanId, String themeId) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnPlayThemeMotion(errType, errmsg, womanId, themeId);
			}
		}		
	}

	@Override
	public void OnRecvThemeMotion(String themeId, String manId, String womanId) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnRecvThemeMotion(themeId, manId, womanId);
			}
		}		
	}

	@Override
	public void OnRecvThemeRecommend(String themeId, String manId,
			String womanId) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.OnRecvThemeRecommend(themeId, manId, womanId);
			}
		}		
	}

	@Override
	public void onThemeDownloadUpdate(String themeId, int progress) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.onThemeDownloadUpdate(themeId, progress);
			}
		}
	}

	@Override
	public void onThemeDownloadFinish(boolean isSuccess, String themeId,
			String sourceDir) {
		synchronized(mThemeListeners) 
		{
			for (Iterator<LiveChatManagerThemeListener> iter = mThemeListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerThemeListener listener = iter.next();
				listener.onThemeDownloadFinish(isSuccess, themeId, sourceDir);
			}
		}
	}

	// ---------------- LiveChat CamShare回调函数(CamShare) ----------------

	@Override
	public void OnSendCamShareInvite(LiveChatErrType errType, String errmsg, String userId) {
		synchronized(mCamShareListeners) 
		{
			for (Iterator<LiveChatManagerCamShareListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerCamShareListener listener = iter.next();
				listener.OnSendCamShareInvite(errType, errmsg, userId);
			}
		}		
	}

	@Override
	public void OnApplyCamShare(LiveChatErrType errType, String errmsg,
                                String userId, String inviteId) {
		synchronized(mCamShareListeners) 
		{
			for (Iterator<LiveChatManagerCamShareListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerCamShareListener listener = iter.next();
				listener.OnApplyCamShare(errType, errmsg, userId, inviteId);
			}
		}		
	}

	@Override
	public void OnRecvAcceptCamInvite(String fromId, String toId, CamshareLadyInviteType inviteType, int sessionId, String fromName, boolean isCam) {
		synchronized(mCamShareListeners) 
		{
			for (Iterator<LiveChatManagerCamShareListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerCamShareListener listener = iter.next();
				listener.OnRecvAcceptCamInvite(fromId, toId, inviteType, sessionId, fromName, isCam);
			}
		}			
	}

	@Override
	public void OnRecvCamHearbeatException(String errMsg,
                                           LiveChatErrType errType, String targetId) {
		synchronized(mCamShareListeners) 
		{
			for (Iterator<LiveChatManagerCamShareListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerCamShareListener listener = iter.next();
				listener.OnRecvCamHearbeatException(errMsg, errType, targetId);
			}
		}		
	}
	
	@Override
	public void OnCamshareUseTryTicket(LiveChatErrType errType, String errmsg,
                                       String userId, String ticketId, String inviteId){
		synchronized(mCamShareListeners) 
		{
			for (Iterator<LiveChatManagerCamShareListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				LiveChatManagerCamShareListener listener = iter.next();
				listener.OnCamshareUseTryTicket(errType, errmsg, userId, ticketId, inviteId);
			}
		}
	}

}
