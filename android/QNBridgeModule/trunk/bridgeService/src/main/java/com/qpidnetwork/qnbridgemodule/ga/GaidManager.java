package com.qpidnetwork.qnbridgemodule.ga;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.qpidnetwork.qnbridgemodule.appsflyer.AppsFlyerSpUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ThreadPoolExecutorUtil;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2018/11/8.
 * <p>
 * google play service 获取广告 id 的管理类
 */
public class GaidManager {

    private static String TAG = "info";

    private static GaidManager gaidManager;

    private Context mContext;
    private Handler mHandler;
    private String gaid;

    private List<OnGetGaidCallback> mCallbackList;

    public static GaidManager newInstance(Context context) {
        if (null == gaidManager) {
            gaidManager = new GaidManager(context);
        }
        return gaidManager;
    }

    public static GaidManager getInstance() {
        return gaidManager;
    }

    private GaidManager(Context context) {
        this.mContext = context.getApplicationContext();

        mHandler = new Handler(Looper.getMainLooper());
        mCallbackList = new ArrayList<>();
    }

    private void addGaidCallback(OnGetGaidCallback callback) {
        synchronized (mCallbackList) {
            if (mCallbackList != null) {
                mCallbackList.add(callback);
            }
        }
    }

    private void onGaidCallbackListUpdate(String gaid) {
        synchronized (mCallbackList) {
            for (OnGetGaidCallback callback : mCallbackList) {
                callback.onGetGaid(gaid);
            }

            // 立即解绑
            if (mCallbackList != null) {
                mCallbackList.clear();
            }
        }
    }

    public void loadGaid(OnGetGaidCallback onGetGaidCallback) {
        addGaidCallback(onGetGaidCallback);

        if (TextUtils.isEmpty(gaid)) {
            gaid = AppsFlyerSpUtil.getGaidSp(mContext);
        }
        Log.i(TAG, "loadGaid from sp----------> gaid: " + gaid);
        if (!TextUtils.isEmpty(gaid)) {
            handlerGaidCallback(gaid);
        }else {
            ThreadPoolExecutorUtil.doTask(new Runnable() {
                @Override
                public void run() {
                    String id = "";
                    try {
                        //com.google.android.gms.common.GooglePlayServicesNotAvailableException
                        //因没Google服务
                        AdvertisingIdClient.Info info = AdvertisingIdClient.getAdvertisingIdInfo(mContext);

                        if (info != null) {
                            id = info.getId();

                            Log.i(TAG, "ThreadPoolExecutorUtil gaid: " + id + "---> id: " + Thread.currentThread().getId());

                            AppsFlyerSpUtil.saveGaidSp(mContext, id);
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        handlerGaidCallback(id);
                    }
                }
            });
        }
    }


    //=====================     interface   ==============================

    private void handlerGaidCallback(final String gaid) {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                Log.i(TAG, "mHandler gaid: " + gaid + "---> id: " + Thread.currentThread().getId());

                onGaidCallbackListUpdate(gaid);
            }
        });

    }

    public interface OnGetGaidCallback {
        // UI 线程
        void onGetGaid(String gaid);
    }
    //=====================     interface   ==============================
}
