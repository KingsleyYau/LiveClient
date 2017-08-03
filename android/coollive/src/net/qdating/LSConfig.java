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
	public static String TAG = "coollive";
	/**
	 * 重连时间
	 */
	public static Integer RECONNECT_SECOND = 3000;
	/**
	 * 视频宽度
	 */
	public static int VIDEO_WIDTH = 640;
	/**
	 * 视频高度
	 */
	public static int VIDEO_HEIGHT = 480;
	/**
	 * 码率
	 */
	public static int VIDEO_BITRATE = 1000 * 1000;
	/**
	 * 视频帧率
	 */
	public static int VIDEO_FPS = 15;
	/**
	 * 视频关键帧间隔
	 */
	public static int VIDEO_KEYFRAMEINTERVAL = VIDEO_FPS;
	
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
