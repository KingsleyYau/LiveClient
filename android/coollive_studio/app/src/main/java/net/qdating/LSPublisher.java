package net.qdating;

import java.io.File;
import java.util.Arrays;

import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.view.SurfaceView;
import net.qdating.player.LSVideoPlayer;
import net.qdating.publisher.ILSAudioRecorderCallback;
import net.qdating.publisher.ILSPublisherCallback;
import net.qdating.publisher.ILSPublisherStatusCallback;
import net.qdating.publisher.ILSVideoCaptureCallback;
import net.qdating.publisher.LSAudioRecorder;
import net.qdating.publisher.LSPublisherJni;
import net.qdating.publisher.LSVideoCapture;
import net.qdating.publisher.LSVideoEncoder;
import net.qdating.utils.Log;

/**
 * RTMP流推流器
 * @author max
 * @version 1.0.0
 */
public class LSPublisher implements ILSPublisherCallback, ILSVideoCaptureCallback, ILSAudioRecorderCallback {
	/**
	 * RTMP模块
	 */
	private LSPublisherJni publisher = new LSPublisherJni();
	/**
	 * 视频采集
	 */
	private LSVideoCapture videoCapture = new LSVideoCapture();
	/**
	 * 音频录制
	 */
	private LSAudioRecorder audioRecorder = new LSAudioRecorder();
	/**
	 * 视频解码器
	 */
	private LSVideoEncoder videoEncoder = new LSVideoEncoder();
	/**
	 * 视频播放器
	 */
	private LSVideoPlayer videoPlayer = new LSVideoPlayer();
	/**
	 * 状态回调接口
	 */
	private ILSPublisherStatusCallback statusCallback;
	/**
	 * 主线程消息处理
	 */
	private Handler handler = new Handler();
	/**
	 * 是否已经启动
	 */
	private boolean isRuning = false;
	/**
	 * 是否静音
	 */
	private boolean isMute = false;
	/**
	 * 流推送地址
	 */
	private String url;
	/**
	 * H264录制绝对路径
	 */
	private String recordH264FilePath;
	/**
	 * AAC录制绝对路径
	 */
	private String recordAACFilePath; 
	
	/***
	 * 初始化流推送器
	 * @param surfaceView	显示界面
	 * @param statusCallback 状态回调接口
	 * @return true:成功/false:失败
	 */
	public boolean init(SurfaceView surfaceView, int rotation, ILSPublisherStatusCallback statusCallback) {
		boolean bFlag = true;
		
		File path = Environment.getExternalStorageDirectory();
		String filePath = path.getAbsolutePath() + "/" + LSConfig.TAG + "/";
		Log.initFileLog(filePath);
		Log.setWriteFileLog(true);
		
		// 初始化状态回调
		this.statusCallback = statusCallback;
		
		// 初始化视频播放器
//		videoPlayer.init(surfaceView.getHolder(), LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
		
		// 初始化推流器
		if( bFlag ) {
			bFlag = publisher.Create(this, videoEncoder, videoPlayer);
		}
		
		// 初始化视频采集
		if( bFlag ) {
			bFlag = videoCapture.init(surfaceView.getHolder(), this, rotation);
		}
		
		// 初始化音频录制
		if( bFlag ) {
			bFlag = audioRecorder.init(this);
		}
		
		if( bFlag ) {
			handler = new Handler() {
				@Override
				public void handleMessage(Message msg) {      
					Log.i(LSConfig.TAG, String.format("LSPublisher::handleMessage( "
							+ "[Connect], "
							+ "isRuning : %s "
							+ ")", 
							isRuning?"true":"false"
							)
							);
					synchronized (this) {
						if( isRuning ) {
							// 非手动停止, 准备重连
							boolean bFlag = start();
							if( !bFlag ) {
								// 重连失败, 1秒后重连
								Log.i(LSConfig.TAG, 
										String.format("LSPublisher::handleMessage( "
										+ "[Connect Fail, Reconnect After %d Seconds] ",
										LSConfig.RECONNECT_SECOND
										)
										);
								handler.sendEmptyMessageDelayed(0, LSConfig.RECONNECT_SECOND);
							}
						}
					}
				}
			};
		}
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::init( "
				+ "[%s] "
				+ ")", 
				bFlag?"Suucess":"Fail"
				)
				);
		
		return bFlag;
	}
	
	/***
	 * 反初始化流推送器
	 */
	public void uninit() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::uninit( "
				+ ")"
				)
				);
		
		// 销毁推流器
		publisher.Destroy();
		// 销毁视频采集
		videoCapture.uninit();
		// 销毁音频录制
		audioRecorder.uninit();
		// 销毁视频播放器
		videoPlayer.uninit();
	}
	
	/**
	 * 开始流推送
	 * @see	主线程调用
	 * @param url					流推送地址
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return true:成功/false:失败
	 */
	public boolean publisherUrl(String url, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		
		Log.d(LSConfig.TAG, String.format("LSPublisher::publisherUrl( "
				+ "url : %s "
				+ ")",
				url
				)
				);

	    synchronized (this) {
	    	if( !isRuning ) {
	    		isRuning = true;
	    		
	    	    this.url = url;
	    	    this.recordH264FilePath = recordH264FilePath;
	    	    this.recordAACFilePath = recordAACFilePath;
	    	    
	    		// 开始[视频采集/音频录制]
	    	    bFlag = videoCapture.start() && audioRecorder.start();
	    	    if( bFlag ) {
		    	    // 开始消息队列
		    		handler.post(new Runnable() {
		    			@Override
		    			public void run() {
		    				// TODO Auto-generated method stub
		    				handler.sendEmptyMessage(0);
		    			}
		    		});
	    	    } else {
	    	    	isRuning = false;
	    	    	videoCapture.stop();
	    	    	audioRecorder.stop();
	    	    }
	    	}
	    }
	    
		Log.i(LSConfig.TAG, String.format("LSPublisher::publisherUrl( "
				+ "[%s], "
				+ "url : %s "
				+ ")",
				bFlag?"Success":"Fail",
				url
				)
				);
		
		return bFlag;
	}
	
	/**
	 * 停止推送
	 * @see	主线程调用
	 */
	public void stop() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::stop()"));
		
		synchronized(this) {
			isRuning = false;
		}
		
		// 取消事件
		handler.removeMessages(0);
		
    	// 停止流推送器
		if( publisher != null ) {
			publisher.Stop();
		}
		// 停止视频采集
		if( videoCapture != null ) {
			videoCapture.stop();
		}
		// 停止音频录制
		if( audioRecorder != null ) {
			audioRecorder.stop();
		}
    	
		Log.i(LSConfig.TAG, String.format("LSPublisher::stop( [Success] )"));
	}

	public boolean getMute() {
		return isMute;
	}
	
	public void setMute(boolean isMute) {
		this.isMute = isMute;
	}
	
	/**
	 * 开始推送
	 * @see	主线程调用
	 * @return 成功失败
	 */
	private boolean start() {
		boolean bFlag = true;
		
		Log.d(LSConfig.TAG, String.format("LSPublisher::start( "
				+ "url : %s "
				+ ")",
				url
				)
				);
		
    	bFlag = publisher.PublishUrl(url, recordH264FilePath, recordAACFilePath);
		if( !bFlag ) {
			publisher.Stop();
		}
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::start( "
				+ "[%s], "
				+ "url : %s "
				+ ")",
				bFlag?"Success":"Fail",
				url
				)
				);
		
		return bFlag;
	}
	
	@Override
	public void onDisconnect(LSPublisherJni publisher) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPublisher::onDisconnect()"));
		
		// 通知外部监听
		if( statusCallback != null ) {
			statusCallback.onDisconnect(this);
		}

		synchronized (this) {
			if( isRuning ) {
				// 非手动断开, 发送重连消息
				handler.sendEmptyMessageDelayed(0, LSConfig.RECONNECT_SECOND);
			}
		}
	}

	@Override
	public void onVideoCapture(byte[] data, int size, int width, int height) {
		// TODO Auto-generated method stub
		publisher.PushVideoFrame(data, size, width, height);
	}

	@Override
	public void onAudioRecord(byte[] data, int size) {
		// TODO Auto-generated method stub
		if( isMute ) {
			Arrays.fill(data, (byte)0);
		}
		publisher.PushAudioFrame(data, size);
	}

	@Override
	public void onChangeRotation(int rotation) {
		// TODO Auto-generated method stub
		Log.d(LSConfig.TAG, String.format("LSPublisher::onChangeRotation( rotation : %d )", rotation));
		
		publisher.ChangeVideoRotate(rotation);
	}
	
}
