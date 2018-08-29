package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import java.util.List;

/**
 * Created by Jagger on 2018-05-29.
 */

public class TalentPopWinFragmentPagerAdapter extends FragmentPagerAdapter {

    private List<Fragment> mFragments;

    public TalentPopWinFragmentPagerAdapter(FragmentManager fm , List<Fragment> fragments){
        super(fm);
        mFragments = fragments;
    }

    @Override
    public Fragment getItem(int position) {
        return this.mFragments.get(position);
    }

    @Override
    public int getCount() {
        return mFragments.size();
    }

}
