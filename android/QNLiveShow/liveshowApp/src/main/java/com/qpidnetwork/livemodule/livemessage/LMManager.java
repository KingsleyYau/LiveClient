package com.qpidnetwork.livemodule.livemessage;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;

//import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
//import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
//import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
//import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
//import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
//import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
//import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
//import com.qpidnetwork.livemodule.im.listener.IMBookingReplyItem;
//import com.qpidnetwork.livemodule.im.listener.IMClientListener;
//import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
//import com.qpidnetwork.livemodule.im.listener.IMGiftMessageContent;
//import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
//import com.qpidnetwork.livemodule.im.listener.IMHangoutMsgItem;
//import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
//import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
//import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
//import com.qpidnetwork.livemodule.im.listener.IMLoginItem;
//import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
//import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
//import com.qpidnetwork.livemodule.im.listener.IMOngoingShowItem;
//import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
//import com.qpidnetwork.livemodule.im.listener.IMProgramInfoItem;
//import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
//import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
//import com.qpidnetwork.livemodule.im.listener.IMRecvHangoutGiftItem;
//import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
//import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
//import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
//import com.qpidnetwork.livemodule.im.listener.IMScheduleRoomItem;
//import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
//import com.qpidnetwork.livemodule.im.listener.IMTextMessageContent;
//import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
//import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
//import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
//import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
//import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
//import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
//import com.qpidnetwork.livemodule.liveshow.manager.PushMessageType;
//import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
//import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
//import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.livemessage.item.LMClientListener;
import com.qpidnetwork.livemodule.livemessage.item.LMPrivateMsgContactItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;

/**
 * IM聊天管理器（自动登录，事件分发等）
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class LMManager extends LMClientListener {

	private static final String TAG = LMManager.class.getName();
	public static final int IM_INVALID_REQID = -1;

	private Context mContext;
	private static LMManager mIMManager;

	/**
	 * Handler
	 */
	private Handler mHandler = null;

	private LMEventListenerManager mListenerManager; //通知事件分发器



	public static LMManager newInstance(Context context){
		if(mIMManager == null){
			mIMManager = new LMManager(context);
		}
		return mIMManager;
	}

	public static LMManager getInstance(){
		return mIMManager;
	}

	@SuppressLint("HandlerLeak")
	private LMManager(Context context){
		this.mContext = context;
		mListenerManager = new LMEventListenerManager();
	}

	/**
	 * 注册邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean registerLMLiveRoomEventListener(LMLiveRoomEventListener listener){
		return mListenerManager.registerLMLiveRoomEventListener(listener);
	}

	/**
	 * 注销邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterLMLiveRoomEventListener(LMLiveRoomEventListener listener){
		return mListenerManager.unregisterLMLiveRoomEventListener(listener);
	}

	/**
	 * LM 消息管理器 初始化（initManager初始化要在IMManager的init之后创建才行用到IMManger的imclient，IMManger的init才有imclient）
	 * @param  userId   				本人用户ID
	 * @param  privateStartNotice       私信开头通知（从同步配置获取）
	 * @return
	 */
	public boolean initManager(String userId, String privateStartNotice) {
		boolean result = false;
		LMClient.LMPrivateMsgSupportType[] supportArray = new LMClient.LMPrivateMsgSupportType[1];
		supportArray[0] = LMClient.LMPrivateMsgSupportType.PrivateText;
		result = LMClient.InitLMManager(userId, supportArray, IMClient.GetIMClient(), this, privateStartNotice);

		return result;
	}

	/**
	 * LM 消息管理器 释放LM管理器（用于登出）
	 * @return
	 */
	public boolean releaseManager() {
		boolean result = false;
		result =  LMClient.ReleaseLMManager(IMClient.GetIMClient());
		return result;
	}


	/**
	 * LM 消息管理器 获取本地私信联系人列表（用在联系人列表界面，刚开始就调用这个或者接收到c层的联系人有改变通知调用）
	 * @return
	 */
	public LMPrivateMsgContactItem[] GetLocalPrivateMsgFriendList() {

		LMPrivateMsgContactItem[] list = LMClient.GetLocalPrivateMsgFriendList();

		return list;
	}

	/**
	 * LM 消息管理器 请求服务器刷新私信联系人列表（用在联系人列表界面，暂时在断网或刚进来调用完获取本地私信联系人列表（GetLocalPrivateMsgFriendList）才调用）
	 * @return
	 */
	public boolean GetPrivateMsgFriendList() {
		boolean result = LMClient.GetPrivateMsgFriendList();
		return result;
	}


	/**
	 * LM 消息管理器 添加私信在聊列表在聊用户
	 * @return ture： 添加成功， false：失败（可能已经增加过了，或userId为""）
	 */
	public boolean AddPrivateMsgLiveChatList(String userId) {
		boolean result = LMClient.AddPrivateMsgLiveChatList(userId);

		return result;
	}

	/**
	 * LM 消息管理器 移除私信在聊列表在聊用户
	 * @return ture： 移除成功， false：失败（可能列表没有这个用户，或userId为""）
	 */
	public boolean RemovePrivateMsgLiveChatList(String userId) {

		boolean result = LMClient.RemovePrivateMsgLiveChatList(userId);

		return result;
	}

	/**
	 * LM 消息管理器 获取本地用户私信消息 （用于刚进聊天间或者断网重连后调用）
	 * @param userId			对方的userId
	 * @return 私信消息队列
	 */
	public LiveMessageItem[] GetLocalPrivateMsgWithUserId(String userId) {
		LiveMessageItem[] list = LMClient.GetLocalPrivateMsgWithUserId(userId);

		return list;
	}

	/**
	 * LM 消息管理器 刷新用户私信消息 （用于刚进聊天间或者断网重连后调用GetLocalPrivateMsgWithUserId之后接着调用）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public int RefreshPrivateMsgWithUserId(String userId) {
		int reqId = LMClient.RefreshPrivateMsgWithUserId(userId);
		return reqId;
	}

	/**
	 * LM 消息管理器 获取更多用户私信消息 （用于上拉，下拉）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public int GetMorePrivateMsgWithUserId(String userId) {
		int reqId = LMClient.GetMorePrivateMsgWithUserId(userId);
		return reqId;
	}

	/**
	 * LM 消息管理器 设置已读私信（用于RefreshPrivateMsgWithUserId和接收到要更新的私信列表OnUpdatePrivateMsgWithUserId是调用）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public boolean SetPrivateMsgReaded(String userId, OnSetPrivatemsgReadedCallback callback) {
		boolean result = LMClient.SetPrivateMsgReaded(userId, callback);
		return result;
	}


	/**
	 * LM 消息管理器 发送私信（OnUpdatePrivateMsgWithUserId 返回消息数组，可能加上时间item）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public boolean SendPrivateMessage(String userId, String message){
		return LMClient.SendPrivateMessage(userId, message);
	}

	/**
	 * LM 消息管理器 重新发送私信（OnUpdatePrivateMsgWithUserId 返回消息数组，可能加上时间item）
	 * @param userId			对方的userId
	 * @param 	sendMsgId			私信消息的唯一标识位
	 * @return  返回请求Id
	 */
	public boolean RepeatSendPrivateMsg(String userId, int sendMsgId) {
		return LMClient.RepeatSendPrivateMsg(userId, sendMsgId);
	}
	// ----------------	请求回调  --------------------------
	@Override
	/**
	 * LM 消息管理器 刷新私信的回调
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId) {
		mListenerManager.OnRefreshPrivateMsgWithUserId(success, errType, errMsg, userId, messageList, reqId);
	}

	@Override
	/**
	 * LM 消息管理器 更多私信的回调
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
    public void OnGetMorePrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean isMuchMore) {
		mListenerManager.OnGetMorePrivateMsgWithUserId(success, errType, errMsg, userId, messageList, reqId, isMuchMore);
    }


	@Override
	/**
	 * LM 消息管理器 c层通知发送状态结果（用于关闭菊花，不用在插入）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, LiveMessageItem messageItem) {

		mListenerManager.OnSendPrivateMessage(success, errType, errMsg, userId, messageItem);
	}

   // ----------------- 服务器通知  -------------------------------

	@Override
	/**
	 * LM 消息管理器 c层通知联系人列表有改变，需要更新
	 * @return  返回请求Id
	 */
	public void OnUpdateFriendListNotice(boolean success, HttpLccErrType errType, String errMsg) {
		mListenerManager.OnUpdateFriendListNotice(success, errType, errMsg);
	}


	@Override
	/**
	 * LM 消息管理器 c层通知私信有更新（用于插在后面）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public void OnUpdatePrivateMsgWithUserId(String userId, LiveMessageItem[] messageList) {
		mListenerManager.OnUpdatePrivateMsgWithUserId(userId, messageList);

	}


	@Override
	/**
	 * LM 消息管理器 c层通知有没读的私信过来了（用于主界面没读）
	 * @param userId			对方的userId
	 * @return  返回请求Id
	 */
	public void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem) {
		mListenerManager.OnRecvUnReadPrivateMsg(messageItem);
	}

	@Override
	// 重发通知（上层按了重发，c层删除所有时间item（android不好删除可能有时间item），把所有发送给上层）
	public void OnRepeatSendPrivateMsgNotice(String userId, LiveMessageItem[] messageList) {

		mListenerManager.OnRepeatSendPrivateMsgNotice(userId, messageList);
	}


}
