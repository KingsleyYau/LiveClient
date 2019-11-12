package com.qpidnetwork.livemodule.liveshow.flowergift;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.ImageView;

import com.flyco.tablayout.SlidingTabLayout;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.DeliveryListFragment;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersStoreListFragment;

import java.lang.ref.SoftReference;
import java.util.HashMap;

/**
 * 2019/10/8 Hardy
 * 鲜花礼品的主页
 * —— Store
 * —— delivery
 */
public class FlowersMainActivity extends BaseFragmentActivity implements ViewPager.OnPageChangeListener{
    private static final String LIST_TYPE = "LIST_TYPE";    //0:Store; 1:delivery

    public static final String LIST_TYPE_STORE = "0";
    public static final String LIST_TYPE_DELIVERY = "1";

    private static final int OFF_SCREEN_PAGE_LIMIT = 2;    //VP预加载页面(3是为了避免用户疯狂切换，导致Fragment不断Create的问题)

    private SlidingTabLayout tabPageIndicator;
    private ViewPager mViewPagerContent;
    private MyPackageAdapter mAdapter;
    private DeliveryListFragment.onDeliveryEmptyEventListener onDeliveryEmptyEventListener;

    /**
     * start act
     */
    public static void startAct(Context context) {
        startAct(context, "0");
    }

    /**
     * start act
     */
    public static void startAct(Context context, String listType) {
        Intent intent = new Intent(context, FlowersMainActivity.class);
        intent.putExtra(LIST_TYPE, listType);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_flowers_main);

        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        initView();
        initData();
    }

    private void initView(){
        ImageView mIvBack = findViewById(R.id.act_flowers_main_iv_back);
        mIvBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        tabPageIndicator = findViewById(R.id.act_flowers_main_tabPageIndicator);
        mViewPagerContent = findViewById(R.id.act_flowers_main_viewPagerContent);
        //设置页面切换处理
        mViewPagerContent.addOnPageChangeListener(this);
        //防止间隔点击会出现回收，导致Fragment onresume走出现刷新异常
        mViewPagerContent.setOffscreenPageLimit(OFF_SCREEN_PAGE_LIMIT);

        //初始化adapter
        mAdapter = new MyPackageAdapter(this);
        mViewPagerContent.setAdapter(mAdapter);
        tabPageIndicator.setViewPager(mViewPagerContent);
    }

    private void initData(){
        initIntentData();
        onDeliveryEmptyEventListener = new DeliveryListFragment.onDeliveryEmptyEventListener() {
            @Override
            public void onEmptyBtnClicked() {
                mViewPagerContent.setCurrentItem(0);
            }
        };
    }

    private void initIntentData(){
        //传入的参数
        Bundle bundle = getIntent().getExtras();
        if(bundle != null) {
            if (bundle.containsKey(LIST_TYPE)) {
                String listType = bundle.getString(LIST_TYPE);
                if(listType.equals(LIST_TYPE_DELIVERY)){
                    mViewPagerContent.setCurrentItem(1);
                }
            }
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        setIntent(intent);
        initIntentData();
    }

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

        private String[] mTitles = {"Store", "Delivery"};
        private HashMap<Integer, SoftReference<Fragment>> mLocalCache = null;

        public MyPackageAdapter(FragmentActivity activity) {
            super(activity.getSupportFragmentManager());
            mLocalCache = new HashMap<>();
        }

        @Override
        public Fragment getItem(int position) {
            SoftReference<Fragment> fragmentRefer = mLocalCache.get(position);

            if (fragmentRefer != null && fragmentRefer.get() != null) {
                return fragmentRefer.get();
            }

            Fragment fragment = null;
            switch (position) {
                case 0:
                    fragment = new FlowersStoreListFragment();
                    break;

                default:
                    fragment = new DeliveryListFragment();
                    ((DeliveryListFragment)fragment).setOnEmptyEventListener(onDeliveryEmptyEventListener);
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
