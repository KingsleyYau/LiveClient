package net.qdating;

/**
 * RTMP模块初始化配置
 * @author max
 * @version 1.0.0
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
	 * 视频宽度(推流参数)
	 */
	public static int VIDEO_WIDTH = 240;
	/**
	 * 视频高度(推流参数)
	 */
	public static int VIDEO_HEIGHT = 320;
	/**
	 * 码率(推流参数)
	 */
	public static int VIDEO_BITRATE = 1000 * 1000;
	/**
	 * 视频帧率(推流参数)
	 */
	public static int VIDEO_FPS = 10;
	/**
	 * 视频关键帧间隔(推流参数)
	 */
	public static int VIDEO_KEYFRAMEINTERVAL = VIDEO_FPS;
	/**
	 * 视频采集临时Buffer, 数值越大, 效率越高, 占用内存越大(推流参数)
	 */
	public static int VIDEO_CAPTURE_BUFFER_COUNT = 3 * VIDEO_FPS;
	
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
