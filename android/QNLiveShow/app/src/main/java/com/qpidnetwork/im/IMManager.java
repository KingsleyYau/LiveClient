package com.qpidnetwork.im;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.httprequest.OnGetAllGiftCallback;
import com.qpidnetwork.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.httprequest.OnGetUserPhotoCallback;
import com.qpidnetwork.httprequest.item.GiftItem;
import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.im.listener.IMClientListener;
import com.qpidnetwork.im.listener.IMGiftMessageContent;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.im.listener.IMRoomInfoItem;
import com.qpidnetwork.im.listener.IMTextMessageContent;
import com.qpidnetwork.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.utils.Log;

/**
 * IM聊天管理器（自动登录，事件分发等）
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMManager extends IMClientListener implements IAuthorizationListener {
	
	private static final String TAG = IMManager.class.getName();
	public static final int IM_INVALID_REQID = -1;
	
	private Context mContext;
	private static IMManager mIMManager;
	private List<String> mUrlList;//IM连接Url
	
	/**
	 * Handler
	 */
	private Handler mHandler = null;
	
	/*登录相关*/
	private boolean mIsLogin = false; //是否已登录的标志
	private LoginItem mLoginItem; 	  //记录用户登录的个人信息
	private boolean mIsAutoRelogin = false; //是否自动重登录
	private final int mAutoReloginTime = 30 * 1000;	//自动登录间隔时长30秒

	/*基础管理类*/
	private IMUserBaseInfoManager mIMUserBaseInfoManager;

    /**
     * 礼物本地配置列表
     */
    private IMGiftManager mIMGiftManager;
	
	/**
	 * 消息ID生成器
	 */
	private AtomicInteger mMsgIdIndex = null;
	private static final int MsgIdIndexBegin = 1;
	private HashMap<Integer, IMMessageItem> mSendingMsgMap;  //记录发送中消息Map
	
	private IMEventListenerManager mListenerManager; //通知事件分发器

	private boolean isFirstSendLike = true; //在当前房间是否第一次发送点赞

	/**
	 * 请求操作类型
	 */
	private enum IMNotifyOptType {
		HttpLoginEvent,			//php登录通知
		HttpLogoutEvent,		//php注销通知
		IMLoginEvent,			//IM登录成功通知
		IMLogoutEvent,			//IM注销通知
		IMAutoLoginEvent		//IM自动登录事件
	}
	
	public static IMManager newInstance(Context context){
		if(mIMManager == null){
			mIMManager = new IMManager(context);
		}
		return mIMManager;
	}
	
	public static IMManager getInstance(){
		return mIMManager;
	}
	
	private IMManager(Context context){
		this.mContext = context;
		mUrlList = new ArrayList<String>();
		mUrlList.add("ws://172.25.32.17:3006");
		mIsLogin = false;
		mIsAutoRelogin = false;
		mListenerManager = new IMEventListenerManager();
		mMsgIdIndex = new AtomicInteger(MsgIdIndexBegin);
		mSendingMsgMap = new HashMap<Integer, IMMessageItem>();
		mIMUserBaseInfoManager = IMUserBaseInfoManager.newInstance();
        mIMGiftManager = IMGiftManager.newInstance();

		mHandler = new Handler(){
			@Override
			public void handleMessage(Message msg) {
				// TODO Auto-generated method stub
				super.handleMessage(msg);
				switch (IMNotifyOptType.values()[msg.what]) {
				case HttpLoginEvent:{
					HttpRespObject resp = (HttpRespObject)msg.obj;
					LoginItem item = (LoginItem)resp.data;
					if(resp.isSuccess && item != null){
						if(init()){
							//初始化成功,先注销
							Logout();
							Login(item);
						}else{
							Log.d(TAG, "IMManager::IMClient() init failed, urlListSize: " + mUrlList.size());
						}
					}else{
						if(mIsLogin){
							Logout();
						}
					}
				}break;

				case HttpLogoutEvent:{
					//php注销
					Logout();
				}break;
				
				case IMLoginEvent:{
					LCC_ERR_TYPE errType = LCC_ERR_TYPE.values()[msg.arg1];
					if(errType == LCC_ERR_TYPE.LCC_ERR_SUCCESS){
						mIsLogin = true;
					}else if(IsAutoRelogin(errType)){
						timerToAutoLogin();
					}else{
						mLoginItem = null;
					}
				}break;
				
				case IMLogoutEvent:{
					LCC_ERR_TYPE errType = LCC_ERR_TYPE.values()[msg.arg1];
					mIsLogin = false;
					if(IsAutoRelogin(errType)){
						//断线，需要重连
						timerToAutoLogin();
					}else{
						//注销，清除本地缓存
						ResetParam();
					}
				}break;
				
				case IMAutoLoginEvent:{
					AutoRelogin();
				}break;
				
				default:
					break;
				}
			}
		};
	}
	
	/**
	 * 绑定事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMListener(IIMEventListener listener){
		return mListenerManager.registerIMEventListener(listener);
	}
	
	/**
	 * 解除时间监听绑定
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMListener(IIMEventListener listener){
		return mListenerManager.unregisterIMEventListener(listener);
	}
	
	/**
	 * 初始化Client及相关
	 * @return
	 */
	private boolean init(){
		boolean result = false;
		if(!mUrlList.isEmpty()){
			String[] urlArray = new String[mUrlList.size()];
			result = IMClient.init(mUrlList.toArray(urlArray), this);
		}
		return result;
	}
	
	/**
	 * 登录
	 * @param loginItem
	 * @return
	 */
	public synchronized boolean Login(LoginItem loginItem) {
		Log.d(TAG, "IMManager::Login() begin, userId:%s, mIsLogin:%b", loginItem.userId, mIsLogin);
		
		boolean result = false;
		if (mIsLogin) {
			result = mIsLogin;
		}
		else {
			if (!mIsAutoRelogin) {
				// 重置参数
				ResetParam();
			}
			
			// LiveChat登录 
			result = IMClient.Login(loginItem.userId, loginItem.sessionId);
			if (result) 
			{
				mIsAutoRelogin = true;
				mLoginItem = loginItem;
			}
		}
		
		Log.d("LiveChatManager", "LiveChatManager::Login() end, userId:%s, result:%s", mLoginItem.userId, Boolean.toString(result));
		return result;
	}
	
	/**
	 * 定时执行自动登录
	 */
	private void timerToAutoLogin(){
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMAutoLoginEvent.ordinal();
		mHandler.sendMessageDelayed(msg, mAutoReloginTime);
	}
	
	/**
	 * 自动重登录
	 */
	private void AutoRelogin(){
		Log.d(TAG, "IMManager::AutoRelogin() begin, mUserId:%s, Token:%s", mLoginItem.userId, mLoginItem.sessionId);
		
		if (!TextUtils.isEmpty(mLoginItem.userId) && !TextUtils.isEmpty(mLoginItem.sessionId)){
			Login(mLoginItem);
		}
		
		Log.d(TAG, "IMManager::AutoRelogin() end");
	}
	
	/**
	 * 注销
	 * @return
	 */
	private synchronized boolean Logout() {
		Log.d(TAG, "IMManager::Logout() begin");
		// 设置不自动重登录
		mIsAutoRelogin = false;
		//更新点赞状态
		isFirstSendLike = true;

		boolean result =  IMClient.Logout();
		Log.d(TAG, "IMManager::Logout() end, result:%b", result);	
		
		return result;
	}
	
	/**
	 * 重置参数（用于注销后或登录前）
	 */
	private void ResetParam(){
		mLoginItem = null;
		mMsgIdIndex.set(MsgIdIndexBegin);
	}
	
	/**
	 * 是否自动重登录
	 * @return
	 */
	private boolean IsAutoRelogin(LCC_ERR_TYPE errType)
	{
		if (mIsAutoRelogin)
		{
			mIsAutoRelogin = (errType == LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL);
		}
		return mIsAutoRelogin;
	}

	/**
	 * 获取用户头像信息
	 * @return
	 */
	public long getUserSmallPhoto(String userId, OnGetUserPhotoCallback callback){
		return mIMUserBaseInfoManager.getUserSmallPhoto(userId, callback);
	}

	/**
	 * 获取基础用户信息
	 * @param userId
	 * @return
	 */
	public IMUserBaseInfoItem getUserInfo(String userId){
		return mIMUserBaseInfoManager.getUserBaseInfo(userId);
	}

    /***************************** IM Client 本地缓存接口   ********************************************/

	/**
	 * 获取礼物列表配置
	 * @param callback
	 */
	public void getAllGiftConfig(OnGetAllGiftCallback callback){
		mIMGiftManager.getAllGiftConfig(callback);
	}

	/**
	 * 同步单个礼物详情
	 * @param giftId
	 * @param callback
	 * @return
	 */
	public long synGiftDetail(String giftId, OnGetGiftDetailCallback callback){
		return mIMGiftManager.getGiftDetailById(giftId, callback);
	}

	/**
	 * 读取礼物详情
	 * @param giftId
	 */
	public GiftItem getLocalGiftDetailById(String giftId){
		return mIMGiftManager.getLocalGiftDetailById(giftId);
	}


	/***************************** IM Client 功能接口   ********************************************/
	/**
	 * 成功返回有效的ReqId,否则不成功，无回调
	 * @param roomId
	 * @return
	 */
	public int audienceRoomIn(String roomId){
		int reqId = IM_INVALID_REQID;
		//进入房间更新点赞状态
		isFirstSendLike = true;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.FansRoomIn(reqId, mLoginItem.sessionId, roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		return reqId;
	}
	
	/**
	 * 观众离开直播室
	 * @param roomId
	 * @return
	 */
	public int audienceRoomOut(String roomId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.FansRoomOut(reqId, mLoginItem.sessionId, roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		return reqId;
	}
	
	/**
	 * 获取直播间信息
	 * @param roomId
	 * @return
	 */
	public int getRoomInfo(String roomId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.GetRoomInfo(reqId, mLoginItem.sessionId, roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		return reqId;
	}
	
	/**
	 * 主播禁言观众
	 * @param roomId
	 * @param userId
	 * @param timeout
	 * @return
	 */
	public int anchorForbidMessage(String roomId, String userId, int timeout){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.AnchorForbidMessage(reqId, roomId, userId, timeout)){
				reqId = IM_INVALID_REQID;
			}
		}
		return reqId;
	}
	
	/**
	 * 主播踢观众出直播间
	 * @param roomId
	 * @param userId
	 * @return
	 */
	public int anchorKickOffAudience(String roomId, String userId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.AnchorKickOffAudience(reqId, roomId, userId)){
				reqId = IM_INVALID_REQID;
			}
		}
		return reqId;
	}
	
	/**
	 * 发送消息
	 * @param roomId
	 * @param msg
	 * @return
	 */
	public IMMessageItem sendRoomMsg(String roomId, String msg){
		int reqId = IMClient.GetReqId();
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), mLoginItem.userId, mLoginItem.nickName,
				mLoginItem.level, IMMessageItem.MessageType.Normal, new IMTextMessageContent(msg), null);
		if(!mIsLogin || !IMClient.SendRoomMsg(reqId, mLoginItem.sessionId, roomId, mLoginItem.nickName, msg)){
			mListenerManager.OnSendMsg(LCC_ERR_TYPE.LCC_ERR_FAIL, "", msgItem);
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}

	/**
	 * 点赞
	 * @param roomId
	 * @return
	 */
	public IMMessageItem sendLikeEvent(String roomId){
        IMMessageItem msgItem = null;
		if(isFirstSendLike) {
			//第一次点赞生成消息
			isFirstSendLike = false;
            msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), mLoginItem.userId, mLoginItem.nickName,
					mLoginItem.level, IMMessageItem.MessageType.Like, null, null);
			mListenerManager.OnSendMsg(LCC_ERR_TYPE.LCC_ERR_SUCCESS, "", msgItem);
		}

		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.SendLikeEvent(reqId, roomId, mLoginItem.sessionId, mLoginItem.nickName)){
				reqId = IM_INVALID_REQID;
			}
		}
		return msgItem;
	}

	/**
	 * 发送礼物(大小礼物)
	 * @param roomId
	 * @param giftItem
	 * @param count
	 * @param isMultiClick
	 * @param multiStart
	 * @param multiEnd
	 * @param multiClickId
	 * @return
	 */
	public IMMessageItem sendGift(String roomId, GiftItem giftItem, int count, boolean isMultiClick, int multiStart, int multiEnd, int multiClickId){
		int reqId = IMClient.GetReqId();
		IMGiftMessageContent msgContent = new IMGiftMessageContent(giftItem.id, giftItem.name, count, isMultiClick, multiStart, multiEnd, multiClickId);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), mLoginItem.userId, mLoginItem.nickName,
				mLoginItem.level, IMMessageItem.MessageType.Gift, null, msgContent);
		if(!mIsLogin || !IMClient.SendGift(reqId, roomId, mLoginItem.sessionId, mLoginItem.nickName, giftItem.id, giftItem.name, count, isMultiClick, multiStart, multiEnd, multiClickId)){
			mListenerManager.OnSendMsg(LCC_ERR_TYPE.LCC_ERR_FAIL, "", msgItem);
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}

	public IMMessageItem sendBarrage(String roomId, String message){
		int reqId = IMClient.GetReqId();
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), mLoginItem.userId, mLoginItem.nickName,
				mLoginItem.level, IMMessageItem.MessageType.Barrage, new IMTextMessageContent(message), null);
		if(!mIsLogin || !IMClient.SendBarrage(reqId, roomId, mLoginItem.sessionId, mLoginItem.nickName, message)){
			mListenerManager.OnSendMsg(LCC_ERR_TYPE.LCC_ERR_FAIL, "", msgItem);
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}
	
	/**************************** Authorization Listener  **************************************/
	@Override
	public void onLogin(boolean isSuccess, int errCode, String errMsg,
			LoginItem item) {
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.HttpLoginEvent.ordinal();
		msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, item);
		mHandler.sendMessage(msg);
	}

	@Override
	public void onLogout() {
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.HttpLogoutEvent.ordinal();
		mHandler.sendMessage(msg);
		
	}
	/**************************** IM Client Listener  **************************************/
	@Override
	public void OnLogin(LCC_ERR_TYPE errType, String errMsg) {
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMLoginEvent.ordinal();
		msg.arg1 = errType.ordinal();
		mHandler.sendMessage(msg);
		//事件分发通知
		mListenerManager.OnLogin(errType, errMsg);
	}

	/**
	 * 注销/断线回调
	 * @param errType
	 * @param errMsg
	 */
	@Override
	public void OnLogout(LCC_ERR_TYPE errType, String errMsg) {
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMLogoutEvent.ordinal();
		msg.arg1 = errType.ordinal();
		mHandler.sendMessage(msg);
		//事件分发通知
		mListenerManager.OnLogout(errType, errMsg);
	}

	@Override
	public void OnFansRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, IMRoomInfoItem roomInfo) {
		mListenerManager.OnFansRoomIn(reqId, success, errType, errMsg, roomInfo);
	}

	@Override
	public void OnFansRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg) {
		mListenerManager.OnFansRoomOut(reqId, success, errType, errMsg);
	}

	@Override
	public void OnSendRoomMsg(int reqId, LCC_ERR_TYPE errType, String errMsg) {
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendMsg(errType, errMsg, msgItem);
	}

	@Override
	public void OnRecvRoomCloseFans(String roomId, String userId,
			String nickName, int fansNum) {
		mListenerManager.OnRecvRoomCloseFans(roomId, userId, nickName, fansNum);
	}

	@Override
	public void OnRecvRoomCloseBroad(String roomId, int fansNum, int inCome,
			int newFans, int shares, int duration) {
		mListenerManager.OnRecvRoomCloseBroad(roomId, fansNum, inCome, newFans, shares, duration);		
	}

	@Override
	public void OnRecvFansRoomIn(String roomId, String userId, String nickName,
			String photoUrl) {
		//进入房间，消息列表提示
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), userId, nickName,
				-1, IMMessageItem.MessageType.RoomIn, null, null);
		mListenerManager.OnRecvMsg(msgItem);
		Log.i(TAG, "OnRecvFansRoomIn msgId:%d, roomId:%s, userId:%s", msgItem.msgId, msgItem.roomId, msgItem.userId);

		mListenerManager.OnRecvFansRoomIn(roomId, userId, nickName, photoUrl);
	}

	@Override
	public void OnRecvRoomMsg(String roomId, int level, String fromId, String nickName,
			String msg) {
        //收到普通文本消息
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId, nickName,
				level, IMMessageItem.MessageType.Normal, new IMTextMessageContent(msg), null);
		mListenerManager.OnRecvMsg(msgItem);
		Log.i(TAG, "OnRecvRoomMsg msgId:%d, roomId:%s, userId:%s", msgItem.msgId, msgItem.roomId, msgItem.userId);
	}

	@Override
	public void OnGetRoomInfo(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, int fansNum, int contribute) {
		mListenerManager.OnGetRoomInfo(reqId, success, errType, errMsg, fansNum, contribute);
	}

	@Override
	public void OnAnchorForbidMessage(int reqId, boolean success,
			LCC_ERR_TYPE errType, String errMsg) {
		mListenerManager.OnAnchorForbidMessage(reqId, success, errType, errMsg);
	}

	@Override
	public void OnAnchorKickOffAudience(int reqId, boolean success,
			LCC_ERR_TYPE errType, String errMsg) {
		mListenerManager.OnAnchorKickOffAudience(reqId, success, errType, errMsg);
	}

	@Override
	public void OnSendLikeEvent(int reqId, boolean success,
			LCC_ERR_TYPE errType, String errMsg) {

	}

	@Override
	public void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, double coins) {
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendMsg(errType, errMsg, msgItem);
		//金币更新
		mListenerManager.OnCoinsUpdate(coins);
	}

	@Override
	public void OnSendBarrage(int reqId, boolean success, LCC_ERR_TYPE errType,
			String errMsg, double coins) {
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendMsg(errType, errMsg, msgItem);
		//金币更新
		mListenerManager.OnCoinsUpdate(coins);
	}

	@Override
	public void OnKickOff(String reason) {
		mListenerManager.OnKickOff(reason);
	}

	@Override
	public void OnRecvShutUpNotice(String roomId, String userId,
			String nickName, int timeOut) {
		mListenerManager.OnRecvShutUpNotice(roomId, userId, nickName, timeOut);
	}

	@Override
	public void OnRecvKickOffRoomNotice(String roomId, String userId,
			String nickName) {
		mListenerManager.OnRecvKickOffRoomNotice(roomId, userId, nickName);
	}

	@Override
	public void OnRecvPushRoomFav(String roomId, String fromId, String nickName, boolean isFirst) {
		Log.i(TAG, "OnRecvPushRoomFav roomId:%s, fromId:%s, nickName:%s, isFirst: %d", roomId, fromId, nickName, isFirst?1:0);
		if(isFirst) {
            //收到用户首次点赞消息
			IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId, nickName,
					-1, IMMessageItem.MessageType.Like, null, null);
			mListenerManager.OnRecvMsg(msgItem);
			Log.i(TAG, "OnRecvPushRoomFav msgId:%d, roomId:%s, userId:%s", msgItem.msgId, msgItem.roomId, msgItem.userId);
		}
		mListenerManager.OnRecvPushRoomFav(roomId, fromId, nickName);
	}

	@Override
	public void OnRecvRoomGiftNotice(String roomId, String fromId,
			String nickName, String giftId, String giftName, int giftNum, boolean multi_click,
			int multi_click_start, int multi_click_end, int multiClickId) {
		IMGiftMessageContent msgContent = new IMGiftMessageContent(giftId, giftName, giftNum, multi_click, multi_click_start, multi_click_end, multiClickId);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId, nickName, -1, IMMessageItem.MessageType.Gift, null, msgContent);
		mListenerManager.OnRecvMsg(msgItem);
		Log.i(TAG, "OnRecvRoomGiftNotice msgId:%d, roomId:%s, userId:%s", msgItem.msgId, msgItem.roomId, msgItem.userId);
	}

	@Override
	public void OnRecvRoomToastNotice(String roomId, String fromId,
			String nickName, String msg) {
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId, nickName,
				-1, IMMessageItem.MessageType.Barrage, new IMTextMessageContent(msg), null);
		mListenerManager.OnRecvMsg(msgItem);
		Log.i(TAG, "OnRecvRoomGiftNotice msgId:%d, roomId:%s, userId:%s", msgItem.msgId, msgItem.roomId, msgItem.userId);
	}
	
}
