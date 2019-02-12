package net.qdating;

import java.io.File;

import android.opengl.GLSurfaceView;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import net.qdating.LSConfig.DecodeMode;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageFilter;
import net.qdating.player.ILSPlayerCallback;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSAudioPlayer;
import net.qdating.player.LSPlayerJni;
import net.qdating.player.LSVideoHardDecoder;
import net.qdating.player.LSVideoHardPlayer;
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
	 * 视频硬解码器
	 */
	private LSVideoHardDecoder videoHardDecoder = new LSVideoHardDecoder();
	/**
	 * 视频硬渲染器
	 */
	private LSVideoHardPlayer videoHardPlayer = new LSVideoHardPlayer();
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
	/**
	 * 是否使用硬解码
	 */
	private boolean useHardDecoder = false;
	
	// 消息定义
	private final int MSG_CONNECT = 0;
	private final int MSG_DISCONNECT = 1;

	/**
	 * 正在断开
	 */
	private boolean isDisconnecting = false;

	/***
	 * 初始化流播放器
	 * @param surfaceView	显示界面
	 * @param fillMode 渲染模式
	 * @param statusCallback 状态回调接口
	 * @return true:成功/false:失败
	 */
	public boolean init(GLSurfaceView surfaceView, FillMode fillMode, ILSPlayerStatusCallback statusCallback) {
		boolean bFlag = true;

		if( LSConfig.LOGDIR != null && LSConfig.LOGDIR.length() > 0 ) {
			File path = Environment.getExternalStorageDirectory();
			String filePath = path.getAbsolutePath() + "/" + LSConfig.LOGDIR + "/";
			Log.initFileLog(filePath);
			Log.setWriteFileLog(true);
			LSPlayerJni.SetLogDir(filePath);
			LSPlayerJni.SetJniLogLevel(LSConfig.LOG_LEVEL);
		}
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::init( this : 0x%x )", hashCode()));
		
		this.statusCallback = statusCallback;
		
		if( LSConfig.decodeMode == DecodeMode.DecodeModeAuto ) {
			if( LSVideoHardDecoder.supportHardDecoder() ) {
				// 判断可以使用硬解码
				useHardDecoder = true;
			}
		} else if( LSConfig.decodeMode == DecodeMode.DecodeModeHard ) {
			// 强制使用硬解码
			useHardDecoder = true;
		}
		
		if( useHardDecoder ) {
			// 初始化视频硬渲染器
			videoHardPlayer.init(surfaceView, fillMode);
		} else {
			// 初始化视频播放器
			videoPlayer.init(surfaceView, fillMode);
		}
		
		if( bFlag ) {
			// 初始化播放器
			bFlag = player.Create(this, useHardDecoder, videoPlayer, audioPlayer, videoHardDecoder, videoHardPlayer);
			// 断线重连处理
			handler = new Handler() {
				@Override
				public void handleMessage(Message msg) {      
					switch (msg.what) {
					case MSG_CONNECT:{
						Log.i(LSConfig.TAG,
								String.format("LSPlayer::handleMessage( "
												+ "this : 0x%x, "
												+ "[MSG_CONNECT], "
												+ "isRuning : %s "
												+ ")",
										(msg.obj!=null)?msg.obj.hashCode():0,
										isRuning?"true":"false"
								)
						);
						synchronized (msg.obj) {
							if( isRuning ) {
								// 非手动停止, 准备重连
								player.Stop();
								start();
							}
						}
					}break;
					case MSG_DISCONNECT:{
						// 主动断开流
						Log.i(LSConfig.TAG,
								String.format("LSPlayer::handleMessage( "
												+ "this : 0x%x, "
												+ "[Disconnect player] "
												+ ")",
										(msg.obj!=null)?msg.obj.hashCode():0
								)
						);

				    	player.Stop();
						isDisconnecting = false;

					}break;
					default:
						break;
					}
				}
			};
		}
		
		if( bFlag ) {
			Log.i(LSConfig.TAG, String.format("LSPlayer::init( "
							+ "this : 0x%x, "
							+ "[Success with %s] "
							+ ")",
					hashCode(),
					useHardDecoder?"hard decoder":"soft decoder"
					)
					);
		} else {
			Log.e(LSConfig.TAG, String.format("LSPlayer::init( "
					+ "this : 0x%x, "
					+ "[Fail] "
					+ ")",
					hashCode()
					)
					);
		}
		
		return bFlag;
	}
	
	/***
	 * 反初始化流播放器
	 */
	public void uninit() {
		Log.i(LSConfig.TAG, String.format("LSPlayer::uninit( "
				+ "this : 0x%x "
				+ ")",
				hashCode()
				)
				);
		
		// 销毁播放器
		player.Destroy();
		
		if( useHardDecoder ) {
			// 销毁视频硬渲染器
			videoHardPlayer.uninit();
		} else {
			// 销毁视渲染放器
			videoPlayer.uninit();
		}
	}

	/**
	 * 设置自定义滤镜
	 * @param customFilter 自定义滤镜
	 */
	public void setCustomFilter(LSImageFilter customFilter) {
		if( useHardDecoder ) {
			videoHardPlayer.setCustomFilter(customFilter);
		} else {
			videoPlayer.setCustomFilter(customFilter);
		}
	}

	/**
	 * 获取自定义滤镜
	 * @return 自定义滤镜
	 */
	public LSImageFilter getCustomFilter() {
		LSImageFilter filter = null;
		if( useHardDecoder ) {
			filter = videoHardPlayer.getCustomFilter();
		} else {
			filter = videoPlayer.getCustomFilter();
		}
		return filter;
	}

	/***
	 * 开始流播放
	 * @param url					流播放地址
	 * @param recordFilePath		FLV文件录制绝对路径
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return true:成功/false:失败
	 */
	public boolean playUrl(String url, String recordFilePath, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		
		Log.d(LSConfig.TAG, String.format("LSPlayer::playUrl( "
				+ "this : 0x%x, "
				+ "url : %s "
				+ ")",
				hashCode(),
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
						Message msg = Message.obtain();
						msg.what = MSG_CONNECT;
						msg.obj = this;
						handler.sendMessage(msg);
	    			}
	    		});
	    	}
	    }
	    
		Log.i(LSConfig.TAG, String.format("LSPlayer::playUrl( "
				+ "this : 0x%x, "
				+ "[%s], "
				+ "url : %s "
				+ ")",
				hashCode(),
				bFlag?"Success":"Fail",
				url
				)
				);
		
		return bFlag;
	}
	
	/***
	 * 停止播放
	 */
	public void stop() {
		Log.d(LSConfig.TAG, String.format("LSPlayer::stop( "
				+ "this : 0x%x "
				+ ")",
				hashCode()
				));
		
		synchronized(this) {
			isRuning = false;
		}
		
		// 取消事件
		handler.removeMessages(MSG_CONNECT);
    	// 停止流播放器
    	player.Stop();
		// 停止音频播放
		audioPlayer.stop();
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::stop( "
				+ "this : 0x%x, "
				+ "[Success] )",
				hashCode()
				));
	}

	/**
	 * 开始播放
	 * @return 成功失败
	 */
	private boolean start() {
		boolean bFlag = false;
		
		Log.d(LSConfig.TAG, String.format("LSPlayer::start( "
				+ "this : 0x%x, "
				+ "url : %s "
				+ ")",
				hashCode(),
				url
				)
				);
		
    	bFlag = player.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
		if( !bFlag ) {
			player.Stop();
		}
		
		Log.i(LSConfig.TAG, String.format("LSPlayer::start( "
				+ "this : 0x%x, "
				+ "[%s], "
				+ "url : %s "
				+ ")",
				hashCode(),
				bFlag?"Success":"Fail",
				url
				)
				);
		
		return bFlag;
	}

	/***
	 * 当前是否静音
	 * @return
	 */
	public boolean getMute() {
		return audioPlayer.getMute();
	}

	/***
	 * 设置是否静音
	 * @param isMute 是否静音
	 */
	public void setMute(boolean isMute) {
		Log.d(LSConfig.TAG, String.format("LSPlayer::setMute( this : 0x%x, %s )", hashCode(), Boolean.toString(isMute)));
		audioPlayer.setMute(isMute);
	}

	@Override
	public void onConnect(LSPlayerJni player) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPlayer::onConnect( "
				+ "this : 0x%x "
				+ ")",
				hashCode()
				));
		
		// 通知外部监听
		if( statusCallback != null ) {
			statusCallback.onConnect(this);
		}
	}
	
	@Override
	public void onDisconnect(LSPlayerJni player) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPlayer::onDisconnect( "
				+ "this : 0x%x "
				+ ")",
				hashCode()
				));
		
		// 通知外部监听
		if( statusCallback != null ) {
			statusCallback.onDisconnect(this);
		}

		synchronized (this) {
			if( isRuning ) {
				// 非手动断开, 发送重连消息
				Message msg = Message.obtain();
				msg.what = MSG_CONNECT;
				msg.obj = this;
				handler.sendMessageDelayed(msg, LSConfig.RECONNECT_SECOND);
			}
		}
	}

	@Override
	public void onPlayerOnDelayMaxTime(LSPlayerJni player) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPlayer::onPlayerOnDelayMaxTime( "
				+ "this : 0x%x "
				+ ")",
				hashCode()
				));
		
		synchronized (this) {
			if( isRuning && !isDisconnecting ) {
				// 断开连接
				isDisconnecting = true;

				Message msg = Message.obtain();
				msg.what = MSG_DISCONNECT;
				msg.obj = this;
				handler.sendMessageDelayed(msg, 0);
			}
		}
	}

}
