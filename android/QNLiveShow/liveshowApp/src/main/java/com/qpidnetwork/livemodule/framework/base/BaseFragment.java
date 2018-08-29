package com.qpidnetwork.livemodule.framework.base;


import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import java.lang.ref.WeakReference;

/**
 *
 */
public abstract class BaseFragment extends Fragment implements View.OnClickListener{

    protected String TAG = BaseFragment.class.getName();

    protected Context mContext;
    private boolean isNeedOnResume = true;
    //HOME键盘相关
    private HomeWatcherReceiver mHomeWatcherReceiver = null;
    private boolean isBack2Home = false;
    private long time2Home = 0;
    protected long timeIntervalFromHome = 60 * 1000;   //从HOME返回时间间隔

    @Override
    public void onAttach(Activity activity) {
        // TODO Auto-generated method stub
        super.onAttach(activity);
        mContext = activity;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        registerReceiver();
    }

    //https://blog.csdn.net/czhpxl007/article/details/51277319
    //
    //setUserVisibleHint->onAttach->onCreate->onCreateView->onActivityCreated---->onResume
    //                                                                         ^
    //                                                                     onReVisible
    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        if(mContext != null && !isNeedOnResume && isVisibleToUser){
            onReVisible();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        isNeedOnResume = false;
        //
        onReVisible();
        //
        if(isBack2Home && System.currentTimeMillis() - time2Home > timeIntervalFromHome){
            isBack2Home = false;
            onBackFromHomeInTimeInterval();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        isNeedOnResume = true;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unRegisterReceiver();
    }

    /**
     * Fragment重新可见时调用
     * 1.Fragment只有重新创建时才调用onResume
     * 2.setUserVisibleHint优先级太高，在onAttach前就被调用
     *
     * 这个方法作用相当于Activity的onResume
     * @add by Jagger 2018-7-13
     */
    protected void onReVisible(){

    }

    /**
     * 在指定的时间间隔内从HOME返回
     * setUserVisibleHint->onAttach->onCreate->onCreateView->onActivityCreated---->onResume
     *                                                                          ^
     *                                                             onBackFromHomeInTimeInterval
     */
    protected void onBackFromHomeInTimeInterval(){

    }

    @SuppressLint("HandlerLeak")
    protected Handler mUiHandler = new UiHandler(this) {
        public void handleMessage(android.os.Message msg) {
            super.handleMessage(msg);
            if (getFragmentReference() != null && getFragmentReference().get() != null) {
                handleUiMessage(msg);
            }
        }
    };

    private static class UiHandler extends Handler {
        private final WeakReference<Fragment> mFragmentReference;

        public UiHandler(Fragment activity) {
            mFragmentReference = new WeakReference<Fragment>(activity);
        }

        public WeakReference<Fragment> getFragmentReference() {
            return mFragmentReference;
        }
    }

    /**
     * 处理更新UI任务
     *
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
        Log.i(TAG, "handleUiMessage msg: " + msg.what);
        if(getActivity() == null){
            //已经deattach，异步不处理
            return;
        }
    }

    /**
     * 发送UI更新操作
     *
     * @param msg
     */
    protected void sendUiMessage(Message msg) {
        mUiHandler.sendMessage(msg);
    }

    protected void sendUiMessageDelayed(Message msg, long delayMillis) {
        mUiHandler.sendMessageDelayed(msg, delayMillis);
    }

    protected void postUiDelayed(Runnable runnable, long delay){
        mUiHandler.postDelayed(runnable, delay);
    }

    /**
     * 发送UI更新操作
     *
     * @param what
     */
    protected void sendEmptyUiMessage(int what) {
        mUiHandler.sendEmptyMessage(what);
    }

    protected void sendEmptyUiMessageDelayed(int what, long delayMillis) {
        mUiHandler.sendEmptyMessageDelayed(what, delayMillis);
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
    }

    private void registerReceiver() {
        mHomeWatcherReceiver = new HomeWatcherReceiver();
        IntentFilter filter = new IntentFilter(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
        getActivity().registerReceiver(mHomeWatcherReceiver, filter);
    }

    private void unRegisterReceiver(){
        if (mHomeWatcherReceiver != null) {
            try {
                getActivity().unregisterReceiver(mHomeWatcherReceiver);
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public class HomeWatcherReceiver extends BroadcastReceiver {

        private static final String SYSTEM_DIALOG_REASON_KEY = "reason";
//        private static final String SYSTEM_DIALOG_REASON_HOME_KEY = "homekey";

        @Override
        public void onReceive(Context context, Intent intent) {

            String intentAction = intent.getAction();
            Log.i("Jagger", "intentAction =" + intentAction);
            if (TextUtils.equals(intentAction, Intent.ACTION_CLOSE_SYSTEM_DIALOGS)) {
                String reason = intent.getStringExtra(SYSTEM_DIALOG_REASON_KEY);
                Log.i("Jagger", "reason =" + reason);
//                if (TextUtils.equals(SYSTEM_DIALOG_REASON_HOME_KEY, reason)) {
                    isBack2Home = true;
                    time2Home = System.currentTimeMillis();
//                }
            }
        }

    }
}
