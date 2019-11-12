package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Context;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/5.
 * 必需使用FragmentStatePagerAdapter，这样添加删除TAB时才会刷新
 */

public class MainFragmentPagerAdapter4Top extends FragmentStatePagerAdapter {

    private Context mContext;
    private List<TABS> tabsList = new ArrayList<>();
    private HashMap<TABS, SoftReference<BaseFragment>> mLocalCache ;
    private BaseFragment mCurrentFragment;

    /**
     * 页面
     */
    public enum TABS{
        TAB_INDEX_DISCOVER,
        TAB_INDEX_HANGOUT,
        TAB_INDEX_FOLLOW,
        TAB_INDEX_CALENDAR
    }

    public static MainFragmentPagerAdapter4Top newAdapter4NoHangout(FragmentActivity activity){
        return new MainFragmentPagerAdapter4Top(activity,
                TABS.TAB_INDEX_DISCOVER,
                TABS.TAB_INDEX_FOLLOW,
                TABS.TAB_INDEX_CALENDAR);
    }

    public static MainFragmentPagerAdapter4Top newAdapter4HasHangout(FragmentActivity activity){
        return new MainFragmentPagerAdapter4Top(activity,
                TABS.TAB_INDEX_DISCOVER,
                TABS.TAB_INDEX_HANGOUT,
                TABS.TAB_INDEX_FOLLOW,
                TABS.TAB_INDEX_CALENDAR);
    }

    private MainFragmentPagerAdapter4Top(FragmentActivity activity, TABS... tabs){
        super(activity.getSupportFragmentManager());
        mContext = activity;
        mLocalCache = new HashMap<>();
        setTabs(tabs);
    }

    /**
     * 设置菜单可视选项
     * 外部记得调用tabPageIndicator.notifyDataSetChanged();方可生效
     * @param tabs
     */
    public void setTabs(TABS... tabs){
        tabsList.clear();
        for(TABS tab:tabs){
            tabsList.add(tab);
        }
//        notifyDataSetChanged();
    }

    @Override
    public Fragment getItem(int position) {
//        Log.i("Jagger" , "MainFragmentPagerAdapter4Top getItem:" + position);
        TABS tabSelected =  tabsList.get(position);
        SoftReference<BaseFragment> fragmentRefer = mLocalCache.get(tabSelected);
        if(fragmentRefer != null && fragmentRefer.get() != null){
            return fragmentRefer.get();
        }
        BaseFragment fragment = null;
        switch (tabSelected){
            case TAB_INDEX_DISCOVER:
                fragment = new HotListFragment();
                break;

            case TAB_INDEX_HANGOUT:
                //TODO
                fragment = new HangOutFragment();
                break;

            case TAB_INDEX_FOLLOW:
                fragment = new FollowingListFragment();
                break;

            case TAB_INDEX_CALENDAR:
                fragment = new CalendarFragment();
                break;
        }
        mLocalCache.put(tabSelected, new SoftReference<>(fragment));
        return fragment;
    }

    @Override
    public int getCount() {
        return tabsList.size();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return tabToTitleStr(tabsList.get(position));
    }

    @Override
    public void setPrimaryItem(ViewGroup container, int position, Object object) {
        mCurrentFragment = (BaseFragment) object;
        super.setPrimaryItem(container, position, object);
    }

    public BaseFragment getCurrentFragment() {
        return mCurrentFragment;
    }

    /**
     * 类型转文字
     * @param tab
     * @return
     */
    private String tabToTitleStr(TABS tab){
        String title = "";
        switch (tab){
            case TAB_INDEX_DISCOVER:
                title =mContext.getString(R.string.live_main_tab_discover);
                break;
            case TAB_INDEX_HANGOUT:
                title =mContext.getString(R.string.live_main_tab_hangout);
                break;
            case TAB_INDEX_FOLLOW:
                title =mContext.getString(R.string.live_main_tab_follow);
                break;
            case TAB_INDEX_CALENDAR:
                title =mContext.getString(R.string.live_main_tab_calendar);
                break;
        }
        return title;
    }

//    @Override
//    public long getItemId(int position) {
//        return tabsList.get(position).ordinal();
//    }

    /**
     * 类型转索引
     * @param tab
     * @return
     */
    public int tabTypeToIndex(TABS tab){
        int index = 0;
        for(int i = 0 ; i < tabsList.size(); i++){
            if(tabsList.get(i) == tab){
                index = i;
                break;
            }
        }
        return index;
    }
}
