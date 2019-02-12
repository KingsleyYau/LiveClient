package com.qpidnetwork.livemodule.liveshow.adapter;

import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

/**
 * Created by Hardy on 2018/9/19.
 * <p>
 * 针对 new LinearLayoutManager(instance, LinearLayoutManager.HORIZONTAL, false)
 * 这种单行横向滚动的 RecyclerView 的 item 间，左右间距
 */
public class HorizontalLineDecoration extends RecyclerView.ItemDecoration {

    private int mHorizontalSpacing = 0;

    public HorizontalLineDecoration(int horizontalSpacing) {
        mHorizontalSpacing = horizontalSpacing;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);

        int position = parent.getChildAdapterPosition(view);
        int totalCount = parent.getLayoutManager().getItemCount();

        outRect.left = mHorizontalSpacing;
        if (position == totalCount - 1) {
            outRect.right = mHorizontalSpacing;
        }
    }

    public void setLineDecoration(int horizontalSpacing){
        mHorizontalSpacing = horizontalSpacing;
    }
}
