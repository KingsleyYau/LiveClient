package net.qdating;

import java.io.File;
import java.util.Arrays;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import net.qdating.LSConfig.FillMode;
import net.qdating.publisher.ILSAudioRecorderCallback;
import net.qdating.publisher.ILSPublisherCallback;
import net.qdating.publisher.ILSPublisherStatusCallback;
import net.qdating.publisher.ILSVideoCaptureCallback;
import net.qdating.publisher.LSAudioRecorder;
import net.qdating.publisher.LSPublisherJni;
import net.qdating.publisher.LSVideoCapture;
import net.qdating.publisher.LSVideoHardEncoder;
import net.qdating.utils.Log;

/**
 * RTMP流推流器
 * @author max
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
	private LSVideoHardEncoder videoHardEncoder = new LSVideoHardEncoder();
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
    /**
     * 是否使用硬编码
     */
    private boolean useHardEncoder = false;

	// 消息定义
	private final int MSG_CONNECT = 0;

	/***
	 * 初始化流推送器
	 * @param surfaceView	显示界面
	 * @param statusCallback 状态回调接口
	 * @return true:成功/false:失败
	 */
	public boolean init(Context context, GLSurfaceView surfaceView, int rotation, FillMode fillMode, ILSPublisherStatusCallback statusCallback) {
		boolean bFlag = true;
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::init( this : 0x%x )", hashCode()));
		
		File path = Environment.getExternalStorageDirectory();
		String filePath = path.getAbsolutePath() + "/" + LSConfig.TAG + "/";
		Log.initFileLog(filePath);
		Log.setWriteFileLog(true);
		
		// 初始化状态回调
		this.statusCallback = statusCallback;

        if( LSConfig.encodeDecodeMode == LSConfig.EncodeDecodeMode.EncodeDecodeModeAuto ) {
            if( LSVideoHardEncoder.supportHardEncoder() ) {
                // 判断可以使用硬解码
                useHardEncoder = true;
            }
        } else if( LSConfig.encodeDecodeMode == LSConfig.EncodeDecodeMode.EncodeDecodeModeHard ) {
            // 强制使用硬解码
            useHardEncoder = true;
        }

		// 初始化推流器
		if( bFlag ) {
			bFlag = publisher.Create(this, useHardEncoder, videoHardEncoder);
		}
		
		// 初始化视频采集
		if( bFlag ) {
			bFlag = videoCapture.init(surfaceView, this, rotation, fillMode);
		}
		
		// 初始化音频录制
		if( bFlag ) {
			bFlag = audioRecorder.init(this);
		}

		if( bFlag ) {
			handler = new Handler() {
				@Override
				public void handleMessage(Message msg) {
					switch (msg.what) {
						case MSG_CONNECT:{
							Log.i(LSConfig.TAG,
									String.format("LSPublisher::handleMessage( "
													+ "this : 0x%x, "
													+ "[Connect player], "
													+ "isRuning : %s "
													+ ")",
											hashCode(),
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
																+ "this : 0x%x"
																+ "[Connect fail, reconnect after %d seconds] "
																+ ")",
														(msg.obj!=null)?msg.obj.hashCode():0,
														LSConfig.RECONNECT_SECOND
												)
										);
										handler.sendMessageDelayed(msg, LSConfig.RECONNECT_SECOND);
									}
								}
							}
						}break;
						default:
							break;
					}
				}
			};
		}

		if( bFlag ) {
			Log.i(LSConfig.TAG, String.format("LSPublisher::init( "
					+ "this : 0x%x, "
					+ "[Success] "
					+ ")",
					hashCode()
					)
					);
		} else {
			Log.e(LSConfig.TAG, String.format("LSPublisher::init( "
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
	 * 反初始化流推送器
	 */
	public void uninit() {
		Log.i(LSConfig.TAG,
				String.format("LSPublisher::uninit( "
						+ "this : 0x%x "
						+ ")",
						hashCode()
				)
		);
		
		// 销毁推流器
		publisher.Destroy();
		// 销毁视频采集
		videoCapture.uninit();
		// 销毁音频录制
		audioRecorder.uninit();
		
	}
	
	/**
	 * 开始流推送
	 * @param url					流推送地址
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return true:成功/false:失败
	 */
	public boolean publisherUrl(String url, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::publisherUrl( this : 0x%x, url : %s )", hashCode(), url));

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
							Message msg = Message.obtain();
							msg.what = MSG_CONNECT;
							msg.obj = this;
							handler.sendMessage(msg);
		    			}
		    		});
	    	    } else {
	    	    	isRuning = false;
	    	    	videoCapture.stop();
	    	    	audioRecorder.stop();
	    	    }
	    	}
	    }
	    
	    if( !bFlag ) {
			Log.e(LSConfig.TAG, String.format("LSPublisher::publisherUrl( this : 0x%x, [Fail], url : %s )", hashCode(), url));
	    }
		
		return bFlag;
	}
	
	/**
	 * 停止推送
	 */
	public void stop() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::stop( this : 0x%x )", hashCode()));
		
		synchronized(this) {
			isRuning = false;
		}
		
		// 取消事件
		handler.removeMessages(MSG_CONNECT);
		
		// 停止视频采集
		if( videoCapture != null ) {
			videoCapture.stop();
		}
		// 停止音频录制
		if( audioRecorder != null ) {
			audioRecorder.stop();
		}
		
    	// 停止流推送器
		if( publisher != null ) {
			publisher.Stop();
		}
	}

	/**
	 * 当前是否静音
	 * @return
	 */
	public boolean getMute() {
		return isMute;
	}
	
	/**
	 * 设置是否静音
	 * @param isMute 是否静音
	 */
	public void setMute(boolean isMute) {
		Log.d(LSConfig.TAG, String.format("LSPublisher::setMute( this : 0x%x, %s )", hashCode(), Boolean.toString(isMute)));
		this.isMute = isMute;
	}
	
	/**
	 * 切换前后摄像头
	 */
	public void rotateCamera() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::rotateCamera( this : 0x%x )", hashCode()));
		publisher.PausePushVideo();
		videoCapture.rotateCamera();
		publisher.ResumePushVideo();
	}
	
	public void startPreview() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::startPreview( this : 0x%x )", hashCode()));
		videoCapture.start();
		publisher.ResumePushVideo();
	}
	
	public void stopPreview() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::stopPreview( this : 0x%x )", hashCode()));
		publisher.PausePushVideo();
		videoCapture.stop();
	}
	
	/**
	 * 开始推送
	 * @return 成功失败
	 */
	private boolean start() {
		boolean bFlag = false;
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::start( this : 0x%x, url : %s )", hashCode(), url));
		
    	bFlag = publisher.PublishUrl(url, recordH264FilePath, recordAACFilePath);
		if( !bFlag ) {
			publisher.Stop();
		}
		
		if( !bFlag ) {
			Log.e(LSConfig.TAG, String.format("LSPublisher::start( this : 0x%x, [Fail], url : %s )", hashCode(), url));
		}
		
		return bFlag;
	}
	

	@Override
	public void onConnect(LSPublisherJni publisher) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPublisher::onConnect( this : 0x%x )", hashCode()));
		
		// 通知外部监听
		if( statusCallback != null ) {
			statusCallback.onConnect(this);
		}
	}
	
	@Override
	public void onDisconnect(LSPublisherJni publisher) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPublisher::onDisconnect( this : 0x%x )", hashCode()));
		
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
	public void onVideoCapture(byte[] data, int size, int width, int height) {
		// TODO Auto-generated method stub
		// 不需要准, 不要锁
    	if( isRuning ) {
    		publisher.PushVideoFrame(data, size, width, height);
    	}
	}

	@Override
	public void onChangeRotation(int rotation) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPublisher::onChangeRotation( this : 0x%x, rotation : %d )", hashCode(), rotation));
		
		publisher.ChangeVideoRotate(rotation);
	}

	@Override
	public void onAudioRecord(byte[] data, int size) {
		// TODO Auto-generated method stub
		// 不需要准, 不要锁
		if( isRuning ) {
			if( isMute ) {
				Arrays.fill(data, (byte)0);
			}
			publisher.PushAudioFrame(data, size);
		}
	}
	
}
