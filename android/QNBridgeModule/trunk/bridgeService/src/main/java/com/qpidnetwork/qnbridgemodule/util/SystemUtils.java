package com.qpidnetwork.qnbridgemodule.util;

import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.text.TextUtils;

import java.io.File;
import java.util.List;

public class SystemUtils {

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


	public static String getVersionName(Context context) {
		try {
			return context.getPackageManager().getPackageInfo(
					context.getPackageName(), 0).versionName;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "1.0";
	}

	/**
	 * 获取前置摄像头Index
	 * @return
	 */
	public static int GetFrontCameraIndex(){
		int cameraIndex = -1;
		Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
		int cameraCount = Camera.getNumberOfCameras();
		for(int camIdx = 0; camIdx < cameraCount; camIdx++){
			Camera.getCameraInfo(camIdx, cameraInfo);
			if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT){
				cameraIndex = camIdx;
				break;
			}
		}
		return cameraIndex;
	}

	/**
	 * 检测前置摄像头是否可用
	 * @return
	 */
	public static boolean CheckFrontCameraUsable(){
		boolean isCanUse = false;
		int camIndex = GetFrontCameraIndex();
		if(camIndex != -1){
			try{
				Camera camera = Camera.open(camIndex);
				camera.release();
				camera = null;
				isCanUse = true;
			}catch(Exception e){

			}
		}
		return isCanUse;
	}
}
