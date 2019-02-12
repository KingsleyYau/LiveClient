package com.qpidnetwork.livemodule.livechat.camshare;

import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.Handler;
import android.os.Message;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import com.qpidnetwork.camshare.CamshareClient;
import com.qpidnetwork.camshare.CamshareClient.UserType;
import com.qpidnetwork.camshare.CamshareClientCallback;
import com.qpidnetwork.camshare.VideoRenderer;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.io.IOException;
import java.util.List;

public class LCStreamMediaSendClient implements CamshareClientCallback, PreviewCallback{

	
	private static final String TAG = LCStreamMediaSendClient.class.getName();
	private static final int CAMERA_PREVIEW_WIDTH = 176;//Camera 预览尺寸（宽）
	private static final int CAMERA_PREVIEW_HEIGHT = 144;//Camera 预览尺寸（高）
	private static final int CAMERA_FRAME_RATE = 6;//帧率(每秒采集帧数）
	private static final int RECONNECT_TIMESTAMP = 5 * 1000; //重连时间间隔 5秒/次
	public static final int STREAM_MEDIA_TIMEOUT = 60 * 1000; //流媒体重连超时时长
	public static final int STREAM_CONNECT_CHECK_DUARATION = 10 * 1000; //每10秒检测一次是否正常接收到流,如果1分钟都收不到流，通知界面断开（不在继续上传流异常）
	
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
	private OnCamShareSendClientListener mCallback;
	
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
	
	//视频采集
	private Camera mCamera = null;
	private int mCameraId = 0;
    private int PIXEL_FORMAT = ImageFormat.NV21;//采集数据格式
    private final int numCaptureBuffers = 3;    // 采集数目个数
    private SurfaceHolder mHolder = null; // Camera payload 展示地方
	
	public LCStreamMediaSendClient(){
		mVideoRender = new VideoRenderer();
//		mVideoRender.setDebug(true);
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
	 * 发送端需重新初始化
	 */
	public void resetParams(){
		isInited = false;
		this.userId = "";
		this.domain = "";
		this.siteId = "";
		this.sid = "";
		this.targetId = "";
		this.targetServerId = "";
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
				client.SetSendVideoSize(CAMERA_PREVIEW_WIDTH, CAMERA_PREVIEW_HEIGHT);
				client.SetVideoRate(CAMERA_FRAME_RATE);
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
	public void setStreamMediaClientListener(OnCamShareSendClientListener listener){
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
					//启动上传流逻辑
					bindCamera();
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
				stopInternal();
			}break;
			case CAMSHARE_MEDIA_CONNECT_CHECK:{
				long currTime = System.currentTimeMillis();
				long duration = currTime - mLastRevStreamTime;
				Log.i(TAG, "Camshare video chcek duration: " + duration);
				if((mLastRevStreamTime != 0)
						&&(currTime - mLastRevStreamTime > STREAM_MEDIA_TIMEOUT)){
					stopInternal();
					if(mCallback != null){
						mCallback.onCamShareStreamException(targetId);
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
	 * 内部停止，不需要重连
	 */
	private void stopInternal(){
		isClientStop = true;
		mDisconnectTime = 0;
		isCamShareStartedNotified = false;
		unbindCamera();//停止视频采集
		mVideoRender.clean();
		Log.i(TAG, "CAMSHARE_MEDIA_CONNECT_CHECK timer stop");
		mHandler.removeMessages(CAMSHARE_MEDIA_RECONNECT);
		mHandler.removeMessages(CAMSHARE_MEDIA_CONNECT_CHECK);
		if(client != null){
			client.Stop();
		}
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
			stopInternal();
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
	
	public interface OnCamShareSendClientListener{
		public void onCamShareStarted(String targetId);//连接到流媒体服务器第一次收到流
		public void onCamShareReconnect(String targetId); //重连开始回调
		public void onCamShareDisconnect(String targetId);//底部完全断开，需要用户手动重启
		public void onCamShareStreamException(String targetId); //女士端断开Camshare上传超过1分钟
	}

	@Override
	public void onDisconnect() {
		Log.i(TAG, String.format("onDisconnect()"));
		Message msg = Message.obtain();
		msg.what = CAMSHARE_MEDIA_DISCONNECT;
		mHandler.sendMessage(msg);
	}
	
	/**
	 * 上传连接成功后，绑定当前Camera
	 */
	private void bindCamera(){
		boolean isStart = false;
		int width = 0;
		int height = 0;
		mCameraId = SystemUtils.GetFrontCameraIndex();
		if(mCameraId != -1){
			try {
				mCamera = Camera.open(mCameraId);
				if(mCamera != null){
					Size bestSize = getBestSuppportPreviewSize(mCamera);
					Camera.Parameters parameters = mCamera.getParameters();
					if(bestSize != null){
						width = bestSize.width;
						height = bestSize.height;
					}else{
						width = parameters.getPreviewSize().width;
						height = parameters.getPreviewSize().height;
					}
					PIXEL_FORMAT = client.ChooseVideoFormate(getCameraPreviewFormats(mCamera));
					if(PIXEL_FORMAT >= 0){
						parameters.setPreviewSize(width, height); 
						parameters.setPreviewFormat(PIXEL_FORMAT);
						parameters.setPreviewFrameRate(getBestCameraPreviewFrameRate(mCamera));
						parameters.set("rotation", "180");
						mCamera.setDisplayOrientation(90);
						mCamera.setParameters(parameters);
						isStart = true;
					}else{
						Log.i(TAG, "Camera startCapture ChooseVideoFormate Error PIXEL_FORMAT:" + PIXEL_FORMAT);
						isStart = false;
					}
				}
			}catch(RuntimeException e){
				Log.i(TAG, "Camera startCapture RuntimeException: " +  e.getMessage());
				e.printStackTrace();
			}catch (Exception e) {
				Log.i(TAG, "Camera startCapture exception: " +  e.getMessage());
				e.printStackTrace();
			}
			
			if(isStart){
				//打开视频上传成功，重置状态
				isClientStop = false;
				mDisconnectTime = 0;
				Log.i(TAG, "CAMSHARE_MEDIA_CONNECT_CHECK timer start");
				if(mHolder != null){
					startCaptureInternal();
				}
				mHandler.removeMessages(CAMSHARE_MEDIA_RECONNECT);
			}else{
				//使用Camera失败
				stopInternal();
				if(mCallback != null){
					mCallback.onCamShareStreamException(targetId);
				}
			}
		}
	}
	
	/**
	 * 释放Camera资源
	 */
	private void unbindCamera(){
		 try {
	    	  if(mCamera != null){
	    		  mCamera.stopPreview();
	    		  mCamera.setPreviewCallbackWithBuffer(null);
	    		  mCamera.release();
	    		  mCamera = null;
	    	  }
	      } catch (RuntimeException e) {
				Log.i(TAG, "Camera stopCapture RuntimeException: " +  e.getMessage());
				e.printStackTrace();
	      }catch (Exception e){
				Log.i(TAG, "Camera stopCapture exception: " +  e.getMessage());
				e.printStackTrace();
	      }
	}
	
	/**
	 * 开始采集视频流
	 */
	public void startCapture(SurfaceHolder holder){
		if(!isClientStop){
			if(mCamera != null){
				stopCapture();
			}
			mHolder = holder;
			//Camera为空时等待绑定成功启动
			if(mCamera != null){
				startCaptureInternal();
			}
		}
	}
	
	/**
	 * 停止帧上传
	 */
	public void stopCapture(){
		mHandler.removeMessages(CAMSHARE_MEDIA_CONNECT_CHECK);
		 try {
	    	  if(mCamera != null){
	    		  mCamera.stopPreview();
	    		  mCamera.setPreviewCallbackWithBuffer(null);
	    	  }
	      } catch (RuntimeException e) {
				Log.i(TAG, "Camera stopCapture RuntimeException: " +  e.getMessage());
				e.printStackTrace();
	      }catch (Exception e){
				Log.i(TAG, "Camera stopCapture exception: " +  e.getMessage());
				e.printStackTrace();
	      }
	}
	
	/**
	 * 内部开始视频捕捉上传
	 */
	private void startCaptureInternal(){
		Size previewSize = mCamera.getParameters().getPreviewSize();
		PixelFormat pixelFormat = new PixelFormat();
		PixelFormat.getPixelFormatInfo(PIXEL_FORMAT, pixelFormat);
		int bufSize = previewSize.width * previewSize.height * pixelFormat.bitsPerPixel / 8;
        byte[] buffer = null;
        for (int i = 0; i < numCaptureBuffers; i++) {
            buffer = new byte[bufSize];
            mCamera.addCallbackBuffer(buffer);
        }
        try {
            mCamera.setPreviewCallbackWithBuffer(this);
            mCamera.setPreviewDisplay(mHolder);
            mCamera.startPreview();
            mHandler.sendEmptyMessageDelayed(CAMSHARE_MEDIA_CONNECT_CHECK, STREAM_CONNECT_CHECK_DUARATION);
		} catch (IOException e) {
			e.printStackTrace();
			stopInternal();
			if(mCallback != null){
				mCallback.onCamShareStreamException(targetId);
			}
		}
	}
	

	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {
		//Camera 采集帧回调，调用发送
		Log.i(TAG, "onPreviewFrame Callback");
		int width	= camera.getParameters().getPreviewSize().width;
		int height	= camera.getParameters().getPreviewSize().height;
		CameraInfo info = new CameraInfo();
		Camera.getCameraInfo(mCameraId, info);
		client.SendVideoData(data, data.length, System.currentTimeMillis(), width, height, info.orientation);
		mCamera.addCallbackBuffer(data);
	}
	
	/**
	 * 获取最合适的Preview size(大于设定大小，且最小buffer)
	 */
	public Size getBestSuppportPreviewSize(Camera camera){
		Size bestSize = null;
		int minLenght = CAMERA_PREVIEW_WIDTH > CAMERA_PREVIEW_HEIGHT ? CAMERA_PREVIEW_WIDTH : CAMERA_PREVIEW_HEIGHT;
		Camera.Parameters parameters = mCamera.getParameters();
		List<Size> previewSizes = parameters.getSupportedPreviewSizes();
		//取最接近的大小，且最小的
		if(previewSizes.size() > 0){
			for(Size size : previewSizes){
				if(size.width > minLenght
						&& size.height > minLenght){
					if(bestSize == null){
						bestSize = size;
					}else{
						if(bestSize.width > size.width 
								|| bestSize.height > size.height){
							bestSize = size;
						}
					}
				}
			}
		}
		return bestSize;
	}
	
	/**
	 * 获取当前手机支持的预览格式列表
	 * @param camera
	 * @return
	 */
	private int[] getCameraPreviewFormats(Camera camera){
		List<Integer> previewForamts = camera.getParameters().getSupportedPreviewFormats();
		int[] previewFormatArray = new int[previewForamts.size()];
		for(int i=0; i < previewForamts.size(); i++){
			previewFormatArray[i] = previewForamts.get(i);
		}
		return previewFormatArray;
	}
	
	/**
	 * 获取最合适的帧采集率
	 * @return
	 */
	private int getBestCameraPreviewFrameRate(Camera camera){
		int bestFrameRate = 0;
		List<Integer> previewFrameRate = camera.getParameters().getSupportedPreviewFrameRates();
		for(Integer frameRate : previewFrameRate){
			if(bestFrameRate == 0){
				bestFrameRate = frameRate;
			}else{
				if(frameRate >= CAMERA_FRAME_RATE 
						&& frameRate < bestFrameRate){
					bestFrameRate = frameRate;
				}
			}
		}
		return bestFrameRate;
	}

}
