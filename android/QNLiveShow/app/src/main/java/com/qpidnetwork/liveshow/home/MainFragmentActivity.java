package com.qpidnetwork.liveshow.home;

import android.os.Bundle;
import android.support.v4.app.FragmentTabHost;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TabHost;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.liveshow.home.hometab.MainTabFragment;
import com.qpidnetwork.utils.DisplayUtil;

/**
 * FragmentTabHost+Fragment+TabPageIndecator+Fragment方式实现双导航
 */
public class MainFragmentActivity extends BaseFragmentActivity implements TabHost.OnTabChangeListener {

    private FragmentTabHost fragTabHost =null;
    private static final Class[] fragmentClassz = new Class[]{MainTabFragment.class, StartLiveFragment.class,
            PersonInfoFragment.class};
    private static String[] tabStrs = null;
    private ImageView iv_mainTab,iv_mobileLive,iv_personCenter;
    private View view_mainButtomTabs;
    public int lastSelectedPosition = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.GONE);
        initData();
        initView();
        updateButtomTabStyle(lastSelectedPosition);
    }

    private void initData(){
        postUiRunnableDelayed(new Runnable() {
            @Override
            public void run() {
                //获取状态栏高度, 用于全局使用
                int statusHeight = DisplayUtil.getStatusBarHeight(mContext);
                if(statusHeight > 0){
                    new LocalPreferenceManager(mContext).saveStatusBarHeight(statusHeight);
                }
            }
        }, 200);
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.fragment_activity_main;
    }

    private void initView(){
        iv_mainTab = (ImageView) findViewById(R.id.iv_mainTab);
        iv_mobileLive = (ImageView) findViewById(R.id.iv_mobileLive);
        iv_personCenter = (ImageView) findViewById(R.id.iv_personCenter);
        view_mainButtomTabs = findViewById(R.id.view_mainButtomTabs);
        fragTabHost = (FragmentTabHost) super.findViewById(android.R.id.tabhost);
        fragTabHost.setup(MainFragmentActivity.this, getSupportFragmentManager(),android.R.id.tabcontent);
        fragTabHost.getTabWidget().setDividerDrawable(null);
        fragTabHost.setOnTabChangedListener(this);
        tabStrs = getResources().getStringArray(R.array.buttomTabs);
        TabHost.TabSpec tabSpec = null;
        String tabStr = null;
        Bundle bundle = null;
        for (int index = 0; index < fragmentClassz.length; index++) {
            tabStr = tabStrs[index];
            tabSpec = fragTabHost.newTabSpec(tabStr).setIndicator(tabStr);
            fragTabHost.addTab(tabSpec, fragmentClassz[index], null);
            fragTabHost.setTag(index);
        }

    }

    @Override
    public void onClick(View view){
        super.onClick(view);
        switch (view.getId()){
            case R.id.ll_mainTab:
                updateButtomTabStyle(0);
                break;
            case R.id.ll_mobileLive:
                updateButtomTabStyle(1);
                break;
            case R.id.ll_personCenter:
                updateButtomTabStyle(2);
                break;
        }
    }

    public void updateButtomTabStyle(int position){
        if(null != fragTabHost){
            fragTabHost.setCurrentTab(position);
        }
        if(1 == position){
            view_mainButtomTabs.setVisibility(View.GONE);
        }else{
            view_mainButtomTabs.setVisibility(View.VISIBLE);
            lastSelectedPosition = position;
        }

        iv_mainTab.setSelected(0 == position);
        iv_mobileLive.setSelected(1 == position);
        iv_personCenter.setSelected(2 == position);

    }

    @Override
    public void onTabChanged(String tabId) {
        Log.d(TAG,"onTabChanged-tabId:"+tabId);
    }
}
