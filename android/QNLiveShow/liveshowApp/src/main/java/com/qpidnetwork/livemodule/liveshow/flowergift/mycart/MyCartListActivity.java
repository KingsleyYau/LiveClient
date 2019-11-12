package com.qpidnetwork.livemodule.liveshow.flowergift.mycart;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mycontact.MyContactListFragment;
import com.qpidnetwork.qnbridgemodule.util.FragmentUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;

/**
 * 2019/10/8 Jagger
 * My Carts 列表
 */
public class MyCartListActivity extends BaseActionBarFragmentActivity implements MyCartListFragment.onCartEventListener,  SoftKeyboardSizeWatchLayout.OnResizeListener {

    private SoftKeyboardSizeWatchLayout sl_root;

    /**
     * 启动方式
     */
    public static void startAct(Context context) {
        Intent intent = new Intent(context, MyCartListActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_fl_mycart);

        initView();
        initData();
    }

    private void initView() {
        setOnlyTitle(getString(R.string.my_cart_title));
        sl_root = findViewById(R.id.sl_root);
        sl_root.addOnResizeListener(this);

        // add fragment
        MyCartListFragment fragment = new MyCartListFragment();
        FragmentUtils.addFragment(getSupportFragmentManager(), fragment, R.id.activity_fl_content);
        fragment.setOnCartEventListener(this);
    }

    private void initData() {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //解绑监听器，防止泄漏
        if (sl_root != null) {
            sl_root.removeOnResizeListener(this);
        }
    }

    @Override
    public void onGroupsSumRefresh(int sum) {
        //更新 标题
//        setOnlyTitle(getString(R.string.my_cart_title) + "(" + sum + ")");
    }

    @Override
    public void OnSoftPop(int height) {

    }

    @Override
    public void OnSoftClose() {
        // sl_root布局中加入android:focusable="true" android:focusableInTouchMode="true"，
        // 配合MyCartItemAdapter中EditText焦点改变事件，判断是否输入完成
        sl_root.requestFocus();
    }
}
