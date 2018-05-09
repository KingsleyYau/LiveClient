package net.qdating;

import net.qdating.utils.Log;

/**
 * 推拉流模块初始化配置
 * @author max
 * @version 1.1.2
 */
public class LSConfig {
	/**
	 * 版本号
	 */
	final public static String VERSION = "1.1.2";
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
	public static boolean DEBUG = false;
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
	 * 视频参数模式
	 * VideoConfigType120x160 : 采集480x640, 编码120x160
	 * VideoConfigType240x240 : 采集480x640, 编码240x240
	 */
	static public enum VideoConfigType {
		VideoConfigType120x160,
		VideoConfigType240x240
	}
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
	 * 解码模式
	 * DecodeModeAuto 自动选择解码模式
	 * DecodeModeSoft 强制选择软解码模式
	 * DecodeModeHard 强制选择硬解码模式
	 */
	static public enum DecodeMode {
		DecodeModeAuto,
		DecodeModeSoft,
		DecodeModeHard
	}
	public static DecodeMode decodeMode = DecodeMode.DecodeModeAuto;
	/**
	 * 编码模式
	 * EncodeModeAuto 自动选择编码模式
	 * EncodeModeSoft 强制选择编编码模式
	 * EncodeModeHard 强制选择硬编码模式
	 */
	static public enum EncodeMode {
		EncodeModeAuto,
		EncodeModeSoft,
		EncodeModeHard
	}
	public static EncodeMode encodeMode = EncodeMode.EncodeModeAuto;
}
