package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

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
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.lang.ref.SoftReference;
import java.util.HashMap;

import static com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity.MyPackageTab.MyRides;
import static com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity.MyPackageTab.ReceivedGifts;
import static com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity.MyPackageTab.Voucher;

/**
 * Created by Hunter on 17/9/26.
 */

public class MyPackageActivity extends BaseActionBarFragmentActivity implements ViewPager.OnPageChangeListener, ScheduleInvitePackageUnreadManager.OnUnreadListener{

    private static final String DEFAULT_SELECT_PAGE_INDEX = "pageIndex";

    private TabPageIndicator tabPageIndicator;
    private ViewPager mViewPagerContent;
    private MyPackageAdapter mAdapter;

    //data
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

    public static void launchMyPackageActivity(Context context, int defultSelectIndex){
        Intent intent = new Intent(context, MyPackageActivity.class);
        intent.putExtra(DEFAULT_SELECT_PAGE_INDEX, defultSelectIndex);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_my_package);
        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        //设置头
        setTitle(getString(R.string.my_package_title), Color.WHITE);

        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);

        initViews();

        initData();

        //刷新显示未读
        refreshUnreadCount(mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem());
        getPackageUnreadCount();
    }

    private void initViews(){
        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);
        mViewPagerContent = (ViewPager)findViewById(R.id.viewPagerContent);

        //初始化adapter
        mAdapter = new MyPackageAdapter(this);
        mViewPagerContent.setAdapter(mAdapter);
        tabPageIndicator.setViewPager(mViewPagerContent);

        // 设置控件的模式，一定要先设置模式
        tabPageIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tabPageIndicator.setDividerColor(Color.TRANSPARENT);
        //无未读条数
        tabPageIndicator.setHasDigitalHint(false);
        //设置中间竖线上下的padding值
        tabPageIndicator.setDividerPadding(DisplayUtil.dip2px(this, 10));
        //打开未读设置
        tabPageIndicator.setHasDigitalHint(true);
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
     * 获取背包未读
     */
    private void getPackageUnreadCount(){
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
    }

    /**
     * 刷新未读数目
     * @param item
     */
    private void refreshUnreadCount(PackageUnreadCountItem item){
        if(tabPageIndicator != null && item != null){
            tabPageIndicator.updateTabDiginalHintNumb(Voucher.ordinal(), item.voucherNum);
            tabPageIndicator.updateTabDiginalHintNumb(ReceivedGifts.ordinal(), item.giftNum);
            tabPageIndicator.updateTabDiginalHintNumb(MyRides.ordinal(), item.rideNum);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        //Tab切换刷新未读数目
        getPackageUnreadCount();
        //GA统计
        onAnalyticsPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    /*****************************  Unread listener  *********************************/
    @Override
    public void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item) {

    }

    @Override
    public void onPackageUnreadUpdate(final PackageUnreadCountItem item) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //刷新tab未读数目
                refreshUnreadCount(item);
            }
        });
    }

    /**
     * 背包Tab类型
     */
    public enum MyPackageTab{
        Voucher,
        ReceivedGifts,
        MyRides
    }

    public class MyPackageAdapter extends FragmentPagerAdapter{

        private String[] mTitles = null;
        private HashMap<Integer, SoftReference<BaseFragment>> mLocalCache = null;

        public MyPackageAdapter(FragmentActivity activity){
            super(activity.getSupportFragmentManager());
            mTitles = activity.getResources().getStringArray(R.array.myPackageTags);
            mLocalCache = new HashMap<Integer, SoftReference<BaseFragment>>();
        }

        @Override
        public Fragment getItem(int position) {
            SoftReference<BaseFragment> fragmentRefer = mLocalCache.get(Integer.valueOf(position));
            if(fragmentRefer != null && fragmentRefer.get() != null){
                return fragmentRefer.get();
            }
            BaseFragment fragment = null;
            switch (position){
                case 0:{
                    fragment = new VoucherFragment();
                }break;

                case 1:{
                    fragment = new ReceivedGiftFragment();
                }break;

                case 2:{
                    fragment = new MyRidesFragment();
                }break;
            }
            mLocalCache.put(Integer.valueOf(position), new SoftReference<BaseFragment>(fragment));
            return fragment;
        }

        @Override
        public int getCount() {
            return MyPackageTab.values().length;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            String title = "";
            if(position < MyPackageTab.values().length){
                title = getTabTitleByType(MyPackageTab.values()[position]);
            }
            return title;
        }

        /**
         * 根据tab类型获取title
         * @return
         */
        private String getTabTitleByType(MyPackageTab tabtype){
            String tabTitle = "";
            if(tabtype.ordinal() < mTitles.length){
                tabTitle = mTitles[tabtype.ordinal()];
            }
            return tabTitle;
        }
    }
}
