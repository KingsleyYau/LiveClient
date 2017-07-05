package com.qpidnetwork.liveshow.welcome;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.liveshow.home.MainFragmentActivity;

/**
 * Description:新用户欢迎页
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class WelcomeActivity extends BaseFragmentActivity {


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.GONE);
    }

    @Override
    public void onClick(View view){
        super.onClick(view);
        switch (view.getId()){
            case R.id.tv_test:
                new LocalPreferenceManager(mContext).saveFirstLaunchFlags(true);
                startActivity(new Intent(WelcomeActivity.this, MainFragmentActivity.class));
                this.finish();
                break;
        }
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.activity_welcome;
    }


}
