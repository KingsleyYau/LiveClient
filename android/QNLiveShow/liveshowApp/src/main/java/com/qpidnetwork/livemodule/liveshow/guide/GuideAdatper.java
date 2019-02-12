package com.qpidnetwork.livemodule.liveshow.guide;

import android.support.v4.view.PagerAdapter;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;

import java.util.List;

/**
 * Created by lvr on 2017/1/16.
 */

public class GuideAdatper extends PagerAdapter {
    private List<View> mViewList ;
    private Integer[] mResIdList;

    public GuideAdatper(List<View> mViewList , Integer[] resIdList) {
        this.mViewList = mViewList;
        this.mResIdList = resIdList;
    }

    @Override
    public int getCount() {
        return mViewList.size();
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view==object;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
//        container.addView(mViewList.get(position));
        View view = mViewList.get(position);
        ImageView imgBg = (ImageView) view.findViewById(R.id.img_guide_bg);
        imgBg.setBackgroundResource(mResIdList[position]);
        container.addView(view);
        return mViewList.get(position);
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView(mViewList.get(position));
    }
}
