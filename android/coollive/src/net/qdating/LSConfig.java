package net.qdating;

/**
 * 流播放器初始化配置
 * @author max
 *
 */
public class LSConfig {
	/**
	 * 日志TAG
	 */
	public static final String TAG = "livestream";

	/**
	 * 视频宽度
	 */
	public static int VIDEO_WIDTH = 480;
	/**
	 * 视频高度
	 */
	public static int VIDEO_HEIGHT = 640;
	
	/**
	 * 音频PCM采样率
	 */
	public static int SAMPLE_RATE = 44100;
	/**
	 * 音频PCM声道
	 */
	public static int CHANNEL_PER_FRAME = 1;
	/**
	 * 音频PCM精度
	 */
	public static int BIT_PER_SAMPLE = 16;
}
