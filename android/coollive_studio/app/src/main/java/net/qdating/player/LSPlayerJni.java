package net.qdating.player;

import net.qdating.utils.Log;
import net.qdating.LSConfig;

/**
 * 音视频播放器JNI
 * @author max
 *
 */
public class LSPlayerJni implements ILSPlayerCallbackJni {
	static {
		System.loadLibrary("lsplayer");
		Log.i(LSConfig.TAG, String.format("LSPlayerJni::static( Load Library, version : %s )", LSConfig.VERSION));
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
	 * 创建实例
	 * @param playerCallback		状态回调
	 * @param useHardDecoder 		是否使用硬解码器
	 * @param videoRenderer			视频渲染器
	 * @param audioRenderer			音频渲染器
	 * @param videoHardDecoder		视频硬解码器
	 * @return 成功失败
	 */
	public boolean Create(
			ILSPlayerCallback playerCallback, 
			boolean useHardDecoder,
			ILSVideoRendererJni videoRenderer, 
			ILSAudioRendererJni audioRenderer, 
			ILSVideoHardDecoderJni videoHardDecoder,
			ILSVideoHardRendererJni videoHardRenderer
			) {
		// 状态回调
		this.playerCallback = playerCallback;
			
		client = Create(this, useHardDecoder, videoRenderer, audioRenderer, videoHardDecoder, videoHardRenderer);	
		return client != INVALID_CLIENT;
	}
	
	/**
	 * 创建实例
	 * @param playerCallback		状态回调
	 * @param useHardDecoder 		是否使用硬解码器
	 * @param videoRenderer			视频渲染器
	 * @param audioRenderer			音频渲染器
	 * @param videoHardDecoder		视频硬解码器
	 * @param videoHardRenderer		视频硬渲染器
	 * @return 实例指针
	 */
	private native long Create(
			ILSPlayerCallbackJni playerCallback, 
			boolean useHardDecoder,
			ILSVideoRendererJni videoRenderer, 
			ILSAudioRendererJni audioRenderer, 
			ILSVideoHardDecoderJni videoHardDecoder,
			ILSVideoHardRendererJni videoHardRenderer
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
	public void onConnect() {
		// TODO Auto-generated method stub
		if( playerCallback != null ) {
			playerCallback.onConnect(this);
		}
	}
	
	@Override
	public void onDisconnect() {
		// TODO Auto-generated method stub
		if( playerCallback != null ) {
			playerCallback.onDisconnect(this);
		}
	}
	
	@Override
	public void onPlayerOnDelayMaxTime() {
		// TODO Auto-generated method stub
		if( playerCallback != null ) {
			playerCallback.onPlayerOnDelayMaxTime(this);
		}
	}
}
