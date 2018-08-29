package com.qpidnetwork.livemodule.liveshow.home;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;

import java.lang.ref.SoftReference;

/**
 * Created by Hunter Mun on 2017/9/5.
 */

public class MainFragmentPagerAdapter extends FragmentPagerAdapter {

    private String[] mTitles = null;

    private SoftReference<FollowingListFragment> sr_followingFragment = null;
    private SoftReference<HotListFragment> sr_hotFragment = null;

    public MainFragmentPagerAdapter(FragmentActivity activity){
        super(activity.getSupportFragmentManager());
        mTitles = activity.getResources().getStringArray(R.array.topTabs);
    }

    @Override
    public Fragment getItem(int position) {
        BaseFragment fragment = null;
        switch (position){
            case 0: {
                if (null == sr_hotFragment || null == sr_hotFragment.get()) {
                    sr_hotFragment = new SoftReference<HotListFragment>(new HotListFragment());
                }
                fragment = sr_hotFragment.get();
            }break;
            case 1: {
                if (null == sr_followingFragment || null == sr_followingFragment.get()) {
                    sr_followingFragment = new SoftReference<FollowingListFragment>(new FollowingListFragment());
                }
                fragment = sr_followingFragment.get();
            }break;
        }
        return fragment;
    }

    @Override
    public int getCount() {
        return mTitles.length;
    }

    @Override
    public CharSequence getPageTitle(int position) {
        String title = "";
        if(position < mTitles.length){
            title = mTitles[position];
        }
        return title;
    }
}
