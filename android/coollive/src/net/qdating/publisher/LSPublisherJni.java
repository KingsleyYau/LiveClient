package net.qdating.publisher;

import android.util.Log;
import net.qdating.LSConfig;

/**
 * 音视频播放器JNI
 * @author max
 *
 */
public class LSPublisherJni implements ILSPublisherCallbackJni {
	private static final String TAG = "coollive";
	static {
		System.loadLibrary("lspublisher");
		Log.i(TAG, "LSPublisherJni Load Library");
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
	 * 初始化实例
	 * @param videoEncoder		视频编码器
	 * @return 成功失败
	 */
	public boolean Create(ILSPublisherCallback publisherCallback, ILSVideoEncoderJni videoEncoder) {
		// 状态回调
		this.publisherCallback = publisherCallback;
		
		client = Create(this, videoEncoder, LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT, LSConfig.VIDEO_BITRATE, LSConfig.VIDEO_KEYFRAMEINTERVAL, LSConfig.VIDEO_FPS);	
		return client != INVALID_CLIENT;
	}
	
	/**
	 * 创建实例
	 * @param videoEncoder		视频编码器
	 * @return	实例指针
	 */
	private native long Create(
			ILSPublisherCallbackJni publisherCallback, 
			ILSVideoEncoderJni videoEncoder, 
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
	public void PushVideoFrame(byte[] data) {
		if( client != INVALID_CLIENT ) {
			PushVideoFrame(client, data);
		}
	}
	private native void PushVideoFrame(long client, byte[] data);
	
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
	public void onDisconnect() {
		// TODO Auto-generated method stub
		
	}
}
