package com.qpidnetwork.livemodule.liveshow.home;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

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

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.btnBack:{
                finish();
            }break;
        }
    }
}
