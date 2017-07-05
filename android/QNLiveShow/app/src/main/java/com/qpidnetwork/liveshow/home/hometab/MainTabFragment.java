package com.qpidnetwork.liveshow.home.hometab;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.framework.base.BaseFragment;
import com.qpidnetwork.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.liveshow.LiveApplication;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.utils.DisplayUtil;

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
        tpi_fragmentIndicator.setViewPager(vp_tabContainer);
        setTabPagerIndicator();
        return rootView;
    }

    /**
     * 设置TabPageIndicator的显示属性
     */
    private void setTabPagerIndicator() {
        // 设置控件的模式，一定要先设置模式
        tpi_fragmentIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tpi_fragmentIndicator.setDividerColor(Color.TRANSPARENT);
        //设置中间竖线上下的padding值
        tpi_fragmentIndicator.setDividerPadding(DisplayUtil.dip2px(LiveApplication.getContext(), 10));
        //设置底部导航线的颜色
        tpi_fragmentIndicator.setIndicatorColor(Color.parseColor("#43A44b"));
        //设置tab标题选中的颜色
        tpi_fragmentIndicator.setTextColorSelected(Color.parseColor("#43A44b"));
        //设置tab标题未被选中的颜色
        tpi_fragmentIndicator.setTextColor(Color.parseColor("#797979"));
        //设置字体的大小
        tpi_fragmentIndicator.setTextSize(DisplayUtil.sp2px(LiveApplication.getContext(), 16));
    }
}
