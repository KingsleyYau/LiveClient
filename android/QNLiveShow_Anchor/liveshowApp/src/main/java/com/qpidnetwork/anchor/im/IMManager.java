package com.qpidnetwork.anchor.im;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMGiftMessageContent;
import com.qpidnetwork.anchor.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMLoginItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMProgramInfoItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMScheduleRoomItem;
import com.qpidnetwork.anchor.im.listener.IMSendInviteInfoItem;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.im.listener.IMTextMessageContent;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.anchor.liveshow.manager.ProgramUnreadManager;
import com.qpidnetwork.anchor.liveshow.manager.ScheduleInviteManager;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.liveshow.pushmanager.PushManager;
import com.qpidnetwork.anchor.liveshow.pushmanager.PushMessageType;
import com.qpidnetwork.anchor.utils.Log;

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
	private final int mAutoReloginTime = 10 * 1000;	//自动登录间隔时长10秒

	/*基础管理类*/
	private IMUserBaseInfoManager mIMUserBaseInfoManager;

	/**
	 * 消息ID生成器
	 */
	public AtomicInteger mMsgIdIndex = null;
	public static final int MsgIdIndexBegin = 1;
	private HashMap<Integer, IMMessageItem> mSendingMsgMap;  //记录发送中消息Map
	
	private IMEventListenerManager mListenerManager; //通知事件分发器

	/**
	 *  记录当前服务状态
	 */
	private String mRoomId = "";
	private IMRoomInItem.IMPublicRoomType mIMPublicRoomType = IMRoomInItem.IMPublicRoomType.Unknown;

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
        ScheduleInviteUpdate,   //更新预约邀请相关信息
		ProgramUnreadUpdate     //刷新节目未读数目信息
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
					}else if(errType == LCC_ERR_TYPE.LCC_ERR_TOKEN_EXPIRE){
						String errMsg = (String)msg.obj;
						LoginManager.getInstance().onKickedOff(errMsg);
					}else{
						//						mLoginItem = null;
					}
				}break;
				
				case IMLogoutEvent:{
					LCC_ERR_TYPE errType = LCC_ERR_TYPE.values()[msg.arg1];
					mIsLogin = false;
					if(IsAutoRelogin(errType)){
						//断线，需要重连
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
					if(TextUtils.isEmpty(errMsg)){
						errMsg = mContext.getResources().getString(R.string.im_kick_off_tips);
					}
					LoginManager.getInstance().onKickedOff(errMsg);
				}break;

				case ScheduleInviteUpdate:{
					ScheduleInviteManager manager = ScheduleInviteManager.getInstance();
					//更新预约邀请未读数目
					manager.GetCountOfUnreadAndPendingInvite();
					//更新已确认预约邀请数目
					manager.GetAllScheduledInviteCount();
				}break;

				case ProgramUnreadUpdate:{
					ProgramUnreadManager.getInstance().GetNoReadNumProgram();
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
	 * 注册HangOut直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMHangOutRoomEventListener(IMHangOutRoomEventListener listener){
		return mListenerManager.registerIMHangOutRoomEventListener(listener);
	}

	/**
	 * 注销HangOut直播间事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMHangOutRoomEventListener(IMHangOutRoomEventListener listener){
		return mListenerManager.unregisterIMHangOutRoomEventListener(listener);
	}

	/**
	 * 注册HangOut直播间邀请事件监听器
	 * @param listener
	 * @return
	 */
	public boolean registerIMHangOutInviteEventListener(IMHangOutInviteEventListener listener){
		return mListenerManager.registerIMHangOutInviteEventListener(listener);
	}

	/**
	 * 注销HangOut直播间邀请事件监听器
	 * @param listener
	 * @return
	 */
	public boolean unregisterIMHangOutInviteEventListener(IMHangOutInviteEventListener listener){
		return mListenerManager.unregisterIMHangOutInviteEventListener(listener);
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
			result = IMClient.init(mUrlList.toArray(urlArray), this);
		}
		return result;
	}

	/**
	 * 记录IM是否登录
	 * @return
	 */
	public boolean isIMLogined(){
		return mIsLogin;
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
	 * 更新用户信息对象
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
	 * 是否直播中
	 * 		直播中状态定义：起始（发出邀请、应邀、进入直播间），终止（邀请失败、应邀失败、直播间结束等）
	 * @return
	 */
	public boolean isCurrentInLive(){
		boolean isCurrentLive = false;
		Log.d(TAG, "isCurrentInLive-mRoomId: " + mRoomId);
		if(!TextUtils.isEmpty(mRoomId)){
			isCurrentLive = true;
		}
		Log.d(TAG, "isCurrentInLive-isCurrentLive: " + isCurrentLive);
		return isCurrentLive;
	}

	/**
	 * 是否在节目直播中
	 * @return
	 */
	public boolean isInProgramLiveRoom(){
		boolean isInProgram = false;
		if(!TextUtils.isEmpty(mRoomId) && mIMPublicRoomType == IMRoomInItem.IMPublicRoomType.Program){
			isInProgram = true;
		}
		return isInProgram;
	}

	/**
	 * 切换服务时，终止直播服务
	 */
	public void stopLiveServiceLocal(){
		Log.i(TAG, "stopLiveServiceLocal mRoomId: " + mRoomId);
		roomOutAndClearFlag(mRoomId);
		outHangOutRoomAndClearFlag(mRoomId);
	}

	/***************************** IM Client 功能接口   ********************************************/
	/**
	 * 成功返回有效的ReqId,否则不成功，无回调
	 * @param roomId
	 * @return
	 */
	public int RoomIn(String roomId){
		int reqId = IM_INVALID_REQID;
		Log.i(TAG, "RoomIn mRoomId: " + mRoomId);

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
			//解决断线重连时，由于登录状态异常，导致回调失败，未清除房间ID异常
			mRoomId = "";

			//未登录或本地调用错误
			mListenerManager.OnRoomIn(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), null);
		}
		return reqId;
	}

	/**
	 * 过渡页调用退出直播间时，清除直播间中状态
	 * @param roomId
	 * @return
	 */
	public int roomOutAndClearFlag(String roomId){
		if(!TextUtils.isEmpty(mRoomId) && mRoomId.equals(roomId)){
			mRoomId = "";
		}
		return RoomOut(roomId);
	}


	public int outHangOutRoomAndClearFlag(String roomId){
		if(!TextUtils.isEmpty(mRoomId) && mRoomId.equals(roomId)){
			mRoomId = "";
		}
		return exitHangOutRoom(roomId);
	}
	
	/**
	 * 观众离开直播室
	 * @param roomId
	 * @return
	 */
	public int RoomOut(String roomId){
		int reqId = IM_INVALID_REQID;

		//退出直播间清除本地缓存信息
		clearUserInfoList();

		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.RoomOut(reqId, roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnRoomOut(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips));
		}
		return reqId;
	}

	/**
	 * 进入公开直播间
	 * @return
	 */
	public int PublicRoomIn(){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.PublicRoomIn(reqId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnRoomIn(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), null);
		}
		return reqId;
	}

	/**
	 * 3.11 主播切换推流接口
	 * @return
	 */
	public int AnchorSwitchFlow(String roomId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.AnchorSwitchFlow(reqId, roomId, IMDeviceType.App)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnAnchorSwitchFlow(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), new String[]{}, IMDeviceType.App);
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
			mListenerManager.OnGetInviteInfo(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), null);
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
				mLoginItem.userId, mLoginItem.nickName, "", 0,
				IMMessageItem.MessageType.Normal, new IMTextMessageContent(msg), null);
		boolean result = !mIsLogin || !IMClient.SendRoomMsg(reqId, roomId, mLoginItem.nickName, msg, targetIds);
		Log.d(TAG,"sendRoomMsg-mIsLogin:"+mIsLogin+" result:"+result);
		if(result){
			mListenerManager.OnSendRoomMsg(false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), msgItem);
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
				mLoginItem.userId, mLoginItem.nickName, "", 0,
				IMMessageItem.MessageType.Gift, null, msgContent);

		if(!mIsLogin || !IMClient.SendGift(reqId, roomId, mLoginItem.nickName, giftItem.id,
				giftItem.name, isPackage, count, isMultiClick, multiStart, multiEnd, multiClickId)){
			mListenerManager.OnSendGift(false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), msgItem);
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
	 * @return
	 */
	public int sendImmediatePrivateInvite(String userId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.SendImmediatePrivateInvite(reqId, userId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID) {
			//未登录或本地调用错误
			mListenerManager.OnSendImmediatePrivateInvite(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), null);
		}
		return reqId;
	}

	/**
	 * 取消邀请
	 * @param invitationId
	 * @param callback
	 */
	public void cancelImmediatePrivateInvite(String invitationId, final OnRequestCallback callback){
		LiveRequestOperator.getInstance().CancelInstantInvite(invitationId, new OnRequestCallback() {
			@Override
			public void onRequest(final boolean isSuccess, final int errCode, String errMsg) {
				callback.onRequest(isSuccess, errCode, errMsg);
			}
		});
	}

	/**************************** Authorization Listener  **************************************/
	@Override
	public void onLogin(boolean isSuccess, int errCode, String errMsg,
			LoginItem item) {
		Log.d(TAG,"HttpLogin onLoginResult-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" item:"+item);
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.HttpLoginEvent.ordinal();
		msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, item);
		mHandler.sendMessage(msg);
	}

	@Override
	public void onLogout(boolean isMannual) {
		//手动注销清除本地缓存
		Log.i(TAG, "onLogout mRoomId: " + mRoomId + " isMannual: " + isMannual);
		if(isMannual){
			//清除房间id及邀请id
			mRoomId = "";
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
		Log.d(TAG,"IMLogin onLoginResult-errMsg:"+errMsg+" errType:"+errType);
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMLoginEvent.ordinal();
		msg.arg1 = errType.ordinal();
		msg.obj = errMsg;
		mHandler.sendMessage(msg);
		//登录成功或断线重连刷新节目未读数目
		refreshProgramUnreadEvent();
		//事件分发通知
		mListenerManager.OnLogin(errType, errMsg);

		//登录成功，有上次未结束任务需要重启
		if(loginItem != null && LiveService.getInstance().mIsFirstLaunch){
			//重新启动进入直播看，走预约到期点击进入逻辑
//			if(loginItem.roomList != null && loginItem.roomList.length > 0){
//				String url = URL2ActivityManager.createBookExpiredUrl(loginItem.roomList[0].anchorId, loginItem.roomList[0].nickName, loginItem.roomList[0].roomId);
//				Intent intent = new Intent();
//				intent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, url);
//				intent.setAction(CommonConstant.ACTION_PUSH_NOTIFICATION);
//				mContext.sendBroadcast(intent);
//			}

			//检测是否有预约到期通知，有则发push通知
			if(loginItem.scheduleRoomList != null && loginItem.scheduleRoomList.length > 0){
				for(IMScheduleRoomItem item : loginItem.scheduleRoomList){
					//发送push
					String url = URL2ActivityManager.createBookExpiredUrl(item.anchorId, item.nickName, item.anchorPhotoUrl, item.roomId);
					PushManager.getInstance().ShowNotification(PushMessageType.Schedule_Invite_Expired,
							mContext.getResources().getString(R.string.app_name),
							String.format(mContext.getResources().getString(R.string.notification_scheduled_invite_expired_tip), item.nickName),
							url, true);
				}
			}
		}
		//是否第一次启动登录成功
		LiveService.getInstance().mIsFirstLaunch = false;
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
	public void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
						 String errMsg, IMRoomInItem roomInfo) {
		Log.d(TAG,"OnRoomIn-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId
				+" success:"+success+" roomInfo:"+roomInfo);
		//进入房间成功，记录roomid
		Log.i(TAG, "OnRoomIn  mRoomId: " + mRoomId);
		if(success && roomInfo != null){
			mRoomId = roomInfo.roomId;
			mIMPublicRoomType = roomInfo.liveShowType;
			Log.i(TAG, "OnRoomIn success mRoomId: " + mRoomId );

		}else if(!success){
			//进入直播间失败，清除roomID,解决断线重连退出直播间，服务状态错误问题
			mRoomId = "";
		}

		mListenerManager.OnRoomIn(reqId, success, errType, errMsg, roomInfo);
	}

	@Override
	public void OnAnchorSwitchFlow(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] pushUrl, IMDeviceType deviceType) {
		Log.d(TAG,"OnAnchorSwitchFlow-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);

		mListenerManager.OnAnchorSwitchFlow(reqId, success, errType, errMsg, pushUrl, deviceType);
	}

	@Override
	public void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG,"OnRoomOut-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		//退出房间成功，清除房间id

		mListenerManager.OnRoomOut(reqId, success, errType, errMsg);
	}

	@Override
	public void OnPublicRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType,
							   String errMsg, IMRoomInItem roomInfo) {
		Log.i(TAG, "OnPublicRoomIn mRoomId: " + mRoomId);
		if(success && roomInfo != null){
			mRoomId = roomInfo.roomId;
			mIMPublicRoomType = roomInfo.liveShowType;
		}else if(!success){
			mRoomId = "";
		}
		mListenerManager.OnRoomIn(reqId, success, errType, errMsg, roomInfo);
	}

	@Override
	public void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType,
								String errMsg, IMInviteListItem inviteItem) {
		Log.d(TAG,"OnGetInviteInfo-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		mListenerManager.OnGetInviteInfo(reqId, success, errType, errMsg, inviteItem);
	}

	@Override
	public void OnSendRoomMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG,"OnSendRoomMsg-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId+" success:"+success);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendRoomMsg(success, errType, errMsg, msgItem);
	}

	@Override
	public void OnSendHangoutMsg(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG,"OnSendHangoutMsg-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendHangoutMsg(reqId, success, errType, errMsg);
	}


	@Override
	public void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG,"OnSendGift-errType:"+errType+" errMsg:"+errMsg+" reqId:"+reqId
				+" success:"+success);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendGift(success, errType, errMsg, msgItem);
	}

	@Override
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMSendInviteInfoItem inviteInfoItem) {
		Log.i(TAG, "OnSendImmediatePrivateInvite mRoomId: " + mRoomId
				+ " invitationId: " + inviteInfoItem.inviteId + " success: " + success);
		mListenerManager.OnSendImmediatePrivateInvite(reqId, success, errType,
				errMsg, inviteInfoItem);
	}

//	@Override
//	public void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType,
//											 String errMsg, String invitationId, int timeout, String roomId) {
//		Log.i(TAG, "OnSendImmediatePrivateInvite mRoomId: " + mRoomId
//								+ " invitationId: " + invitationId + " success: " + success);
//		mListenerManager.OnSendImmediatePrivateInvite(reqId, success, errType,
//				errMsg, invitationId, timeout, roomId);
//	}

	@Override
	public void OnKickOff(LCC_ERR_TYPE errType, String errMsg) {
		//处理被踢逻辑
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.IMKickOff.ordinal();
		msg.obj = errMsg;
		mHandler.sendMessage(msg);

		mListenerManager.OnKickOff(errType, errMsg);
	}

	@Override
	public void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg) {
		Log.i(TAG, "OnRecvRoomCloseNotice mRoomId: " + mRoomId
									+ " roomId: " + roomId + " errType: " + errType.name());
		if(roomId.equals(mRoomId)) {
			mRoomId = "";
		}
		mListenerManager.OnRecvRoomCloseNotice(roomId, errType, errMsg);
	}

	@Override
	public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
									  String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket) {
		Log.i(TAG, "OnRecvEnterRoomNotice mRoomId: " + mRoomId
				+ " roomId: " + roomId + " nickName: " + nickName + " userId: " + userId);
		//座驾为空的情况下
		mListenerManager.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId,
				riderName, riderUrl, fansNum,isHasTicket);
	}

	@Override
	public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {
		mListenerManager.OnRecvLeaveRoomNotice(roomId, userId, nickName, photoUrl, fansNum);
	}

	@Override
	public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg) {
		Log.i(TAG, "OnRecvLeavingPublicRoomNotice mRoomId: " + mRoomId
								+ " roomId: " + roomId + " err: " + err.name());
		mListenerManager.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg);
	}

	/**
	 * 3.9.接收观众退出直播间通知
	 * @param roomId				 直播间ID
	 * @param anchorId				 退出直播间的主播ID
	 */
	@Override
	public  void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {
        Log.d(TAG,"OnRecvAnchorLeaveRoomNotice-roomId:"+roomId+" anchorId:"+anchorId);
        mListenerManager.OnRecvAnchorLeaveRoomNotice(roomId,anchorId);
	}
	@Override
	public void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg) {
		Log.i(TAG, "OnRecvRoomKickoffNotice mRoomId: " + mRoomId
									+ " roomId: " + roomId + " err: " +  err.name());
		//接收提出直播间通知
		if(roomId.equals(mRoomId)){
			mRoomId = "";
		}

		mListenerManager.OnRecvRoomKickoffNotice(roomId, err, errMsg);
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
		Log.d(TAG,"OnRecvSendSystemNotice-roomId:"+roomId+" nickname:"+message+" link:"+link+" type:"+type);
		IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message,link,
				type == IMSystemType.warn ? IMSysNoticeMessageContent.SysNoticeType.Warning :
						IMSysNoticeMessageContent.SysNoticeType.Normal);
		IMMessageItem msgItem = new IMMessageItem(roomId,mMsgIdIndex.getAndIncrement(),"",
				IMMessageItem.MessageType.SysNotice,msgContent);
		mListenerManager.OnRecvSendSystemNotice(msgItem);
	}

	@Override
	public void OnRecvRoomGiftNotice(String roomId, String fromId, String nickName, String giftId, String giftName, int giftNum, boolean multi_click, int multi_click_start, int multi_click_end, int multiClickId, String honorUrl, int totalCredit) {
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
	public void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName) {
		mListenerManager.OnRecvTalentRequestNotice(talentInvitationId, name, userId, nickName);
	}

	@Override
	public void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMVideoInteractiveOperateType operateType, String[] pushUrls) {
		mListenerManager.OnRecvInteractiveVideoNotice(roomId, userId, nickname, avatarImg, operateType, pushUrls);
	}

	@Override
	public void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String userId,
								  String nickName, String avatarImg) {
		Log.i(TAG, "OnRecvInviteReply mRoomId: " + mRoomId
									+ " inviteId: " +  inviteId + " replyType: " + replyType.name());
		mListenerManager.OnRecvInviteReply(inviteId, replyType, roomId, roomType, userId, nickName, avatarImg);
	}

	@Override
	public void OnRecvAnchoeInviteNotify(String userId, String nickname, String photoUrl, String invitationId) {
		Log.i(TAG, "OnRecvAnchoeInviteNotify userId : %s, nickname: %s, invitationId : %s", userId, nickname, invitationId);
		boolean isAnchorInviteShow = false;
		//生成发送push

		String url = URL2ActivityManager.createManInviteUrl(userId, nickname, photoUrl, invitationId);
		PushManager.getInstance().ShowNotification(PushMessageType.Anchor_Invite_Notify,
											mContext.getResources().getString(R.string.app_name),
											String.format(mContext.getResources().getString(R.string.notification_anchor_inite_tips), nickname),
											url, true);

		mListenerManager.OnRecvAnchoeInviteNotify(userId, nickname, photoUrl, invitationId);
	}

	@Override
	public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

		//发送push
		String url = URL2ActivityManager.createBookExpiredUrl(userId, nickName, photoUrl, roomId);
		PushManager.getInstance().ShowNotification(PushMessageType.Schedule_Invite_Expired,
				mContext.getResources().getString(R.string.app_name),
				String.format(mContext.getResources().getString(R.string.notification_scheduled_invite_expired_tip), nickName),
				url, true);

		mListenerManager.OnRecvBookingNotice(roomId, userId, nickName, photoUrl, leftSeconds);
	}

	@Override
	public void OnRecvInvitationAcceptNotice(String userId, String nickName, String photoUrl, String invitationId, int bookTime) {
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.ScheduleInviteUpdate.ordinal();
		mHandler.sendMessage(msg);
	}


	/**
	 * 进入HangOut直播间
	 * @param roomId
	 * @return
	 */
	public int enterHangOutRoom(String roomId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.EnterHangoutRoom(reqId,roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//未登录或本地调用错误
			mListenerManager.OnEnterHangoutRoom(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips), null,0);
		}
		return reqId;
	}

	/**
	 * 观众离开直播室
	 * @param roomId
	 * @return
	 */
	public int exitHangOutRoom(String roomId){
		int reqId = IM_INVALID_REQID;
		if(mIsLogin){
			reqId = IMClient.GetReqId();
			if(!IMClient.LeaveHangoutRoom(reqId, roomId)){
				reqId = IM_INVALID_REQID;
			}
		}
		if(reqId == IM_INVALID_REQID){
			//解决断线重连时，由于登录状态异常，导致回调失败，未清除房间ID异常
			mRoomId = "";
			//未登录或本地调用错误
			mListenerManager.OnLeaveHangoutRoom(reqId, false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL,
					mContext.getResources().getString(R.string.common_normal_newwork_error_tips));
		}
		return reqId;
	}


	/**
	 * 10.1 进入多人互动直播间
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param hangoutRoomItem		多人互动直播间
	 * @param expire				倒数进入秒数，倒数完成后再调用本接口重新进入
	 */
	@Override
	public  void OnEnterHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType,
									String errMsg, IMHangoutRoomItem hangoutRoomItem, int expire) {
		Log.d(TAG, "OnEnterHangoutRoom-reqId"+reqId+" success:"+success+" errType:"
				+errType+" errMsg:"+errMsg+" hangoutRoomItem:"+hangoutRoomItem+" expire:"+expire);
		if(success && null != hangoutRoomItem){
			mRoomId = hangoutRoomItem.roomId;
		}else if(!success){
			mRoomId = "";
		}
		mListenerManager.OnEnterHangoutRoom(reqId,success,errType,errMsg,hangoutRoomItem,expire);
	}

	/**
	 * 10.2 退出多人互动直播间
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	@Override
	public void OnLeaveHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG, "OnLeaveHangoutRoom-reqId"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
		if(success){
			mRoomId = "";
		}
		mListenerManager.OnLeaveHangoutRoom(reqId,success,errType,errMsg);
	}

	/**
	 * 10.3 接收观众邀请多人互动通知
	 * @param item
	 */
	@Override
	public  void OnRecvInvitationHangoutNotice(IMHangoutInviteItem item) {
//		Log.d(TAG,"OnRecvInvitationHangoutNotice-item:"+item);
//		String url = URL2ActivityManager.createHangOutInviteUrl(item.userId, item.nickName, item.photoUrl, item.inviteId);
//		Log.d(TAG,"OnRecvInvitationHangoutNotice-url:"+url);
//		PushManager.getInstance().ShowNotification(PushMessageType.Man_HangOut_Invite_Notify,
//				mContext.getResources().getString(R.string.app_name),
//				String.format(mContext.getResources().getString(R.string.notification_hangout_inite_tips), item.nickName),
//				url, true);
	}

	/**
	 * 10.4.接收推荐好友通知
	 * @param item		 主播端接收自己推荐好友给观众的信息
	 */
	@Override
	public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {
//		Log.d(TAG, "OnRecvAnchorRecommendHangoutNotice-item"+item);
//		mListenerManager.OnRecvAnchorRecommendHangoutNotice(item);
	}

	/**
	 * 10.5.接收敲门回复通知
	 * @param item		 接收敲门回复信息
	 */
	@Override
	public void OnRecvAnchorDealKnockRequestNotice(IMKnockRequestItem item){
//		Log.d(TAG, "OnRecvAnchorDealKnockRequestNotice-item"+item);
//		mListenerManager.OnRecvAnchorDealKnockRequestNotice(item);
	}

	/**
	 * 10.6.接收观众邀请其它主播加入多人互动通知
	 * @param item		接收观众邀请其它主播加入多人互动信息
	 */
	@Override
	public void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item) {
//		Log.d(TAG, "OnRecvAnchorOtherInviteNotice-item"+item);
//		mListenerManager.OnRecvAnchorOtherInviteNotice(item);
	}

	/**
	 * 10.7.接收主播回复观众多人互动邀请通知
	 * @param item		接收主播回复观众多人互动邀请信息
	 */
	@Override
	public void OnRecvAnchorDealInviteNotice(IMDealInviteItem item) {
//		Log.d(TAG, "OnRecvAnchorDealInviteNotice-item"+item);
//		mListenerManager.OnRecvAnchorDealInviteNotice(item);
	}

	/**
	 * 10.8.观众端/主播端接收观众/主播进入多人互动直播间通知
	 * @param item		接收主播回复观众多人互动邀请信息
	 */
	@Override
	public void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item) {
//		Log.d(TAG, "OnRecvAnchorEnterRoomNotice-item"+item);
//		mListenerManager.OnRecvAnchorEnterRoomNotice(item);
	}

	/**
	 * 10.9.接收观众/主播退出多人互动直播间通知
	 * @param item		接收观众/主播退出多人互动直播间信息
	 */
	@Override
	public void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item) {
//		Log.d(TAG, "OnRecvAnchorLeaveRoomNotice-item"+item);
//		mListenerManager.OnRecvAnchorLeaveRoomNotice(item);
	}

	/**
	 * 10.10.接收观众/主播多人互动直播间视频切换通知
	 * @param roomId		直播间ID
	 * @param isAnchor		是否主播（0：否，1：是）
	 * @param userId		观众/主播ID
	 * @param playUrl		视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
	 */
	@Override
	public void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl) {
//		Log.d(TAG, "OnRecvAnchorChangeVideoUrl-roomId"+roomId+" isAnchor:"+isAnchor+" userId:"+userId);
//		mListenerManager.OnRecvAnchorChangeVideoUrl(roomId,isAnchor,userId,playUrl);
	}

	/**
	 * 发送HangOut直播间礼物(大小礼物)
	 * @param roomId
	 * @param giftItem
	 * @param toUid
	 * @param toUsername
	 * @param count
	 * @param isMultiClick
	 * @param multiStart
	 * @param multiEnd
	 * @param multiClickId
	 * @param isPrivate
	 * @return
	 */
	public IMMessageItem sendHangOutGift(String roomId, GiftItem giftItem, boolean isPackage,
										 String toUid, String toUsername, int count, boolean isMultiClick, int multiStart,
										 int multiEnd, int multiClickId, boolean isPrivate){
		int reqId = IMClient.GetReqId();
		IMGiftMessageContent msgContent = new IMGiftMessageContent(giftItem.id, giftItem.name, count,
				isMultiClick, multiStart, multiEnd, multiClickId,isPrivate);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(),
				mLoginItem.userId, mLoginItem.nickName, null, -1,
				IMMessageItem.MessageType.Gift, new IMTextMessageContent(toUsername), msgContent);

		if(!mIsLogin || !IMClient.SendHangoutGift(reqId, roomId, mLoginItem.nickName, toUid, giftItem.id,
				giftItem.name, isPackage, count, isMultiClick, multiStart, multiEnd, multiClickId,isPrivate)){
			mListenerManager.OnSendHangoutGift(reqId,false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL, mContext.getResources().getString(R.string.common_normal_newwork_error_tips));
			return null;
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}

	/**
	 * 10.11.发送多人互动直播间礼物消息（观众端/主播端发送多人互动直播间礼物消息）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	@Override
	public void OnSendHangoutGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg) {
		Log.d(TAG, "OnSendHangoutGift-reqId"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
		IMMessageItem msgItem = mSendingMsgMap.remove(Integer.valueOf(reqId));
		mListenerManager.OnSendHangoutGift(reqId,success,errType,errMsg);
	}

	/**
	 * 10.12.接收多人互动直播间礼物通知
	 * @param item		接收多人互动直播间礼物信息
	 */
	@Override
	public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {
//		Log.d(TAG, "OnRecvAnchorGiftNotice-item:"+item);
//		mListenerManager.OnRecvAnchorGiftNotice(item);
	}

	/**
	 * 发送HangOut直播间消息
	 * @param roomId
	 * @param msg
	 * @param targetIds
	 * @return
	 */
	public IMMessageItem sendHangOutRoomMsg(String roomId, String msg, String[] targetIds){
		int reqId = IMClient.GetReqId();
		Log.logD(TAG,"sendHangOutRoomMsg-roomId:"+roomId+" msg:"+msg+" reqId0:"+reqId);
		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(),
				mLoginItem.userId, mLoginItem.nickName, "", 0,
				IMMessageItem.MessageType.Normal, new IMTextMessageContent(msg), null);
		boolean result = !mIsLogin || !IMClient.SendHangoutMsg(reqId, roomId, mLoginItem.nickName, msg, targetIds);
		Log.d(TAG,"sendHangOutRoomMsg-mIsLogin:"+mIsLogin+" result:"+result);
		if(result){
			mListenerManager.OnSendHangoutMsg(reqId,false, LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL,
					mContext.getResources().getString(R.string.common_normal_newwork_error_tips));
			return null;
		}else{
			//存储发送中消息
			mSendingMsgMap.put(Integer.valueOf(reqId), msgItem);
		}
		return msgItem;
	}

	@Override
	public void OnRecvHangoutMsg(String roomId, int level, String fromId, String nickName, String msg, String honorUrl, String[] at) {
		Log.d(TAG,"OnRecvHangoutMsg-roomId:"+roomId+" level:"+level+" fromId:"+fromId
				+" nickName:"+nickName+" honorUrl:"+honorUrl);
//		//HangOut直播间接受消息的时候做@昵称文本插入处理
//		if(null != at){
//			StringBuilder sb = new StringBuilder("");
//			for(String id : at){
//				IMUserBaseInfoItem imUserBaseInfoItem = getUserInfo(id);
//				if(null != imUserBaseInfoItem){
//					sb.append("@");
//					sb.append(imUserBaseInfoItem.nickName);
//					sb.append(" ");
//				}
//			}
//			sb.append(msg);
//			msg = sb.toString();
//		}
//		//收到普通文本消息
//		IMMessageItem msgItem = new IMMessageItem(roomId, mMsgIdIndex.getAndIncrement(), fromId,
//				nickName, honorUrl, level, IMMessageItem.MessageType.Normal,
//				new IMTextMessageContent(msg), null);
//		mListenerManager.OnRecvHangoutMsg(msgItem);
	}

	@Override
	public void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond) {
//		mListenerManager.OnRecvAnchorCountDownEnterRoomNotice(roomId,anchorId,leftSecond);
	}

	@Override
	public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId,
													String nickname, String avatarImg,
													IMVideoInteractiveOperateType operateType, String[] pushUrls) {
//		mListenerManager.OnRecvHangoutInteractiveVideoNotice(roomId,userId,nickname,avatarImg,operateType,pushUrls);
	}


	/**
	 * 11.1.接收节目开播通知
	 * @param item      节目信息
	 * @param msg       消息提示文字
	 */
	@Override
	public void OnRecvProgramPlayNotice(IMProgramInfoItem item, String msg) {
		refreshProgramUnreadEvent();
		if(item != null) {
			String url = URL2ActivityManager.createProgramStartUrl(item.showLiveId);
			PushManager.getInstance().ShowNotification(PushMessageType.Program_Start_Notify,
					mContext.getResources().getString(R.string.app_name),
					msg,
					url, true);
		}
	}

	/**
	 * 11.2.接收节目状态改变通知
	 * @param item			节目信息
	 */
	@Override
	public void OnRecvChangeStatusNotice(IMProgramInfoItem item) {
		refreshProgramUnreadEvent();
	}

	/**
	 * 11.3.接收无操作的提示通知
	 * @param backgroundUrl		背景图url
	 * @param msg				描述
	 */
	@Override
	public void OnRecvShowMsgNotice(String backgroundUrl, String msg) {
		if(!TextUtils.isEmpty(msg)) {
			PushManager.getInstance().ShowNotification(PushMessageType.Program_10_Minute_Notify,
					mContext.getResources().getString(R.string.app_name),
					msg,
					"", true);
		}
	}

	/**
	 * 12.1.多端获取预约邀请未读或代处理数量同步推送
	 * @param total					以下参数数量总和
	 * @param pendingNum			待主播处理的数量
	 * @param confirmedUnreadCount	已接受的未读数量
	 * @param otherUnreadCount		历史超时、拒绝的未读数量
	 */
	@Override
	public void OnRecvGetScheduleListNReadNum(int total, int pendingNum, int confirmedUnreadCount, int otherUnreadCount) {
		ScheduleInviteManager.getInstance().onRecvGetScheduleListNReadNumSuccess(total, pendingNum, confirmedUnreadCount, otherUnreadCount);
	}

	/**
	 * 12.2.多端获取已确认的预约数同步推送
	 * @param scheduleNum	已确认的预约数量
	 */
	@Override
	public void OnRecvGetScheduledAcceptNum(int scheduleNum) {
		ScheduleInviteManager.getInstance().onRecvGetScheduledAcceptNumSuccess(scheduleNum);
	}

	/**
	 * 12.3.多端获取节目未读数同步推送
	 * @param num	未读数量
	 */
	@Override
	public void OnRecvNoreadShowNum(int num) {
		ProgramUnreadManager.getInstance().onRecvNoreadShowNumSuccess(num);
	}

	/**
	 * 通知刷新节目未读数目
	 */
	private void refreshProgramUnreadEvent(){
		Message msg = Message.obtain();
		msg.what = IMNotifyOptType.ProgramUnreadUpdate.ordinal();
		mHandler.sendMessage(msg);
	}

}
