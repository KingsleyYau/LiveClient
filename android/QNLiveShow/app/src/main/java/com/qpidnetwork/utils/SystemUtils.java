package com.qpidnetwork.utils;

import com.qpidnetwork.httprequest.RequestJni;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;

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

}
