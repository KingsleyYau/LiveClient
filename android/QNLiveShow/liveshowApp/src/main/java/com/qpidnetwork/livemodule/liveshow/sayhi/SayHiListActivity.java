package com.qpidnetwork.livemodule.liveshow.sayhi;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.Gravity;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.BadgeHelper;
import com.qpidnetwork.livemodule.view.dialog.SayHiGuideDialog;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * 2019/5/29 Hardy
 * <p>
 * 直播 SayHi 列表主界面，包括以下
 * 1）all list
 * 2）response list
 */
public class SayHiListActivity extends BaseActionBarFragmentActivity implements ViewPager.OnPageChangeListener {

    private static final String DEFAULT_SELECT_PAGE_INDEX = "pageIndex";

    // 左 tab 未读数距离 tab 文本的间距
    private static final int LEFT_TAB_RED_CIRCLE_PADDING_LEFT_NORMAL = 30;
    private static final int LEFT_TAB_RED_CIRCLE_PADDING_LEFT_BIG = 24;     // 值越小，越靠右

    private TabPageIndicator tabPageIndicator;
    private ViewPager mViewPagerContent;
    private MyPackageAdapter mAdapter;

    // 小红点
    private Badge badgeResponse;

    private SayHiGuideDialog sayHiGuideDialog;


    public enum TabType {
        ALL,
        RESPONSE
    }

    public static void startAct(Context context) {
        startAct(context, TabType.ALL);
    }

    public static void startAct(Context context, TabType tabType) {
//        if(checkHasChatPermission(context)){
        Intent intent = new Intent(context, SayHiListActivity.class);
        intent.putExtra(DEFAULT_SELECT_PAGE_INDEX, tabType.ordinal());
        context.startActivity(intent);
//        }
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_say_hi_list);

        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        initView();
        initData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (sayHiGuideDialog != null) {
            sayHiGuideDialog.destroy();
            sayHiGuideDialog = null;
        }
    }

    private void initView() {
        //设置头
        setOnlyTitle(getString(R.string.sayhi));
        hideTitleBarBottomDivider();
        // 右边按钮
        addTitleRightMenu(R.drawable.ic_say_hi_list_info, new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showGuideDialog();
            }
        });

        tabPageIndicator = findViewById(R.id.tabPageIndicator);
        mViewPagerContent = findViewById(R.id.viewPagerContent);

        //初始化adapter
        mAdapter = new MyPackageAdapter(this);
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

        // 由于 tabPageIndicator 自带的小红点不支持需求样式
        // 右边小红点
        badgeResponse = new QBadgeView(this).bindTarget(tabPageIndicator.getCurTabView(1));     // response 标签
        badgeResponse.setBadgeNumber(0);
        badgeResponse.setBadgeGravity(Gravity.CENTER | Gravity.END);
        BadgeHelper.setBaseStyle(this, badgeResponse);
        badgeResponse.setGravityOffset(LEFT_TAB_RED_CIRCLE_PADDING_LEFT_NORMAL, 0, true);

    }


    private void initData() {
        if (getIntent() != null) {
            int position = getIntent().getIntExtra(DEFAULT_SELECT_PAGE_INDEX, 0);
            if (position > 0) {
                mViewPagerContent.setCurrentItem(position);
            }
        }

        // 2019/5/29 新手引导弹窗
        checkShowGuideDialog();

        // test
//        showRightTabUnReadNum(true, 8);
    }

    /**
     * 左 tab 是否显示未读数字
     *
     * @param isShow
     * @param num
     */
    private void showRightTabUnReadNum(boolean isShow, int num) {
        badgeResponse.setBadgeNumber(isShow ? num : 0);
        if (isShow && num > 99) {
            badgeResponse.setGravityOffset(LEFT_TAB_RED_CIRCLE_PADDING_LEFT_BIG, 0, true);
        } else {
            badgeResponse.setGravityOffset(LEFT_TAB_RED_CIRCLE_PADDING_LEFT_NORMAL, 0, true);
        }
    }

    private void showGuideDialog() {
        if (sayHiGuideDialog == null) {
            sayHiGuideDialog = new SayHiGuideDialog(mContext);
        }

        sayHiGuideDialog.show();
    }

    private void checkShowGuideDialog(){
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        boolean hasShow = localPreferenceManager.hasShowSayHiGuide();
        if (!hasShow) {
            showGuideDialog();
            // 保存本地
            localPreferenceManager.saveHasShowSayHiGuide(true);
        }
    }

    /**
     * 未读数回调
     */
    SayHiListResponseFragment.OnUnReadChangeListener onUnReadChangeListener = new SayHiListResponseFragment.OnUnReadChangeListener() {
        @Override
        public void onUnReadChange(int count) {
            showRightTabUnReadNum(count > 0, count);
        }
    };

    //====================      ViewPager   ==================================================
    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        //GA统计
        onAnalyticsPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }
    //====================      ViewPager   ==================================================


    //====================      Adapter   ==================================================
    private class MyPackageAdapter extends FragmentPagerAdapter {

        private String[] mTitles = {"All", "Response"};
        private HashMap<Integer, SoftReference<SayHiBaseListFragment>> mLocalCache = null;

        public MyPackageAdapter(FragmentActivity activity) {
            super(activity.getSupportFragmentManager());
            mLocalCache = new HashMap<>();
        }

        @Override
        public Fragment getItem(int position) {
            SoftReference<SayHiBaseListFragment> fragmentRefer = mLocalCache.get(position);

            if (fragmentRefer != null && fragmentRefer.get() != null) {
                return fragmentRefer.get();
            }

            SayHiBaseListFragment fragment = null;
            switch (position) {
                case 0:
                    fragment = new SayHiListAllFragment();
                    break;

                default:
                    fragment = new SayHiListResponseFragment();
                    ((SayHiListResponseFragment) fragment).setOnUnReadChangeListener(onUnReadChangeListener);
                    break;
            }

            mLocalCache.put(position, new SoftReference<>(fragment));

            return fragment;
        }

        @Override
        public int getCount() {
            return mTitles.length;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mTitles[position];
        }
    }

}
