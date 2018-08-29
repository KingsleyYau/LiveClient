package com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.lang.ref.SoftReference;
import java.util.HashMap;

/**
 * Created by Hunter on 17/9/30.
 */

public class ScheduleInviteActivity extends BaseActionBarFragmentActivity
        implements ViewPager.OnPageChangeListener,
        ScheduleInvitePackageUnreadManager.OnUnreadListener{

    private static final String DEFAULT_SELECT_PAGE_INDEX = "pageIndex";
    private HashMap<Integer, SoftReference<BaseListFragment>> mLocalCache = null;
    private TabPageIndicator tabPageIndicator;
    private ViewPager mViewPagerContent;
    private ScheduleInviteAdapter mAdapter;

    private int mCurrentPage = 0;

    //data
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

    public static void launchScheduleListActivity(Context context, int defultSelectIndex){
        Intent intent = new Intent(context, ScheduleInviteActivity.class);
        intent.putExtra(DEFAULT_SELECT_PAGE_INDEX, defultSelectIndex);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = ScheduleInviteActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_schedule_invite);
        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        //状态栏颜色
//        StatusBarUtil.setColor(this,Color.parseColor("#5d0e86"),0);
        //设置头
        setTitle(getString(R.string.my_schedule_invite_title), R.color.theme_default_black);
        hideTitleBarBottomDivider();

        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
        initViews();
        //初始化读取传入数据
        initData();
        //刷新显示未读
        refreshUnreadCount(mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem());
        getScheduleInviteUnreadCount();
        //注册时间接收器
        registerTimeChangeReceier();
    }

    private void initViews(){
        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);
        mViewPagerContent = (ViewPager)findViewById(R.id.viewPagerContent);

        //初始化adapter
        mAdapter = new ScheduleInviteAdapter(this);
        mViewPagerContent.setAdapter(mAdapter);
        tabPageIndicator.setViewPager(mViewPagerContent);

        // 设置控件的模式，一定要先设置模式
        tabPageIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tabPageIndicator.setDividerColor(Color.TRANSPARENT);
        //设置中间竖线上下的padding值
        tabPageIndicator.setDividerPadding(DisplayUtil.dip2px(this, 10));
        //设置页面切换处理
        tabPageIndicator.setOnPageChangeListener(this);
    }

    private void initData(){
        Bundle bundle = getIntent().getExtras();
        int defaultIndex = 0;
        if(bundle != null){
            if(bundle.containsKey(DEFAULT_SELECT_PAGE_INDEX)){
                defaultIndex = bundle.getInt(DEFAULT_SELECT_PAGE_INDEX);
            }
        }
        if(defaultIndex >= 0 && defaultIndex < mAdapter.getCount()){
            mViewPagerContent.setCurrentItem(defaultIndex);
        }
    }

    /**
     * 获取预约邀请相关未读数目
     */
    private void getScheduleInviteUnreadCount(){
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
    }

    /**
     * 刷新未读数目
     * @param item
     */
    private void refreshUnreadCount(ScheduleInviteUnreadItem item){
        if(tabPageIndicator != null && item != null){
            int[] indexs = new int[]{ScheduleInviteTab.NewInvite.ordinal(), ScheduleInviteTab.PendingConfirm.ordinal(),
                    ScheduleInviteTab.Confirmed.ordinal(),ScheduleInviteTab.History.ordinal()};
            int[] unreads = new int[]{item.pendingNum, 0, item.confirmedUnreadCount,item.otherUnreadCount};
            for(int index = 0; index<indexs.length; index++){
                int tabPageIndex = indexs[index];
                int tabUnReadOnIndex = unreads[index];
                tabPageIndicator.updateTabDiginalHint(tabPageIndex,tabUnReadOnIndex>0,false,tabUnReadOnIndex);
//                if(null != mLocalCache && mLocalCache.size()>tabPageIndex){
//                    SoftReference<BaseListFragment> fragmentSr = mLocalCache.get(tabPageIndex);
//                    if(null != fragmentSr && fragmentSr.get() != null){
//                        if(fragmentSr.get().isVisible()){
//                            fragmentSr.get().showLoadingProcess();
//                            fragmentSr.get().onPullDownToRefresh();
//                        }
//                    }
//                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
        unregisterTimeChangeReceier();
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
//        //Tab切换刷新未读数目
//        getScheduleInviteUnreadCount();
        mCurrentPage = position;
        //GA统计
        onAnalyticsPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }


    /*****************************  添加系统时间修改监听器，用于处理系统时间修改导致Timer挂起  *********************************/
    private BroadcastReceiver timeChangeReciver = new BroadcastReceiver(){
        public void onReceive(android.content.Context context, android.content.Intent intent) {
            String action = intent.getAction();
            if(action.equals(Intent.ACTION_TIME_CHANGED)
                    || action.equals(Intent.ACTION_DATE_CHANGED)){
                //系统时间修改，通知模块
                if(mCurrentPage == 2){
                    if(null != mLocalCache && mLocalCache.size() > mCurrentPage){
                        SoftReference<BaseListFragment> fragmentSr = mLocalCache.get(mCurrentPage);
                        if(null != fragmentSr && fragmentSr.get() != null
                                && fragmentSr.get() instanceof ConfirmedInviteFragment){
                            ((ConfirmedInviteFragment)(fragmentSr.get())).onSystemTimeChange();
                        }
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

    /*****************************  Unread listener  *********************************/
    @Override
    public void onScheduleInviteUnreadUpdate(final ScheduleInviteUnreadItem item) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //刷新tab未读数目
                refreshUnreadCount(item);
            }
        });
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {

    }

    /**
     * 背包Tab类型
     */
    public enum ScheduleInviteTab{
        NewInvite,
        PendingConfirm,
        Confirmed,
        History
    }

    public class ScheduleInviteAdapter extends FragmentPagerAdapter {

        private String[] mTitles = null;


        public ScheduleInviteAdapter(FragmentActivity activity){
            super(activity.getSupportFragmentManager());
            mTitles = activity.getResources().getStringArray(R.array.scheduleInviteTabs);
            mLocalCache = new HashMap<Integer, SoftReference<BaseListFragment>>();
        }

        @Override
        public Fragment getItem(int position) {
            SoftReference<BaseListFragment> fragmentRefer = mLocalCache.get(Integer.valueOf(position));
            if(fragmentRefer != null && fragmentRefer.get() != null){
                return fragmentRefer.get();
            }
            BaseListFragment fragment = null;
            switch (position){
                case 0:{
                    fragment = new NewInviteFragment();
                }break;

                case 1:{
                    fragment = new PendingConfirmFragment();
                }break;

                case 2:{
                    fragment = new ConfirmedInviteFragment();
                }break;

                case 3:{
                    fragment = new InviteHistoryFragment();
                }break;
            }
            mLocalCache.put(Integer.valueOf(position), new SoftReference<BaseListFragment>(fragment));
            return fragment;
        }

        @Override
        public int getCount() {
            return ScheduleInviteTab.values().length;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return getTabTitleByType(ScheduleInviteTab.values()[position]);
        }

        /**
         * 根据tab类型获取title
         * @return
         */
        private String getTabTitleByType(ScheduleInviteTab tabtype){
            String tabTitle = "";
            if(tabtype.ordinal() < mTitles.length){
                tabTitle = mTitles[tabtype.ordinal()];
            }
            return tabTitle;
        }
    }
}
