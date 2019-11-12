package com.qpidnetwork.anchor.utils;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import com.qpidnetwork.anchor.httprequest.RequestJni;

import java.io.File;
import java.util.List;

public class SystemUtils {
	
	/**
	 * 生成唯一机器码
	 * @param context
	 * @return
	 */
    static public String getDeviceId(Context context) {
    	TelephonyManager tm = (TelephonyManager)context.getSystemService(Context.TELEPHONY_SERVICE);
		String uniqueId = tm.getDeviceId();
		if( uniqueId == null || 
				uniqueId.length() == 0 || 
				uniqueId.compareTo("000000000000000") == 0 ) {
			uniqueId = RequestJni.GetLocalMacMD5();
		}
    	return uniqueId;
    }

	/**
	 * 检测fileId对应的礼物文件是否存在
	 * @param localPath
	 * @return
	 */
	public static boolean fileExists(String localPath){
		boolean exists = false;
		if(!TextUtils.isEmpty(localPath)){
			File file = new File(localPath);
			exists = null != file && file.exists();
		}

		return exists;
	}

	/**
	 * 判断是否后台运行
	 * @param context
	 * @return
	 */
	public static boolean isBackground(Context context) {
		ActivityManager activityManager = (ActivityManager) context
				.getSystemService(Context.ACTIVITY_SERVICE);
		List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager
				.getRunningAppProcesses();
		if((appProcesses != null) && (appProcesses.size() > 0)){
			for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
				if (appProcess.processName.equals(context.getPackageName())) {
                    return appProcess.importance != ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND;
				}
			}
		}
		return false;
	}

	/**
	 * 取VersionCode
	 * @param context
	 * @return
	 */
	public static int getVersionCode(Context context) {
		int versionCode = 0;
		PackageManager pm = context.getPackageManager();
		PackageInfo pi = null;
		try {
			pi = pm.getPackageInfo(context.getPackageName(), PackageManager.GET_ACTIVITIES);
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}
		if (pi != null) {
			// 版本号
			versionCode = pi.versionCode;
		}
		return versionCode;
	}

	/**
	 * 取VersionName
	 * @param context
	 * @return
	 */
	public static String getVersionName(Context context) {
		String versionName = "";
		PackageManager pm = context.getPackageManager();
		PackageInfo pi = null;
		try {
			pi = pm.getPackageInfo(context.getPackageName(), PackageManager.GET_ACTIVITIES);
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}
		if (pi != null) {
			// 版本号
			versionName = pi.versionName;
		}
		return versionName;
	}

	/**
	 * 取设备名（蓝牙列表中可见的名称）
	 * @param context
	 * @return
	 */
	static public String getDeviceName(Context context) {
		String deviceName = "Phone";
		deviceName = Settings.Secure.getString(context.getContentResolver(),"bluetooth_name");
		if(TextUtils.isEmpty(deviceName)){
			deviceName = android.os.Build.MODEL;
		}
		return deviceName;
	}
}
