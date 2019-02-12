package net.qdating.publisher;

import net.qdating.utils.Log;
import net.qdating.LSConfig;
import net.qdating.player.ILSVideoRendererJni;

/**
 * 音视频播放器JNI
 * @author max
 *
 */
public class LSPublisherJni implements ILSPublisherCallbackJni {
	static {
		System.loadLibrary("lspublisher");
		Log.i(LSConfig.TAG, String.format("LSPublisherJni::static( Load Library, version : %s )", LSConfig.VERSION));
	}
	
	/**
	 * 无效的指针
	 */
	private static long INVALID_CLIENT = 0;  
	
	/**
	 * C实例指针
	 */
	private long client = INVALID_CLIENT;
	
	/**
	 * 状态回调
	 */
	ILSPublisherCallback publisherCallback = null;

	/**
	 * 初始化日志目录
	 */
	public native static void SetLogDir(String logDir);

	/**
	 * 设置日志等级 <br/>
	 * {@link android.util.Log#VERBOSE} <br/>
	 * {@link android.util.Log#DEBUG} <br/>
	 * {@link android.util.Log#INFO} <br/>
	 * {@link android.util.Log#WARN} <br/>
	 * {@link android.util.Log#ERROR} <br/>
	 */
	public static void SetJniLogLevel(int logLevel) {
		SetLogLevel(logLevel - android.util.Log.DEBUG);
	}
	private native static void SetLogLevel(int logLevel);

	/**
	 * 创建实例
	 * @param publisherCallback		状态回调
	 * @param useHardEncoder		是否使用硬编码器
	 * @param videoHardEncoder		视频硬编码器
	 * @return 成功失败
	 */
	public boolean Create(
			ILSPublisherCallback publisherCallback, 
			boolean useHardEncoder,
			ILSVideoHardEncoderJni videoHardEncoder,
			LSPublishConfig publishConfig
			) {
		// 状态回调
		this.publisherCallback = publisherCallback;
		
		client = Create(this, useHardEncoder, videoHardEncoder, publishConfig.videoWidth, publishConfig.videoHeight, publishConfig.videoBitrate, publishConfig.videoKeyFrameInterval, publishConfig.videoFps);
		return client != INVALID_CLIENT;
	}
	
	/**
	 * 创建实例
	 * @param publisherCallback		状态回调
	 * @param useHardDecoder		是否使用硬编码器
	 * @param videoHardEncoder		视频硬编码器
	 * @return 实例指针
	 */
	private native long Create(
			ILSPublisherCallbackJni publisherCallback, 
			boolean useHardDecoder,
			ILSVideoHardEncoderJni videoHardEncoder,
			int width,
			int height,
			int bitRate,
			int keyFrameInterval,
			int fps
			);
	
	/**
	 * 销毁实例
	 */
	public void Destroy() {
		if( client != INVALID_CLIENT ) {
			Destroy(client);
			client = INVALID_CLIENT;
		}
	}
	
	/**
	 * 销毁实例
	 * @param client	实例指针
	 */
	private native void Destroy(long client);
		    
	/**
	 * 开始推流
	 * @param url
	 * @param recordH264FilePath
	 * @param recordAACFilePath
	 * @return
	 */
	public boolean PublishUrl(String url, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		if( client != INVALID_CLIENT ) {
			bFlag = PublishUrl(client, url, recordH264FilePath, recordAACFilePath);
		}
		return bFlag;
	}
	private native boolean PublishUrl(long client, String url, String recordH264FilePath, String recordAACFilePath);

	/**
	 * 发送视频帧
	 * @param data
	 */
	public void PushVideoFrame(byte[] data, int size, int width, int height) {
		if( client != INVALID_CLIENT ) {
			PushVideoFrame(client, data, size, width, height);
		}
	}
	private native void PushVideoFrame(long client, byte[] data, int size, int width, int height);
	
	/**
	 * 暂停推送视频
	 */
	public void PausePushVideo() {
		if( client != INVALID_CLIENT ) {
			PausePushVideo(client);
		}
	}
	private native void PausePushVideo(long client);

	/**
	 * 恢复推送视频
	 */
	public void ResumePushVideo() {
		if( client != INVALID_CLIENT ) {
			ResumePushVideo(client);
		}
	}
	private native void ResumePushVideo(long client);
		
	/**
	 * 发送音频帧
	 * @param data
	 */
	public void PushAudioFrame(byte[] data, int size) {
		if( client != INVALID_CLIENT ) {
			PushAudioFrame(client, data, size);
		}
	}
	private native void PushAudioFrame(long client, byte[] data, int size);
	
	/***
	 * 改变视频输入角度
	 * @param rotation
	 */
	public void ChangeVideoRotate(int rotation) {
		if( client != INVALID_CLIENT ) {
			ChangeVideoRotate(client, rotation);
		}
	}
	private native void ChangeVideoRotate(long client, int rotation);
	
	/**
	 * 停止播放
	 */
	public void Stop() {
		if( client != INVALID_CLIENT ) {
			Stop(client);
		}
	}
	private native void Stop(long client);

	@Override
	public void onConnect() {
		// TODO Auto-generated method stub
		if( publisherCallback != null ) {
			publisherCallback.onConnect(this);
		}
	}
	
	@Override
	public void onDisconnect() {
		// TODO Auto-generated method stub
		if( publisherCallback != null ) {
			publisherCallback.onDisconnect(this);
		}
	}

}
