package com.qpidnetwork.livemodule.liveshow.manager;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.FileSizeUtil;

import java.text.DecimalFormat;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by Hardy on 2018/10/30.
 * 清理缓存管理类
 */
public class LiveCleanCacheManager {

    private static final String TAG = "info";
    //
    private static final String SP_FILE_NAME = "qn_live_cache_file";
    private static final String SP_FILE_NAME_TIME = "qn_live_cache_file_time";
    private static final String SP_FILE_NAME_SIZE = "qn_live_cache_file_size";
    //
    public static final String DEFAULT_CACHE_SIZE = "0m";

    private Context mContext;

    private Disposable mDCleanCache;    // 清理缓存接收器
    private Disposable mDLoadCache;     // 加载缓存接收器


    public LiveCleanCacheManager(Context mContext) {
        this.mContext = mContext;
    }

    public void onDestroy() {
        if (mDCleanCache != null) {
            mDCleanCache.dispose();
            mDCleanCache = null;
        }
        if (mDLoadCache != null) {
            mDLoadCache.dispose();
            mDLoadCache = null;
        }
    }

    private void Logi(String val) {
        com.qpidnetwork.qnbridgemodule.util.Log.i(TAG, val);
    }

    private void saveTimeAndCacheSize(long time, String size) {
        Logi("saveTimeAndCacheSize ----> start");

        SharedPreferences sp = mContext.getSharedPreferences(SP_FILE_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putLong(SP_FILE_NAME_TIME, time);
        editor.putString(SP_FILE_NAME_SIZE, size);

//        2018/11/2 Hardy
        // 由于清理缓存进行 io 操作，占用 cpu 稍高，此时再同步进行提交 sp，写 xml 文件，会导致在等待 cpu 释放资源后
        // 才能进行提交，经测试，这里会耗时 5s 左右的等待时间，进而卡住 ui 线程，导致 ANR。
        // 若放在新线程进行该提交操作，经测试，耗时时间一样，只不过不会卡住 ui 线程而导致 ANR
        // 在这里，由于对提交结果不实时关心，直接异步提交即可。
//        editor.commit();  // 同步阻塞提交

        // 异步提交
        editor.apply();

        Logi("saveTimeAndCacheSize ----> end");
    }

    private long getSpTime() {
        long time = 0;
        SharedPreferences sp = mContext.getSharedPreferences(SP_FILE_NAME, Context.MODE_PRIVATE);
        time = sp.getLong(SP_FILE_NAME_TIME, 0);
        return time;
    }

    private String getSpCacheSize() {
        String val = DEFAULT_CACHE_SIZE;
        SharedPreferences sp = mContext.getSharedPreferences(SP_FILE_NAME, Context.MODE_PRIVATE);
        val = sp.getString(SP_FILE_NAME_SIZE, val);
        return val;
    }

    private boolean isOverOneDay() {
        long curTime = System.currentTimeMillis() / 1000;
        long lastTime = getSpTime();

        return curTime - lastTime >= 3600;
    }


//    private long mLastTimeLoad;
//    private long mLastTimeClean;

    public void showCleanCacheDialog() {
        // 2018/10/29
        // 引用系统的样式
        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setMessage(mContext.getString(R.string.myprofile_sure_clean_cache));
        builder.setPositiveButton(mContext.getString(R.string.common_btn_ok), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                cleanCacheSize();
                LoginManager.getInstance().LogoutAndClean(true);
            }
        });
        builder.setNegativeButton(mContext.getString(R.string.common_btn_cancel), null);
        builder.create().show();
    }


    /**
     * 清理缓存
     */
    private void cleanCacheSize() {
        onStartCleaning();

        Observable<Boolean> observable = Observable.create(new ObservableOnSubscribe<Boolean>() {

            @Override
            public void subscribe(final ObservableEmitter<Boolean> emitter) {
                Logi("cleanCacheSize subscribe: " + Thread.currentThread().getId());

//                mLastTimeClean = System.currentTimeMillis();
//                Logi("cleanCacheSize ----> start time: " + mLastTimeClean);

                FileCacheManager.getInstance().ClearCache();

                emitter.onNext(true);
            }
        });

        mDCleanCache = observable.subscribeOn(Schedulers.newThread())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Boolean>() {
                    @Override
                    public void accept(Boolean value) throws Exception {
                        Logi("cleanCacheSize accept: " + Thread.currentThread().getId());

//                        long endTime = System.currentTimeMillis();
//                        Logi("cleanCacheSize ----> end time: " + endTime);
//                        Logi("cleanCacheSize ----> total time: " + (endTime - mLastTimeClean));

                        onCleanCompleted();

                        //清除完成，注销会自动关闭当前页面回主界面，弹出dialog会leakedwindow
                        // dialog
//                        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
//                        builder.setMessage("All cache has been clean!");
//                        builder.setPositiveButton(mContext.getString(R.string.common_btn_ok), null);
//                        builder.create().show();
                    }
                });
    }

    /**
     * 获取缓存大小
     */
    public void loadCacheSize() {
        // 超过 1 天，才获取真实的缓存大小
        if (!isOverOneDay()) {
            String val = getSpCacheSize();
            Logi("isOverOneDay not: " + val);
            onCacheFileSize(val);
            return;
        }

        Observable<Double> observable = Observable.create(new ObservableOnSubscribe<Double>() {

            @Override
            public void subscribe(final ObservableEmitter<Double> emitter) {
                Logi("subscribe: " + Thread.currentThread().getId());

//                mLastTimeLoad = System.currentTimeMillis();
//                Logi("loadCacheSize ----> start time: " + mLastTimeLoad);

                double d = FileSizeUtil.getFileOrFilesSize(FileCacheManager.getInstance().getFileCacheHomePath(), FileSizeUtil.SIZETYPE_MB);

                emitter.onNext(d);
            }
        });

        mDLoadCache = observable.subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Double>() {
                    @Override
                    public void accept(Double aDouble) throws Exception {
                        Logi("accept: " + Thread.currentThread().getId());

//                        long endTime = System.currentTimeMillis();
//                        Logi("loadCacheSize ----> end time: " + endTime);
//                        Logi("loadCacheSize ----> total time: " + (endTime - mLastTimeLoad));

                        double valD = aDouble.doubleValue();
                        if (valD < 0) {
                            valD = 0;
                        }
                        DecimalFormat df = new DecimalFormat("#");
                        String val = df.format(valD) + "m";

                        // 回调外层
                        onCacheFileSize(val);
                    }
                });
    }


    /**
     * UI 线程
     * 开始清理缓存
     */
    public void onStartCleaning() {

    }

    /**
     * UI 线程
     * 告诉外层，清理完毕...
     */
    public void onCleanCompleted() {
        saveTimeAndCacheSize(0, "");
    }

    /**
     * UI 线程
     * 告诉外层，缓存文件夹的大小
     *
     * @param sizeVal
     */
    public void onCacheFileSize(String sizeVal) {
        saveTimeAndCacheSize(System.currentTimeMillis() / 1000, sizeVal);
    }


}
