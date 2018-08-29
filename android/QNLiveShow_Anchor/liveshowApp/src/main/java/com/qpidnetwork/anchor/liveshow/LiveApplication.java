package com.qpidnetwork.anchor.liveshow;

import android.content.Context;
import android.os.Build;
import android.os.StrictMode;
import android.support.multidex.MultiDex;
import android.support.multidex.MultiDexApplication;

import com.facebook.drawee.backends.pipeline.BuildConfig;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.picassocompat.PicassoHttpsSupportUtil;
import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.utils.CrashHandler;
import com.qpidnetwork.anchor.utils.CrashHandlerJni;
import com.qpidnetwork.anchor.utils.Log;

import net.qdating.LSConfig;

/**
 * Created by Harry on 2017/5/16.
 */

public class LiveApplication extends MultiDexApplication {
    private static Context mContext;
    private static final String TAG = LiveApplication.class.getSimpleName();
    public static boolean isDemo = false;

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        Log.d(TAG,"attachBaseContext");
        MultiDex.install(this);
        setStrictMode();
        mContext = this;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        // 获取是否demo标志
        isDemo = getResources().getBoolean(R.bool.demo);

        //FileCacheManager 单例初始化
        FileCacheManager.newInstance(this);
        // Jni错误捕捉(需要先于httprequest库加载，httprequest库对CrashHandler库有依赖)
        CrashHandlerJni.SetCrashLogDirectory(FileCacheManager.getInstance().getCrashInfoPath());

        //Application初始化
        LiveService.newInstance(this);

        //Java Crash日志管理
        CrashHandler.newInstance(this);
        CrashHandler.getInstance().SaveAppVersionFile();

        //Picasso 单例支持https和本地缓存
        PicassoHttpsSupportUtil.openHttpsSupport(this);
    }

    private void setStrictMode() {
        if (BuildConfig.DEBUG && Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            StrictMode.enableDefaults();
        }
    }


    /**
     * 获取全局的context
     */
    public static Context getContext() {
        return mContext;
    }
}
