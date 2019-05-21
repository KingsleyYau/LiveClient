package net.qdating;

import net.qdating.utils.Log;

/**
 * RTMP推拉流模块初始化配置
 * @author max
 * @version 1.9.2
 */
public class LSConfig {
	/**
	 * 版本号
	 */
	public final static String VERSION = "1.9.2";
	/**
	 * 日志TAG
	 */
	public static String TAG = "coollive";
	/**
	 * 日志路径 <br/>
	 * 如 /sdcard/LOGDIR, 空则不创建目录 <br/>
	 */
	public static String LOGDIR = "";
	/**
	 * 是否调试模式
	 */
	public static boolean DEBUG = false;
	/**
	 * 设置日志等级 <br/>
	 * {@link android.util.Log#VERBOSE} <br/>
	 * {@link android.util.Log#DEBUG} <br/>
	 * {@link android.util.Log#INFO} <br/>
	 * {@link android.util.Log#WARN} <br/>
	 * {@link android.util.Log#ERROR} <br/>
	 */
	public static int LOG_LEVEL = android.util.Log.ERROR;
	/**
	 * 重连时间
	 */
	public static Integer RECONNECT_SECOND = 3000;
	/**
	 * 初始化解码缓存(播放器参数) <br/>
	 * 总量 = 缓存时间 * FPS <br/>
	 */
	public static int VIDEO_DECODE_FRAME_COUNT = 30;
	/**
	 * 最大解码缓存(播放器参数) <br/>
	 */
	public static final int VIDEO_DECODE_FRAME_MAX_COUNT = 100;
	/**
	 * 初始化编码缓存(推流器参数) <br/>
	 * 总量 = 缓存时间 * FPS <br/>
	 */
	public static int VIDEO_ENCODE_FRAME_COUNT = 10;
	/**
	 * 视频参数模式 <br/>
	 * VideoConfigType240x240 采集480x640, 编码240x240 <br/>
	 * VideoConfigType240x320 采集480x640, 编码240x320 <br/>
	 * VideoConfigType320x320 采集480x640, 编码320x320 <br/>
	 */
	static public enum VideoConfigType {
		VideoConfigType240x240,
		VideoConfigType240x320,
		VideoConfigType320x320
	}
	/**
	 * 渲染模式类型 <br/>
	 * FillModeStretch 			满屏拉伸 <br/>
	 * FillModeAspectRatioFit 	保持比例全图显示 <br/>
	 * FillModeAspectRatioFill 	保持比例全屏显示 <br/>
	 */
	static public enum FillMode {
		FillModeStretch,
		FillModeAspectRatioFit,
		FillModeAspectRatioFill
	};
	/**
	 * 解码模式 <br/>
	 * DecodeModeAuto 自动选择解码模式 <br/>
	 * DecodeModeSoft 强制选择软解码模式 <br/>
	 * DecodeModeHard 强制选择硬解码模式 <br/>
	 */
	static public enum DecodeMode {
		DecodeModeAuto,
		DecodeModeSoft,
		DecodeModeHard
	}
	public static DecodeMode decodeMode = DecodeMode.DecodeModeAuto;
	/**
	 * 编码模式 <br/>
	 * EncodeModeAuto 自动选择编码模式 <br/>
	 * EncodeModeSoft 强制选择编编码模式 <br/>
	 * EncodeModeHard 强制选择硬编码模式 <br/>
	 */
	static public enum EncodeMode {
		EncodeModeAuto,
		EncodeModeSoft,
		EncodeModeHard
	}
	public static EncodeMode encodeMode = EncodeMode.EncodeModeAuto;
}
