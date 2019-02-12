package com.qpidnetwork.qnbridgemodule.util;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import java.util.ArrayList;
import java.util.List;

/**
 * 应用前后台状态监听帮助类，仅在Application中使用
 * 参考:https://blog.csdn.net/bzlj2912009596/article/details/80073396
 */
public class AppFrontBackHelper {
    private List<OnAppStatusListener> mOnAppStatusListeners;
    private Application mApplication;
    private long time2Home = 0;

    private static AppFrontBackHelper instance = null;

    public static AppFrontBackHelper newInstance(Application application) {
        if (instance == null) {
            instance = new AppFrontBackHelper(application);
        }
        return instance;
    }

    public static synchronized AppFrontBackHelper getInstance() {
        return instance;
    }

    private AppFrontBackHelper(Application application){
        mApplication = application;
        mApplication.registerActivityLifecycleCallbacks(activityLifecycleCallbacks);
        mOnAppStatusListeners = new ArrayList<>();
    }

    public void destroy(){
        mApplication.unregisterActivityLifecycleCallbacks(activityLifecycleCallbacks);
    }

    /**
     * 注册状态监听
     * @param listener
     */
    public void register(OnAppStatusListener listener){
        mOnAppStatusListeners.add(listener);
    }

    public void unRegister(OnAppStatusListener listener){
        if(mOnAppStatusListeners.contains(listener)){
            mOnAppStatusListeners.remove(listener);
        }
    }

    /**
     * 切到后台一刻 毫秒
     * @return
     */
    public long getTheTime2Home() {
        return time2Home;
    }

    private Application.ActivityLifecycleCallbacks activityLifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {
        //打开的Activity数量统计
        private int activityStartCount = 0;

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

        }

        @Override
        public void onActivityStarted(Activity activity) {
            activityStartCount++;
            //数值从0变到1说明是从后台切到前台
            if (activityStartCount == 1){
                //从后台切到前台
                for (OnAppStatusListener listener:mOnAppStatusListeners ) {
                    listener.onFront();
                }
            }
        }

        @Override
        public void onActivityResumed(Activity activity) {

        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {
            activityStartCount--;
            //数值从1到0说明是从前台切到后台
            if (activityStartCount == 0){
                //从前台切到后台
                time2Home = System.currentTimeMillis();
                for (OnAppStatusListener listener:mOnAppStatusListeners ) {
                    listener.onBack();
                }
            }
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }
    };

    public interface OnAppStatusListener{
        void onFront();
        void onBack();
    }

}
