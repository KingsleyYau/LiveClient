package com.qpidnetwork.livemodule.liveshow.promotion;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.utils.Log;

import java.net.URLDecoder;

/**
 * 用于接收app安装广播(推广使用)
 * @author Samson Fan
 *
 */
public class InstallReferrerReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(Context context, Intent intent) {
		// TODO Auto-generated method stub
		// 获取广播参数字符串
		String utm_referrer = "";
		String referrer = intent.getStringExtra("referrer");
		// 处理广播参数字符串
		if (!TextUtils.isEmpty(referrer)) {
			try {
				utm_referrer = URLDecoder.decode(referrer, "US-ASCII");
			} catch (Exception e) {
				// TODO: handle exception
			}
			Log.e("InstallReferrerReceiver", "referrer:%s", referrer);
		}
		else {
			Log.e("InstallReferrerReceiver", "referrer is empty");
		}
		//本地存储utm_reference字符串
		new LocalPreferenceManager(context).savePromotionUtmReference(utm_referrer);
	}
}
