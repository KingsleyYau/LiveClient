package com.qpidnetwork.livemodule.view;

import android.graphics.Canvas;
import android.graphics.Rect;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;

/**
 * RecyclerView 间距设置器
 * @author Jagger 2019-10-9
 */
public class SpaceItemDecoration extends RecyclerView.ItemDecoration {

    private int leftRight;
    private int topBottom;

    public SpaceItemDecoration(int leftRight, int topBottom) {
        this.leftRight = leftRight;
        this.topBottom = topBottom;
    }

    @Override
    public void onDraw(Canvas c, RecyclerView parent, RecyclerView.State state) {
        super.onDraw(c, parent, state);
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        LinearLayoutManager layoutManager = (LinearLayoutManager) parent.getLayoutManager();
        //竖直方向的
        if (layoutManager.getOrientation() == LinearLayoutManager.VERTICAL) {

            if (parent.getChildAdapterPosition(view) == 0) {
                //第一项
                outRect.top = 0;
                outRect.bottom = topBottom;
                outRect.left = leftRight;
                outRect.right = leftRight;
            }else if (parent.getChildAdapterPosition(view) == layoutManager.getItemCount() - 1) {
                //最后一项需要 bottom
                outRect.bottom = 0;
                outRect.top = topBottom;
                outRect.left = leftRight;
                outRect.right = leftRight;
            }else{
                outRect.top = topBottom;
                outRect.bottom = topBottom;
                outRect.left = leftRight;
                outRect.right = leftRight;
            }
        } else {
            //最后一项需要right
            if (parent.getChildAdapterPosition(view) == layoutManager.getItemCount() - 1) {
                outRect.right = leftRight;
            }
            outRect.top = topBottom;
            outRect.left = leftRight;
            outRect.bottom = topBottom;
        }
    }


}
