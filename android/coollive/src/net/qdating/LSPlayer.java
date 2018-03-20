package net.qdating;

import java.io.File;

import android.opengl.GLSurfaceView;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import net.qdating.LSConfig.FillMode;
import net.qdating.player.ILSPlayerCallback;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSAudioPlayer;
import net.qdating.player.LSPlayerJni;
import net.qdating.player.LSVideoDecoder;
import net.qdating.player.LSVideoPlayer;
import net.qdating.utils.Log;

/**
 * RTMP流播放器
 * @author max
 */
public class LSPlayer implements ILSPlayerCallback {
	/**
	 * RTMP模块
	 */
	private LSPlayerJni player = new LSPlayerJni();
	/**
	 * 视频播放器
	 */
	private LSVideoPlayer videoPlayer = new LSVideoPlayer();
	/**
	 * 音频播放器
	 */
	private LSAudioPlayer audioPlayer = new LSAudioPlayer();
	/**
	 * 视频解码器
	 */
	private LSVideoDecoder videoDecoder = new LSVideoDecoder();
	/**
	 * 状态回调接口
	 */
	private ILSPlayerStatusCallback statusCallback;
	/**
	 * 主线程消息处理
	 */
	private Handler handler = new Handler();
	/**
	 * 是否已经启动
	 */
	private boolean isRuning = false;
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
	 * @return true:成功/false:失败
	 */
	public boolean init(GLSurfaceView surfaceView, FillMode fillMode, ILSPlayerStatusCallback statusCallback) {
		boolean bFlag = false;
		
		File path = Environment.getExternalStorageDirectory();
		String filePath = path.getAbsolutePath() + "/" + LSConfig.TAG + "/";
		Log.initFileLog(filePath);
		Log.setWriteFileLog(true);
		
		this.statusCallback = statusCallback;
		
//		// 初始化硬解码器
//		videoDecoder.init();
		
		// 初始化视频播放器
		videoPlayer.init(surfaceView, fillMode);
		
		// 初始化播放器
		bFlag = player.Create(this, videoPlayer, audioPlayer, videoDecoder);
		
		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {      
				Log.i(LSConfig.TAG, String.format("LSPlayer::handleMessage( "
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
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::init( "
				+ "[%s] "
				+ ")", 
				bFlag?"Success":"Fail"
				)
				);
		
		return bFlag;
	}
	
	/**
	 * 反初始化流播放器
	 */
	public void uninit() {
		Log.i(LSConfig.TAG, String.format("LSPlayer::uninit( "
				+ ")"
				)
				);
		// 销毁播放器
		player.Destroy();
//		// 销毁解码器
//		videoDecoder.uninit();
		// 销毁视频播放器
		videoPlayer.uninit();
	}
	
	/**
	 * 开始流播放
	 * @see	主线程调用
	 * @param url					流播放地址
	 * @param recordFilePath		FLV文件录制绝对路径
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return true:成功/false:失败
	 */
	public boolean playUrl(String url, String recordFilePath, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		
		Log.d(LSConfig.TAG, String.format("LSPlayer::playUrl( "
				+ "url : %s "
				+ ")",
				url
				)
				);

	    synchronized (this) {
	    	if( !isRuning ) {
	    		isRuning = true;
	    		
	    	    this.url = url;
	    	    this.recordFilePath = recordFilePath;
	    	    this.recordH264FilePath = recordH264FilePath;
	    	    this.recordAACFilePath = recordAACFilePath;
	    	    
	    	    bFlag = true;
	    	    
	    	    // 开始消息队列
	    		handler.post(new Runnable() {
	    			@Override
	    			public void run() {
	    				// TODO Auto-generated method stub
	    				handler.sendEmptyMessage(0);
	    			}
	    		});
	    	}
	    }
	    
		Log.i(LSConfig.TAG, String.format("LSPlayer::playUrl( "
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
	 * 停止播放
	 * @see	主线程调用
	 */
	public void stop() {
		Log.d(LSConfig.TAG, String.format("LSPlayer::stop()"));
		
		synchronized(this) {
			isRuning = false;
		}
		
		// 取消事件
		handler.removeMessages(0);
    	// 停止流播放器
    	player.Stop();
		// 停止音频播放
		audioPlayer.stop();
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::stop( [Success] )"));
	}

	/**
	 * 开始播放
	 * @see	主线程调用
	 * @return 成功失败
	 */
	private boolean start() {
		boolean bFlag = true;
		
		Log.d(LSConfig.TAG, String.format("LSPlayer::start( "
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
	public void onDisconnect(LSPlayerJni player) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPlayer::onDisconnect()"));
		
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
}
