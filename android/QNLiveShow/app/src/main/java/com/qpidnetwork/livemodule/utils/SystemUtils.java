package com.qpidnetwork.livemodule.utils;

import com.qpidnetwork.livemodule.httprequest.RequestJni;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import java.io.File;

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

}
