package net.qdating;

import net.qdating.utils.Log;

/**
 * 推拉流模块初始化配置
 * @author max
 * @version 1.1.1
 */
public class LSConfig {
	/**
	 * 版本号
	 */
	final public static String VERSION = "1.1.1";
	/**
	 * 日志TAG
	 */
	public static String TAG = "coollive";
	/**
	 * 日志路径
	 * 如 /sdcard/LOGDIR, 空则不创建目录
	 */
	public static String LOGDIR = "coollive";
	/**
	 * 是否调试模式
	 */
	public static boolean DEBUG = true;
	/**
	 * 设置日志等级
	 * {@link android.util.Log#VERBOSE}
	 * {@link android.util.Log#DEBUG}
	 * {@link android.util.Log#INFO}
	 * {@link android.util.Log#WARN}
	 * {@link android.util.Log#ERROR}
	 */
	public static int LOG_LEVEL = android.util.Log.ERROR;
	/**
	 * 重连时间
	 */
	public static Integer RECONNECT_SECOND = 3000;
	/**
	 * 初始化解码缓存(播放器参数)
	 * 总量 = 缓存时间 * FPS
	 */
	public static int VIDEO_DECODE_FRAME_COUNT = 30;
	/**
	 * 初始化编码缓存推流器参数)
	 */
	public static int VIDEO_ENCODE_FRAME_COUNT = 10;
	/**
	 * 视频宽度(摄像头参数)
	 */
	public static int VIDEO_CAPTURE_WIDTH = 1080;
	/**
	 * 视频高度(摄像头参数)
	 */
	public static int VIDEO_CAPTURE_HEIGHT = 1920;
	/**
	 * 视频宽度(推流参数)
	 * 大部分硬编码器要求是4的倍数, 有些要求其他, 但都是2的指数
	 */
	public static int VIDEO_WIDTH = 240;
	/**
	 * 视频高度(推流参数)
	 * 大部分硬编码器要求是4的倍数, 有些要求其他, 但都是2的指数
	 */
	public static int VIDEO_HEIGHT = 240;
	/**
	 * 码率(推流参数)
	 */
	public static int VIDEO_BITRATE = 500 * 1000;
	/**
	 * 视频帧率(推流参数)
	 */
	public static int VIDEO_FPS = 12;
	/**
	 * 视频关键帧间隔(推流参数)
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
	
	/**
	 * 视频预览用的对象
	 */
	public static int MAGIC_TEXTURE_ID = 10;
	
	/**
	 * 渲染模式类型
	 * FillModeStretch 			满屏拉伸
	 * FillModeAspectRatioFit 	保持比例全图显示
	 * FillModeAspectRatioFill 	保持比例全屏显示
	 */
	static public enum FillMode {
		FillModeStretch, 
		FillModeAspectRatioFit,
		FillModeAspectRatioFill
	};
	
	/**
	 * 编解码模式
	 * @author max
	 * EncodeDecodeModeAuto 自动选择解码模式
	 * EncodeDecodeModeSoft 强制选择软解码模式
	 * EncodeDecodeModeHard 强制选择硬解码模式
	 */
	static public enum EncodeDecodeMode {
		EncodeDecodeModeAuto,
		EncodeDecodeModeSoft,
		EncodeDecodeModeHard
	}
	public static EncodeDecodeMode encodeDecodeMode = EncodeDecodeMode.EncodeDecodeModeAuto;
}
