package net.qdating;

import android.util.Log;
import android.view.SurfaceView;

/**
 * RTMP流播放器
 * @author max
 *
 */
public class LSPlayer implements ILSPlayerCallback {
	// RTMP模块
	private LSPlayerJni player = new LSPlayerJni();
	
	// 播放相关
	private LSVideoPlayer videoPlayer;
//	private LSVideoGLPlayer videoGLPlayer;
	private LSAudioPlayer audioPlayer;
	
	// 解码相关
	private LSVideoDecoder videoDecoder;
	
	// 状态回调接口
	private ILSPlayerStatusCallback statusCallback;
	
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

		return bFlag;
	}
	
	/**
	 * 开始流播放
	 * @param url	流播放地址
	 * @param recordFilePath	FLV文件录制绝对路径
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return
	 */
	public boolean PlayUrl(String url, String recordFilePath, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = player.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
		
		Log.i("livestream", String.format("LSPlayer::PlayUrl( "
				+ "url : %s "
				+ ")",
				url
				)
				);
		
		return bFlag;
	}
	
	/**
	 * 停止播放
	 */
	public void Stop() {
		// 停止播放器
		player.Stop();
		
		// 停止音频播放
		audioPlayer.stop();
	}

	@Override
	public void onDisconnect(LSPlayerJni player) {
		// TODO Auto-generated method stub
		Log.i("livestream", "LSPlayer::onDisconnect()");
		
		if( statusCallback != null ) {
			statusCallback.onDisconnect(this);
		}
	}
}
