package com.qpidnetwork.anchor.liveshow.home;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseFragment;

import java.lang.ref.SoftReference;

/**
 * Created by Hunter Mun on 2017/9/5.
 */

public class MainFragmentPagerAdapter extends FragmentPagerAdapter {

    private String[] mTitles = null;

    /**
     * tab
     */
    public enum TABS{
        TAB_HOME,
        TAB_NULL,
        TAB_ME
    }

    private SoftReference<HomeFragment> sr_homeFragment = null;
    private SoftReference<MeFragment> sr_meFragment = null;

    public MainFragmentPagerAdapter(FragmentActivity activity){
        super(activity.getSupportFragmentManager());
        mTitles = activity.getResources().getStringArray(R.array.topTabs);
    }

    @Override
    public Fragment getItem(int position) {
        BaseFragment fragment = null;
        switch (position){
            case 0: {
                if (null == sr_homeFragment || null == sr_homeFragment.get()) {
                    sr_homeFragment = new SoftReference<HomeFragment>(new HomeFragment());
                }
                fragment = sr_homeFragment.get();
            }break;
            case 1: {
                if (null == sr_meFragment || null == sr_meFragment.get()) {
                    sr_meFragment = new SoftReference<MeFragment>(new MeFragment());
                }
                fragment = sr_meFragment.get();
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

    //del by Jagger 2018-4-14 在Fragment中setUserVisibleHint即可刷新数据
//    @Override
//    public int getItemPosition(Object object) {
//        if(object instanceof HomeFragment){
//            //代表每次切换到PersonalCenterFragment都要刷新数据
////            Log.i("Jagger" , "MainFragmentPagerAdapter-->getItemPosition:object instanceof PersonalCenterFragment" );
//            return POSITION_NONE;
//        }
//        return super.getItemPosition(object);
//    }
}
