package com.qpidnetwork.livemodule.livechat.camshare;

import android.os.Handler;
import android.os.Message;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.SurfaceView;

import com.qpidnetwork.camshare.CamshareClient;
import com.qpidnetwork.camshare.CamshareClient.UserType;
import com.qpidnetwork.camshare.CamshareClientCallback;
import com.qpidnetwork.camshare.VideoRenderer;

public class LCStreamMediaClient implements CamshareClientCallback{
	
	private static final String TAG = LCStreamMediaClient.class.getName();
	private static final int RECONNECT_TIMESTAMP = 5 * 1000; //重连时间间隔 5秒/次
	public static final int STREAM_MEDIA_TIMEOUT = 60 * 1000; //流媒体重连超时时长
	public static final int STREAM_CONNECT_CHECK_DUARATION = 10 * 1000; //每10秒检测一次是否正常接收到流,如果1分钟都收不到流，通知界面断开
	
	//线程同步操作，防止异步客户端启动异常
	private static final int CAMSHARE_MEDIA_LOGIN = 1;
	private static final int CAMSHARE_MEDIA_MAKECALL = 2;
	private static final int CAMSHARE_MEDIA_HANGUP = 3;
	private static final int CAMSHARE_MEDIA_DISCONNECT = 4;
	private static final int CAMSHARE_MEDIA_STARTED = 5;
	private static final int CAMSHARE_MEDIA_RECONNECT = 6;
	private static final int CAMSHARE_MEDIA_STOP = 7;
	private static final int CAMSHARE_MEDIA_CONNECT_CHECK = 8;
	
	private CamshareClient client;
	private VideoRenderer mVideoRender;
	private OnCamShareClientListener mCallback;
	
	private String userId;
	private String domain;
	private String siteId;
	private String sid;
	private UserType userType;
	private String targetId;
	private String targetServerId;
	//客户端重连
	private boolean isClientStop = true;
	private int mTimeOut = 0;//重连超时时间,以毫秒为单位
	private long mDisconnectTime = 0; //断线时间，以秒为单位
	private boolean isCamShareStartedNotified = false;//标志位，标记启动后第一次收到流通知界面
	private boolean isInited = false;
	private long mLastRevStreamTime = 0;//最后一次收到流时间
	
	public LCStreamMediaClient(){
		mVideoRender = new VideoRenderer();
	}
	
	/**
	 * 设置超时时长（重连时间间隔为5秒）
	 * @param timeOut
	 */
	public void setTimeOut(int timeOut){
		mTimeOut = timeOut;
	}
	
	public void init(String userId, String domain, String siteId, String sid,
			UserType userType, String targetId, String targetServer){
		this.isInited = true;
		this.userId = userId;
		this.domain = domain;
		this.siteId = siteId;
		this.sid = sid;
		this.userType = userType;
		this.targetId = targetId;
		this.targetServerId = targetServer;
	}
	
	/**
	 * 启动客户端
	 */
	public void startCamShareClient(){
		if(isClientStop){
			isClientStop = false;
			mDisconnectTime = 0;
			if(client == null){
				client = new CamshareClient();
				client.setCamShareClientListener(this);
				client.Create(mVideoRender);
			}
			client.Login(userId, domain, siteId, sid, userType);
		}
	}	
	
	/**
	 * 绑定界面View，刷新界面
	 * @param view
	 * @param viewWidth
	 * @param viewHeight
	 */
	public void bindSurfaceView(SurfaceView view, int viewWidth, int viewHeight){
		mVideoRender.bindView(view, viewWidth, viewHeight);
	}
	
	/**
	 * 解除界面绑定
	 */
	public void unbindSurfaceView(){
		mVideoRender.unbindView();
	}
	
	/**
	 * 客户端是否stop
	 * @return
	 */
	public boolean isClientClose(){
		return isClientStop;
	}
	
	/**
	 * 是否初始化成功
	 * @return
	 */
	public boolean isInited(){
		return isInited;
	}
	
	/**
	 * 设置流媒体监听回调
	 * @param listener
	 */
	public void setStreamMediaClientListener(OnCamShareClientListener listener){
		mCallback = listener;
	}
	
	private Handler mHandler = new Handler(){
		
		public void handleMessage(Message msg) {
			Log.i(TAG, "handleMessage msg what: " + msg.what + " isClientStop:" + isClientStop);
			if(isClientStop){
				return;
			}
			switch (msg.what) {
			case CAMSHARE_MEDIA_LOGIN:{
				if(msg.arg1 == 1){
					//成功，继续makecall
					if(client != null){
						client.MakeCall(targetId, targetServerId);
					}
				}else{
					if(client != null){
						client.Stop();
					}
				}
			}break;
			case CAMSHARE_MEDIA_MAKECALL:{
				Log.i(TAG, "CAMSHARE_MEDIA_MAKECALL Success: " + msg.arg1);
				if(msg.arg1 != 1){
					if(client != null){
						client.Stop();
					}
				}else{
					//重连成功，删除定时器
					isClientStop = false;
					mDisconnectTime = 0;
					Log.i(TAG, "CAMSHARE_MEDIA_CONNECT_CHECK timer start");
					mHandler.sendEmptyMessageDelayed(CAMSHARE_MEDIA_CONNECT_CHECK, STREAM_CONNECT_CHECK_DUARATION);
					mHandler.removeMessages(CAMSHARE_MEDIA_RECONNECT);
				}
			}break;
			case CAMSHARE_MEDIA_HANGUP:{
				//收到hangup，关闭，重新连接
				if(client != null){
					client.Stop();
				}
			}break;
			case CAMSHARE_MEDIA_DISCONNECT:{
				startReconnected();
			}break;
			case CAMSHARE_MEDIA_STARTED:{
				//通知界面Camshare服务器开始收到流，刷新界面
				if(mCallback != null){
					mCallback.onCamShareStarted(targetId);
				}
			}break;
			case CAMSHARE_MEDIA_RECONNECT:{
				//重连
				client.Login(userId, domain, siteId, sid, userType);
			}break;
			case CAMSHARE_MEDIA_STOP:{
				//用户主动停止
				isClientStop = true;
				isCamShareStartedNotified = false;
				mVideoRender.clean();
				Log.i(TAG, "CAMSHARE_MEDIA_CONNECT_CHECK timer stop");
				mHandler.removeMessages(CAMSHARE_MEDIA_CONNECT_CHECK);
				if(client != null){
					client.Stop();
				}
			}break;
			case CAMSHARE_MEDIA_CONNECT_CHECK:{
				long currTime = System.currentTimeMillis();
				long duration = currTime - mLastRevStreamTime;
				Log.i(TAG, "Camshare video chcek duration: " + duration);
				if((mLastRevStreamTime != 0)
						&&(currTime - mLastRevStreamTime > STREAM_MEDIA_TIMEOUT)){
					mDisconnectTime = 0;
					isClientStop = true;
					mVideoRender.clean();
					if(client != null){
						client.Stop();
					}
					if(mCallback != null){
						mCallback.onCamShareStreamRevTimeout(targetId);
					}
				}else{
					mHandler.sendEmptyMessageDelayed(CAMSHARE_MEDIA_CONNECT_CHECK, STREAM_CONNECT_CHECK_DUARATION);
				}
			}break;
			default:
				break;
			}
		};
	};
	
	/*
	 * 用户主动关闭Camshare流媒体客户端
	 */
	public void stop(){
		//线程同步，防止重连与stop冲突
		Message msg = Message.obtain();
		msg.what = CAMSHARE_MEDIA_STOP;
		mHandler.sendMessage(msg);
	}
	
	/**
	 * 启动重新连接
	 */
	private void startReconnected(){
		long currentTime = System.currentTimeMillis();
		Log.i(TAG, "startReconnected");
		if(mDisconnectTime <= 0){
			mDisconnectTime = currentTime;
			isCamShareStartedNotified = false;
			if(mCallback != null){
				mCallback.onCamShareReconnect(targetId);
			}
		}
		if(mDisconnectTime + mTimeOut <= currentTime){
			mDisconnectTime = 0;
			isClientStop = true;
			mVideoRender.clean();
			Log.i(TAG, "CAMSHARE_MEDIA_CONNECT_CHECK timer out stop");
			mHandler.removeMessages(CAMSHARE_MEDIA_CONNECT_CHECK);
			if(mCallback != null){
				mCallback.onCamShareDisconnect(targetId);
			}
		}else{
			mHandler.removeMessages(CAMSHARE_MEDIA_RECONNECT);
			mHandler.sendEmptyMessageDelayed(CAMSHARE_MEDIA_RECONNECT, RECONNECT_TIMESTAMP);
		}
	}

	@Override
	public void onLogin(CamshareClient client, boolean success) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		msg.what = CAMSHARE_MEDIA_LOGIN;
		msg.arg1 = success?1:0;
		mHandler.sendMessage(msg);
	}

	@Override
	public void onMakeCall(CamshareClient client, boolean success) {
		Message msg = Message.obtain();
		msg.what = CAMSHARE_MEDIA_MAKECALL;
		msg.arg1 = success?1:0;
		mHandler.sendMessage(msg);		
	}

	@Override
	public void onHangup(CamshareClient client, String cause) {
		Message msg = Message.obtain();
		msg.what = CAMSHARE_MEDIA_HANGUP;
		mHandler.sendMessage(msg);		
	}

	@Override
	public void onRecvVideo() {
		// TODO Auto-generated method stub
		mLastRevStreamTime = System.currentTimeMillis();
		if(!isCamShareStartedNotified){
			isCamShareStartedNotified = true;
			Message msg = Message.obtain();
			msg.what = CAMSHARE_MEDIA_STARTED;
			mHandler.sendMessage(msg);	
		}
	}
	
	public interface OnCamShareClientListener{
		public void onCamShareStarted(String targetId);//连接到流媒体服务器第一次收到流
		public void onCamShareReconnect(String targetId); //重连开始回调
		public void onCamShareDisconnect(String targetId);//底部完全断开，需要用户手动重启
		public void onCamShareStreamRevTimeout(String targetId); //女士端断开Camshare上传超过1分钟
	}

	@Override
	public void onDisconnect() {
		Log.i(TAG, String.format("onDisconnect()"));
		Message msg = Message.obtain();
		msg.what = CAMSHARE_MEDIA_DISCONNECT;
		mHandler.sendMessage(msg);
	}

}
