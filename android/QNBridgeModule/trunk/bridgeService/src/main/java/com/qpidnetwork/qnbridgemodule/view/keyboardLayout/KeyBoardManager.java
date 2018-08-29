package com.qpidnetwork.qnbridgemodule.view.keyboardLayout;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

/**
 * 系统软键盘相关
 * @author Hunter Mun
 * @since 2016.11.15
 */
public class KeyBoardManager {
	private static final String KEYBOARDPREFERENCE = "liveVirtualKeyboard";
	private static final String KEYBOARD_HEIGHT_KEY = "keyboardHeight";
	
	/**
	 * 存储keyboardHeight
	 * @param keyboardHeight
	 */
	public static void saveKeyboardHeight(Context context, int keyboardHeight){
		SharedPreferences pref = context.getSharedPreferences(KEYBOARDPREFERENCE, Context.MODE_PRIVATE);
		Editor eidtor = pref.edit();
		eidtor.putInt(KEYBOARD_HEIGHT_KEY, keyboardHeight);
		eidtor.commit();
	}
	
	/**
	 * 获取KeyboardHeight
	 * @return
	 */
	public static int getKeyboardHeight(Context context){
		int keyboardHeight = -1;
		SharedPreferences pref = context.getSharedPreferences(KEYBOARDPREFERENCE, Context.MODE_PRIVATE);
		keyboardHeight = pref.getInt(KEYBOARD_HEIGHT_KEY, -1);
		return keyboardHeight;
	}
}
