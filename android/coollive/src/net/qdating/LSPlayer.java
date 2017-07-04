package net.qdating;

import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.SurfaceView;

/**
 * RTMP流播放器
 * @author max
 * @version 1.0.0
 */
public class LSPlayer implements ILSPlayerCallback {
	/**
	 * RTMP模块
	 */
	private LSPlayerJni player = new LSPlayerJni();
	/**
	 * 视频播放器
	 */
	private LSVideoPlayer videoPlayer;
//	private LSVideoGLPlayer videoGLPlayer;
	/**
	 * 音频播放器
	 */
	private LSAudioPlayer audioPlayer;
	/**
	 * 视频解码器
	 */
	private LSVideoDecoder videoDecoder;
	/**
	 * 状态回调接口
	 */
	private ILSPlayerStatusCallback statusCallback;
	/**
	 * 主线程消息处理
	 */
	private Handler handler = new Handler();
	/**
	 * 是否正在播放
	 */
	private boolean running = false;
	/**
	 * 是否已经启动
	 */
	private boolean start = false;
	/**
	 * 流播放地址
	 */
	private String url;
	/**
	 * FLV文件录制绝对路径
	 */
	private String recordFilePath;
	/**
	 * H264录制绝对路径
	 */
	private String recordH264FilePath;
	/**
	 * AAC录制绝对路径
	 */
	private String recordAACFilePath; 
	
	/***
	 * 初始化流播放器
	 * @param surfaceView	显示界面
	 * @param statusCallback 状态回调接口
	 * @return
	 */
	public boolean init(SurfaceView surfaceView, ILSPlayerStatusCallback statusCallback) {
		boolean bFlag = false;
		
		this.statusCallback = statusCallback;
		
		// 初始化视频播放器
		videoPlayer = new LSVideoPlayer();
		videoPlayer.init(surfaceView.getHolder(), LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
		// GL渲染
//		videoGLPlayer = new LSVideoGLPlayer();
//		videoGLPlayer.init((GLSurfaceView)surfaceView);
		
		// 初始化音频播放器
		audioPlayer = new LSAudioPlayer();
		
		// 初始化硬解码器
		videoDecoder = new LSVideoDecoder();
		
		// 初始化播放器
//		player.Create(this, videoPlayer, audioPlayer, videoDecoder);
		player.Create(this, videoPlayer, audioPlayer, videoDecoder);
		
		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {      
				Log.i(LSConfig.TAG, String.format("LSPlayer::handleMessage( "
						+ "[Connect], "
						+ "start : %s "
						+ ")", 
						start?"true":"false"
						)
						);
				synchronized (this) {
					if( start ) {
						// 非手动停止, 准备重连
						boolean bFlag = start();
						if( !bFlag ) {
							// 重连失败, 1秒后重连
							Log.i(LSConfig.TAG, String.format("LSPlayer::handleMessage( "
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
		
		return bFlag;
	}
	
	/**
	 * 开始流播放
	 * @see	主线程调用
	 * @param url					流播放地址
	 * @param recordFilePath		FLV文件录制绝对路径
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return
	 */
	public boolean playUrl(String url, String recordFilePath, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = true;
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::playUrl( "
				+ "url : %s "
				+ ")",
				url
				)
				);
		
	    this.url = url;
	    this.recordFilePath = recordFilePath;
	    this.recordH264FilePath = recordH264FilePath;
	    this.recordAACFilePath = recordAACFilePath;

	    stop();
	    
	    synchronized (this) {
	    	start = true;
	    }
	    
	    // 开始消息队列
		handler.post(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				handler.sendEmptyMessage(0);
			}
		});
	    
		Log.i(LSConfig.TAG, String.format("LSPlayer::playUrl( "
				+ "[Finish], "
				+ "url : %s, "
				+ "bFlag : %s "
				+ ")",
				url,
				bFlag?"true":"false"
				)
				);
		
		return bFlag;
	}
	
	/**
	 * 停止播放
	 * @see	主线程调用
	 */
	public void stop() {
		Log.i("livestream", String.format("LSPlayer::stop()"));
		
		synchronized(this) {
			start = false;
		}
		
    	// 停止流播放器
    	player.Stop();
		// 停止音频播放
		audioPlayer.stop();
		
		Log.i("livestream", String.format("LSPlayer::stop( [Finish] )"));
	}

	/**
	 * 开始播放
	 * @see	主线程调用
	 * @return 成功失败
	 */
	private boolean start() {
		boolean bFlag = true;
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::start( "
				+ "url : %s "
				+ ")",
				url
				)
				);
		
    	bFlag = player.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
		if( !bFlag ) {
			player.Stop();
		}
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::start( "
				+ "[Finish], "
				+ "url : %s, "
				+ "bFlag : %s "
				+ ")",
				url,
				bFlag?"true":"false"
				)
				);
		
		return bFlag;
	}
	
	@Override
	public void onDisconnect(LSPlayerJni player) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPlayer::onDisconnect()"));
		
		// 通知外部监听
		if( statusCallback != null ) {
			statusCallback.onDisconnect(this);
		}

		synchronized (this) {
			if( start ) {
				// 非手动断开, 发送重连消息
				handler.sendEmptyMessage(0);
			}
		}

	}
}
