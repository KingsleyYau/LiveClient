package com.qpidnetwork.anchor.liveshow.hangout;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.anchor.framework.base.BaseListFragment;
import com.qpidnetwork.anchor.liveshow.personal.scheduleinvite.ConfirmedInviteFragment;

import java.lang.ref.SoftReference;

/**
 * Created by Hunter Mun on 2018/5/14.
 */

public class OngoingHangoutListActivity extends BaseActionBarFragmentActivity {

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_hangout_knocklist);

        //状态栏颜色
//        StatusBarUtil.setColor(this,Color.WHITE,0);
        //设置头
        setTitle(getString(R.string.hangout_list_knock_title), Color.BLACK);
        initViews();
    }

    private void initViews(){
        BaseListFragment fragment = new OngoingHangoutListFragment();

        //替换内部页
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.replace(R.id.flContent, fragment);
        transaction.commit();
    }
}
