package net.qdating;

import java.io.File;
import java.util.Arrays;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.opengl.GLSurfaceView;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageFilter;
import net.qdating.publisher.ILSAudioRecorderCallback;
import net.qdating.publisher.ILSPublisherCallback;
import net.qdating.publisher.ILSPublisherStatusCallback;
import net.qdating.publisher.ILSVideoCaptureCallback;
import net.qdating.publisher.LSAudioRecorder;
import net.qdating.publisher.LSPublishConfig;
import net.qdating.publisher.LSPublisherJni;
import net.qdating.publisher.LSVideoCapture;
import net.qdating.publisher.LSVideoHardEncoder;
import net.qdating.utils.Log;

import static android.content.Context.ACTIVITY_SERVICE;

/**
 * RTMP流推流器
 * @author max
 */
public class LSPublisher {
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
	protected ILSPublisherStatusCallback statusCallback;
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
	/*
	* 重连消息
	* */
	private final int MSG_CONNECT = 0;

	/**
	 * 检查设备是否支持推流
	 * @return true:成功/false:失败
	 */
	public static boolean checkDeviceSupport(Context context) {
		boolean bFlag = false;
		ActivityManager activityManager = (ActivityManager)context.getSystemService(ACTIVITY_SERVICE);
		ConfigurationInfo configurationInfo = activityManager.getDeviceConfigurationInfo();
		int major = ((configurationInfo.reqGlEsVersion & 0xffff0000) >> 16);
		bFlag = (major >= 3);

		Log.i(LSConfig.TAG,
				String.format("LSPublisher::checkDeviceSupport( "
								+ "[%s], "
								+ "reqGlEsVersion : 0x%x, "
								+ "major : %d "
								+ ")",
						bFlag?"Success":"Fail",
						configurationInfo.reqGlEsVersion,
						major
				)
		);

		return bFlag;
	}

	/***
	 * 初始化流推送器
	 * @param surfaceView	显示界面
	 * @param rotation 旋转角度
	 * @param fillMode 填充模式
	 * @param statusCallback 状态回调接口
	 * @param videoConfigType 视频配置
	 * @param fps 帧率(12)
	 * @param keyFrameInterval 关键帧间隔(12)
	 * @param videoBitrate 视频码率(500 * 1000)
	 * @return true:成功/false:失败
	 */
	public boolean init(Context context,
						GLSurfaceView surfaceView,
						int rotation,
						FillMode fillMode,
						final ILSPublisherStatusCallback statusCallback,
						LSConfig.VideoConfigType videoConfigType,
						int fps,
						int keyFrameInterval,
						int videoBitrate
	) {
		boolean bFlag = true;

		if( LSConfig.LOGDIR != null && LSConfig.LOGDIR.length() > 0 ) {
			File path = Environment.getExternalStorageDirectory();
			String filePath = path.getAbsolutePath() + "/" + LSConfig.LOGDIR + "/";
			Log.initFileLog(filePath);
			Log.setWriteFileLog(true);
			LSPublisherJni.SetLogDir(filePath);
			LSPublisherJni.SetJniLogLevel(LSConfig.LOG_LEVEL);
		}

		Log.i(LSConfig.TAG,
				String.format("LSPublisher::init( "
								+ "this : 0x%x, "
								+ "rotation : %d, "
								+ "fillMode : %d, "
								+ "videoConfigType : %d "
								+ "fps : %d "
								+ "keyFrameInterval : %d "
								+ "videoBitrate : %d "
								+ ")",
						hashCode(),
						rotation,
						fillMode.ordinal(),
						videoConfigType.ordinal(),
						fps,
						keyFrameInterval,
						videoBitrate
				)
		);

		// 初始化状态回调
		this.statusCallback = statusCallback;

		// 创建推流视频配置
		LSPublishConfig publishConfig = new LSPublishConfig();
		bFlag = publishConfig.updateVideoConfig(videoConfigType, fps, keyFrameInterval, videoBitrate);

		// 编码模式选择
//        if( LSConfig.encodeMode == LSConfig.EncodeMode.EncodeModeAuto ) {
//            if( LSVideoHardEncoder.supportHardEncoder(publishConfig) ) {
//                // 判断可以使用硬解码
//                useHardEncoder = true;
//            }
//        } else if( LSConfig.encodeMode == LSConfig.EncodeMode.EncodeModeHard ) {
//            // 强制使用硬解码
//            useHardEncoder = true;
//        }

		final LSPublisher lsPublisher = this;
		// 初始化推流器
		if( bFlag ) {
			bFlag = publisher.Create(new ILSPublisherCallback() {
				@Override
				public void onConnect(LSPublisherJni publisher) {
					Log.i(LSConfig.TAG, String.format("LSPublisher::onConnect( this : 0x%x )", lsPublisher.hashCode()));

					// 通知外部监听
					if( statusCallback != null ) {
						statusCallback.onConnect(lsPublisher);
					}
				}

				@Override
				public void onDisconnect(LSPublisherJni publisher) {
					Log.i(LSConfig.TAG, String.format("LSPublisher::onDisconnect( this : 0x%x )", lsPublisher.hashCode()));

					// 通知外部监听
					if( statusCallback != null ) {
						statusCallback.onDisconnect(lsPublisher);
					}

					synchronized (lsPublisher) {
						if( isRuning ) {
							// 非手动断开, 发送重连消息
							Message msg = Message.obtain();
							msg.what = MSG_CONNECT;
							msg.obj = lsPublisher;
							handler.sendMessageDelayed(msg, LSConfig.RECONNECT_SECOND);
						}
					}
				}
			}, useHardEncoder, videoHardEncoder, publishConfig);
		}
		
		// 初始化视频采集
		if( bFlag ) {
			bFlag = videoCapture.init(surfaceView, new ILSVideoCaptureCallback() {
                @Override
                public void onChangeRotation(int rotation) {
                    Log.i(LSConfig.TAG, String.format("LSPublisher::onChangeRotation( this : 0x%x, rotation : %d )", lsPublisher.hashCode(), rotation));
                    publisher.ChangeVideoRotate(rotation);
                }

                @Override
                public void onVideoCapture(final byte[] data, int size, final int width, final int height) {
//					Log.d(LSConfig.TAG, String.format("LSPublisher::onVideoCapture( this : 0x%x, width : %d, height : %d )", lsPublisher.hashCode(), width, height));
                    if( isRuning ) {
                        publisher.PushVideoFrame(data, size, width, height);
                    }

//					// 通知外部监听
//					if( statusCallback != null ) {
//						statusCallback.onVideoCapture(lsPublisher, data, size, width, height);
//					}
                }

				@Override
				public void onVideoCaptureError(int error) {
					Log.e(LSConfig.TAG, String.format("LSPublisher::onVideoCaptureError( this : 0x%x, error : %d )", lsPublisher.hashCode(), error));

					// 暂停视频推送
					publisher.PausePushVideo();

					// 通知外部监听
					if( statusCallback != null ) {
						statusCallback.onVideoCaptureError(lsPublisher, error);
					}
				}

            }, rotation, fillMode, useHardEncoder, publishConfig);
		}
		
		// 初始化音频录制
		if( bFlag ) {
			bFlag = audioRecorder.init(new ILSAudioRecorderCallback() {
				@Override
				public void onAudioRecord(byte[] data, int size) {
					if( isRuning ) {
						if( isMute ) {
							Arrays.fill(data, (byte)0);
						}
						publisher.PushAudioFrame(data, size);
					}
				}
			}, publishConfig);
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
									publisher.Stop();
									start();
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
					+ "[Success with %s] "
					+ ")",
					hashCode(),
					useHardEncoder?"hard encoder":"soft encoder"
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
     * 设置自定义滤镜
     * @param customFilter 自定义滤镜
     */
    public void setCustomFilter(LSImageFilter customFilter) {
        videoCapture.setCustomFilter(customFilter);
    }

	/**
	 * 获取自定义滤镜
	 * @return 自定义滤镜
	 */
	public LSImageFilter getCustomFilter() {
		LSImageFilter filter = videoCapture.getCustomFilter();
		return filter;
	}

	/***
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
					final LSPublisher lsPublisher = this;

		    	    // 开始重连消息队列
		    		handler.post(new Runnable() {
		    			@Override
		    			public void run() {
		    				// TODO Auto-generated method stub
							Message msg = Message.obtain();
							msg.what = MSG_CONNECT;
							msg.obj = lsPublisher;
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

	/***
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

		Log.i(LSConfig.TAG, String.format("LSPublisher::stop( this : 0x%x, [Success] )", hashCode()));
	}

	/***
	 * 当前是否静音
	 * @return true:静音/false:不静音
	 */
	public boolean getMute() {
		return isMute;
	}
	
	/***
	 * 设置是否静音
	 * @param isMute 是否静音
	 */
	public void setMute(boolean isMute) {
		Log.d(LSConfig.TAG, String.format("LSPublisher::setMute( this : 0x%x, %s )", hashCode(), Boolean.toString(isMute)));
		this.isMute = isMute;
	}
	
	/***
	 * 切换前后摄像头
	 * @return true:成功/false:失败
	 */
	public boolean rotateCamera() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::rotateCamera( this : 0x%x )", hashCode()));
		publisher.PausePushVideo();
		boolean bFlag = videoCapture.rotateCamera();
		if( bFlag ) {
			publisher.ResumePushVideo();
		}
		return bFlag;
	}

	/**
	 * 开启预览
	 * @return true:成功/false:失败
	 */
	public boolean startPreview() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::startPreview( this : 0x%x )", hashCode()));
		boolean bFlag = videoCapture.start();
		if( bFlag ) {
			publisher.ResumePushVideo();
		}
		return bFlag;
	}

	/***
	 * 停止预览
	 */
	public void stopPreview() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::stopPreview( this : 0x%x )", hashCode()));
		publisher.PausePushVideo();
		videoCapture.stop();
	}

	/**
	 * 开始推送
	 * @return true:成功/false:失败
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
}
