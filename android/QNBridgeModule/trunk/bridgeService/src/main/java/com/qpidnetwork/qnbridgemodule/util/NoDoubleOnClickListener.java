package com.qpidnetwork.qnbridgemodule.util;

import android.view.View;

/**
 * Created by Hardy on 16/6/16.
 */
public abstract class NoDoubleOnClickListener implements View.OnClickListener {

    // 间隔时间越大，效果越好
    private static final long INTERVAL_TIME = 1000;

    private long startTime = 0;

    @Override
    public void onClick(View v) {
        long clickTime = System.currentTimeMillis();
        if (isCanOnClick(startTime, clickTime)) {
            startTime = clickTime;
            onNoDoubleClick(v);
        }
    }


    public static boolean isCanOnClick(long startTime, long clickTime) {
        if (clickTime - startTime > INTERVAL_TIME) {
            return true;
        } else {
            return false;
        }
    }


    public abstract void onNoDoubleClick(View v);
}
