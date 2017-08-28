package com.qpidnetwork.livemodule.liveshow.home.hometab;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

/**
 */
public class MainTabFragment extends BaseFragment {

    private TabFragmentPagerAdapter tabFragmPagerAdapter;

    private ViewPager vp_tabContainer;
    private TabPageIndicator tpi_fragmentIndicator;

    public MainTabFragment() {
        // Required empty public constructor
        TAG = MainTabFragment.class.getSimpleName();
        Log.d(TAG,TAG+"()");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate (R.layout.fragment_main_tab, container, false);
        //解决Fragment+ViewPager+Fragment场景下出现的Fragment空白问题:
        // getActivity().getSupportFragmentManager()->getChildFragmentManager()
        tabFragmPagerAdapter = new TabFragmentPagerAdapter(getChildFragmentManager());
        tabFragmPagerAdapter.setTabTitles(getContext().getResources().getStringArray(R.array.topTabs));
        vp_tabContainer = (ViewPager) rootView.findViewById(R.id.vp_tabContainer);
        vp_tabContainer.setAdapter(tabFragmPagerAdapter);
        vp_tabContainer.setCurrentItem(1);
        tpi_fragmentIndicator = (TabPageIndicator) rootView.findViewById(R.id.tpi_fragmentIndicator);
        setTabPagerIndicator();
        return rootView;
    }

    /**
     * 设置TabPageIndicator的显示属性
     */
    private void setTabPagerIndicator() {
//        tpi_fragmentIndicator.setViewPager(vp_tabContainer);
        tpi_fragmentIndicator.setDefaultPosition(1);
        //测试将viewpager的listener设置在外部，并在外部控制tabindicator的显示
        vp_tabContainer.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
                tpi_fragmentIndicator.onTabScrolled(position,positionOffset,positionOffsetPixels);
            }

            @Override
            public void onPageSelected(int position) {
                tpi_fragmentIndicator.onTabSelected(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                tpi_fragmentIndicator.onTabScroolStateChanged(state,vp_tabContainer.getCurrentItem());
            }
        });
        tpi_fragmentIndicator.setTitles(getContext().getResources().getStringArray(R.array.topTabs));
        // 设置控件的模式，一定要先设置模式
        tpi_fragmentIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tpi_fragmentIndicator.setDividerColor(Color.TRANSPARENT);
        //设置中间竖线上下的padding值
        tpi_fragmentIndicator.setDividerPadding(DisplayUtil.dip2px(LiveApplication.getContext(), 10));
//        tpi_fragmentIndicator.setIndicatorColor(Color.parseColor("#43A44b"));
        tpi_fragmentIndicator.setOnTabClickListener(new TabPageIndicator.OnTabClickListener() {
            @Override
            public void onTabClicked(int position,String title) {
                vp_tabContainer.setCurrentItem(position);
            }
        });
    }
}
