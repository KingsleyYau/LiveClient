package com.qpidnetwork.qnbridgemodule.util;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.v4.content.LocalBroadcastManager;

/**
 * Created by Hardy on 2016/5/31.
 * 广播的统一管理类
 * 采用 LocalBroadcastManager 来管理本应用内的广播
 */
public class BroadcastManager {

    /**
     * 注册广播
     *
     * @param context
     * @param receiver
     * @param filter
     */
    public static void registerReceiver(Context context, BroadcastReceiver receiver, IntentFilter filter) {
        if (context == null)
            return;
        LocalBroadcastManager.getInstance(context).registerReceiver(receiver, filter);
    }

    /**
     * 取消注册
     *
     * @param context
     * @param receiver
     */
    public static void unregisterReceiver(Context context, BroadcastReceiver receiver) {
        if (context == null)
            return;
        LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver);
    }

    /**
     * 发送广播
     *
     * @param context
     * @param intent
     */
    public static void sendBroadcast(Context context, Intent intent) {
        if (context == null)
            return;
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }
}



















