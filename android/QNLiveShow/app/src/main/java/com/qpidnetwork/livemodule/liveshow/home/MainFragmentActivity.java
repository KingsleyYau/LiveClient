package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.personal.PersonalCenterActivity;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

public class MainFragmentActivity extends BaseFragmentActivity {

    //头部
    private FrameLayout btnBack;
    private TabPageIndicator tabPageIndicator;

    //内容
    private ViewPager viewPagerContent;
    private MainFragmentPagerAdapter mAdapter;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setContentView(R.layout.activity_main);
        initView();
        Log.i("hunter", "MainFragmentActivity onCreate");
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Bundle bundle = intent.getExtras();
        Log.i("hunter", "MainFragmentActivity onNewIntetn");
        if(bundle != null){
            if(bundle.containsKey("event")){
                String value = bundle.getString("event");
                Log.i("hunter", "MainFragmentActivity onNewIntetn value: " + value);
                if(value.equals("kickoff")){
                    showKickOffDialog();
                }
            }
        }
    }

    private void initView(){
        btnBack = (FrameLayout) findViewById(R.id.btnBack);
        btnBack.setOnClickListener(this);
        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);

        viewPagerContent = (ViewPager) findViewById(R.id.viewPagerContent);

        //初始化viewpager
        mAdapter = new MainFragmentPagerAdapter(this);
        viewPagerContent.setAdapter(mAdapter);
        tabPageIndicator.setViewPager(viewPagerContent);

        // 设置控件的模式，一定要先设置模式
        tabPageIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tabPageIndicator.setDividerColor(Color.TRANSPARENT);
        //无未读条数
        tabPageIndicator.setHasDigitalHint(false);
        //设置中间竖线上下的padding值
        tabPageIndicator.setDividerPadding(DisplayUtil.dip2px(LiveApplication.getContext(), 10));

    }

    /**
     * 切换到页
     * @param pageId
     */
    public void setCurrentPager(int pageId){
        viewPagerContent.setCurrentItem(pageId);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.btnBack:{
                finish();
            }break;
            case R.id.rlPersonalCenter:{
                Intent intent = new Intent(this, PersonalCenterActivity.class);
                startActivity(intent);
            }break;
        }
    }

    /**
     * 被踢提示
     */
    private void showKickOffDialog(){
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setCancelable(false);
        dialog.setMessage("Your account logined on another device. Please login again.");
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //被踢
                LoginManager.getInstance().logout();

                Intent intent = new Intent(MainFragmentActivity.this, PeacockActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                finish();
            }
        }));
        dialog.show();
    }

}
