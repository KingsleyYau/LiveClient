package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.qpidnetwork.livemodule.utils.DisplayUtil;

/**
 * Created  by Oscar
 */
public class WatchItemDecoration extends RecyclerView.ItemDecoration {

    /**
     * @param itemSpace item间隔
     * @param itemNum 每行item的个数
     */
    private int itemSpace;
    private int itemNum = 2;


    public WatchItemDecoration(Context context) {
        this.itemSpace = DisplayUtil.dip2px(context,4);

    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        outRect.bottom = itemSpace;
        if (parent.getChildLayoutPosition(view) % itemNum == 0) {  //parent.getChildLayoutPosition(view) 获取view的下标
            outRect.left = 0;
        } else {
            outRect.left = itemSpace;
        }

    }
}
