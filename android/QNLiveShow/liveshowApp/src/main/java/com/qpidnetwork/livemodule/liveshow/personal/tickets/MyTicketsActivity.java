package com.qpidnetwork.livemodule.liveshow.personal.tickets;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.liveshow.home.CalendarFragment;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.lang.ref.SoftReference;
import java.util.HashMap;

public class MyTicketsActivity extends BaseActionBarFragmentActivity implements ViewPager.OnPageChangeListener{

    private static final String DEFAULT_SELECT_PAGE_INDEX = "pageIndex";

    private TabPageIndicator tabPageIndicator;
    private ViewPager mViewPagerContent;
    private MyTicketsAdapter mAdapter;


    public static void launchMyTicketsActivity(Context context, int defultSelectIndex) {
        Intent intent = new Intent(context, MyTicketsActivity.class);
        intent.putExtra(DEFAULT_SELECT_PAGE_INDEX, defultSelectIndex);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_my_tickets);
        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        //设置头
        setTitle(getString(R.string.my_tickets_invite_title), R.color.theme_default_black);
        hideTitleBarBottomDivider();


        initViews();

        initData();
    }

    private void initViews() {
        //状态栏颜色
//        StatusBarUtil.setColor(this,Color.parseColor("#5d0e86"),0);

        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);
        mViewPagerContent = (ViewPager) findViewById(R.id.viewPagerContent);

        //初始化adapter
        mAdapter = new MyTicketsAdapter(this);
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

    private void initData() {
        Bundle bundle = getIntent().getExtras();
        int defaultIndex = 0;
        if (bundle != null) {
            if (bundle.containsKey(DEFAULT_SELECT_PAGE_INDEX)) {
                defaultIndex = bundle.getInt(DEFAULT_SELECT_PAGE_INDEX);
            }
        }
        if (defaultIndex >= 0 && defaultIndex < mAdapter.getCount()) {
            mViewPagerContent.setCurrentItem(defaultIndex);
        }
    }


    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
//        //Tab切换刷新未读数目
//        getPackageUnreadCount();
        //GA统计
        onAnalyticsPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    /**
     * 背包Tab类型
     */
    public enum MyTicketsTab {
        Scheduled,
        History
    }

    public class MyTicketsAdapter extends FragmentPagerAdapter {

        private String[] mTitles = null;
        private HashMap<Integer, SoftReference<BaseFragment>> mLocalCache = null;

        public MyTicketsAdapter(FragmentActivity activity) {
            super(activity.getSupportFragmentManager());
            mTitles = activity.getResources().getStringArray(R.array.myTicketsTags);
            mLocalCache = new HashMap<Integer, SoftReference<BaseFragment>>();
        }

        @Override
        public Fragment getItem(int position) {
            SoftReference<BaseFragment> fragmentRefer = mLocalCache.get(Integer.valueOf(position));
            if (fragmentRefer != null && fragmentRefer.get() != null) {
                return fragmentRefer.get();
            }
            BaseFragment fragment = null;
            switch (position) {
                case 0: {
                    fragment = CalendarFragment.newInstance(CalendarFragment.ShowType.UNUSED);
                }
                break;

                case 1: {
                    fragment = CalendarFragment.newInstance(CalendarFragment.ShowType.HISTORY);
                }
                break;

            }
            mLocalCache.put(Integer.valueOf(position), new SoftReference<BaseFragment>(fragment));
            return fragment;
        }

        @Override
        public int getCount() {
            return MyTicketsTab.values().length;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            String title = "";
            if (position < MyTicketsTab.values().length) {
                title = getTabTitleByType(MyTicketsTab.values()[position]);
            }
            return title;
        }

        /**
         * 根据tab类型获取title
         *
         * @return
         */
        private String getTabTitleByType(MyTicketsTab tabtype) {
            String tabTitle = "";
            if (tabtype.ordinal() < mTitles.length) {
                tabTitle = mTitles[tabtype.ordinal()];
            }
            return tabTitle;
        }
    }
}
