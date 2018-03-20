package net.qdating.player;

import android.util.Log;

/**
 * 音视频播放器JNI
 * @author max
 *
 */
public class LSPlayerJni implements ILSPlayerCallbackJni {
	private static final String TAG = "coollive";
	static {
		System.loadLibrary("lsplayer");
		Log.i(TAG, "LSPlayerJni::static( Load Library )");
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
	ILSPlayerCallback playerCallback = null;
	
	/**
	 * 初始化实例
	 * @param playerCallback	状态回调
	 * @param videoRenderer		视频渲染器
	 * @param audioRenderer		音频渲染器
	 * @param videoDecoder		视频解码器
	 * @return 成功失败
	 */
	public boolean Create(
			ILSPlayerCallback playerCallback, 
			ILSVideoRendererJni videoRenderer, 
			ILSAudioRendererJni audioRenderer, 
			ILSVideoDecoderJni videoDecoder
			) {
		// 状态回调
		this.playerCallback = playerCallback;
			
		client = Create(this, videoRenderer, audioRenderer, videoDecoder);	
		return client != INVALID_CLIENT;
	}
	
	/**
	 * 创建实例
	 * @param playerCallback	状态回调
	 * @param videoRenderer		视频渲染器
	 * @param audioRenderer		音频渲染器
	 * @param videoDecoder		视频解码器
	 * @return	实例指针
	 */
	private native long Create(
			ILSPlayerCallbackJni playerCallback, 
			ILSVideoRendererJni videoRenderer, 
			ILSAudioRendererJni audioRenderer, 
			ILSVideoDecoderJni videoDecoder);
	
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
	 * 
	 * @param url
	 * @param recordFilePath
	 * @param recordH264FilePath
	 * @param recordAACFilePath
	 * @return
	 */
	public boolean PlayUrl(String url, String recordFilePath, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		if( client != INVALID_CLIENT ) {
			bFlag = PlayUrl(client, url, recordFilePath, recordH264FilePath, recordAACFilePath);
		}
		return bFlag;
	}
	private native boolean PlayUrl(long client, String url, String recordFilePath, String recordH264FilePath, String recordAACFilePath);

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
		if( playerCallback != null ) {
			playerCallback.onDisconnect(this);
		}
	}
}
