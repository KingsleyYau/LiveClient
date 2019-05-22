package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.SparseArray;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

import java.lang.ref.WeakReference;

public class LiveChatRecentWatchPreviewActivity
        extends BaseFragmentActivity
        implements ViewPager.OnPageChangeListener {


    private static final String TAG_VIDEO_TITLES = "TAG_VIDEO_TITLES";
    private static final String TAG_VIDEO_URLS = "TAG_VIDEO_URLS";
    private static final String TAG_VIDEO_COVER = "TAG_VIDEO_COVER";
    private static final String TAG_CURRENT_POSITION = "TAG_CURRENT_POSITION";
    private ViewPager mViewPager;
    private MyAdapter mAdapter;
    private int mSwitchPos = 0;


    /**
     * @param context
     * @param videoTitles
     * @param videoUrls
     */
    public static void launch(Context context,
                              int currentPos,
                              String[] videoTitles,
                              String[] videoCovers,
                              String[] videoUrls) {
        Intent intent = new Intent(context, LiveChatRecentWatchPreviewActivity.class);
        intent.putExtra(TAG_VIDEO_TITLES, videoTitles);
        intent.putExtra(TAG_VIDEO_URLS, videoUrls);
        intent.putExtra(TAG_VIDEO_COVER, videoCovers);
        intent.putExtra(TAG_CURRENT_POSITION, currentPos);
        context.startActivity(intent);
    }

    private String[] videoTitles;
    private String[] videoUrls;
    private String[] videoCovers;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_livechat_photo_and_video_preview);
        initData();
        initView();
    }

    private void initData() {

        Intent data = getIntent();
        videoTitles = data.getStringArrayExtra(TAG_VIDEO_TITLES);
        videoUrls = data.getStringArrayExtra(TAG_VIDEO_URLS);
        videoCovers = data.getStringArrayExtra(TAG_VIDEO_COVER);
        mSwitchPos = data.getIntExtra(TAG_CURRENT_POSITION, 0);
    }


    private void initView() {
        ImageView mIvBack = findViewById(R.id.act_livechat_photo_and_video_preview_iv_back);
        mIvBack.setOnClickListener(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) mIvBack.getLayoutParams();
            params.topMargin += DisplayUtil.getStatusBarHeight(mContext);
            mIvBack.setLayoutParams(params);
        }

        mViewPager = findViewById(R.id.act_livechat_photo_and_video_preview_viewpager);
        mViewPager.addOnPageChangeListener(this);

        // 设置 adapter
        mAdapter = new MyAdapter(getSupportFragmentManager());
        mAdapter.setCovers(videoCovers);
        mAdapter.setTitles(videoTitles);
        mAdapter.setUrls(videoUrls);
        mViewPager.setAdapter(mAdapter);

        // 跳转到指定的 position
        mViewPager.setCurrentItem(mSwitchPos);
    }


    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.act_livechat_photo_and_video_preview_iv_back) {
            finish();
        }
    }

    @Override
    public void onPageScrolled(int position,
                               float positionOffset,
                               int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {

    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    private class MyAdapter extends FragmentStatePagerAdapter {


        private String[] titles;
        private String[] covers;
        private String[] urls;
        private SparseArray<WeakReference<LiveChatRecentWatchFragment>> mPageReference;

        public MyAdapter(FragmentManager fm) {
            super(fm);
            mPageReference = new SparseArray<>();
        }

        public void setTitles(String[] titles) {
            this.titles = titles;
        }

        public void setCovers(String[] covers) {
            this.covers = covers;
        }

        public void setUrls(String[] urls) {
            this.urls = urls;
        }

        @Override
        public Fragment getItem(int position) {
            LiveChatRecentWatchFragment fragment = getFragment(position);
            if (fragment == null) {
                fragment = new LiveChatRecentWatchFragment();
                mPageReference.put(position, new WeakReference<>(fragment));
            }
            fragment.setData(
                    titles[position],
                    covers[position],
                    urls[position]);
            return fragment;
        }

        private LiveChatRecentWatchFragment getFragment(int position) {
            LiveChatRecentWatchFragment fragment = null;
            WeakReference<LiveChatRecentWatchFragment> weakReference = mPageReference.get(position);
            if (weakReference != null) {
                fragment = weakReference.get();
            }
            return fragment;
        }

        @Override
        public int getCount() {
            return titles.length;
        }
    }
}
