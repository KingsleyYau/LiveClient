package com.qpidnetwork.livemodule.livechat.camshare;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.SurfaceView;

import com.qpidnetwork.camshare.CamshareClient.UserType;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerCamShareListener;
import com.qpidnetwork.livemodule.livechat.camshare.CamShareStartTask.CamShareTaskType;
import com.qpidnetwork.livemodule.livechat.camshare.CamShareStartTask.ErrorType;
import com.qpidnetwork.livemodule.livechat.camshare.CamShareStartTask.OnCamSharePreTaskCallback;
import com.qpidnetwork.livemodule.livechat.camshare.LCStreamMediaClient.OnCamShareClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.CamshareLadyInviteType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.qnbridgemodule.util.Log;

public class LCCamShareClient implements OnCamSharePreTaskCallback
					, OnCamShareClientListener,LiveChatManagerCamShareListener {
	private static final String TAG = LCCamShareClient.class.getName();
	private static final int CMASHARE_HEART_UPDATE = 1; 
	private static final int CAMSHARE_HEART_EXCEPTION_UPDATE = 2;
	private static final int CAMSHARE_BACKGROUD_OVERTIEM_EXCEPTION = 3;
	private static final int CAMSHARE_BACKGROUD_TOOLONG_NOTIFY = 4;
	
	private static final int CAMSHARE_FEE_HEART = 15 * 1000; //15秒每次发送扣费心跳包
	private static final int CAMSHARE_IN_BACKGROUD_NOTIFY_DURATION = 3 * 60 * 1000;//camshare client 后台时间超过3分钟，提示用户
	private static final int CAMSHARE_IN_BACKGROUD_OVERTIME = 4 * 60 * 1000; //camshare client 后台超过5分钟，时间过长自动关闭
	
	CamShareStartTask mCamShareStartTask;// 邀请/应邀流程管理器
	LCStreamMediaClient mStreamMediaClient;//流服务器客户端
	OnLCCamShareClientListener mListener; //Client状态更新，用于界面交互
	
	//Base data
	private String mUserId = "";//当前用户Id
	private String mUserName = "";//当前用户名字
	private String mTargetId = "";//CamShare对象
	private String mTargetName = "";//视频对象名字
	private String mTargetServerId = "";//Camshare对象所在服务器
	private String domain = ""; //Camshare流媒体服务器地址
	private String siteId = "";//所在分站ID
	private String sid = "";//服务器认证session
	private UserType userType = UserType.Man;
	
	private Context mConext;
	private int mCamInviteSid = -1;//存放Camshare邀请请求sequence
	private String mInviteId = ""; //会话发起成功后，记录CamShare会话Id，请与状态配合使用
	private CamShareClientStatus mCamShareClientStatus = CamShareClientStatus.Idle;
	private CamShareClientErrorType mErrorNo = CamShareClientErrorType.NONE;
	
	/**
	 * 当前Camshare Client状态
	 */
	public enum CamShareClientStatus{
		Idle,
		Inviting,//执行邀请流程中
		Answering,//执行应邀流程中
		Reconnecting, //手动重连中
		InviteAnswerError,//邀请或应答异常
		Connecting,//连接流媒体服务器中
		Videoing,//接收视频流正在视频中
		CamshareError//心跳包异常（流媒体服务器异常）
	}
	
	/**
	 * CamShareClient错误类型列表
	 */
	public enum CamShareClientErrorType{
		NONE, //无异常
		NORMAL, //未知异常
		CamshareNetworkException,//本地网络异常
		CamshareNoEnoughMoney, //没钱
		CamshareServiceException, //Camshare服务异常
		CamshareTargetException,  //对方断线等异常
		InLiveChatException,    //会话开始检测在Livechat会话中
		CamshareInBackgroudOvertime //Camshare会话在后台时间过久，被客户端主动关闭
	}
	
	public LCCamShareClient(Context context, String userId, String userName, String targetId, String targetName,
			String domain, String siteId, String sid){
		this.mConext = context;
		this.mUserId = userId;
		this.mUserName = userName;
		this.mTargetId = targetId;
		this.mTargetName = targetName;
		this.domain = domain;
		this.siteId = siteId;
		this.sid = sid;
		LiveChatManager.getInstance().RegisterCamShareListener(this);
	}
	
	/**
	 * 获取当前Camshare状态
	 */
	public CamShareClientStatus getCamShareStatusByUserId(){
		return mCamShareClientStatus;
	}
	
	/**
	 * 设置Client状态监控器
	 * @param listener
	 */
	public void setOnLCCamShareClientListener(OnLCCamShareClientListener listener){
		mListener = listener;
	}
	
	/**
	 * 发起CamShare请求
	 */
	public void startCamShareInvite(){
		this.mCamInviteSid = LCCamShareManager.getCamshareInviteSessionId();
		mCamShareStartTask = new CamShareStartTask(CamShareStartTask.CamShareTaskType.NEW_INVITE,
				mTargetId, mUserName, mCamInviteSid, this);
		mCamShareStartTask.start();
		
		mCamShareClientStatus = CamShareClientStatus.Inviting;
	} 
	
	/**
	 * 取消已发送CamShare邀请
	 */
	public void cancelCamShareInvite(){
		if(mCamShareStartTask != null){
			mCamShareStartTask.stop();
			LiveChatClient.SendCamShareInvite(mTargetId, CamshareInviteType.CamshareInviteType_Cancel, mCamInviteSid, mUserName);
		}
	}
	
	/**
	 * 应邀
	 */
	public void answerCamShareInvite(){
		mCamShareStartTask = new CamShareStartTask(CamShareTaskType.ANSWER_INVITE, 
				mTargetId, "", -1, this);
		mCamShareStartTask.start();
		
		mCamShareClientStatus = CamShareClientStatus.Answering;
	} 
	
	/**
	 * 手动重连时调用
	 */
	public void Reconect(){
		mCamShareStartTask = new CamShareStartTask(CamShareTaskType.RECONNECT, 
				mTargetId, "", -1, this);
		mCamShareStartTask.start();
		
		mCamShareClientStatus = CamShareClientStatus.Reconnecting;
	}
	
	/**
	 * 获取当前客户端使用试聊券信息（未使用时返回null）
	 * @param targetId
	 * @return
	 */
	public Coupon GetCouponItem(String targetId){
		Coupon item = null;
		if(mCamShareStartTask != null){
			item = mCamShareStartTask.getCouponItem();
		}
		return item;
	}
	
	/**
	 * 获取聊天对象名字
	 * @return
	 */
	public String getTargetName(){
		return mTargetName;
	}
	
	/**
	 * 获取聊天对象Id
	 * @return
	 */
	public String getTargetId(){
		return mTargetId;
	}
	
	/**
	 * 判断Client是否在服务中 
	 * @return
	 */
	public boolean isClientRunning(){
		boolean isRunning = false;
		if(mCamShareClientStatus == CamShareClientStatus.Inviting
				|| mCamShareClientStatus == CamShareClientStatus.Answering
				|| mCamShareClientStatus == CamShareClientStatus.Reconnecting
				|| mCamShareClientStatus == CamShareClientStatus.Connecting
				|| mCamShareClientStatus == CamShareClientStatus.Videoing){
			isRunning = true;
		}
		return isRunning;
	}

	/**
	 * 定时器
	 */
	private Handler mHandler = new Handler(){
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case CMASHARE_HEART_UPDATE:{
				//发送心跳
				sendCamshareHeart();
				mHandler.sendEmptyMessageDelayed(CMASHARE_HEART_UPDATE, CAMSHARE_FEE_HEART);
			}break;
			case CAMSHARE_HEART_EXCEPTION_UPDATE:{
				//关闭流媒体
				if(mStreamMediaClient != null){
					mStreamMediaClient.unbindSurfaceView();
					mStreamMediaClient.stop();
					mStreamMediaClient = null;
				}
				mCamShareClientStatus = CamShareClientStatus.CamshareError;
				mErrorNo = convertFromLiveChatError(LiveChatErrType.values()[msg.arg1]);
				if(mListener != null){
					mListener.onCamShareClientFailed(mTargetId, mErrorNo);
				}
			}break;
			case CAMSHARE_BACKGROUD_OVERTIEM_EXCEPTION:{
				//后台运行超时，停止Client
				if(mCamShareStartTask != null){
					mCamShareStartTask.stop();
					mCamShareStartTask = null;
				}
				stopTimer();
				if(mStreamMediaClient != null){
					mStreamMediaClient.unbindSurfaceView();
					mStreamMediaClient.stop();
					mStreamMediaClient = null;
				}
				mCamShareClientStatus = CamShareClientStatus.CamshareError;
				mErrorNo = CamShareClientErrorType.CamshareInBackgroudOvertime;
				if(mListener != null){
					mListener.onCamShareClientFailed(mTargetId, mErrorNo);
				}
			}break;
			
			case CAMSHARE_BACKGROUD_TOOLONG_NOTIFY:{
//				String tickerText = mConext.getResources().getString(R.string.camshare_notify_backgroud_toolong);
////				CamShareNotification nt = CamShareNotification.getInstance();
////				nt.ShowNotification(R.drawable.logo_40dp, mTargetId, mTargetName,
////						tickerText, true, true);
//
//				NotifyManager.getInstance(mConext).showCamShareNotification(tickerText , mTargetId , mTargetName);
			}break;

			default:
				break;
			}
		};
	};
	
	/**
	 * 启动定时器
	 */
	private void startTimer(){
		mHandler.sendEmptyMessage(CMASHARE_HEART_UPDATE);
	}
	
	/**
	 * 停止定时器
	 */
	private void stopTimer(){
		mHandler.removeMessages(CMASHARE_HEART_UPDATE);
	}
	
	/**
	 * 暂停心跳包扣费扣费（处理自动充值逻辑）
	 */
	public void pauseDeduction(){
		stopTimer();
	}
	
	/**
	 * Camshare 进入后台执行
	 */
	public void StartBackgroudOvertimeCheck(){
		mHandler.sendEmptyMessageDelayed(CAMSHARE_BACKGROUD_TOOLONG_NOTIFY, CAMSHARE_IN_BACKGROUD_NOTIFY_DURATION);
		mHandler.sendEmptyMessageDelayed(CAMSHARE_BACKGROUD_OVERTIEM_EXCEPTION, CAMSHARE_IN_BACKGROUD_OVERTIME);
	}
	
	/**
	 * Camshare从后台返回界面（如果Cam还没结束，停掉定时器）
	 */
	public void StopBackgroudOverTimeCheck(){
		mHandler.removeMessages(CAMSHARE_BACKGROUD_TOOLONG_NOTIFY);
		mHandler.removeMessages(CAMSHARE_BACKGROUD_OVERTIEM_EXCEPTION);
	}
	
	/**
	 * 重新心跳包启动扣费
	 */
	public void resumeDeduction(){
		if(mCamShareClientStatus == CamShareClientStatus.Connecting
				|| mCamShareClientStatus == CamShareClientStatus.Videoing){
			startTimer();
		}
	}
	
	/**
	 * 发送心跳包通知服务器
	 */
	private void sendCamshareHeart(){
		LiveChatClient.CamShareHearbeat(mTargetId, mInviteId);
	}
	
	/**
	 * 获取当前错误类型
	 * @return
	 */
	public CamShareClientErrorType getCamshareClientErrorNo(){
		return mErrorNo;
	}
	
	/**
	 * 获取当前用户Camshare inviteId
	 * @return
	 */
	public String getInviteId(){
		return mInviteId;
	}
	
	/**
	 * 停掉当前客户端
	 */
	public void stop(){
		stopTimer();
		mCamInviteSid = -1;
		mInviteId = "";
		mListener = null;
		StopBackgroudOverTimeCheck();
		mCamShareClientStatus = CamShareClientStatus.Idle;
		mErrorNo = CamShareClientErrorType.NONE;
		LiveChatManager.getInstance().UnregisterCamShareListener(this);
		if(mCamShareStartTask != null){
			mCamShareStartTask.stop();
			mCamShareStartTask = null;
		}
		if(mStreamMediaClient != null){
			mStreamMediaClient.unbindSurfaceView();
			mStreamMediaClient.stop();
			mStreamMediaClient = null;
		}
	}
	
	//---------------------------- Camshare 连接流媒体服务器 ------------------------------
	/**
	 * 连接流媒体服务器
	 */
	private void connectToStreamMedia(){
		mCamShareClientStatus = CamShareClientStatus.Connecting;
		mStreamMediaClient = new LCStreamMediaClient();
		mStreamMediaClient.init(mUserId, domain, siteId, sid, userType, mTargetId, mTargetServerId);
		mStreamMediaClient.setTimeOut(LCStreamMediaClient.STREAM_MEDIA_TIMEOUT);
		mStreamMediaClient.setStreamMediaClientListener(this);
		if(!TextUtils.isEmpty(mInviteId)){
			Log.i(TAG, "connectToStreamMedia inviteId: " + mInviteId + " ~~ targetId: " + mTargetId);
			mStreamMediaClient.startCamShareClient();
		}else{
			Log.i(TAG, "connectToStreamMedia error!");
			mCamShareClientStatus = CamShareClientStatus.CamshareError;
		}
	}
	
	/**
	 * 绑定view与流媒体客户端
	 * @param view
	 * @param viewWidth
	 * @param viewHeight
	 */
	public void bindVideoView(SurfaceView view, int viewWidth, int viewHeight){
		if(mStreamMediaClient != null){
			mStreamMediaClient.bindSurfaceView(view, viewWidth, viewHeight);
		}
	}
	
	/**
	 * 解除流媒体显示View绑定
	 */
	public void unbindVideoView(){
		if(mStreamMediaClient != null){
			mStreamMediaClient.unbindSurfaceView();
		}
	}
	
	// ---------------------------- CamShare 流媒体回调 ---------------------------------- 
	@Override
	public void onCamShareStarted(String targetId) {
		Log.i(TAG,"onCamShareStarted targetId: " + targetId);
		mCamShareClientStatus = CamShareClientStatus.Videoing;
		if(mListener != null){
			mListener.onStreamMediaConnected(targetId);
		}		
	}

	@Override
	public void onCamShareReconnect(String targetId) {
		Log.i(TAG,"onCamShareReconnect targetId: " + targetId);
		mCamShareClientStatus = CamShareClientStatus.Connecting; 
		if(mListener != null){
			mListener.onStreamMediaReconnect(targetId);
		}		
	}

	@Override
	public void onCamShareDisconnect(String targetId) {
		Log.i(TAG,"onCamShareDisconnect targetId: " + targetId);
		stopTimer();
		mCamShareClientStatus = CamShareClientStatus.CamshareError;
		mErrorNo = CamShareClientErrorType.CamshareNetworkException;
		if(mListener != null){
			mListener.onCamShareClientFailed(targetId, mErrorNo);
		}
	}
	
	@Override
	public void onCamShareStreamRevTimeout(String targetId) {
		Log.i(TAG,"onCamShareStreamRevTimeout targetId: " + targetId);
		stopTimer();
		mCamShareClientStatus = CamShareClientStatus.CamshareError;
		mErrorNo = CamShareClientErrorType.CamshareTargetException;
		if(mListener != null){
			mListener.onCamShareClientFailed(targetId, mErrorNo);
		}
	}

	//------------------------- Camshare 应邀/邀请启动流程回调 --------------------------------
	@Override
	public void onStartCamTaskFailed(String userId, ErrorType errorType) {
		Log.i(TAG,"onStartCamTaskFailed userId: " + userId + " ~~~ errorType: " + errorType.name());
		mCamShareClientStatus = CamShareClientStatus.InviteAnswerError;
		mErrorNo = convertFromTaskErrorType(errorType);
		if(mListener != null){
			mListener.onCamShareInviteFinish(false, mErrorNo, userId, "");
		}
	}

	@Override
	public void onStartCamTaskSuccess(String userId, String inviteId, String userServerId) {
		Log.i(TAG,"onStartCamTaskSuccess userId: " + userId + " ~~~ inviteId: " + inviteId + " ~~~ userServerId: " + userServerId);
		this.mInviteId = inviteId;
		this.mTargetServerId = userServerId;
		startTimer();
		connectToStreamMedia();
		if(mListener != null){
			mListener.onCamShareInviteFinish(true, CamShareClientErrorType.NONE, userId, inviteId);
		}
	}

	@Override
	public void onStartCamTaskInviteStart(String userId) {
		Log.i(TAG,"onStartCamTaskInviteStart userId: " + userId);
		if(mListener != null){
			mListener.onCamShareInviteStart(mTargetId);
		}
	}
	
	/**
	 * 转换LivechatError到Camshare error，统一错误类型
	 * @param errType
	 * @return
	 */
	private CamShareClientErrorType convertFromLiveChatError(LiveChatErrType errType){
		CamShareClientErrorType camshareErrorType = CamShareClientErrorType.NORMAL;
		if(errType == LiveChatErrType.CamChatServiceException
				|| errType == LiveChatErrType.CamServiceUnStartException
				|| errType == LiveChatErrType.NoCamServiceException){
			camshareErrorType = CamShareClientErrorType.CamshareServiceException;
		}else if(errType == LiveChatErrType.TargetNotExist){
			camshareErrorType = CamShareClientErrorType.CamshareTargetException;
		}else if(errType == LiveChatErrType.NoMoney){
			camshareErrorType = CamShareClientErrorType.CamshareNoEnoughMoney;
		}
		return camshareErrorType;
	}
	
	/**
	 * 邀请模块错误转换成CamshareClient错误
	 * @param errorType
	 * @return
	 */
	private CamShareClientErrorType convertFromTaskErrorType(ErrorType errorType){
		CamShareClientErrorType camshareErrorType = CamShareClientErrorType.NORMAL;
		if(errorType == ErrorType.ERROR_NORMAL
				|| errorType == ErrorType.ERROR_INVITE_FAIL
				|| errorType == ErrorType.ERROR_INVITE_OVERTIME
				|| errorType == ErrorType.ERROR_INVITE_CANCEL){
			camshareErrorType = CamShareClientErrorType.NORMAL;
		}else if(errorType == ErrorType.ERROR_RISK_CONTROL
				|| errorType == ErrorType.ERROR_CAM_NOT_OPEN){
			camshareErrorType = CamShareClientErrorType.CamshareServiceException;
		}else if(errorType == ErrorType.ERROR_OFFLINE){
			camshareErrorType = CamShareClientErrorType.CamshareTargetException;
		}else if(errorType == ErrorType.ERROR_NO_MONEY){
			camshareErrorType = CamShareClientErrorType.CamshareNoEnoughMoney;
		}else if(errorType == ErrorType.ERROR_IN_LIVECHAT){
			camshareErrorType = CamShareClientErrorType.InLiveChatException;
		}
		return camshareErrorType;
	}
	
	
	public interface OnLCCamShareClientListener{
		//邀请时才有回调，用于界面20秒后可取消逻辑
		public void onCamShareInviteStart(String userId);
		//邀请结束回调
		public void onCamShareInviteFinish(boolean isSuccess, CamShareClientErrorType errorType, String userId, String inviteId);
		//流媒体连接上
		public void onStreamMediaConnected(String userId);
		//流媒体重新连接
		public void onStreamMediaReconnect(String userId);
		//流媒体断开链接，需用户手动连接
		public void onCamShareClientFailed(String userId, CamShareClientErrorType errType);
	}


	@Override
	public void OnSendCamShareInvite(LiveChatErrType errType, String errmsg,
                                     String userId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnApplyCamShare(LiveChatErrType errType, String errmsg,
                                String userId, String inviteId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvAcceptCamInvite(String fromId, String toId, CamshareLadyInviteType inviteType, int sessionId, String fromName, boolean isCam) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvCamHearbeatException(String errMsg,
                                           LiveChatErrType errType, String targetId) {
		if(targetId.equals(mTargetId)){
			//停止发送心跳
			stopTimer();
			Log.i(TAG, "OnRecvCamHearbeatException errType: " + errType.name());
			Message msg = Message.obtain();
			msg.what = CAMSHARE_HEART_EXCEPTION_UPDATE;
			msg.arg1 = errType.ordinal();
			mHandler.sendMessage(msg);
		}
	}

	@Override
	public void OnCamshareUseTryTicket(LiveChatErrType errType, String errmsg,
                                       String userId, String ticketId, String inviteId) {
		// TODO Auto-generated method stub
		
	}

}
