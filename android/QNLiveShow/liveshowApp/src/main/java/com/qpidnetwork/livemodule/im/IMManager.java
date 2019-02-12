package com.qpidnetwork.livemodule.im;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.im.listener.IMBookingReplyItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMGiftMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutMsgItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteErrItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteReplyItem;
import com.qpidnetwork.livemodule.im.listener.IMLoginItem;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMOngoingShowItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMProgramInfoItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMScheduleRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMTextMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.livemessage.LMManager;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

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

	/* 直播间相关 */
	private HashMap<String , IMRoomInItem> mMapRoomItems = new HashMap<>();	//在这维护房间信息为了解决:BUG#14463 add by Jagger 2019-1-17

	/*基础管理类*/
	private IMUserBaseInfoManager mIMUserBaseInfoManager;

	/**
	 * 消息ID生成器
	 */
	public AtomicInteger mMsgIdIndex = null;
	public static final int MsgIdIndexBegin = 1;
	private HashMap<Integer, IMMessageItem> mSendingMsgMap;  //记录发送中消息Map
	
	private IMEventListenerManager mListenerManager; //通知事件分发器

	//私信管理器
	private LMManager mLManager;

	/**
	 *  记录当前服务状态
	 */
	private String mInvitationId = "";
	private String mRoomId = "";
	private String mLiveInAnchorId = "";

	/**
	 * 是否连击过程中出现断线重连的情况
	 */
	public static boolean imReconnecting = false;
	/**
	 * 是否连击过程中出现断线而后重连成功的情况
	 */
	public static boolean hasIMReconnected = false;

	/**
	 * 请求操作类型
	 */
	private enum IMNotifyOptType {
		HttpLoginEvent,			//php登录通知
		HttpLogoutEvent,		//php注销通知
		IMLoginEvent,			//IM登录成功通知
		IMLogoutEvent,			//IM注销通知
		IMAutoLoginEvent,		//IM自动登录事件
		IMKickOff,				//IM被踢事件
		IMAnchorInviteShow,		//通知服务器主播邀请是否被显示处理
		IMShowNoReadEvent		//节目、背包、预约、信件、门票、私信等未读数据的刷新处理
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
	
	@SuppressLint("HandlerLeak")
	private IMManager(Context context){
		this.mContext = context;
		mUrlList = new ArrayList<String>();
		mIsLogin = false;
		mIsAutoRelogin = false;
		mListenerManager = new IMEventListenerManager();
		mMsgIdIndex = new AtomicInteger(MsgIdIndexBegin);
		mSendingMsgMap = new HashMap<Integer, IMMessageItem>();
		mIMUserBaseInfoManager = new IMUserBaseInfoManager();
		mLManager = LMManager.newInstance(context);
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
							//初始化私信管理器，必须在IMClient初始化成功后再初始化，私信依赖IMClient,即必须im初始化成功，私信功能才可用
							String messageNoMoreDesc = "";
							ConfigItem configItem = LoginManager.getInstance().getSynConfig();
							if( configItem != null){
								messageNoMoreDesc = configItem.pmStartNotice;
							}
							mLManager.initManager(item.userId, messageNoMoreDesc);

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
						reLoginSuc();

						//登录成功同步用户信息
						GetUserInfo();
					}else if(IsAutoRelogin(errType)){
						timerToAutoLogin();
					}else{
//						mLoginItem = null;
					}
				}break;
				
				case IMLogoutEvent:{
					LCC_ERR_TYPE errType = LCC_ERR_TYPE.values()[msg.arg1];
					mIsLogin = false;
					if(IsAutoRelogin(errType)){
						//断线，需要重连
						imReconnecting = true;
						Log.d(TAG,"IMLogoutEvent-断线，需要重连");
						timerToAutoLogin();
					}else{
						//注销，清除本地缓存
						ResetParam();
					}
				}break;
				
				case IMAutoLoginEvent:{
					AutoRelogin();
				}break;

				case IMKickOff:{
				    String errMsg = (String)msg.obj;
					LiveModule.getInstance().onModuleKickoff(errMsg);
				}break;

				case IMAnchorInviteShow:{
					//通知服务器
					boolean isShow = msg.arg1 == 1 ? true:false;
					String inviteId = (String)msg.obj;
					if(!TextUtils.isEmpty(inviteId)){
						InstantInviteUserReport(inviteId, isShow);
					}
				}break;

				case IMShowNoReadEvent:{
					//刷新节目未读数目
					//ShowUnreadManager.getInstance().GetNoReadNumProgram();
					ShowUnreadManager.getInstance().refreshUnReadData();
				}break;
				
				default:
					break;
				}
			}
		};
	}

	/**
	 * 注册邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMInviteLaunchEventListener(IMInviteLaunchEventListener listener){
		return mListenerManager.registerIMInviteLaunchEventListener(listener);
	}

	/**
	 * 注销邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMInviteLaunchEventListener(IMInviteLaunchEventListener listener){
		return mListenerManager.unregisterIMInviteLaunchEventListener(listener);
	}

	/**
	 * 注册邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMLiveRoomEventListener(IMLiveRoomEventListener listener){
		return mListenerManager.registerIMLiveRoomEventListener(listener);
	}

	/**
	 * 注销邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMLiveRoomEventListener(IMLiveRoomEventListener listener){
		return mListenerManager.unregisterIMLiveRoomEventListener(listener);
	}

	/**
	 * 注册邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMOtherEventListener(IMOtherEventListener listener){
		return mListenerManager.registerIMOtherEventListener(listener);
	}

	/**
	 * 注销邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMOtherEventListener(IMOtherEventListener listener){
		return mListenerManager.unregisterIMOtherEventListener(listener);
	}

	/**
	 * 注册节目事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMShowEventListener(IMShowEventListener listener){
		return mListenerManager.registerIMShowEventListener(listener);
	}

	/**
	 * 注销节目事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMShowEventListener(IMShowEventListener listener){
		return mListenerManager.unregisterIMShowEventListener(listener);
	}
	
	/**
	 * 初始化Client及相关
	 * @return
	 */
	private boolean init(){
		boolean result = false;
		if(mUrlList.isEmpty()){
			ConfigItem item = LoginManager.getInstance().getSynConfig();
			if(item != null && !TextUtils.isEmpty(item.imServerUrl)){
				mUrlList.add(item.imServerUrl);
			}
		}
		if(!mUrlList.isEmpty()){
			String[] urlArray = new String[mUrlList.size()];
			//IMClient.IMSetLogDirectory("/storage/emulated/0/QpidDating/live/log/");
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
		}else {
			if (!mIsAutoRelogin) {
				// 重置参数
				ResetParam();
			}
			// LiveChat登录 result为true仅代表ConnectServer成功，但IM并没有登上，需要等待OnLoginIn回调
			result = IMClient.Login(loginItem.token);
			if (result){
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
	 * 外部注销清除定时器，解决注销和自动登录冲突问题
	 */
	private void removeTimerAutoLogin(){
		if(mHandler != null){
			mHandler.removeMessages(IMNotifyOptType.IMAutoLoginEvent.ordinal());
		}
	}
	
	/**
	 * 自动重登录
	 */
	private void AutoRelogin(){
		Log.d(TAG, "IMManager::AutoRelogin() begin, mUserId:%s, Token:%s", mLoginItem.userId, mLoginItem.token);
		
		if (!TextUtils.isEmpty(mLoginItem.userId) && !TextUtils.isEmpty(mLoginItem.token)){
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
		boolean result =  IMClient.Logout();
		if(result){
			mIsLogin = false;
		}
		Log.d(TAG, "IMManager::Logout() end, result:%b", result);	
		
		return result;
	}
	
	/**
	 * 重置参数（用于注销后或登录前）
	 */
	private void ResetParam(){
//		mLoginItem = null;		//IM登录异常导致数据被清除后又未提出应用，发消息构建消息空指针异常，修改为PHP控制IM消息
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
	 * 获取基础用户信息
	 * @param userId
	 * @return
	 */
	public IMUserBaseInfoItem getUserInfo(String userId){
		return mIMUserBaseInfoManager.getUserBaseInfo(userId);
	}

	/**
	 * 清理基础用户信息
	 */
	public void clearUserInfoList(){
		Log.d(TAG,"clearUserInfoList");
		if(null != mIMUserBaseInfoManager){
			mIMUserBaseInfoManager.clearUserBaseInfoList();
		}
	}

	/**
	 * 更新用户信息
	 * @param userInfo
	 */
	public void updateOrAddUserBaseInfo(IMUserBaseInfoItem userInfo){
		if(null != mIMUserBaseInfoManager){
			mIMUserBaseInfoManager.updateOrAddUserBaseInfo(userInfo);
		}
	}

	/**
	 * 更新用户信息
	 * @param userId
	 * @param userName
	 * @param photoUrl
	 */
	public void updateOrAddUserBaseInfo(String userId, String userName, String photoUrl){
		if(null != mIMUserBaseInfoManager){
			mIMUserBaseInfoManager.updateOrAddUserBaseInfo(userId, userName, photoUrl);
		}
	}

	/**
	 * 获取正在交互中主播Id
	 * @return
	 */
	public String getCurrentLivingAnchorId(){
		Log.i(TAG, "getCurrentLivingAnchorId mLiveInAnchorId: " + mLiveInAnchorId);
		return mLiveInAnchorId;
	}

	/**
	 * 是否直播中
	 * 		直播中状态定义：起始（发出邀请、应邀、进入直播间），终止（邀请失败、应邀失败、直播间结束等）
	 * @return
	 */
	public boolean isCurrentInLive(){
		boolean isCurrentLive = false;
		Log.i(TAG, "isCurrentInLive mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId);
		if(!TextUtils.isEmpty(mInvitationId)
				|| !TextUtils.isEmpty(mRoomId)){
			isCurrentLive = true;
		}
		return isCurrentLive;
	}

	/**
	 * 切换服务时，终止直播服务
	 */
	public void stopLiveServiceLocal(){
		Log.i(TAG, "stopLiveServiceLocal mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId);
		if(!TextUtils.isEmpty(mInvitationId)){
			//邀请中，默认取消
			cancelImmediatePrivateInvite(mInvitationId);
		}

		if(!TextUtils.isEmpty(mRoomId)){
			//已经入直播间，调用退出直播间
			RoomOut(mRoomId);
		}
		mInvitationId = "";
		mRoomId = "";
		mLiveInAnchorId = "";
	}

	/**
	 * 根据直播间ID取直播间信息
	 * @param roomId
	 * @return
	 */
	public IMRoomInItem getRoomInItem(String roomId){
		if(mMapRoomItems.containsKey(roomId)){
			return mMapRoomItems.get(roomId);
		}
		return null;
	}

	/**
	 * 清空所有直播间信息缓存
	 */
	public void cleanRoomInItems(){
		mMapRoomItems.clear();
	}

	/***************************** IM Client 功能接口   ********************************************/
	/**
	 * 成功返回有效的ReqId,否则不成功，无回调
	 * @param roomId
	 * @return
	 */
	public int RoomIn(String roomId){
		int reqId = IM_INVALID_REQID;
		Log.i(TAG, "RoomIn mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId);
		//调用进入直播间清除本地邀请id
		mInvitationId = "";
		mLiveInAnchorId = "";

		Log.d(TAG,"RoomIn-reqId0:"+reqId+" mIsLogin:"+mIsLogin+" roomId:"+roomId );
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			Log.d(TAG,"RoomIn-reqId1:"+reqId);
			if(!IMClient.RoomIn(reqId, roomId)){
				reqId = IM_INVALID_REQID;
				Log.d(TAG,"RoomIn-reqId2:"+reqId);
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnRoomIn(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), null, null);
		}
		return reqId;
	}
	
	/**
	 * 观众离开直播室
	 * @param roomId
	 * @return
	 */
	public int RoomOut(String roomId){
		int reqId = IM_INVALID_REQID;
		Log.i(TAG, "RoomOut mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId + " roomId: " + roomId);
		//调用roomout后不需要等待处理（业务设计如此）
		mRoomId = "";
		mInvitationId = "";
		mLiveInAnchorId = "";

		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.RoomOut(reqId, roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnRoomOut(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description));
		}
		return reqId;
	}

	/**
	 * 进入公开直播间
	 * @param anchorId
	 * @return
	 */
	public int PublicRoomIn(String anchorId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.PublicRoomIn(reqId, anchorId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnRoomIn(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), null, null);
		}
		return reqId;
	}

	/**
	 * 直播间互动，开启或关闭视频
	 * @param roomId
	 * @param operateType
	 * @return
	 */
	public int ControlManPush(String roomId, IMClient.IMVideoInteractiveOperateType operateType){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.ControlManPush(reqId, roomId, operateType)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnControlManPush(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), null);
		}
		return reqId;
	}

	/**
	 * 断线重连获取指定邀请信息
	 * @param invatationId
	 * @return
	 */
	public int GetInviteInfo(String invatationId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.GetInviteInfo(reqId, invatationId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnGetInviteInfo(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), null, null);
		}
		return reqId;
	}

	/**
	 * 发送消息
	 * @param roomId
	 * @param msg
	 * @param targetIds
	 * @return
	 */
	public IMMessageItem sendRoomMsg(String roomId, String msg, String[] targetIds){
		int reqId = IMClient.GetReqId();
		Log.logD(TAG,"sendRoomMsg-roomId:"+roomId+" msg:"+msg+" reqId0:"+reqId);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(),
				mLoginItem.userId, mLoginItem.nickName, "", mLoginItem.level,
				IMMessageItem.MessageType.Normal, new IMTextMessageContent(msg), null);
		boolean result = !mIsLogin || !IMClient.SendRoomMsg(reqId, roomId, mLoginItem.nickName, msg, targetIds);
		Log.d(TAG,"sendRoomMsg-mIsLogin:"+mIsLogin+" result:"+result);
		if(result){
			mListenerManager.OnSendRoomMsg(false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), msgItem);
			return null;
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
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
	public IMMessageItem sendGift(String roomId, GiftItem giftItem, boolean isPackage,
								  int count, boolean isMultiClick, int multiStart,
								  int multiEnd, int multiClickId){
		int reqId = IMClient.GetReqId();
		IMGiftMessageContent msgContent = new IMGiftMessageContent(giftItem.id, giftItem.name, count,
				isMultiClick, multiStart, multiEnd, multiClickId);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(),
				mLoginItem.userId, mLoginItem.nickName, "", mLoginItem.level,
				IMMessageItem.MessageType.Gift, null, msgContent);

		if(!mIsLogin || !IMClient.SendGift(reqId, roomId, mLoginItem.nickName, giftItem.id,
				giftItem.name, isPackage, count, isMultiClick, multiStart, multiEnd, multiClickId)){
			mListenerManager.OnSendGift(false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), msgItem, 0, 0);
			return null;
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}

	/**
	 * 发送弹幕消息
	 * @param roomId
	 * @param message
	 * @return
	 */
	public IMMessageItem sendBarrage(String roomId, String message){
		int reqId = IMClient.GetReqId();
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(),
				mLoginItem.userId, mLoginItem.nickName, "", mLoginItem.level,
				IMMessageItem.MessageType.Barrage, new IMTextMessageContent(message), null);
		if(!mIsLogin || !IMClient.SendBarrage(reqId, roomId, mLoginItem.nickName, message)){
			mListenerManager.OnSendBarrage(false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), msgItem, 0, 0);
			return null;
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}

	/**
	 * 7.1.观众立即私密邀请
	 * @param userId
	 * @param logId			用于区分是否主播发起
	 * @param force
	 * @return
	 */
	public int sendImmediatePrivateInvite(String userId, String logId, boolean force){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.SendImmediatePrivateInvite(reqId, userId, logId, force)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnSendImmediatePrivateInvite(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), "", 0, "", null);
		}else{
			//设置直播中主播对象
			mLiveInAnchorId = userId;
		}
		return reqId;
	}

	/**
	 * 7.2.观众取消立即私密邀请
	 * @param inviteId
	 * @return
	 */
	public int cancelImmediatePrivateInvite(String inviteId){
		int reqId = IM_INVALID_REQID;
		//调用取消就代表取消，不需要等待是否成功（业务设计）
		Log.i(TAG, "cancelImmediatePrivateInvite mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId + " inviteId: " + inviteId);
		if(inviteId.equals(mInvitationId)){
			mInvitationId = "";
			mLiveInAnchorId = "";
		}

		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.CancelImmediatePrivateInvite(reqId, inviteId)){
				reqId = IM_INVALID_REQID;
			}
			
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnCancelImmediatePrivateInvite(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), "");
		}
		return reqId;
	}

	/**
	 * 8.1.发送直播间才艺点播邀请
	 * @param roomId
	 * @param talentId
	 * @return
	 */
	public int sendTalentInvite(String roomId, String talentId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.SendTalentInvite(reqId , roomId , talentId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnSendTalent(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_connect_error_description), "", talentId);
		}
		return reqId;
	}

	/**
	 * 通知服务器是否显示主播邀请
	 * @param inviteId
	 * @param isShow
	 * @return
	 */
	private int InstantInviteUserReport(String inviteId, boolean isShow){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.InstantInviteUserReport(reqId , inviteId , isShow)){
				reqId = IM_INVALID_REQID;
			}
		}
		return reqId;
	}

	/**************************** Authorization Listener  **************************************/
	@Override
	public void onLogin(boolean isSuccess, int errCode, String errMsg,
			LoginItem item) {
		Log.d(TAG,"HttpLogin onLogin-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" item:"+item);
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.HttpLoginEvent.ordinal();
		msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, item);
		mHandler.sendMessage(msg);
	}

	@Override
	public void onLogout(boolean isMannual) {
		//手动注销清除本地缓存
		Log.i(TAG, "onLogout mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId + " isMannual: " + isMannual);
		if(isMannual){
			//清除房间id及邀请id
			mRoomId = "";
			mInvitationId = "";
			mLiveInAnchorId = "";

			//私信重置
			mLManager.releaseManager();
		}
		//清除自动登录定时设置
		removeTimerAutoLogin();

		Log.d(TAG,"HttpLogin onLogout");
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.HttpLogoutEvent.ordinal();
		mHandler.sendMessage(msg);
		
	}
	/**************************** IM Client Listener  **************************************/
	@Override
	public void OnLogin(LCC_ERR_TYPE errType, String errMsg, IMLoginItem loginItem) {
		Log.d(TAG,"IMLogin onLogin-errMsg:"+errMsg+" errType:"+errType);
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMLoginEvent.ordinal();
		msg.arg1 = errType.ordinal();
		mHandler.sendMessage(msg);
		//事件分发通知
		mListenerManager.OnLogin(errType, errMsg);
		//断线重连等登录成功刷新节目未读数
		SendRefreshShowNoRead();


		//增加登录成功，节目列表处理
		if(loginItem != null && loginItem.ongoingShowList != null){
			for(IMOngoingShowItem item : loginItem.ongoingShowList){
				OnRecvProgramPlayNotice(item.showInfo, item.type, item.msg);
			}
		}

		//登录成功，有上次未结束任务需要重启
		if(loginItem != null && LiveModule.getInstance().mIsFirstLaunch){
			//重新启动进入直播看，走预约到期点击进入逻辑
//			if(loginItem.roomList != null && loginItem.roomList.length > 0){
//				String url = URL2ActivityManager.createBookExpiredUrl(loginItem.roomList[0].anchorId, loginItem.roomList[0].nickName, loginItem.roomList[0].roomId);
//				Intent intent = new Intent();
//				intent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, url);
//				intent.setAction(CommonConstant.ACTION_PUSH_NOTIFICATION);
//				mContext.sendBroadcast(intent);
//			}

			//检测是否有预约到期通知，有则发push通知
//			if(loginItem.scheduleRoomList != null && loginItem.scheduleRoomList.length > 0){
//				for(IMScheduleRoomItem item : loginItem.scheduleRoomList){
//					//发送push
//					String url = URL2ActivityManager.createBookExpiredUrl(item.anchorId, item.nickName, item.anchorPhotoUrl, item.roomId);
//					PushManager.getInstance().ShowNotification(NotificationTypeEnum.SCHEDULEINVITE_NOFICATION,
//							mContext.getResources().getString(R.string.app_name),
//							String.format(mContext.getResources().getString(R.string.notification_scheduled_invite_expired_tip), item.nickName),
//							url, true);
//				}
//			}
		}
		//是否第一次启动登录成功
		LiveModule.getInstance().mIsFirstLaunch = false;
	}

	/**
	 * 注销/断线回调
	 * @param errType
	 * @param errMsg
	 */
	@Override
	public void OnLogout(LCC_ERR_TYPE errType, String errMsg) {

		Log.d(TAG,"IMLogin onLogout-errType:"+errType+" errMsg:"+errMsg);
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMLogoutEvent.ordinal();
		msg.arg1 = errType.ordinal();
		mHandler.sendMessage(msg);
		//事件分发通知
		mListenerManager.OnLogout(errType, errMsg);
	}

	@Override
	public void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo, IMAuthorityItem authorityItem) {
		Log.d(TAG,"OnRoomIn-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId
				+" success:"+success+" roomInfo:"+roomInfo);
		//进入房间成功，记录roomid
		Log.i(TAG, "OnRoomIn mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId);
		if(success && roomInfo != null){
			mRoomId = roomInfo.roomId;
			mLiveInAnchorId = roomInfo.userId;
			mMapRoomItems.put(mRoomId, roomInfo);
			Log.i(TAG, "OnRoomIn success mInvitationId: " + mInvitationId
					+ " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId);
			if(null != LoginManager.getInstance() && null != LoginManager.getInstance().getLoginItem()){
				LoginManager.getInstance().getLoginItem().level = roomInfo.manLevel;
			}
			//更新返点信息
			LiveRoomCreditRebateManager.getInstance().setImRebateItem(roomInfo.rebateItem);
		}

		mListenerManager.OnRoomIn(reqId, success, errType, errMsg, roomInfo, authorityItem);
	}

	@Override
	public void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG,"OnRoomOut-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		//退出房间成功，清除房间id
//		if(success){
//			mRoomId = "";
//		}

		mListenerManager.OnRoomOut(reqId, success, errType, errMsg);
	}

	@Override
	public void OnPublicRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo, IMAuthorityItem authorityItem) {
		Log.i(TAG, "OnPublicRoomIn mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId);
		if(success && roomInfo != null){
			mRoomId = roomInfo.roomId;
			mLiveInAnchorId = roomInfo.userId;
			mMapRoomItems.put(mRoomId, roomInfo);
			Log.i(TAG, "OnPublicRoomIn success mInvitationId: " + mInvitationId
					+ " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId);
			if(null != LoginManager.getInstance() && null != LoginManager.getInstance().getLoginItem()){
				LoginManager.getInstance().getLoginItem().level = roomInfo.manLevel;
			}
			//更新返点信息
			LiveRoomCreditRebateManager.getInstance().setImRebateItem(roomInfo.rebateItem);
		}
		mListenerManager.OnRoomIn(reqId, success, errType, errMsg, roomInfo, authorityItem);
	}

	@Override
	public void OnControlManPush(int reqId, boolean success, LCC_ERR_TYPE errType,
								 String errMsg, String[] manPushUrl) {
		Log.d(TAG,"OnControlManPush-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		mListenerManager.OnControlManPush(reqId, success, errType, errMsg, manPushUrl);
	}

	@Override
	public void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem, IMAuthorityItem priv) {
		Log.d(TAG,"OnGetInviteInfo-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		mListenerManager.OnGetInviteInfo(reqId, success, errType, errMsg, inviteItem, priv);
	}

	@Override
	public void OnSendRoomMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG,"OnSendRoomMsg-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendRoomMsg(success, errType, errMsg, msgItem);
	}

	@Override
	public void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg,
						   double credit, double rebateCredit) {
		Log.d(TAG,"OnSendGift-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId
				+" success:"+success+" credit:"+credit+ " rebateCredit:"+rebateCredit);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendGift(success, errType, errMsg, msgItem, credit, rebateCredit);
	}

	@Override
	public void OnSendBarrage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg,
							  double credit, double rebateCredit) {
		Log.d(TAG,"OnSendBarrage-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId
				+" success:"+success+" credit:"+credit+ " rebateCredit:"+rebateCredit);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendBarrage(success, errType, errMsg, msgItem, credit, rebateCredit);
	}

	@Override
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId, IMInviteErrItem errItem) {
		Log.i(TAG, "OnSendImmediatePrivateInvite mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId
				+ " invitationId: " + invitationId + " success: " + success + " chatOnlineStatus:" + errItem.status.name());
		//记录最后一次邀请id
		if(success) {
			mInvitationId = invitationId;
		}else{
			mLiveInAnchorId = "";
		}

		mListenerManager.OnSendImmediatePrivateInvite(reqId, success, errType,
				errMsg, invitationId, timeout, roomId, errItem);
	}

	@Override
	public void OnCancelImmediatePrivateInvite(int reqId, boolean success,
											   LCC_ERR_TYPE errType, String errMsg, String roomId) {
		//取消成功，清除邀请
//		if(success){
//			mInvitationId = "";
//		}

		mListenerManager.OnCancelImmediatePrivateInvite(reqId, success, errType, errMsg, roomId);
	}
	@Override
	public void OnInstantInviteUserReport(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {

	}

	@Override
	public void OnSendTalent(int reqId, boolean success, LCC_ERR_TYPE errType,
							 String errMsg, String talentInviteId, String talentId) {
		mListenerManager.OnSendTalent(reqId , success , errType ,errMsg, talentInviteId, talentId);
	}

	@Override
	public void OnEnterHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem item) {

	}

	@Override
	public void OnLeaveHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {

	}

	@Override
	public void OnSendHangoutGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double credit) {

	}

	@Override
	public void OnControlManPushHangout(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {

	}

	@Override
	public void OnSendHangoutRoomMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {

	}

	@Override
	public void OnKickOff(LCC_ERR_TYPE errType, String errMsg) {
		//处理被踢逻辑
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMKickOff.ordinal();
		msg.obj = errMsg;
		mHandler.sendMessage(msg);

		mListenerManager.OnKickOff(errType, errMsg);
	}

	/**
	 *
	 * @param roomId
	 * @param errType
	 * @param errMsg
	 * @param privItem  2018-12-4 add by Alex
	 */
	@Override
	public void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg, IMAuthorityItem privItem) {
		Log.i(TAG, "OnRecvRoomCloseNotice mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId
				+ " roomId: " + roomId + " errType: " + errType.name());
		if(roomId.equals(mRoomId)) {
			mRoomId = "";
			mLiveInAnchorId = "";
		}
		mListenerManager.OnRecvRoomCloseNotice(roomId, errType, errMsg, privItem);
	}

	@Override
	public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
									  String riderId, String riderName, String riderUrl, int fansNum,
									  String honorImg, boolean isHasTicket) {
		//座驾为空的情况下
		mListenerManager.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId,
				riderName, riderUrl, fansNum, honorImg, isHasTicket);
	}

	@Override
	public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {
		mListenerManager.OnRecvLeaveRoomNotice(roomId, userId, nickName, photoUrl, fansNum);
	}

	@Override
	public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {
		LiveRoomCreditRebateManager.getInstance().setImRebateItem(item);
		mListenerManager.OnRecvRebateInfoNotice(roomId, item);
	}

	/**
	 *
	 * @param roomId
	 * @param leftSeconds
	 * @param err
	 * @param errMsg
	 * @param privItem  2018-12-4 add by Alex
	 */
	@Override
	public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg, IMAuthorityItem privItem) {
		Log.i(TAG, "OnRecvLeavingPublicRoomNotice mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId
				+ " roomId: " + roomId + " err: " + err.name());
		//直播间关闭倒计时通知
		if(roomId.equals(mRoomId)){
			mRoomId = "";
			mLiveInAnchorId = "";
		}
		mListenerManager.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg, privItem);
	}

	/**
	 *
	 * @param roomId
	 * @param err
	 * @param errMsg
	 * @param credit
	 * @param privItem  2018-12-4 add by Alex
	 */
	@Override
	public void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg, double credit, IMAuthorityItem privItem) {
		Log.i(TAG, "OnRecvRoomKickoffNotice mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId
				+ " roomId: " + roomId + " err: " +  err.name());
		//接收提出直播间通知
		if(roomId.equals(mRoomId)){
			mRoomId = "";
			mLiveInAnchorId = "";
		}

		mListenerManager.OnRecvRoomKickoffNotice(roomId, err, errMsg, credit, privItem);
	}

	@Override
	public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {
		mListenerManager.OnRecvLackOfCreditNotice(roomId, message, credit);
	}

	@Override
	public void OnRecvCreditNotice(String roomId, double credit) {
		mListenerManager.OnRecvCreditNotice(roomId, credit);
	}

	@Override
	public void OnRecvLiveStart(String roomId, String anchorId, String nickName, String avatarImg, int leftSeconds, String[] playUrls) {
		mListenerManager.OnRecvLiveStart(roomId, leftSeconds, playUrls);
	}

	@Override
	public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String[] playUrls) {
		mListenerManager.OnRecvChangeVideoUrl(roomId, isAnchor, playUrls);
	}

	@Override
	public void OnRecvRoomMsg(String roomId, int level, String fromId, String nickName, String msg, String honorUrl) {
		//收到普通文本消息
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId,
				nickName, honorUrl, level, IMMessageItem.MessageType.Normal,
				new IMTextMessageContent(msg), null);
		mListenerManager.OnRecvRoomMsg(msgItem);
		Log.i(TAG, "OnRecvRoomMsg msgId:%d, roomId:%s, userId:%s", msgItem.msgId,
				msgItem.roomId, msgItem.userId);
	}

	@Override
	public void OnRecvSendSystemNotice(String roomId, String message, String link, IMSystemType type){
		Log.d(TAG,"OnRecvSendSystemNotice-roomId:"+roomId+" message:"+message+" link:"+link+" type:"+type);
		IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message,link,
				type == IMSystemType.warn ? IMSysNoticeMessageContent.SysNoticeType.Warning :
						IMSysNoticeMessageContent.SysNoticeType.Normal);
		IMMessageItem msgItem = new IMMessageItem(roomId,mMsgIdIndex.getAndIncrement(),"",
				IMMessageItem.MessageType.SysNotice,msgContent);
		mListenerManager.OnRecvSendSystemNotice(msgItem);
	}

	@Override
	public void OnRecvRoomGiftNotice(String roomId, String fromId, String nickName, String giftId,
									 String giftName, int giftNum, boolean multi_click,
									 int multi_click_start, int multi_click_end, int multiClickId, String honorUrl) {
		IMGiftMessageContent msgContent = new IMGiftMessageContent(giftId, giftName, giftNum,
				multi_click, multi_click_start, multi_click_end, multiClickId);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(),
				fromId, nickName, honorUrl, -1, IMMessageItem.MessageType.Gift, null, msgContent);
		mListenerManager.OnRecvRoomGiftNotice(msgItem);
		Log.i(TAG, "OnRecvRoomGiftNotice msgId:%d, roomId:%s, userId:%s", msgItem.msgId,
				msgItem.roomId, msgItem.userId);
	}

	@Override
	public void OnRecvRoomToastNotice(String roomId, String fromId, String nickName, String msg, String honorUrl) {
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId, nickName, honorUrl,
				-1, IMMessageItem.MessageType.Barrage, new IMTextMessageContent(msg), null);
		mListenerManager.OnRecvRoomToastNotice(msgItem);
		Log.i(TAG, "OnRecvRoomGiftNotice msgId:%d, roomId:%s, userId:%s", msgItem.msgId, msgItem.roomId, msgItem.userId);
	}

	@Override
	public void OnRecvInviteReply(IMInviteReplyItem replyItem) {
		Log.i(TAG, "OnRecvInviteReply mInvitationId: " + mInvitationId + " mRoomId: " + mRoomId + " mLiveInAnchorId: " + mLiveInAnchorId
				+ " inviteId: " +  replyItem.inviteId + " replyType: " + replyItem.replyType.name());
		//收到主播邀请回复
		if(replyItem.inviteId.equals(mInvitationId)) {
			mInvitationId = "";
			mLiveInAnchorId = "";
		}

		mListenerManager.OnRecvInviteReply(replyItem);
	}

	@Override
	public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
		Log.i(TAG, "OnRecvAnchoeInviteNotify anchorId : %s, anchorName: %s, message : %s", anchorId, anchorName, message);
		boolean isAnchorInviteShow = false;
		//生成发送push
		if(checkAnchorInviteNotify(anchorId)){
			isAnchorInviteShow = true;
			String url = URL2ActivityManager.createAnchorInviteUrl(anchorId, anchorName, anchorPhotoUrl, logId);
			PushManager pushManager = PushManager.getInstance();
			if(pushManager != null) {
				pushManager.ShowNotification(NotificationTypeEnum.ANCHORINVITE_NOTIFICATION,
						mContext.getResources().getString(R.string.app_name),
						String.format(mContext.getResources().getString(R.string.notification_anchor_inite_tips), anchorName),
						url, true);
			}
		}

		//通知服务器主播邀请显示与否
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMAnchorInviteShow.ordinal();
		msg.arg1 = isAnchorInviteShow ? 1: 0;
		msg.obj = logId;
		mHandler.sendMessage(msg);

		mListenerManager.OnRecvAnchoeInviteNotify(logId, anchorId, anchorName, anchorPhotoUrl, message);
	}

	@Override
	public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
        //刷新邀请未读数目
        SendRefreshShowNoRead();
		mListenerManager.OnRecvScheduledInviteNotify(inviteId, anchorId, anchorName, anchorPhotoUrl, message);
	}

	@Override
	public void OnRecvSendBookingReplyNotice(IMBookingReplyItem imBookingReplyItem) {
		//刷新邀请未读数目
		SendRefreshShowNoRead();
		mListenerManager.OnRecvSendBookingReplyNotice(imBookingReplyItem.inviteId, imBookingReplyItem.replyType);
	}

	@Override
	public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

		//发送push
//		String url = URL2ActivityManager.createBookExpiredUrl(userId, nickName, photoUrl, roomId);
//		PushManager.getInstance().ShowNotification(NotificationTypeEnum.SCHEDULEINVITE_NOFICATION,
//				mContext.getResources().getString(R.string.app_name),
//				String.format(mContext.getResources().getString(R.string.notification_scheduled_invite_expired_tip), nickName),
//				url, true);

		mListenerManager.OnRecvBookingNotice(roomId, userId, nickName, photoUrl, leftSeconds);
	}

	@Override
	public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, TalentInviteStatus status, double rebateCredit, String giftId, String giftName, int giftNum) {
		mListenerManager.OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, status, rebateCredit, giftId, giftName, giftNum);
	}

	@Override
	public void OnRecvTalentPromptNotice(String roomId, String introduction) {
		mListenerManager.OnRecvTalentPromptNotice(roomId, introduction);
	}

	@Override
	public void OnRecvLevelUpNotice(int level) {
        //更新用户信息中等级
        LoginManager.getInstance().getLoginItem().level = level;

		mListenerManager.OnRecvLevelUpNotice(level);
	}

	@Override
	public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {
		mListenerManager.OnRecvLoveLevelUpNotice(lovelevelItem);
	}

	@Override
	public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {
		SendRefreshShowNoRead();
		mListenerManager.OnRecvBackpackUpdateNotice(item);
	}

	@Override
	public void OnRecvGetHonorNotice(String honorId, String honorUrl) {
		mListenerManager.OnRecvHonorNotice(honorId, honorUrl);
	}

	// ---------------   多人互动   --------------
	@Override
	public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {

	}

	@Override
	public void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item) {

	}

	@Override
	public void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item) {

	}

	@Override
	public void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item) {

	}

	@Override
	public void OnRecvHangoutGiftNotice(IMRecvHangoutGiftItem item) {

	}

	@Override
	public void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item) {

	}

	@Override
	public void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item) {

	}

	@Override
	public void OnRecvHangoutRoomMsg(IMHangoutMsgItem item) {

	}

	@Override
	public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item) {

	}

	// ---------------  end 多人互动   --------------

	@Override
	public void OnRecvProgramPlayNotice(IMProgramInfoItem showinfo, IMProgramPlayType type, String msg) {
		SendRefreshShowNoRead();

		if(showinfo != null && type == IMProgramPlayType.BuyTicketPlay){
//			//买票状态时构成push系统通知
//			//发送push
//			String url = URL2ActivityManager.createProgramShowUrl(showinfo.anchorId, showinfo.anchorNickname, showinfo.anchorAvatar, showinfo.showLiveId);
//			PushManager.getInstance().ShowNotification(NotificationTypeEnum.PROGRAMSTART_NOTIFICATION,
//					mContext.getResources().getString(R.string.app_name),
//					msg,
//					url, true);
		}

		//分发事件
		mListenerManager.OnRecvProgramPlayNotice(showinfo, type, msg);
	}

	@Override
	public void OnRecvCancelProgramNotice(IMProgramInfoItem showinfo) {
		SendRefreshShowNoRead();
		mListenerManager.OnRecvCancelProgramNotice(showinfo);
	}

	@Override
	public  void OnRecvRetTicketNotice(IMProgramInfoItem showinfo, double leftCredit) {
		SendRefreshShowNoRead();
		mListenerManager.OnRecvRetTicketNotice(showinfo, leftCredit);
	}

	@Override
	public void OnRecvLoiNotice(String anchorId, String loiId) {
		//接受意向信通知
		SendRefreshShowNoRead();
	}

	@Override
	public void OnRecvEMFNotice(String anchorId, String emfId) {
		SendRefreshShowNoRead();
	}

	/************************************** 统一事件通知  ****************************************/
	/**
	 * 刷新未读节目数目（出现状态更新）
	 */
	private void SendRefreshShowNoRead(){
		//刷新未读接口控制红点未读显示逻辑
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMShowNoReadEvent.ordinal();
		mHandler.sendMessage(msg);
	}

	//--------------------断线重登陆---------------------------------------------------------
	/**
	 * 注册邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMLoginStatusListener(IMLoginStatusListener listener){
		return mListenerManager.registerIMLoginStatusListener(listener);
	}

	/**
	 * 注销邀请启动监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMLoginStatusListener(IMLoginStatusListener listener){
		return mListenerManager.unregisterIMLoginStatusListener(listener);
	}

	private void reLoginSuc(){
		Log.d(TAG,"reLoginSuc");
		if(imReconnecting) {
			hasIMReconnected = true;
			imReconnecting = false;
			Log.d(TAG, "Login-断线重连成功");
			mListenerManager.onIMAutoReLogined();
		}
	}

	/*************************************** 更新用户信息 *********************************/
	/**
	 * 更新当前用户信息
	 */
	private void GetUserInfo(){
		String userId = "";
		if(mLoginItem != null && !TextUtils.isEmpty(mLoginItem.userId)){
			userId = mLoginItem.userId;
		}
		LiveRequestOperator.getInstance().GetUserInfo(userId, new OnGetUserInfoCallback() {
			@Override
			public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, UserInfoItem userItem) {
				if(isSuccess && (userItem != null)){
					LoginManager loginManager = LoginManager.getInstance();
					if(loginManager != null){
						LoginItem item = loginManager.getLoginItem();
						if(item != null){
							//更新用户等级信息
							item.level = userItem.userLevel;
						}
					}
				}
			}
		});
	}

	/**
	 * 检测主播邀请是否通知（在直播模块，且不再直播过程中才推送）
	 * @param anchorId
	 * @return
	 */
	private boolean checkAnchorInviteNotify(String anchorId){
		boolean notify = true;
		String liveAnchorId = getCurrentLivingAnchorId();
		if(isCurrentInLive()){
			//直播中非当前主播立即私密邀请不push
			if(anchorId.equals(liveAnchorId)){
				notify = true;
			}else{
				notify = false;
			}
		}else{
			notify = true;
		}
		return notify;
	}
}
