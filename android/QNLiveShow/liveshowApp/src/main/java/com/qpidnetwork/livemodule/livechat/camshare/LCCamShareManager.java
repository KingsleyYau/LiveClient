package com.qpidnetwork.livemodule.livechat.camshare;

import android.content.Context;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.text.TextUtils;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import com.qpidnetwork.camshare.CamshareClient.UserType;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.CamShareClientErrorType;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.CamShareClientStatus;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.OnLCCamShareClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkListInfo;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkSessionListItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 管理CamShare业务逻辑
 * 
 * @author Hunter Mun
 * @since 2016.11.1
 */
public class LCCamShareManager implements OnLCCamShareClientListener{
	private static final String TAG = LCCamShareManager.class.getName();
	
	private static AtomicInteger mInviteIdGenerator = new AtomicInteger(0); //邀请SessionId唯一ID生成器
	
	//CamShareClient相关
	private String userId = "";
	private String userName = "";
	private String userServerId = "";
	private String domain = "";
	private String siteId = "";
	private String sid = "";
	private HashMap<String, LCCamShareClient> mReceiveClientMap;//存放指定会话流媒体接收Client
	private LCStreamMediaSendClient mSendClient;//存放发送流媒体客户端实例
	
	private Context mContext;
	private HashMap<String, Boolean> mCamServiceBackMap = new HashMap<String, Boolean>();//存放当前正在后台运行服务
	
	//屏幕锁，视频中屏幕不能锁屏
	private WakeLock mWakeLock;
	/**
	 * CamShare状态监听器列表
	 */
	private ArrayList<OnLCCamShareClientListener> mCamShareListeners;

	public LCCamShareManager(Context context, LiveChatManager manager) {
		mContext = context;
		mReceiveClientMap = new HashMap<String, LCCamShareClient>();
		mCamShareListeners = new ArrayList<OnLCCamShareClientListener>();
	
		//初始化屏幕锁
		PowerManager pm = (PowerManager)context.getSystemService(Context.POWER_SERVICE);
		mWakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "CamShareWakeLock");
		mWakeLock.setReferenceCounted(false);
		
		//初始化发送Client
		mSendClient = new LCStreamMediaSendClient();
		mSendClient.setTimeOut(LCStreamMediaClient.STREAM_MEDIA_TIMEOUT);
		if(!TextUtils.isEmpty(userServerId)){
			mSendClient.init(userId, domain, siteId, sid, UserType.Man, userId, userServerId);
		}
	}
	
	/**
	 * 登录成功同步信息
	 * 跟站点配置有关 WebSiteType(ChnLove, CharmDate, IDateAsia, LatamDate, AsiaMe)
	 */
	public void updateConfig(String domain, String userId, String userName, String sid){
		this.domain = domain;
		this.userId = userId;
		this.userName = userName;
		this.sid = sid;
		int siteTypeId = WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
		switch (siteTypeId) {
		case 1:
			this.siteId = String.valueOf(0);
			break;
		case 2:
			this.siteId = String.valueOf(1);
			break;
		case 4:
			this.siteId = String.valueOf(4);
			break;
		case 8:
			this.siteId = String.valueOf(5);
			break;
		case 16:
			this.siteId = String.valueOf(6);
			break;
		default:
			break;
		}
	}
	
	/**
	 * 是否在和某人使用Camshare服务(由于断线即失效，本地存储有效)
	 * @param targetId
	 * @return
	 */
	public boolean isInCamshareService(String targetId){
		boolean isInCamService = false;
		CamShareClientStatus camStatus = getCamShareStatusById(targetId);
		if( camStatus != CamShareClientStatus.Idle
				&& camStatus != CamShareClientStatus.InviteAnswerError
				&& camStatus != CamShareClientStatus.CamshareError){
			isInCamService = true;
		}
		return isInCamService;
	}
	
	/**
	 * Camshare 服务是否使用中(并清除异常结束的CamshareClient)
	 * @return
	 */
	public boolean isCamshareServiceUsed(){
		boolean isServiceUsed = false;
		List<String> finishList = new ArrayList<String>();
		synchronized (mReceiveClientMap) {
			for(String key :  mReceiveClientMap.keySet()){
				LCCamShareClient client = mReceiveClientMap.get(key);
				if(client.getCamShareStatusByUserId() == CamShareClientStatus.InviteAnswerError
						|| client.getCamShareStatusByUserId() == CamShareClientStatus.CamshareError
						|| client.getCamShareStatusByUserId() == CamShareClientStatus.Idle){
					finishList.add(key);
					removeFromCamshareClientMap(key);
				}
			}
			isServiceUsed = mReceiveClientMap.size()>0?true:false;
		}
		//清除已经结束的Camshare
		for(String useId : finishList){
			LiveChatManager.getInstance().EndCamshareChat(useId);
		}
		return isServiceUsed;
	}
	
	/**
	 * 获取正在Camshare中女士名称，用于界面显示(由于单用户取第一个就可以)
	 * @return
	 */
	public String getUserNameInCamshareService(){
		String userName = "";
		synchronized (mReceiveClientMap) {
			for(String key :  mReceiveClientMap.keySet()){
				LCCamShareClient client = mReceiveClientMap.get(key);
				if(client.getCamShareStatusByUserId() != CamShareClientStatus.InviteAnswerError
						&& client.getCamShareStatusByUserId() != CamShareClientStatus.CamshareError
						&& client.getCamShareStatusByUserId() != CamShareClientStatus.Idle){
					userName = client.getTargetName();
					break;
				}
			}
		}
		return userName;
	}
	
	/**
	 * 更新用户所在服务器
	 * @param userServer
	 */
	public void updateUserServer(String userServer){
		if(TextUtils.isEmpty(userServerId)
				|| !userServerId.equals(userServer)){
			userServerId = userServer;
			if(mSendClient != null){
				mSendClient.stop();
				mSendClient.init(userId, domain, siteId, sid, UserType.Man, userId, userServerId);
			}
		}
		if(getCurrentValidCamCount() > 0){
			CheckOrStartSenderClient();
		}
	}
	
	/**
	 * 换站等需要重置发送端参数，故先清除客户端
	 */
	public void clearSendClient(){
		userServerId = "";
		if(mSendClient != null){
			mSendClient.stop();
			mSendClient.resetParams();
		}
	}
	
	/**
	 * 获取Cam中用户列表
	 * @return
	 */
	public List<String> getUsersInCamshare(){
		ArrayList<String> userList = new ArrayList<String>();
		synchronized (mReceiveClientMap) {
			userList.addAll(mReceiveClientMap.keySet());
		}
		return userList;
	}
	
	/**
	 * 获取指定对指定女士使用试聊券信息
	 * @param targetId
	 * @return
	 */
	public Coupon GetCouponItem(String targetId){
		Coupon item = null;
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			item = client.GetCouponItem(targetId);
		}
		return item;
	}
	
	/**
	 * 获取在聊列表后，处理inchat中自启动及其他Endchat功能
	 * @param talkListInfo
	 */
	public void OnGetTalkList(LiveChatTalkListInfo talkListInfo){
		if(talkListInfo != null){
			ArrayList<String> camshareInchatList = new ArrayList<String>(); 
			ArrayList<String> camsharePauseList = new ArrayList<String>(); 
			for(LiveChatTalkSessionListItem sessionItem : talkListInfo.chatingSessionArray){
				if(sessionItem.serviceType == 1){
					//是Camshare
					camshareInchatList.add(sessionItem.userId);
				}
			}
			for(LiveChatTalkSessionListItem sessionItem : talkListInfo.pauseSessionArray){
				if(sessionItem.serviceType == 1){
					//是Camshare
					camsharePauseList.add(sessionItem.userId);
				}
			}
			for(String userId : camshareInchatList){
				if(!isInCamshareService(userId)){
					//在聊中需要重启
					AutoLaunchCamshareService(userId);
				}
			}
			for(String userId : camsharePauseList){
				if(!isInCamshareService(userId)){
					//本地已关闭，需要Endchat
					LiveChatManager.getInstance().EndCamshareChat(userId);
				}
			}
		}
	}
	
	/**
	 * 后台自动启动和指定用户的Camshare服务
	 * @param targetId
	 */
	private void AutoLaunchCamshareService(String targetId){
		if(!TextUtils.isEmpty(targetId)){
			LCUserItem userItem = LiveChatManager.getInstance().GetUserWithId(targetId);
			restartCamshareService(userItem.userId, userItem.userName);
			updateCamshareServiceBackgroud(userItem.userId, true);
		}
	}
	
	/**
	 * 添加到本地Client列表
	 * @param targetId
	 * @param client
	 */
	private void addToCamshareClientMap(String targetId, LCCamShareClient client){
		synchronized (mReceiveClientMap) {
			if(mReceiveClientMap != null){
				mReceiveClientMap.put(targetId, client);
			}
		}
		//新启动会话，锁定屏幕
		camshareAcquireScreenLock();
	}
	
	/**
	 * 清除指定用户的Camshare client相关及背景状态和浮窗
	 * @param targetId
	 */
	private LCCamShareClient clearCamshareClientById(String targetId){
		mCamServiceBackMap.remove(targetId);
//		FloatingWindowManager.getInstance().hideFLoatingWindow();
////		CamShareNotification.getInstance().Cancel();
//		NotifyManager.getInstance(mContext).cancelAll(NotificationTypeEnum.CAMSHARE_NOTIFICATION);

		//会话结束，检测是否需要解除屏幕锁定
		camshareReleaseScreenLock();
		
		return removeFromCamshareClientMap(targetId);
	}
	
	/**
	 * 从当前列表中删除
	 * @param targetId
	 */
	private LCCamShareClient removeFromCamshareClientMap(String targetId){
		LCCamShareClient client = null;
		synchronized (mReceiveClientMap) {
			if(mReceiveClientMap != null){
				client = mReceiveClientMap.remove(targetId);
			}
		}
		return client;
	}
	
	/**
	 * 获取当前正在Camshare用户数目
	 * @return
	 */
	private int getCurrentValidCamCount(){
		int count = 0;
		synchronized (mReceiveClientMap) {
			for(String key :  mReceiveClientMap.keySet()){
				LCCamShareClient client = mReceiveClientMap.get(key);
				if(client.getCamShareStatusByUserId() != CamShareClientStatus.InviteAnswerError
						&& client.getCamShareStatusByUserId() != CamShareClientStatus.CamshareError
						&& client.getCamShareStatusByUserId() != CamShareClientStatus.Idle){
					count++;
				}
			}
		}
		return count;
	}
	
	/**
	 * 获取用户的Client
	 * @param targetId
	 * @return
	 */
	private LCCamShareClient getCamshareClientById(String targetId){
		LCCamShareClient client = null;
		synchronized (mReceiveClientMap) {
			if(mReceiveClientMap != null){
				client = mReceiveClientMap.get(targetId);
			}
		}
		return client;
	}
	
	/**
	 * 发起CamShare请求
	 * @param targetId
	 */
	public void startCamShareInvite(String targetId, String targetName){ 
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			CamShareClientStatus status = client.getCamShareStatusByUserId();
			if( status == CamShareClientStatus.Idle
					|| status == CamShareClientStatus.InviteAnswerError
					|| status == CamShareClientStatus.CamshareError){
				//异常重启
				client.stop();
				clearCamshareClientById(targetId);
			}else{
				//启动中
				return;
			}
		}
		client = new LCCamShareClient(mContext, userId, userName, targetId, targetName, domain, siteId, sid);
		client.setOnLCCamShareClientListener(this);
		client.startCamShareInvite();
		addToCamshareClientMap(targetId, client);
	}
	
	/**
	 * 取消已发送CamShare邀请
	 * @param targetId
	 */
	public void cancelCamShareInvite(String targetId){
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			client.cancelCamShareInvite();
			client.stop();
			clearCamshareClientById(targetId);
		}
	}
	
	/**
	 * 获取和当前用户Camshare状态
	 * @param targetId
	 * @return
	 */
	public CamShareClientStatus getCamShareStatusById(String targetId){
		CamShareClientStatus status = CamShareClientStatus.Idle;
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			status = client.getCamShareStatusByUserId();
		}
		return status;
	}
	
	/**
	 * 应邀
	 * @param targetId
	 */
	public void answerCamShareInvite(String targetId, String targetName){
		LCCamShareClient client = new LCCamShareClient(mContext, userId, userName, 
				targetId, targetName, domain, siteId, sid);
		client.setOnLCCamShareClientListener(this);
		client.answerCamShareInvite();
		addToCamshareClientMap(targetId, client);
	}
	
	/**
	 * 重新启动Camshare （不走邀请和试聊券逻辑）
	 * @param targetId
	 */
	public void restartCamshareService(String targetId, String targetName){
		LCCamShareClient client = new LCCamShareClient(mContext, userId, userName, 
				targetId, targetName, domain, siteId, sid);
		client.setOnLCCamShareClientListener(this);
		client.Reconect();
		addToCamshareClientMap(targetId, client);
	}
	
	/**
	 * 指定聊天界面进入后台，开始后台运行统计
	 * @param targetId
	 */
	public void StartBackgroudOvertimeCheck(String targetId){
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			client.StartBackgroudOvertimeCheck();
		}
	}
	
	/**
	 * 结束后台运行统计
	 * @param targetId
	 */
	public void StopBackgroudOverTimeCheck(String targetId){
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			client.StopBackgroudOverTimeCheck();
		}
	}
	
	/**
	 * 检测发送Client是否正在使用中
	 * @return
	 */
	public boolean isSendClientRunning(){
		boolean isRunning = false;
		if(mSendClient != null){
			isRunning = !mSendClient.isClientClose();
		}
		return isRunning;
	}
	
	/**
	 * 检测并启动上传视频逻辑
	 */
	private void CheckOrStartSenderClient(){
		if(mSendClient.isClientClose()){
			if(SystemUtils.CheckFrontCameraUsable()){
				if(mSendClient.isInited()){
					//前置摄像头可用且初始化完成
					mSendClient.startCamShareClient();
				}else{
					//获取当前用户所在服务器
					LiveChatClient.GetUserInfo(userId);
				}
			}
		}
	}
	
	/**
	 * 检测并停止上传视频逻辑
	 */
	private void CheckOrStopSenderClient(){
		if(mSendClient != null 
				&& getCurrentValidCamCount() <= 0){
			mSendClient.stop();
		}
	}
	
	/**
	 * 停止和指定用户的Camshare
	 * @param targetId
	 */
	public void stopCamshare(String targetId){
		LCCamShareClient client = clearCamshareClientById(targetId);
		if(client != null){
			client.stop();
		}
		if(getCurrentValidCamCount() <=0 ){
			//当前camshare对象都关闭，关闭上传
			if(mSendClient != null){
				mSendClient.stop();
			}
		}
	}
	
	/**
	 * 获取正在Cam中的inviteID
	 * @param targetId
	 * @return
	 */
	public String getInviteIdByUserId(String targetId){
		String inviteId = "";
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			inviteId = client.getInviteId();
		}
		return inviteId;
	}
	
	/**
	 *  绑定
	 * @param target
	 * @param view
	 */
	public void bindStreamClient(String target, SurfaceView view, int viewWidth, int viewHeight){
		if(target.equals(userId)){
			//本人
			if(mSendClient != null){
				mSendClient.bindSurfaceView(view, viewWidth, viewHeight);
			}
		}else{
			LCCamShareClient client = getCamshareClientById(target);
			if(client != null){
				client.bindVideoView(view, viewWidth, viewHeight);
			}
		}
	}
	
	/**
	 * 清除界面绑定
	 * @param target
	 */
	public void clearStreamClientView(String target){
		if(target.equals(userId)){
			//本人
			if(mSendClient != null){
				mSendClient.unbindSurfaceView();
			}
		}else{
			LCCamShareClient client = getCamshareClientById(target);
			if(client != null){
				client.unbindVideoView();
			}
		}
	}
	
	/**
	 * 开始采集
	 */
	public void sendClientStartCapture(SurfaceHolder holder){
		if(mSendClient != null){
			mSendClient.startCapture(holder);
		}
	}
	
	/**
	 * 停止采集
	 */
	public void sendClientStopCapture(){
		if(mSendClient != null){
			mSendClient.stopCapture();
		}
	}
	
	/**
	 * 获取CamshareClient错误码
	 * @param targetId
	 * @return
	 */
	public CamShareClientErrorType getCamshareClientErrorNo(String targetId){
		CamShareClientErrorType errorType = CamShareClientErrorType.NORMAL;
		LCCamShareClient client = getCamshareClientById(targetId);
		if(client != null){
			errorType = client.getCamshareClientErrorNo();
		}
		return errorType;
	}
	
	/**
	 * 注册CamShare状态监听器
	 * @param listener
	 * @return
	 */
	public boolean registerCamShareStatusListener(OnLCCamShareClientListener listener){
		boolean result = false;
		synchronized(mCamShareListeners) 
		{
			if (null != listener) {
				boolean isExist = false;
				
				for (Iterator<OnLCCamShareClientListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
					OnLCCamShareClientListener theListener = iter.next();
					if (theListener == listener) {
						isExist = true;
						break;
					}
				}
				
				if (!isExist) {
					result = mCamShareListeners.add(listener);
				}
				else {
					Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", "LCCamShareManager", "registerCamShareStatusListener", listener.getClass().getSimpleName()));
				}
			}
			else {
				Log.e(TAG, String.format("%s::%s() fail, listener is null", "LCCamShareManager", "registerCamShareStatusListener"));
			}
		}
		return result;
	}
	
	/**
	 * 注销CamShare监听器
	 * @param listener
	 * @return
	 */
	public boolean unRegisterCamShareStatusListener(OnLCCamShareClientListener listener) 
	{
		boolean result = false;
		synchronized(mCamShareListeners)
		{
			result = mCamShareListeners.remove(listener);
		}

		if (!result) {
			Log.e(TAG, String.format("%s::%s() fail, listener:%s", "LCCamShareManager", "unRegisterCamShareStatusListener", listener.getClass().getSimpleName()));
		}
		return result;
	}
	
	/**
	 * 获取邀请sequence
	 * @return
	 */
	public static int getCamshareInviteSessionId(){
		return mInviteIdGenerator.getAndIncrement();
	}

	@Override
	public void onCamShareInviteStart(String userId) {
		synchronized(mCamShareListeners){
			for (Iterator<OnLCCamShareClientListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				OnLCCamShareClientListener listener = iter.next();
				listener.onCamShareInviteStart(userId);
			}
		}		
	}

	@Override
	public void onCamShareInviteFinish(boolean isSuccess, CamShareClientErrorType errorType,
			String userId, String inviteId) {
		if(isSuccess){
			CheckOrStartSenderClient();
		}else{
			//邀请失败需要检测是否需要取消锁定屏幕
			camshareReleaseScreenLock();
		}
		
		updateBackRunStatus(userId);//跟新通知栏及状态
		synchronized(mCamShareListeners){
			for (Iterator<OnLCCamShareClientListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				OnLCCamShareClientListener listener = iter.next();
				listener.onCamShareInviteFinish(isSuccess, errorType, userId, inviteId);
			}
		}		
	}

	@Override
	public void onStreamMediaConnected(String userId) {
		synchronized(mCamShareListeners){
			for (Iterator<OnLCCamShareClientListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				OnLCCamShareClientListener listener = iter.next();
				listener.onStreamMediaConnected(userId);
			}
		}		
	}

	@Override
	public void onStreamMediaReconnect(String userId) {
		synchronized(mCamShareListeners){
			for (Iterator<OnLCCamShareClientListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				OnLCCamShareClientListener listener = iter.next();
				listener.onStreamMediaReconnect(userId);
			}
		}		
	}

	@Override
	public void onCamShareClientFailed(String userId, CamShareClientErrorType errType) {
		CheckOrStopSenderClient();
		updateBackRunStatus(userId);//跟新通知栏及状态
		//会话结束，检测是否需要解除屏幕锁定
		camshareReleaseScreenLock();
		synchronized(mCamShareListeners){
			for (Iterator<OnLCCamShareClientListener> iter = mCamShareListeners.iterator(); iter.hasNext(); ) {
				OnLCCamShareClientListener listener = iter.next();
				listener.onCamShareClientFailed(userId, errType);
			}
		}		
	}
	
	/***************************** 弹窗及通知等业务 ****************************************/
	/**
	 * 后台运行时，状态更新
	 */
	private void updateBackRunStatus(String targetId){
		if(mCamServiceBackMap.containsKey(targetId)){
			LCCamShareClient client = getCamshareClientById(targetId);
			if(client != null){
				CamShareClientStatus clientStatus = client.getCamShareStatusByUserId();
				if(clientStatus == CamShareClientStatus.InviteAnswerError
						|| clientStatus == CamShareClientStatus.CamshareError){
					//失败后
					mCamServiceBackMap.remove(targetId);
//					FloatingWindowManager.getInstance().hideFLoatingWindow();
					StopBackgroudOverTimeCheck(targetId);
				}
				sendSystemNotification(client);
			}
		}
	}
	
	/**
	 * 设置当前Cam是否后台运行
	 * @param isBackgroud
	 */
	public void updateCamshareServiceBackgroud(String targetId, boolean isBackgroud){
		LCCamShareClient client = getCamshareClientById(targetId);
		if(isBackgroud && client != null
				&& client.isClientRunning()){
			mCamServiceBackMap.put(targetId, true);
			sendSystemNotification(client);
//			FloatingWindowManager.getInstance().showFloatingWindow(client.getTargetId(), client.getTargetName());
			StartBackgroudOvertimeCheck(targetId);
		}else{
			mCamServiceBackMap.remove(targetId);
			//取消状态栏，隐藏浮窗
//			CamShareNotification.getInstance().Cancel();
			PushManager.getInstance().Cancel(NotificationTypeEnum.CAMSHARE_NOTIFICATION);
//			FloatingWindowManager.getInstance().hideFLoatingWindow();
			StopBackgroudOverTimeCheck(targetId);
		}
	}
	
	/**
	 * 更新通知栏告诉用户状态改变
	 */
	private void sendSystemNotification(LCCamShareClient client){
		if(client != null){
			String targetName = client.getTargetName();
			String targetId = client.getTargetId();
			CamShareClientStatus camStatus = client.getCamShareStatusByUserId();
			CamShareClientErrorType errNo =	client.getCamshareClientErrorNo();
//			CamShareNotification nt = CamShareNotification.getInstance();
//			nt.ShowNotification(R.drawable.logo_40dp, targetId, targetName,
//					getNotificationTicker(camStatus, errNo, targetName), true, true);

//			PushManager.getInstance().ShowNotification(
//					NotificationTypeEnum.CAMSHARE_NOTIFICATION,
//					getNotificationTicker(camStatus, errNo, targetName),
//					targetId,
//					targetName);
		}
	}
	
	/**
	 * 获取当前通知描述
	 * @param camshareStatus
	 * @param errNo
	 * @param targetName
	 * @return
	 */
	private String getNotificationTicker(CamShareClientStatus camshareStatus, CamShareClientErrorType errNo, String targetName){
		String tickerText = "";
		switch (camshareStatus) {
		case Inviting:
		case Reconnecting:{
			//正在邀请中
			tickerText = String.format(mContext.getString(R.string.camshare_floating_invite_tips), targetName);
		}break;
		
		case Answering:
		case Connecting:
		case Videoing: {
			//视频会话中
			tickerText = String.format(mContext.getString(R.string.camshare_floating_video_tips), targetName);
		}break;
		
		case InviteAnswerError:
		case CamshareError:{
			//邀请或者会话失败
			switch (errNo) {
			case CamshareNoEnoughMoney:{
				tickerText = mContext.getString(R.string.camshare_notify_nomoney_error);
			}break;
			case InLiveChatException:{
				tickerText = mContext.getString(R.string.camshare_notify_inlivechat_error);
			}break;
			case CamshareInBackgroudOvertime:{
				tickerText = mContext.getString(R.string.camshare_floating_video_over_time_tips);
			}break;
			default:{
				if(camshareStatus == CamShareClientStatus.InviteAnswerError){
					tickerText = mContext.getString(R.string.camshare_notify_invite_normalerror);
				}else if(camshareStatus == CamShareClientStatus.CamshareError){
					tickerText = mContext.getString(R.string.camshare_notify_service_exception);
				}
			}break;
			}
		}break;

		default:
			break;
		}
		return tickerText;
	}
	
	/**
	 * 获取屏幕锁，防止手机休眠，屏幕熄屏
	 */
	private void camshareAcquireScreenLock(){
		if(mWakeLock != null && !mWakeLock.isHeld()){
			mWakeLock.acquire();
		}
	}
	
	/**
	 * 解除防止休眠及熄屏
	 */
	private void camshareReleaseScreenLock(){
		if(mWakeLock != null && mWakeLock.isHeld()
				&& !isCamshareServiceUsed()){
			mWakeLock.release();
		}
	}
	
}
