package com.qpidnetwork.qnbridgemodule.util;

import android.content.Context;
import android.text.TextUtils;
import android.widget.Toast;

/**
 * 解决多次点击导致Toast弹出时长累加，长时间无法取消
 * 
 * @author Hunter 2015.4.3
 * 
 */
public class ToastUtil {

	private static String oldMsg = "";
	private static Toast toast = null;
	private static long showTime = 0; // 上一次Toast提示时，系统时间

	public static void showToast(Context context, String s) {
		if(context == null || TextUtils.isEmpty(s)){
			return;
		}

		if (toast == null) {
//			toast = Toast.makeText(context, s, Toast.LENGTH_SHORT);

			// 2019/2/22 Hardy
			toast = Toast.makeText(context.getApplicationContext(), s, Toast.LENGTH_SHORT);
		} else {
			//相同且时间间距过短时不重复显示
			if ((s.equals(oldMsg))
					&& (System.currentTimeMillis() - showTime <= Toast.LENGTH_SHORT)) {
				return;
			}
		}
		toast.setText(s);
		toast.show();
		showTime = System.currentTimeMillis();
		oldMsg = s;
	}
	
	public static void showToast(Context context, int resId){
		showToast(context, context.getString(resId));
	}
}
