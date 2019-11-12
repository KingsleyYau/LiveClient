package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.content.Context;
import android.support.v7.widget.LinearSmoothScroller;
import android.support.v7.widget.RecyclerView;

/**
 * Created by Hardy on 2019/10/10.
 * http://www.pianshen.com/article/3036346826/
 */
public class RecyclerViewTopSmoothScroller extends LinearSmoothScroller {

    private RecyclerView recyclerView;

    public RecyclerViewTopSmoothScroller(Context context, RecyclerView recyclerView) {
        super(context);
        this.recyclerView = recyclerView;
    }

    @Override
    protected int getHorizontalSnapPreference() {
        return SNAP_TO_START;
    }

    @Override
    protected int getVerticalSnapPreference() {
        return SNAP_TO_START;  // 将子view与父view顶部对齐
    }

    public void scroll2PositionAnim(int listPos) {
        setTargetPosition(listPos);
        recyclerView.getLayoutManager().startSmoothScroll(this);
    }
}