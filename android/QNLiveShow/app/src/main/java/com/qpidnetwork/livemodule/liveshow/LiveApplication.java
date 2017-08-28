package com.qpidnetwork.livemodule.liveshow;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.StrictMode;
import android.support.multidex.MultiDex;
import android.support.multidex.MultiDexApplication;
import android.telephony.TelephonyManager;

import com.facebook.drawee.backends.pipeline.BuildConfig;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.CrashHandler;
import com.qpidnetwork.livemodule.utils.CrashHandlerJni;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

/**
 * Created by Harry on 2017/5/16.
 */

public class LiveApplication extends MultiDexApplication {
    private static Context mContext;
    private static final String TAG = LiveApplication.class.getSimpleName();

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
        // 设置log级别（demo环境才打印log）
//        if (ApplicationSettingUtil.isDemoEnviroment(this)) {
//            Log.SetLevel(android.util.Log.DEBUG);
//        }
//        else {
//            Log.SetLevel(android.util.Log.ERROR);
//        }

        //FileCacheManager 单例初始化
        FileCacheManager.newInstance(this);
        FileDownloadManager.init(this,true);
        //Java Crash日志管理
        CrashHandler.newInstance(this);
        CrashHandler.getInstance().SaveAppVersionFile();

        // Jni错误捕捉
        CrashHandlerJni.SetCrashLogDirectory(FileCacheManager.getInstance().getCrashInfoPath());

        //http请求Jni初始化
        try {
            PackageManager pm = getPackageManager();
            PackageInfo pi = pm.getPackageInfo(getPackageName(), PackageManager.GET_ACTIVITIES);
            if (pi != null) {
                //本地文件Log存放地址
                RequestJni.SetLogDirectory(FileCacheManager.getInstance().getLogPath());
                RequestJni.SetWebSite("http://172.25.32.17:3007");
                RequestJni.SetPhotoUploadSite("http://172.25.32.17:82");
//                RequestJni.SetWebSite("http://192.168.88.90:8881");
                // 版本号
                RequestJni.SetVersionCode(String.valueOf(pi.versionCode));
                // 设备Id
                TelephonyManager tm = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
                RequestJni.SetDeviceId(SystemUtils.getDeviceId(this));
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        //初始化LoginManager单例
        LoginManager loginManager = LoginManager.newInstance(this);

        //初始化IMManager
        IMManager imManager = IMManager.newInstance(this);
        loginManager.register(imManager);

        //Fresco库初始化
        Fresco.initialize(this);

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
