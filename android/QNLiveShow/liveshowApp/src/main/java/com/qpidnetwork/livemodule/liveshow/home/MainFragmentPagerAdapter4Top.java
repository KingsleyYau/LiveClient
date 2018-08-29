package com.qpidnetwork.livemodule.liveshow.home;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyRidesFragment;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.ReceivedGiftFragment;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.VoucherFragment;

import java.lang.ref.SoftReference;
import java.util.HashMap;

/**
 * Created by Hunter Mun on 2017/9/5.
 */

public class MainFragmentPagerAdapter4Top extends FragmentPagerAdapter {

    //**严重注意:这个东西会限制显示的数目,要和界面显示的TAB数目一样**
    private String[] mTitles = null;
    private HashMap<Integer, SoftReference<BaseFragment>> mLocalCache = null;

//    private SoftReference<FollowingListFragment> sr_followingFragment = null;
//    private SoftReference<HotListFragment> sr_hotFragment = null;
//    private SoftReference<CalendarFragment> sr_calendarFragment = null;
//    private SoftReference<PersonalCenterFragment> sr_personalFragment = null;

    private BaseFragment mCurrentFragment;

    /**
     * 页面
     */
//    public enum TABS{
//        TAB_INDEX_DISCOVER,
//        TAB_INDEX_FOLLOW
//    }

    public MainFragmentPagerAdapter4Top(FragmentActivity activity){
        super(activity.getSupportFragmentManager());
        mTitles = activity.getResources().getStringArray(R.array.topTabs);
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
                fragment = new HotListFragment();
            }break;

            case 1:{
                fragment = new FollowingListFragment();
            }break;

            case 2:{
                fragment = new CalendarFragment();
            }break;
        }
        mLocalCache.put(Integer.valueOf(position), new SoftReference<BaseFragment>(fragment));
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

    /**
     * 根据tab类型获取title
     * @return
     */
//    private String getTabTitleByType(TABS tabtype){
//        String tabTitle = "";
//        if(tabtype.ordinal() < mTitles.length){
//            tabTitle = mTitles[tabtype.ordinal()];
//        }
//        return tabTitle;
//    }

    //del by Jagger 移到setUserVisibleHint处理
//    @Override
//    public int getItemPosition(Object object) {
//        if(object instanceof PersonalCenterFragment){
//            //代表每次切换到PersonalCenterFragment都要刷新数据
////            Log.i("Jagger" , "MainFragmentPagerAdapter-->getItemPosition:object instanceof PersonalCenterFragment" );
//            return POSITION_NONE;
//        }
//        return super.getItemPosition(object);
//    }

    @Override
    public void setPrimaryItem(ViewGroup container, int position, Object object) {
        mCurrentFragment = (BaseFragment) object;
        super.setPrimaryItem(container, position, object);
    }

    public BaseFragment getCurrentFragment() {
        return mCurrentFragment;
    }
}
