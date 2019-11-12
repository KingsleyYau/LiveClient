package com.qpidnetwork.livemodule.livechat.camshare;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSLeftCreditItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerCamShareListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerOtherListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerTryTicketListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadyInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusProtocol;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.KickOfflineType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkEmfNoticeType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TryTicketEventType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.ServiceType;
import com.qpidnetwork.livemodule.livechathttprequest.LivechatRequestOperator;
import com.qpidnetwork.livemodule.livechathttprequest.OnCheckCouponCallCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCUseCouponCallback;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon.CouponStatus;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCOtherGetCountItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.http.RequestBaseResponse;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 统一处理CamShare应邀及发起邀请接通逻辑，回调方式处理与界面进行交互
 * 
 * @author Hunter Mun
 * @since 2016.11.1
 */
public class CamShareStartTask implements LiveChatManagerCamShareListener,
        LiveChatManagerOtherListener, LiveChatManagerTryTicketListener {

	private static final String TAG = CamShareStartTask.class.getName();
	private static final double CAMSHARE_TARIFFS_BASE = 0.6; // CamShare 最低资费标准
	private static final int CAMSHARE_INVITE_VALID_DURATION = 2 * 60 * 1000;// CamShare邀请发出2分钟后无回复，视为过期无效邀请
	private static final int CAMSHARE_BLOCK_SENDFORBID_DURATION = 1 * 60 * 1000;// 黑名单或者禁发邀请时，假装发送，设置1分钟超时

	private Handler mHandler;// 跨线程处理
	private LiveChatManager mLiveChatManager;

	private String mTargetId;
	private String mUserName;
	private String mTargetServerId;
	private CamShareTaskType mCamShareTaskType = CamShareTaskType.NEW_INVITE;// 默认发出邀请
	private OnCamSharePreTaskCallback mCallback;

	private boolean isStart = false;
	private int mInviteId = -1;
	
	//缓存试聊券信息
	private Coupon mCoupon;

	public enum CamShareTaskType {
		ANSWER_INVITE, // 男士应邀
		NEW_INVITE, // 男士发起邀请
		RECONNECT   //重连
	}

	public enum ProcessEvent {
		BLOCK_CHECK_CALLBACK,
		SEND_FORBID_CHECK_CALLBACK,
		SESSION_CHECK_CALLBACK,
		GET_USER_INFO_CALLBACK,
		RISK_CONTROL_CALLBACK, 
		CAM_CHECK_CALLBACK, 
		ONLINE_STATUS_CHECK_CALLBACK,
		COUPON_CHECK_CALLBACK,
		COUPON_BIND_CALLBACK,
		COUPON_USE_CALLBACK,
		MONEY_CHECK_CALLBACK, 
		CAMSHARE_INVITE_CALLBACK, 
		CAMSHARE_INIVTE_ANSWER,
		CAMSHARE_LAUNCH_CALLBACK,  
		CAMSHARE_INVITE_OVERTIME_UPDATE
	}

	public enum ErrorType {
		ERROR_NONE,//默认类型
		ERROR_NORMAL, // 对应用户操作，Retry
		ERROR_IN_LIVECHAT,
		ERROR_RISK_CONTROL, 
		ERROR_CAM_NOT_OPEN, 
		ERROR_OFFLINE, 
		ERROR_NO_MONEY,
		ERROR_INVITE_FAIL,
		ERROR_INVITE_OVERTIME,
		ERROR_INVITE_CANCEL
	}

	/**
	 * CamShareStartTask 处理回调
	 * 
	 * @author Hunter Mun
	 * @since 2016.11.1
	 */
	public interface OnCamSharePreTaskCallback {
		public void onStartCamTaskFailed(String userId, ErrorType errorType);
		public void onStartCamTaskSuccess(String userId, String inviteId, String userServerId);
		public void onStartCamTaskInviteStart(String userId);

	}

	public CamShareStartTask(CamShareTaskType type, String targetId,
                             String userName, int inviteId, OnCamSharePreTaskCallback callback) {
		Log.i(TAG, String.format("CamShareStartTask type: %d, targetId: %s, userName: %s, inviteId: %d", 
				type.ordinal(), targetId, userName, inviteId) );
		mLiveChatManager = LiveChatManager.getInstance();
		mCamShareTaskType = type;
		this.mTargetId = targetId;
		this.mUserName = userName;
		this.mInviteId = inviteId;
		this.mCallback = callback;
		mHandler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				// TODO Auto-generated method stub
				super.handleMessage(msg);
				if (!isStart) {
					// 任务结束，关闭所有回调
					return;
				}
				switch (ProcessEvent.values()[msg.what]) {
				case BLOCK_CHECK_CALLBACK: {
					Log.i(TAG, String.format("BLOCK_CHECK_CALLBACK resultCode: %d", msg.arg1));
					if (msg.arg1 == 1) {
						//在黑名单列表，假装发送，1分钟后出错
						mHandler.sendEmptyMessageDelayed(ProcessEvent.CAMSHARE_INVITE_OVERTIME_UPDATE.ordinal(),
								CAMSHARE_BLOCK_SENDFORBID_DURATION);
					} else {
						//不在黑名单列表,开始流程
						GetUserInfo();
					}
				}break;
				case GET_USER_INFO_CALLBACK: {
					Log.i(TAG, String.format("GET_USER_INFO_CALLBACK resultCode: %d", msg.arg1));
					mLiveChatManager.UnregisterOtherListener(CamShareStartTask.this);
					if (msg.arg1 == 1) {
						//更新用户信息成功
						LiveChatTalkUserListItem item = (LiveChatTalkUserListItem)msg.obj;
						mTargetServerId = item.server;
						RiskControlCheck();
					} else {
						//更新用户信息失败
						onCamShareTaskError(ErrorType.ERROR_NORMAL);
					}
				}break;
				case SESSION_CHECK_CALLBACK: {
					Log.i(TAG, String.format("SESSION_CHECK_CALLBACK resultCode: %d", msg.arg1));
					mLiveChatManager.UnregisterOtherListener(CamShareStartTask.this);
					if (msg.arg1 == 1) {
						//获取会话信息成功，检测
						LiveChatSessionInfoItem item = (LiveChatSessionInfoItem)msg.obj;
						if(item.charget || item.freeChat){
							//会话中
							if(item.serviceType == 1){
								//camshare会话中
								onCamShareTaskSuccess(item.inviteId);
							}else{
								//Livechat会话中
								onCamShareTaskError(ErrorType.ERROR_IN_LIVECHAT);
							}
						}else{
							//不在会话中,重启会话
//							if(mCamShareTaskType == CamShareTaskType.RECONNECT){
//								//重连时，会话在无法使用试聊券
//								MoneyCheck();
//							}else{
							if(mCamShareTaskType == CamShareTaskType.ANSWER_INVITE){
								//应答时不需要禁发检测
								CouponCheck();
							}else{
								//发起邀请，检测禁发标志
								SendForbidCheck();
							}
//							}
						}
					} else {
						//获取会话信息失败，检测失败，回调
						onCamShareTaskError(ErrorType.ERROR_NORMAL);
					}
				}break;
				case SEND_FORBID_CHECK_CALLBACK: {
					Log.i(TAG, String.format("SEND_FORBID_CHECK_CALLBACK resultCode: %d", msg.arg1));
					if (msg.arg1 == 1) {
						//禁止发送邀请
						mHandler.sendEmptyMessageDelayed(ProcessEvent.CAMSHARE_INVITE_OVERTIME_UPDATE.ordinal(),
								CAMSHARE_BLOCK_SENDFORBID_DURATION);
					} else {
						// 走正常流程
						CouponCheck();
					}
				}break;
				case RISK_CONTROL_CALLBACK: {
					Log.i(TAG, String.format("RISK_CONTROL_CALLBACK resultCode: %d", msg.arg1));
					if (msg.arg1 == 1) {
						// 风控检测通过，继续下一步
						CamOpenCheck();
					} else {
						// 风控检测失败回调
						onCamShareTaskError(ErrorType.ERROR_RISK_CONTROL);
					}
				}break;
				case CAM_CHECK_CALLBACK: {
					Log.i(TAG, String.format("CAM_CHECK_CALLBACK resultCode: %d", msg.arg1));
					mLiveChatManager
							.UnregisterOtherListener(CamShareStartTask.this);
					if (msg.arg1 == 1) {
						//会话状态检测
						SessionCheck();
					} else {
						// 女士Cam未打开，检测女士在线状态
						OnlineStatusCheck();
					}
				}break;
				case ONLINE_STATUS_CHECK_CALLBACK: {
					Log.i(TAG, "ONLINE_STATUS_CHECK_CALLBACK Callback");
					mLiveChatManager
							.UnregisterOtherListener(CamShareStartTask.this);
					LCUserItem userItem = mLiveChatManager
							.GetUserWithId(mTargetId);
					if (userItem != null
							&& userItem.statusType == UserStatusType.USTATUS_ONLINE) {
						onCamShareTaskError(ErrorType.ERROR_CAM_NOT_OPEN);
					} else {
						onCamShareTaskError(ErrorType.ERROR_OFFLINE);
					}
				}break;
				case COUPON_CHECK_CALLBACK:{
					RequestBaseResponse response = (RequestBaseResponse) msg.obj;
					Log.i(TAG, String.format("COUPON_CHECK_CALLBACK resultCode: %d", response.isSuccess?1:0));
					Coupon item = (Coupon)response.body;
					if(response.isSuccess && (item.status == CouponStatus.Yes
							|| item.status == CouponStatus.Started)){
						mCoupon = item;
						CouponBind();
					}else{
						MoneyCheck();
					}
				}break;
				case COUPON_BIND_CALLBACK:{
					RequestBaseResponse response = (RequestBaseResponse) msg.obj;
					Log.i(TAG, String.format("COUPON_BIND_CALLBACK resultCode: %d", response.isSuccess?1:0));
					String ticketId = (String)response.body;
					if(response.isSuccess && !TextUtils.isEmpty(ticketId)){
						//绑定成功后,应邀使用启动会话或发起邀请
						//CouponUse(ticketId);
						if (mCamShareTaskType == CamShareTaskType.ANSWER_INVITE) {
							// 男士应邀，直接发起扣费
							CouponUseAndStartCamshare(ticketId);
						} else {
							// 发送邀请
							StartCamInvite();
						}
					}else{
						mCoupon = null;
						MoneyCheck();
					}
				}break;
				case COUPON_USE_CALLBACK:{
					mLiveChatManager.UnregisterCamShareListener(CamShareStartTask.this);
					LiveChatErrType errType = LiveChatErrType.values()[msg.arg1];
					String inviteId = (String)msg.obj;
					Log.i(TAG, String.format("COUPON_USE_CALLBACK resultCode: %d", msg.arg1));
					if(errType == LiveChatErrType.Success){
						//使用试聊券启动会话成功
						onCamShareTaskSuccess(inviteId);
					}else{
						//使用试聊券启动会话失败
						if(errType == LiveChatErrType.NoMoney){
							onCamShareTaskError(ErrorType.ERROR_NO_MONEY);
						}else if(errType == LiveChatErrType.BlockUser
								|| errType == LiveChatErrType.TargetNotExist
								|| errType == LiveChatErrType.CamChatServiceException
								|| errType == LiveChatErrType.NoCamServiceException){
							onCamShareTaskError(ErrorType.ERROR_OFFLINE);
						}else{
							onCamShareTaskError(ErrorType.ERROR_NORMAL);
						}
					}
				}break;
				case MONEY_CHECK_CALLBACK: {
					boolean isNoMoney = false;
					RequestBaseResponse response = (RequestBaseResponse) msg.obj;
					Log.i(TAG, String.format("MONEY_CHECK_CALLBACK resultCode: %d", response.isSuccess?1:0));
					if (response.isSuccess) {
						LCOtherGetCountItem countItem = (LCOtherGetCountItem) response.body;
						if (countItem.money < CAMSHARE_TARIFFS_BASE) {
							isNoMoney = true;
						}
					}
					if (isNoMoney) {
						onCamShareTaskError(ErrorType.ERROR_NO_MONEY);
					} else {
						if (mCamShareTaskType == CamShareTaskType.ANSWER_INVITE) {
							// 男士应邀，直接发起扣费
							LaunchCamShare();
						} else {
							// 发送邀请
							StartCamInvite();
						}
					}
				}break;
				case CAMSHARE_INVITE_CALLBACK: {
					Log.i(TAG, String.format("CAMSHARE_INVITE_CALLBACK resultCode: %d", msg.arg1));
					if (msg.arg1 == 1) {
						//发送邀请成功，等待女士应答并启动超时设置
						onCamShareTaskInviteStart();
						mHandler.sendEmptyMessageDelayed(ProcessEvent.CAMSHARE_INVITE_OVERTIME_UPDATE.ordinal(),
								CAMSHARE_INVITE_VALID_DURATION);
					} else {
						mLiveChatManager.UnregisterCamShareListener(CamShareStartTask.this);
						onCamShareTaskError(ErrorType.ERROR_INVITE_FAIL);
					}
				}break;
				
				case CAMSHARE_INVITE_OVERTIME_UPDATE: {
					Log.i(TAG, "CAMSHARE_INVITE_OVERTIME_UPDATE");
					onCamShareTaskError(ErrorType.ERROR_INVITE_OVERTIME);
				}break;
				
				case CAMSHARE_INIVTE_ANSWER: {
					mLiveChatManager.UnregisterCamShareListener(CamShareStartTask.this);
					CamshareLadyInviteType camshareLadyInviteType = CamshareLadyInviteType.values()[msg.arg1];
					Log.i(TAG, String.format("CAMSHARE_INIVTE_ANSWER camshareLadyInviteType: %s", camshareLadyInviteType.name()));
					boolean isAnswer = false;
					if( camshareLadyInviteType == camshareLadyInviteType.CamshareLadyInviteType_Anwser){
						isAnswer = true;
					}
					if(isAnswer){
						//启动扣费
						mHandler.removeMessages(ProcessEvent.CAMSHARE_INVITE_OVERTIME_UPDATE.ordinal());
						if(mCoupon != null && !TextUtils.isEmpty(mCoupon.couponId)){
							CouponUseAndStartCamshare(mCoupon.couponId);
						}else{
							LaunchCamShare();
						}
					}else{
						onCamShareTaskError(ErrorType.ERROR_INVITE_CANCEL);
					}
				}break;
				
				case CAMSHARE_LAUNCH_CALLBACK: {
					mLiveChatManager.UnregisterCamShareListener(CamShareStartTask.this);
					LiveChatErrType errType = LiveChatErrType.values()[msg.arg1];
					String inviteId = (String)msg.obj;
					Log.i(TAG, String.format("CAMSHARE_INIVTE_ANSWER errType: %d, inviteId: %s", 
							errType.ordinal(), inviteId));
					if(errType == LiveChatErrType.Success){
						onCamShareTaskSuccess(inviteId);
					}else{
						if(errType == LiveChatErrType.NoMoney){
							onCamShareTaskError(ErrorType.ERROR_NO_MONEY);
						}else if(errType == LiveChatErrType.BlockUser
								|| errType == LiveChatErrType.TargetNotExist
								|| errType == LiveChatErrType.CamChatServiceException
								|| errType == LiveChatErrType.NoCamServiceException){
							onCamShareTaskError(ErrorType.ERROR_OFFLINE);
						}else{
							onCamShareTaskError(ErrorType.ERROR_NORMAL);
						}
					}
				}break;
				
				default:
					break;
				}
			}
		};
	}

	/**
	 * 启动任务
	 * @return
	 */
	public boolean start() {
		if (TextUtils.isEmpty(mTargetId)) {
			return false;
		}
		if (!isStart) {
			Log.i(TAG, "start TargetId: " + mTargetId);
			isStart = true;
//			BlockListCheck();	//取消黑名单检测逻辑，假设男士主动发起，允许执行
			GetUserInfo();
		}
		return isStart;
	}

	/**
	 * 停止任务
	 */
	public void stop() {
		Log.i(TAG, "stop");
		isStart = false;
		mHandler.removeMessages(ProcessEvent.CAMSHARE_INVITE_OVERTIME_UPDATE.ordinal());
		onCamShareTaskFinish();
	}
	
	/**
	 * 获取当前Task的CamShare邀请唯一Id（用于男士端取消邀请）
	 * @return
	 */
	public int getCamShareSessionId(){
		return mInviteId;
	}
	
	/**
	 * 获取用户信息（主要获取用户所在服务器信息，留到后面使用）
	 */
	private void GetUserInfo(){
		mLiveChatManager.RegisterOtherListener(this);
		if(!mLiveChatManager.GetUserInfo(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.GET_USER_INFO_CALLBACK.ordinal();
			msg.arg1 = 0;
			mHandler.sendMessage(msg);
		}
	}
	
	/**
	 * 获取试聊券情况用于判断是否使用试聊券
	 * @return
	 */
	public Coupon getCouponItem(){
		return mCoupon;
	}
	
	/**
	 * 会话检测，检测是否Camshare会话中（Livechat会话中）
	 */
	private void SessionCheck(){
		mLiveChatManager.RegisterOtherListener(this);
		if(!mLiveChatManager.GetSessionInfo(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.SESSION_CHECK_CALLBACK.ordinal();
			msg.arg1 = 0;
			mHandler.sendMessage(msg);
		}
	}
	
	/**
	 * 是否在黑名单列表
	 */
	private void BlockListCheck(){
		boolean isInBlock = mLiveChatManager.isInBlockList(mTargetId);
		Message msg = Message.obtain();
		msg.what = ProcessEvent.BLOCK_CHECK_CALLBACK.ordinal();
		msg.arg1 = isInBlock ? 1 : 0;
		mHandler.sendMessage(msg);
	}
	
	/**
	 * 禁发邀请检测
	 */
	private void SendForbidCheck(){
		boolean isForbit = mLiveChatManager.isSendMessageLimited(mTargetId);
		Message msg = Message.obtain();
		msg.what = ProcessEvent.SEND_FORBID_CHECK_CALLBACK.ordinal();
		msg.arg1 = isForbit ? 1 : 0;
		mHandler.sendMessage(msg);
	}

	/**
	 * 风控检测
	 */
	private void RiskControlCheck() {
		Log.i(TAG, "RiskControlCheck");
		boolean isRiskControl = false;
		LoginItem loginItem = LoginManager.getInstance().getLoginItem();
		if (loginItem!= null && loginItem.camshare) {
			isRiskControl = true;
		}
		Message msg = Message.obtain();
		msg.what = ProcessEvent.RISK_CONTROL_CALLBACK.ordinal();
		msg.arg1 = isRiskControl ? 0 : 1;
		mHandler.sendMessage(msg);
	}

	/**
	 * 对方Cam是否开启测试
	 */
	private void CamOpenCheck() {
		Log.i(TAG, "CamOpenCheck");
		mLiveChatManager.RegisterOtherListener(this);
		if (!mLiveChatManager.GetLadyCamStatus(mTargetId)) {
			Message msg = Message.obtain();
			msg.what = ProcessEvent.CAM_CHECK_CALLBACK.ordinal();
			msg.arg1 = 0;
			mHandler.sendMessage(msg);
		}
	}

	/**
	 * 对方是否在线检测
	 */
	private void OnlineStatusCheck() {
		Log.i(TAG, "OnlineStatusCheck");
		mLiveChatManager.RegisterOtherListener(this);
		if (!mLiveChatManager.GetUserStatus(new String[] { mTargetId })) {
			Message msg = Message.obtain();
			msg.what = ProcessEvent.ONLINE_STATUS_CHECK_CALLBACK.ordinal();
			mHandler.sendMessage(msg);
		}
	}

	/**
	 * 试聊券检测
	 */
	private void CouponCheck() {
		LivechatRequestOperator.getInstance().CheckCoupon(mTargetId, ServiceType.CamShare,
				new OnCheckCouponCallCallback() {
					
					@Override
					public void OnCheckCoupon(long requestId, boolean isSuccess, String errno,
							String errmsg, Coupon item) {
						Message msg = Message.obtain();
						RequestBaseResponse response = new RequestBaseResponse(isSuccess, errno, errmsg, item);
						msg.what = ProcessEvent.COUPON_CHECK_CALLBACK.ordinal();
						msg.obj = response;
						mHandler.sendMessage(msg);
					}
				});
	}
	
	/**
	 * 使用试聊券
	 */
	private void CouponBind(){
		LivechatRequestOperator.getInstance().UseCoupon(mTargetId, ServiceType.CamShare,
				new OnLCUseCouponCallback() {
					
					@Override
					public void OnLCUseCoupon(long requestId, boolean isSuccess, String errno,
							String errmsg, String userId, String couponid) {
						Message msg = Message.obtain();
						RequestBaseResponse response = new RequestBaseResponse(isSuccess, errno, errmsg, couponid);
						msg.what = ProcessEvent.COUPON_BIND_CALLBACK.ordinal();
						msg.obj = response;
						mHandler.sendMessage(msg);						
					}
				});
	}
	
	/**
	 * 试聊券使用
	 */
	private void CouponUseAndStartCamshare(String ticketId){
		mLiveChatManager.RegisterCamShareListener(this);
		if(!LiveChatClient.CamshareUseTryTicket(mTargetId, ticketId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.COUPON_USE_CALLBACK.ordinal();
			msg.arg1 = LiveChatErrType.Fail.ordinal();
			mHandler.sendMessage(msg);
		}
	}
	
	/**
	 * 信用点检测
	 */
	private void MoneyCheck(){
		Log.i(TAG, "CouponCheck");
		LiveRequestOperator.getInstance().GetAccountBalance(new OnGetAccountBalanceCallback() {
			@Override
			public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, LSLeftCreditItem creditItem) {
//					Message msg = Message.obtain();
//					msg.what = ProcessEvent.MONEY_CHECK_CALLBACK.ordinal();
//					RequestBaseResponse response = new RequestBaseResponse(
//							isSuccess, String.valueOf(errCode), errMsg, item);
//					msg.obj = response;
//					mHandler.sendMessage(msg);
			}
		});
//		LCRequestJniOther.GetCount(true, false, false, false,
//				false, false, new OnLCOtherGetCountCallback() {
//
//					@Override
//					public void OnOtherGetCount(boolean isSuccess,
//							String errno, String errmsg, LCOtherGetCountItem item) {
//						Message msg = Message.obtain();
//						msg.what = ProcessEvent.MONEY_CHECK_CALLBACK.ordinal();
//						RequestBaseResponse response = new RequestBaseResponse(
//								isSuccess, errno, errmsg, item);
//						msg.obj = response;
//						mHandler.sendMessage(msg);
//					}
//				});
	}

	/**
	 * 开启Cam邀请
	 */
	private void StartCamInvite() {
		Log.i(TAG, "StartCamInvite");
		mLiveChatManager.RegisterCamShareListener(this);
		if (!mLiveChatManager.SendCamShareInvite(mTargetId, CamshareInviteType.CamshareInviteType_Ask, mInviteId, mUserName)) {
			Message msg = Message.obtain();
			msg.what = ProcessEvent.CAMSHARE_INVITE_CALLBACK.ordinal();
			msg.arg1 = 0;
			mHandler.sendMessage(msg);
		}
	}

	/**
	 * 启动CamShare扣费
	 */
	private void LaunchCamShare() {
		Log.i(TAG, "LaunchCamShare");
		mLiveChatManager.RegisterCamShareListener(this);
		if(!mLiveChatManager.ApplyCamShare(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.CAMSHARE_LAUNCH_CALLBACK.ordinal();
			msg.arg1 = LiveChatErrType.Fail.ordinal();
			mHandler.sendMessage(msg);
		}
	}

	private void onCamShareTaskFinish() {
		if (mLiveChatManager != null) {
			mLiveChatManager.UnregisterCamShareListener(this);
			mLiveChatManager.UnregisterOtherListener(this);
		}
	}

	/**
	 * CamShare启动失败统一处理
	 * 
	 * @param errorType
	 */
	private void onCamShareTaskError(ErrorType errorType) {
		// 任务完成
		isStart = false;
		// 清除回调监听
		onCamShareTaskFinish();
		if (mCallback != null) {
			mCallback.onStartCamTaskFailed(mTargetId, errorType);
		}
	}
	
	/**
	 * 通知邀请已经发送，等待回应
	 */
	private void onCamShareTaskInviteStart(){
		if (mCallback != null) {
			mCallback.onStartCamTaskInviteStart(mTargetId);
		}
	}
	
	/**
	 * 任务成功回调
	 * @param inviteId
	 */
	private void onCamShareTaskSuccess(String inviteId) {
		// 任务完成
		isStart = false;
		// 清除回调监听
		onCamShareTaskFinish();
		if (mCallback != null) {
			mCallback.onStartCamTaskSuccess(mTargetId, inviteId, mTargetServerId);
		}
	}

	/****************************** Livechat 相关回调处理 ******************************/
	@Override
	public void OnGetLadyCamStatus(LiveChatErrType errType, String errmsg,
                                   String womanId, boolean isCam) {
		if (!TextUtils.isEmpty(womanId) && womanId.equals(mTargetId)) {
			Message msg = Message.obtain();
			msg.what = ProcessEvent.CAM_CHECK_CALLBACK.ordinal();
			msg.arg1 = isCam ? 1 : 0;
			mHandler.sendMessage(msg);
		}
	}

	@Override
	public void OnSendCamShareInvite(LiveChatErrType errType, String errmsg,
                                     String userId) {
		if(!TextUtils.isEmpty(userId)
				&& userId.equals(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.CAMSHARE_INVITE_CALLBACK.ordinal();
			msg.arg1 = errType == LiveChatErrType.Success ? 1:0;
			mHandler.sendMessage(msg);
		}
	}

	@Override
	public void OnApplyCamShare(LiveChatErrType errType, String errmsg,
                                String userId, String inviteId) {
		if(!TextUtils.isEmpty(userId)
				&& userId.equals(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.CAMSHARE_LAUNCH_CALLBACK.ordinal();
			msg.arg1 = errType.ordinal();
			msg.obj = inviteId;
			mHandler.sendMessage(msg);
		}
	}

	@Override
	public void OnGetUsersCamStatus(LiveChatErrType errType, String errmsg,
                                    LiveChatUserCamStatus[] userIds) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnRecvLadyCamStatus(String userId, UserStatusProtocol statuType) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnLogin(LiveChatErrType errType, String errmsg,
                        boolean isAutoLogin) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnLogout(LiveChatErrType errType, String errmsg,
                         boolean isAutoLogin) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnGetTalkList(LiveChatErrType errType, String errmsg) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnGetHistoryMessage(boolean success, String errno,
			String errmsg, LCUserItem userItem) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnGetUsersHistoryMessage(boolean success, String errno,
			String errmsg, LCUserItem[] userItems) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnSetStatus(LiveChatErrType errType, String errmsg) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnGetUserStatus(LiveChatErrType errType, String errmsg,
                                LCUserItem[] userList) {
		Message msg = Message.obtain();
		msg.what = ProcessEvent.ONLINE_STATUS_CHECK_CALLBACK.ordinal();
		mHandler.sendMessage(msg);
	}

	@Override
	public void OnUpdateStatus(LCUserItem userItem) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnChangeOnlineStatus(LCUserItem userItem) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnRecvKickOffline(KickOfflineType kickType) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnRecvEMFNotice(String fromId, TalkEmfNoticeType noticeType) {
		// TODO Auto-generated method stub

	}

	@Override
	public void OnRecvAcceptCamInvite(String fromId, String toId, CamshareLadyInviteType inviteType, int sessionId, String fromName, boolean isCam) {
		if(!TextUtils.isEmpty(fromId)
				&& fromId.equals(mTargetId) && (sessionId == mInviteId)){
			Message message = Message.obtain();
			message.what = ProcessEvent.CAMSHARE_INIVTE_ANSWER.ordinal();
			message.arg1 = inviteType.ordinal();
			mHandler.sendMessage(message);
		}
	}

	@Override
	public void OnGetUserInfo(LiveChatErrType errType, String errmsg,
                              String userId, LiveChatTalkUserListItem item) {
		if(userId.equals(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.GET_USER_INFO_CALLBACK.ordinal();
			msg.arg1 = errType == LiveChatErrType.Success?1:0;
			msg.obj = item;
			mHandler.sendMessage(msg);
		}
	}

	@Override
	public void OnGetUsersInfo(LiveChatErrType errType, String errmsg,
                               String[] userIds, LiveChatTalkUserListItem[] itemList) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetContactList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list) {

	}

	@Override
	public void OnUseTryTicket(LiveChatErrType errType, String errno,
                               String errmsg, String userId, TryTicketEventType eventType) {

	}

	@Override
	public void OnRecvTryTalkBegin(LCUserItem userItem, int time) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvTryTalkEnd(LCUserItem userItem) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnCheckCoupon(boolean success, String errno, String errmsg,
			Coupon item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnEndTalk(LiveChatErrType errType, String errmsg,
                          LCUserItem userItem) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvTalkEvent(LCUserItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetSessionInfo(LiveChatErrType errType, String errmsg,
                                 String userId, LiveChatSessionInfoItem item) {
		if(userId.equals(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.SESSION_CHECK_CALLBACK.ordinal();
			msg.arg1 = errType == LiveChatErrType.Success?1:0;
			msg.obj = item;
			mHandler.sendMessage(msg);
		}
	}

	@Override
	public void OnRecvCamHearbeatException(String errMsg,
                                           LiveChatErrType errType, String targetId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnCamshareUseTryTicket(LiveChatErrType errType, String errmsg,
                                       String userId, String ticketId, String inviteId) {
		if(!TextUtils.isEmpty(userId) && userId.equals(mTargetId)){
			Message msg = Message.obtain();
			msg.what = ProcessEvent.COUPON_USE_CALLBACK.ordinal();
			msg.arg1 = errType.ordinal();
			msg.obj = inviteId;
			mHandler.sendMessage(msg);
		}
	}

}
