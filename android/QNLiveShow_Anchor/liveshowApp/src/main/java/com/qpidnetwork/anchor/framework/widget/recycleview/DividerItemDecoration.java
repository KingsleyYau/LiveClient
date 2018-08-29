package com.qpidnetwork.anchor.framework.widget.recycleview;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.ItemDecoration;
import android.view.View;

import com.qpidnetwork.anchor.utils.Log;

/**
 * Description:根据外部样式自定义RecycleView水平/垂直方向的分割线
 * 参考:https://blog.csdn.net/bobo8945510/article/details/52849084
 * <p>
 * Created by Harry on 2018/6/14.
 */
public class DividerItemDecoration extends ItemDecoration {

    //可延长分割线
    private Drawable mDivider;
    private int mOrientation;
    private Context mContext;

    private final String TAG = DividerItemDecoration.class.getSimpleName();

    public DividerItemDecoration(Context context, int orientation, int dividerResId){
        mDivider = context.getResources().getDrawable(dividerResId);
        this.mContext = context;
        setOrientation(orientation);
    }

    public DividerItemDecoration(Context context, int orientation, Drawable drawable){
        this.mDivider = drawable;
        this.mContext = context;
        setOrientation(orientation);
    }

    /**
     * 判断分割线绘制方向
     * @param orientation
     */
    private void setOrientation(int orientation) {
        if (orientation != LinearLayoutManager.HORIZONTAL && orientation != LinearLayoutManager.VERTICAL) {
            throw new IllegalArgumentException("param orientation is not found!");
        }
        //设定分割线绘制方向
        mOrientation = orientation;
    }

    @Override
    public void onDraw(Canvas c, RecyclerView parent) {
        if (mOrientation == LinearLayoutManager.VERTICAL) {
            drawVertical(c, parent);
        } else {
            drawHorizontal(c, parent);
        }
    }

    /**
     * 绘制水平方向分割线
     * @param c
     * @param parent
     */
    private void drawHorizontal(Canvas c,RecyclerView parent){
        //左右的间距,left就是距离匪类编辑的距离，right同理，可以自行修改
        final int left = parent.getPaddingLeft()+0;
        final int right = parent.getWidth() - parent.getPaddingRight()-0;
        //获取item数据的长度
        final int childCount = parent.getChildCount();
        //循环绘制分割线，根据有多少扫条数据来绘制
        for (int i = 0; i < childCount; i++) {
            final View child = parent.getChildAt(i);
            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child .getLayoutParams();
            final int top = child.getBottom() + params.bottomMargin;
            final int bottom = top + mDivider.getIntrinsicHeight();
            mDivider.setBounds(left, top, right, bottom);
            mDivider.draw(c);
        }
    }

    /**
     * 绘制垂直方向分割线
     * @param c
     * @param parent
     */
    private void drawVertical(Canvas c,RecyclerView parent){
        //上下间距
        final int top = parent.getPaddingTop();
        final int bottom = parent.getHeight() - parent.getPaddingBottom();

        final int childCount = parent.getChildCount();
        //循环绘制分割线
        for (int i = 0; i < childCount; i++) {
            final View child = parent.getChildAt(i);
            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child.getLayoutParams();
            final int left = child.getRight() + params.rightMargin;
            final int right = left + mDivider.getIntrinsicHeight();
            mDivider.setBounds(left, top, right, bottom);
            mDivider.draw(c);
        }
    }

    /**
     * 获取分割线尺寸
     * getItemOffsets中为outRect设置的四个方向的值，将被计算进所有decoration的尺寸中，而这个尺寸，
     * 被计入了RecycleView每个itemView的padding中
     * @param outRect
     * @param itemPosition
     * @param parent
     */
    @Override
    public void getItemOffsets(Rect outRect, int itemPosition, RecyclerView parent) {
        Log.d(TAG,"getItemOffsets-itemPosition:"+itemPosition);
        if(mOrientation == LinearLayoutManager.VERTICAL){
            outRect.set(0, 0, 0,  mDivider.getIntrinsicWidth());
        }else{
            outRect.set(0, 0, mDivider.getIntrinsicWidth(), 0);
        }
    }
}
