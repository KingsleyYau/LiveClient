package com.qpidnetwork.livemodule.liveshow.home.hometab;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import com.qpidnetwork.livemodule.framework.base.BaseFragment;

import java.lang.ref.SoftReference;


/**
 * Created by Harry on 2017/5/16.
 */

public class TabFragmentPagerAdapter extends FragmentPagerAdapter {

    private String[] tabTitles = null;
    private int itemCount = 0;

    private SoftReference<BaseFragment> sr_followingFragment = null;
    private SoftReference<BaseFragment> sr_hotFragment = null;
    private SoftReference<BaseFragment> sr_dicoverFragment = null;

    public void setTabTitles(String[] tabTitles){
        this.tabTitles = tabTitles;
        itemCount = tabTitles.length;
    }

    public int getTabCount(){
        return itemCount;
    }

    public TabFragmentPagerAdapter(FragmentManager fm){
        super(fm);
    }

    /**
     * Return the Fragment associated with a specified position.
     *
     * @param position
     */
    @Override
    public Fragment getItem(int position) {
        BaseFragment fragment = null;
        switch (position){
            case 0:
                if(null == sr_hotFragment || null == sr_hotFragment.get()){
                    sr_hotFragment = new SoftReference<BaseFragment>(new HotFragment());
                }
                return sr_hotFragment.get();
            case 1:
                if(null == sr_followingFragment || null == sr_followingFragment.get()){
                    sr_followingFragment = new SoftReference<BaseFragment>(new FollowingFragment());
                }
                return sr_followingFragment.get();
            case 2:
                if(null == sr_dicoverFragment || null == sr_dicoverFragment.get()){
                    sr_dicoverFragment = new SoftReference<BaseFragment>(new DicoverFragment());
                }
                return sr_dicoverFragment.get();
            default:
                return null;
        }
    }

    /**
     * Return the number of views available.
     */
    @Override
    public int getCount() {
        return itemCount;
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return null == tabTitles ? "" : tabTitles[position%itemCount];
    }
}
