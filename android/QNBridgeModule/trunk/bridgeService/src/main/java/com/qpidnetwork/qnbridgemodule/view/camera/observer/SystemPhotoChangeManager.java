package com.qpidnetwork.qnbridgemodule.view.camera.observer;

import android.content.Context;
import android.provider.MediaStore;

import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumDataHolderManager;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by Hardy on 2019/5/23.
 * 监听系统相册变化的管理类
 */
public class SystemPhotoChangeManager {

    private static SystemPhotoChangeManager instance;

    private Context mContext;

    private SystemPhotoChangeContentObserver photoChangeContentObserver;

    private ArrayList<SystemPhotoChangeListener> mListeners;

    public static SystemPhotoChangeManager getInstance(Context mContext) {
        if (instance == null) {
            instance = new SystemPhotoChangeManager(mContext);
        }

        return instance;
    }

    private SystemPhotoChangeManager(Context mContext) {
        this.mContext = mContext.getApplicationContext();

        mListeners = new ArrayList<>();
    }

    /**
     * 开启监听变化
     */
    public void startWatch() {
        if (photoChangeContentObserver == null) {
            photoChangeContentObserver = new SystemPhotoChangeContentObserver(mContext, null,
                    new SystemPhotoChangeContentObserver.OnPhotoChangeListener() {
                        @Override
                        public void onPhotoChange() {
                            // 2019/5/23 通知外层更新 UI
                            List<ImageBean> list = AlbumDataHolderManager.getInstance().getDataList();

                            onUpdateListener(list);
                        }
                    });
        }

        // 注册监听
        mContext.getContentResolver()
                .registerContentObserver(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        false, photoChangeContentObserver);
    }

    /**
     * 停止监听变化
     */
    public void stopWatch() {
        // 反注册
        mContext.getContentResolver().unregisterContentObserver(photoChangeContentObserver);
        photoChangeContentObserver = null;
    }

    public void onDestroy() {
        // TODO: 2019/5/23  
    }

    /**
     * 更新通知 listener
     */
    private void onUpdateListener(List<ImageBean> list) {
        synchronized (mListeners) {
            for (Iterator<SystemPhotoChangeListener> iter = mListeners.iterator(); iter.hasNext(); ) {
                SystemPhotoChangeListener listener = iter.next();
                listener.onSystemPhotoChange(list);
            }
        }
    }

    /**
     * 注销回调
     */
    public boolean unregisterListener(SystemPhotoChangeListener listener) {
        boolean result = false;

        synchronized (mListeners) {
            result = mListeners.remove(listener);
        }

        if (!result) {
            Log.e("livechat", String.format("%s::%s() fail, listener:%s", "SystemPhotoChangeManager", "SystemPhotoChangeListener", listener.getClass().getSimpleName()));
        }

        return result;
    }

    /**
     * 注册回调
     */
    public boolean registerListener(SystemPhotoChangeListener listener) {
        boolean result = false;

        synchronized (mListeners) {
            if (null != listener) {
                boolean isExist = false;

                for (Iterator<SystemPhotoChangeListener> iter = mListeners.iterator(); iter.hasNext(); ) {
                    SystemPhotoChangeListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mListeners.add(listener);
                } else {
                    Log.d("livechat", String.format("%s::%s() fail, listener:%s is exist", "SystemPhotoChangeManager", "SystemPhotoChangeListener", listener.getClass().getSimpleName()));
                }
            } else {
                Log.e("livechat", String.format("%s::%s() fail, listener is null", "SystemPhotoChangeManager", "SystemPhotoChangeListener"));
            }
        }

        return result;
    }
}
