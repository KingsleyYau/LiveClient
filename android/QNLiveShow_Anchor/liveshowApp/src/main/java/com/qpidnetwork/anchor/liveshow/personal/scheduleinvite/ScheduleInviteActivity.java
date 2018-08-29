package com.qpidnetwork.anchor.liveshow.personal.scheduleinvite;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.anchor.framework.base.BaseListFragment;
import com.qpidnetwork.anchor.framework.widget.statusbar.StatusBarUtil;

import java.lang.ref.SoftReference;

/**
 * Created by Hunter on 17/9/30.
 */

public class ScheduleInviteActivity extends BaseActionBarFragmentActivity{

    private SoftReference<BaseListFragment> mFragmentCache = null;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_schedule_invite);

        //状态栏颜色
//        StatusBarUtil.setColor(this,Color.WHITE,0);
        //设置头
        setTitle(getString(R.string.my_schedule_invite_title), Color.BLACK);
        initViews();
        //注册时间接收器
        registerTimeChangeReceier();
    }

    private void initViews(){
        BaseListFragment fragment = new ConfirmedInviteFragment();
        mFragmentCache = new SoftReference<BaseListFragment>(fragment);

        //替换内部页
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.flContent, fragment);
        transaction.commit();
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterTimeChangeReceier();
    }

    /*****************************  添加系统时间修改监听器，用于处理系统时间修改导致Timer挂起  *********************************/
    private BroadcastReceiver timeChangeReciver = new BroadcastReceiver(){
        public void onReceive(android.content.Context context, android.content.Intent intent) {
            String action = intent.getAction();
            if(action.equals(Intent.ACTION_TIME_CHANGED)
                    || action.equals(Intent.ACTION_DATE_CHANGED)){
                //系统时间修改，通知模块
                if(mFragmentCache != null) {
                    if (null != mFragmentCache && mFragmentCache.get() != null
                            && mFragmentCache.get() instanceof ConfirmedInviteFragment) {
                        ((ConfirmedInviteFragment) (mFragmentCache.get())).onSystemTimeChange();
                    }
                }
            }
        };
    };

    /**
     * 注册系统时间通知接收器
     */
    private void registerTimeChangeReceier(){
        //添加广播接收器，解决列表到设置修改系统时间导致定时器挂起的问题
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_TIME_CHANGED);
        filter.addAction(Intent.ACTION_DATE_CHANGED);
        this.registerReceiver(timeChangeReciver, filter);
    }

    /**
     * 注销系统时间通知广播接收器
     */
    private void unregisterTimeChangeReceier(){
        try {
            if(timeChangeReciver != null){
                unregisterReceiver(timeChangeReciver);
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
