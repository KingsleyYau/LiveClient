package com.qpidnetwork.livemodule.liveshow.adapter;

import android.graphics.Rect;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;

/**
 * Created by Hardy on 2018/9/19.
 * <p>
 * 针对 new LinearLayoutManager(instance, LinearLayoutManager.HORIZONTAL, false)
 * 这种单行横向滚动的 RecyclerView 的 item 间，左右间距
 */
public class HorizontalLineDecoration extends RecyclerView.ItemDecoration {

    private int mHorizontalSpacing;

    public HorizontalLineDecoration(int horizontalSpacing) {
        mHorizontalSpacing = horizontalSpacing;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);

        int position = parent.getChildAdapterPosition(view);

        LinearLayoutManager linearLayoutManager = (LinearLayoutManager) parent.getLayoutManager();
        if (linearLayoutManager.getReverseLayout()) {
            // 反向滚动，向右滑动
            outRect.left = mHorizontalSpacing;
            if (position == 0) {
                outRect.right = mHorizontalSpacing;
            }
        } else {
            // 一般，向左滑动
            int totalCount = linearLayoutManager.getItemCount();
            outRect.left = mHorizontalSpacing;
            if (position == totalCount - 1) {
                outRect.right = mHorizontalSpacing;
            }
        }
    }

    public void setLineDecoration(int horizontalSpacing) {
        mHorizontalSpacing = horizontalSpacing;
    }
}
