package com.qpidnetwork.qnbridgemodule.view.camera.observer;

import android.content.Context;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.qpidnetwork.qnbridgemodule.view.camera.AlbumDataHolderManager;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumHelper;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.List;

/**
 * Created by Hardy on 2019/5/22.
 * <p>
 * 监听系统相册，增加/删除的操作
 */
public class SystemPhotoChangeContentObserver extends ContentObserver {

    private String TAG = "info";

    // 记录 onChange 时间戳
    private static final long TIME_INTERVAL = 1000;
    private long lastChangeTime;

    private Context mContext;
    // 回调 UI 线程
    private Handler mHandler;
    // 是否过滤 png 图片
    private boolean isSortPng;

    private AlbumHelper albumHelper;

    /**
     * @param handler 为空，则 onChange 时在线程中执行
     *                不为空，则 onChange 跟随 handler 所在的线程执行
     */
    public SystemPhotoChangeContentObserver(Context context, Handler handler, boolean isSortPng,
                                            OnPhotoChangeListener onPhotoChangeListener) {
        super(handler);

        this.mContext = context;
        this.isSortPng = isSortPng;
        this.onPhotoChangeListener = onPhotoChangeListener;

        mHandler = new Handler(Looper.getMainLooper());
        albumHelper = new AlbumHelper(context);
    }

    /**
     * 用在直播模块，要过滤 png 图片
     */
    public SystemPhotoChangeContentObserver(Context context, Handler handler,
                                            OnPhotoChangeListener onPhotoChangeListener) {
        this(context, handler, true, onPhotoChangeListener);
    }


//    // Added in API level 16
//    @Override
//    public void onChange(boolean selfChange, Uri uri) {
//        Log.i(TAG, "-------------onChange---------------selfChange: " + selfChange +
//                "----thread id: " + Thread.currentThread().getId() + "----> uri: " + (uri != null ? uri.toString() : "null"));
//        super.onChange(selfChange, uri);
//    }


    //  Added in API level 1
    @Override
    public void onChange(boolean selfChange) {
        super.onChange(selfChange);

        Log.i(TAG, "-------------onChange---------------selfChange: " + selfChange +
                "----thread id: " + Thread.currentThread().getId());

        long nowTime = System.currentTimeMillis();
        if (nowTime - lastChangeTime < TIME_INTERVAL) {
            return;
        }

        // 记录当次有效时间
        lastChangeTime = System.currentTimeMillis();

        Log.i(TAG, "-------------onChange---------------selfChange: " + selfChange +
                "----thread id: " + Thread.currentThread().getId() + "------- inside--------");

        // 后台线程中执行：获取系统最新的图片
        List<ImageBean> list = null;
        if (isSortPng) {
            list = albumHelper.getAlbumImageListNoPng();
        } else {
            list = albumHelper.getAlbumImageList();
        }
        // 设置缓存持有
        AlbumDataHolderManager.getInstance().setDataList(list);


        // 回调 UI 线程，更新 UI
        if (onPhotoChangeListener != null) {
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    onPhotoChangeListener.onPhotoChange();
                }
            });
        }
    }


    private OnPhotoChangeListener onPhotoChangeListener;

    public interface OnPhotoChangeListener {
        void onPhotoChange();
    }
}
