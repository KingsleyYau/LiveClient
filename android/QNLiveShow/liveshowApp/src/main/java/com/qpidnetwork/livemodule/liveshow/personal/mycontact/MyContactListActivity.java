package com.qpidnetwork.livemodule.liveshow.personal.mycontact;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.qnbridgemodule.util.FragmentUtils;

/**
 * 2019/8/9 Hardy
 * My Contacts 列表
 */
public class MyContactListActivity extends BaseActionBarFragmentActivity {


    /**
     * 启动方式
     */
    public static void startAct(Context context) {
        Intent intent = new Intent(context, MyContactListActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_fl_content_normal);

        initView();
        initData();
    }

    private void initView() {
        setOnlyTitle("My Contacts");

        // add fragment
        MyContactListFragment fragment = new MyContactListFragment();
        FragmentUtils.addFragment(getSupportFragmentManager(), fragment, R.id.activity_fl_content);
    }

    private void initData() {

    }
}
