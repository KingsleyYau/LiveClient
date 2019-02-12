package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.database.Cursor;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class NetworkUtil {

	private static final String TAG = NetworkUtil.class.getSimpleName();

	// 上网类型
	/** 没有网络 */
	public static final byte NETWORK_TYPE_INVALID = 0x0;
	/** wifi网络 */
	public static final byte NETWORK_TYPE_WIFI = 0x1;
	/** 3G和3G以上网络，或统称为快速网络 */
	public static final byte NETWORK_TYPE_3G = 0x2;
	/** 2G网络 */
	public static final byte NETWORK_TYPE_2G = 0x3;
	/**
	 * 从原快速网络剥离 4G网络
	 */
	public static final byte NETWORK_TYPE_4G = 0x4;
	public static final byte XIAO_MI_SHARE_PC_NETWORK = 9;

	public static String getNetType(Context context){
		//获取网络连接管理者
		ConnectivityManager connectionManager = (ConnectivityManager)
				context.getSystemService(Context.CONNECTIVITY_SERVICE);
		//获取网络的状态信息，有下面三种方式
		NetworkInfo networkInfo = connectionManager.getActiveNetworkInfo();
		//ConnectivityManager.getNetworkInfo(Network) 返回了null。需检查权限以及是否机型兼容问题
		return null == networkInfo ? "" : networkInfo.getTypeName();
	}

	public static String getNetWorkTypeValue(Context context){
		String nwtValue = "unknown";
		if (context != null){
			ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo networkInfo = manager.getActiveNetworkInfo();
			if (networkInfo != null && networkInfo.isConnected()) {
				if(networkInfo.getType() == ConnectivityManager.TYPE_WIFI || XIAO_MI_SHARE_PC_NETWORK == networkInfo.getType()){
					nwtValue="WIFI";
				}else if(ConnectivityManager.TYPE_MOBILE == networkInfo.getType()){
					switch (networkInfo.getSubtype()){
						case TelephonyManager.NETWORK_TYPE_UNKNOWN:
							nwtValue = "unknown";
							break;
						case TelephonyManager.NETWORK_TYPE_GPRS:
							nwtValue = "(2.5G)移动/联通";
							break;
						case TelephonyManager.NETWORK_TYPE_EDGE:
							nwtValue = "(2.75G)移动/联通";
							break;
						case TelephonyManager.NETWORK_TYPE_UMTS:
							nwtValue = "(3G)联通";
							break;
						case TelephonyManager.NETWORK_TYPE_CDMA:
							nwtValue = "(2G)电信";
							break;
						case TelephonyManager.NETWORK_TYPE_EVDO_0:
							nwtValue = "(3G)电信";
							break;
						case TelephonyManager.NETWORK_TYPE_EVDO_A:
							nwtValue = "3.5G";
							break;
						case TelephonyManager.NETWORK_TYPE_1xRTT:
							nwtValue = "2G";
							break;
						case TelephonyManager.NETWORK_TYPE_HSDPA:
							nwtValue = "3.5G";
							break;
						case TelephonyManager.NETWORK_TYPE_HSUPA:
							nwtValue = "3.5G";
							break;
						case TelephonyManager.NETWORK_TYPE_HSPA:
							nwtValue = "(3G)联通";
							break;
						case TelephonyManager.NETWORK_TYPE_IDEN:
							nwtValue = "2G";
							break;
						case TelephonyManager.NETWORK_TYPE_EVDO_B:
							nwtValue = "3G-3.5G";
							break;
						case TelephonyManager.NETWORK_TYPE_LTE:
							nwtValue = "4G";
							break;
						case TelephonyManager.NETWORK_TYPE_EHRPD:
							nwtValue = "3G(3G到4G的升级产物)";
							break;
						case TelephonyManager.NETWORK_TYPE_HSPAP:
							nwtValue = "3G";
							break;
						case 16:
							nwtValue = "GSM";
							break;
						case 17:
							nwtValue = "TD_SCDMA";
							break;
						case 18:
							nwtValue = "IWLAN";
							break;
						default:
							break;
					}
				}

			}
		}
		return nwtValue;
	}

	/**
	 * 获取网络状态，wifi,3g,2g,无网络。
	 * 
	 * @param context
	 *            上下文
	 * @return byte 网络状态 {@link #NETWORK_TYPE_WIFI}, {@link #NETWORK_TYPE_3G},
	 *         {@link #NETWORK_TYPE_2G}, {@link #NETWORK_TYPE_INVALID}
	 */
	public static byte getNetWorkType(Context context) {
		byte mNetWorkType = NETWORK_TYPE_INVALID;
		if (context == null)
			return mNetWorkType;
		ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo networkInfo = manager.getActiveNetworkInfo();

		if (networkInfo != null && networkInfo.isConnected()) {
			int nType = networkInfo.getType();
			Log.e("NetworkUtil", nType + "");
			if (nType == ConnectivityManager.TYPE_WIFI) {
				mNetWorkType = NETWORK_TYPE_WIFI;
			} else if (nType == ConnectivityManager.TYPE_MOBILE) {
				// String proxyHost =
				// android.net.Proxy.getDefaultHost();//TextUtils.isEmpty(proxyHost)=false为wap网络
//				mNetWorkType = (isFastMobileNetwork(context) ? NETWORK_TYPE_3G : NETWORK_TYPE_2G);
				//modify by @freeman 07-28
				mNetWorkType = getMobileNetworkType(context);
			} else if (nType == XIAO_MI_SHARE_PC_NETWORK) {
				mNetWorkType = NETWORK_TYPE_WIFI;
			}

		} else {
			mNetWorkType = NETWORK_TYPE_INVALID;

		}

		return mNetWorkType;
	}



	/**
	 * 检测网络是否可用
	 * 
	 * @return
	 */
	public static boolean isNetworkConnected(Context context) {
		ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo ni = cm.getActiveNetworkInfo();
		return ni != null && ni.isConnectedOrConnecting();
	}

	/**
	 * 判断是2G网络还是3G以上网络 false:2G网络;true:3G以上网络
	 */
	private static boolean isFastMobileNetwork(Context context) {
		TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		switch (telephonyManager.getNetworkType()) {
		case TelephonyManager.NETWORK_TYPE_UNKNOWN:// 0
			return false;
		case TelephonyManager.NETWORK_TYPE_GPRS:// 1
			return false; // ~ 100 kbps
		case TelephonyManager.NETWORK_TYPE_EDGE:// 2
			return false; // ~ 50-100 kbps
		case TelephonyManager.NETWORK_TYPE_UMTS:// 3
			return true; // ~ 400-7000 kbps
		case TelephonyManager.NETWORK_TYPE_CDMA:// 4
			return false; // ~ 14-64 kbps
		case TelephonyManager.NETWORK_TYPE_EVDO_0:// 5
			return true; // ~ 400-1000 kbps
		case TelephonyManager.NETWORK_TYPE_EVDO_A:// 6
			return true; // ~ 600-1400 kbps
		case TelephonyManager.NETWORK_TYPE_1xRTT:// 7
			return false; // ~ 50-100 kbps
		case TelephonyManager.NETWORK_TYPE_HSDPA:// 8
			return true; // ~ 2-14 Mbps
		case TelephonyManager.NETWORK_TYPE_HSUPA:// 9
			return true; // ~ 1-23 Mbps
		case TelephonyManager.NETWORK_TYPE_HSPA:// 10
			return true; // ~ 700-1700 kbps
		case TelephonyManager.NETWORK_TYPE_IDEN:// 11
			return false; // ~25 kbps
			// SDK4.0才支持以下接口
		case 12:// TelephonyManager.NETWORK_TYPE_EVDO_B://12
			return true; // ~ 5 Mbps
		case 13:// TelephonyManager.NETWORK_TYPE_LTE://13
			return true; // ~ 10+ Mbps
		case 14:// TelephonyManager.NETWORK_TYPE_EHRPD://14
			return true; // ~ 1-2 Mbps
		case 15:// TelephonyManager.NETWORK_TYPE_HSPAP://15
			return true; // ~ 10-20 Mbps
		default:
			return false;
		}
	}

	private static byte getMobileNetworkType (Context context) {
		TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		switch (telephonyManager.getNetworkType()) {
			case TelephonyManager.NETWORK_TYPE_UNKNOWN:// 0
			case TelephonyManager.NETWORK_TYPE_GPRS:// 1
			// ~ 100 kbps
			case TelephonyManager.NETWORK_TYPE_EDGE:// 2
			// ~ 50-100 kbps
			case TelephonyManager.NETWORK_TYPE_CDMA:// 4
				 // ~ 14-64 kbps
			case TelephonyManager.NETWORK_TYPE_1xRTT:// 7
				// ~ 50-100 kbps
			case TelephonyManager.NETWORK_TYPE_IDEN:// 11
				 // ~25 kbps
			return NETWORK_TYPE_2G;

			case TelephonyManager.NETWORK_TYPE_UMTS:// 3
				 // ~ 400-7000 kbps
			case TelephonyManager.NETWORK_TYPE_EVDO_0:// 5
				 // ~ 400-1000 kbps
			case TelephonyManager.NETWORK_TYPE_EVDO_A:// 6
				// ~ 600-1400 kbps
			case TelephonyManager.NETWORK_TYPE_HSDPA:// 8
				// ~ 2-14 Mbps
			case TelephonyManager.NETWORK_TYPE_HSUPA:// 9
				// ~ 1-23 Mbps
			case TelephonyManager.NETWORK_TYPE_HSPA:// 10
				// ~ 700-1700 kbps
			case 12:// TelephonyManager.NETWORK_TYPE_EVDO_B://12
				 // ~ 5 Mbps
			case 14:// TelephonyManager.NETWORK_TYPE_EHRPD://14
				// ~ 1-2 Mbps
			case 15:// TelephonyManager.NETWORK_TYPE_HSPAP://15
				 // ~ 10-20 Mbps
			return NETWORK_TYPE_3G;

			// SDK4.0才支持以下接口
			case 13:// TelephonyManager.NETWORK_TYPE_LTE://13
				return NETWORK_TYPE_4G; // ~ 10+ Mbps
			default:
				return NETWORK_TYPE_2G;
		}
	}

	public static final String CTWAP = "ctwap";
	public static final String CMWAP = "cmwap";
	public static final String WAP_3G = "3gwap";
	public static final String UNIWAP = "uniwap";
	/** @Fields TYPE_NET_WORK_DISABLED : 网络不可用 */
	public static final int TYPE_NET_WORK_DISABLED = 0;
	/** @Fields TYPE_CM_CU_WAP : 移动联通wap10.0.0.172 */
	public static final int TYPE_CM_CU_WAP = 4;
	/** @Fields TYPE_CT_WAP : 电信wap 10.0.0.200 */
	public static final int TYPE_CT_WAP = 5;
	/** @Fields TYPE_OTHER_NET : 电信,移动,联通,wifi 等net网络 */
	public static final int TYPE_OTHER_NET = 6;
	public static Uri PREFERRED_APN_URI = Uri.parse("content://telephony/carriers/preferapn");

	/**
	 * 判断Network具体类型（联通移动wap，电信wap，其他net）
	 * 
	 * @param mContext
	 */
	public static int checkNetworkType(Context mContext) {
		try {
			final ConnectivityManager connectivityManager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
			final NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
			if (networkInfo == null || !networkInfo.isAvailable()) {
				// 注意一：
				// NetworkInfo 为空或者不可以用的时候正常情况应该是当前没有可用网络，
				// 但是有些电信机器，仍可以正常联网，
				// 所以当成net网络处理依然尝试连接网络。
				// （然后在socket中捕捉异常，进行二次判断与用户提示）。
				Log.i("", "=====================>无网络");
				return TYPE_NET_WORK_DISABLED;
			} else {
				// NetworkInfo不为null开始判断是网络类型
				int netType = networkInfo.getType();
				if (netType == ConnectivityManager.TYPE_WIFI) {
					// wifi net处理
					Log.i("", "=====================>wifi网络");
					return TYPE_OTHER_NET;
				} else if (netType == ConnectivityManager.TYPE_MOBILE) {
					// 注意二：
					// 判断是否电信wap:
					// 不要通过getExtraInfo获取接入点名称来判断类型，
					// 因为通过目前电信多种机型测试发现接入点名称大都为#777或者null，
					// 电信机器wap接入点中要比移动联通wap接入点多设置一个用户名和密码,
					// 所以可以通过这个进行判断！
					final Cursor c = mContext.getContentResolver().query(PREFERRED_APN_URI, null, null, null, null);
					if (c != null) {
						c.moveToFirst();
						final String user = c.getString(c.getColumnIndex("user"));
						if (!TextUtils.isEmpty(user)) {
							Log.i("", "=====================>代理：" + c.getString(c.getColumnIndex("proxy")));
							if (user.startsWith(CTWAP)) {
								Log.i("", "=====================>电信wap网络");
								return TYPE_CT_WAP;
							}
						}
					}
					c.close();

					// 注意三：
					// 判断是移动联通wap:
					// 其实还有一种方法通过getString(c.getColumnIndex("proxy")获取代理ip
					// 来判断接入点，10.0.0.172就是移动联通wap，10.0.0.200就是电信wap，但在
					// 实际开发中并不是所有机器都能获取到接入点代理信息，例如魅族M9 （2.2）等...
					// 所以采用getExtraInfo获取接入点名字进行判断
					String netMode = networkInfo.getExtraInfo();
					Log.i("", "netMode ================== " + netMode);
					if (netMode != null) {
						// 通过apn名称判断是否是联通和移动wap
						netMode = netMode.toLowerCase();
						if (netMode.equals(CMWAP) || netMode.equals(WAP_3G) || netMode.equals(UNIWAP)) {
							Log.i("", "=====================>移动联通wap网络");
							return TYPE_CM_CU_WAP;
						}
					}
				}
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			return TYPE_OTHER_NET;
		}
		return TYPE_OTHER_NET;
	}

	/**
	 * 获取网络的时时网速，使用方法是：
	 * 每隔一段时间读取一次总流量，然后用本次和前一次的差除以间隔时间来获取平均速度，再换算为 K/s M/s
	 * 等单位，显示即可。
	 *
	 * @return 实时的网速（单位byte）
	 */
	public static int getNetSpeedBytes() {
		String line;
		String[] segs;
		int received = 0;
		int i;
		int tmp = 0;
		boolean isNum;
		try {
			FileReader fr = new FileReader("/proc/net/dev");
			BufferedReader in = new BufferedReader(fr, 500);
			while ((line = in.readLine()) != null) {
				line = line.trim();
				if (line.startsWith("rmnet") || line.startsWith("eth") || line.startsWith("wlan")) {
					segs = line.split(":")[1].split(" ");
					for (i = 0; i < segs.length; i++) {
						isNum = true;
						try {
							tmp = Integer.parseInt(segs[i]);
						} catch (Exception e) {
							isNum = false;
						}
						if (isNum == true) {
							received += tmp;
							break;
						}
					}
				}
			}
			in.close();
		} catch (IOException e) {
			return -1;
		}
		return received;
	}



}
