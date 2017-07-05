package com.qpidnetwork.framework.livemsglist;

import android.support.v7.widget.RecyclerView;

/**
 * Created by Jagger on 2017/6/1.
 */

public abstract class RecyclerViewScrollDetector  extends RecyclerView.OnScrollListener {
    private int mScrollThreshold;

    abstract void onScrollUp();

    abstract void onScrollDown();

    abstract void onLoadMore();

    abstract void onHold();

    @Override
    public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
        boolean isSignificantDelta = Math.abs(dy) > mScrollThreshold;
        if (isSignificantDelta) {
            if (dy > 0) {
                onScrollUp();
            } else {
                onScrollDown();
            }
        }
    }

    public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
        super.onScrollStateChanged(recyclerView, newState);

        if(newState == RecyclerView.SCROLL_STATE_IDLE ){
            //值表示是否能向上滚动，false表示已经滚动到底部)
            if(!recyclerView.canScrollVertically(1)){
                onLoadMore();
            }else{
                onHold();
            }

        }
    }

    /**
     * 设置上下滑动伐值 （一般为：4DP）
     * @param scrollThreshold
     */
    public void setScrollThreshold(int scrollThreshold) {
        mScrollThreshold = scrollThreshold;
    }
}
