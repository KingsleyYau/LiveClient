package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;

import com.takwolf.android.hfrecyclerview.HeaderAndFooterRecyclerView;


public class HeaderAndFooterRecyclerViewEx extends HeaderAndFooterRecyclerView {
    private boolean mLoadMoreEnabled = true;
    private int mActivePointerId;
    private float mLastY = -1;
    private float sumOffSet;
    private static final float DRAG_RATE = 2.0f;

    public enum LayoutManagerType {
        LinearLayout,
        StaggeredGridLayout,
        GridLayout
    }

    /**
     * 当前RecyclerView类型
     */
    protected LayoutManagerType layoutManagerType;

    /**
     * 最后一个的位置
     */
    private int[] lastPositions;

    /**
     * 第一个可见的item的位置
     */
    private int firstVisibleItemPosition;

    /**
     * 最后一个可见的item的位置
     */
    private int lastVisibleItemPosition;

    /**
     * 当前滑动的状态
     */
    private int currentScrollState = 0;

    /**
     * 触发在上下滑动监听器的容差距离
     */
    private static final int HIDE_THRESHOLD = 20;

    /**
     * 滑动的距离
     */
    private int mDistance = 0;

    /**
     * 是否需要监听控制
     */
    private boolean mIsScrollDown = true;

    /**
     * Y轴移动的实际距离（最顶部为0）
     */
    private int mScrolledYDistance = 0;

    /**
     * X轴移动的实际距离（最左侧为0）
     */
    private int mScrolledXDistance = 0;

    private HFScrollListener mHFScrollListener;
    private HFRefreshListener mHFRefreshListener;

    //-------------自定义接口-------------
    public interface HFScrollListener {

        /**
         * 向上滚（数据多于一页，可以滚动时才触发）
         */
        void onScrollUp();

        /**
         * 向下滚（数据多于一页，可以滚动时才触发）
         */
        void onScrollDown();

        /**
         * 数据多于一页，可以滚动时才触发
         * @param distanceX
         * @param distanceY
         */
        void onScrolled(int distanceX, int distanceY);

        /**
         * 只要手势上下滑动就触发
         * @param state
         */
        void onScrollStateChanged(int state);
    }

    public interface HFRefreshListener {
        /**
         * 滚到最顶了，可以看到"刷新"
         * 由于这是手势触发的，所以会触发很多次，外部要加上标识处理
         */
        void onTopRefreshShow();

        /**
         * 滚到最底了，可以看到"更多"
         * 由于这是手势触发的，所以会触发很多次，外部要加上标识处理
         */
        void onBottomMoreShow();
    }

    //-------------end 自定义接口-------------


    public HeaderAndFooterRecyclerViewEx(@NonNull Context context) {
        super(context);
    }

    public HeaderAndFooterRecyclerViewEx(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public void setHFScrollListener(HFScrollListener listener) {
        mHFScrollListener = listener;
    }

    public void setHFRefreshListner(HFRefreshListener listner){
        mHFRefreshListener = listner;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (mLastY == -1) {
            mLastY = ev.getY();
            mActivePointerId = ev.getPointerId(0);
            sumOffSet = 0;
        }


        switch (ev.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                mLastY = ev.getY();
                mActivePointerId = ev.getPointerId(0);
                sumOffSet = 0;

//                Log.i("Jagger" , "HeaderAndFooterRecyclerViewEx ACTION_DOWN:" + mLastY);

                break;

            case MotionEvent.ACTION_POINTER_DOWN:
                final int index = ev.getActionIndex();
                mActivePointerId = ev.getPointerId(index);
                mLastY = (int) ev.getY(index);
                break;

            case MotionEvent.ACTION_MOVE:
                try{
                    int pointerIndex = ev.findPointerIndex(mActivePointerId);
                    final int moveY = (int) ev.getY(pointerIndex);
                    final float deltaY = (moveY - mLastY) / DRAG_RATE;
                    mLastY = moveY;
                    sumOffSet += deltaY;

//                Log.i("Jagger" , "HeaderAndFooterRecyclerViewEx ACTION_MOVE:" + mLastY + ",sumOffSet:" + sumOffSet);
                }catch (IllegalArgumentException e){}
                break;
            case MotionEvent.ACTION_UP:
                mLastY = -1; // reset
                mActivePointerId = -1;
                break;
        }

        return super.onTouchEvent(ev);
    }

    @Override
    public void onScrollStateChanged(int state) {
        super.onScrollStateChanged(state);
        currentScrollState = state;

        if (mHFScrollListener != null) {
            mHFScrollListener.onScrollStateChanged(state);
        }

        updateVisibleItemPosition();

        //滚到最顶了，可以看到"刷新"
        if(firstVisibleItemPosition <= 1 && sumOffSet > 0){
            //TODO show refresh
            if(mHFRefreshListener != null){
                mHFRefreshListener.onTopRefreshShow();
            }
        }
    }

    @Override
    public void onScrolled(int dx, int dy) {
        super.onScrolled(dx, dy);

        updateVisibleItemPosition();

        // 根据类型来计算出第一个可见的item的位置，由此判断是否触发到底部的监听器
        // 计算并判断当前是向上滑动还是向下滑动
        calculateScrollUpOrDown(firstVisibleItemPosition, dy);
        // 移动距离超过一定的范围，我们监听就没有啥实际的意义了
        mScrolledXDistance += dx;
        mScrolledYDistance += dy;
        mScrolledXDistance = (mScrolledXDistance < 0) ? 0 : mScrolledXDistance;
        mScrolledYDistance = (mScrolledYDistance < 0) ? 0 : mScrolledYDistance;
        if (mIsScrollDown && (dy == 0)) {
            mScrolledYDistance = 0;
        }
        //Be careful in here
        if (null != mHFScrollListener) {
            mHFScrollListener.onScrolled(mScrolledXDistance, mScrolledYDistance);
        }
//        if (mLoadMoreListener != null && mLoadMoreEnabled) {
//        if (mLoadMoreEnabled) {
            int visibleItemCount = getLayoutManager().getChildCount();
            int totalItemCount = getLayoutManager().getItemCount();
//            Log.i("Jagger" , "visibleItemCount:" + visibleItemCount + ",lastVisibleItemPosition:" + lastVisibleItemPosition + ",totalItemCount:" + totalItemCount);
            if (visibleItemCount > 0
                    && lastVisibleItemPosition >= totalItemCount - 1
                    && totalItemCount > visibleItemCount){
//                    && !isNoMore
//                    && !mRefreshing) {

//                mFootView.setVisibility(View.VISIBLE);
//                if (!mLoadingData) {
//                    mLoadingData = true;
//                    mLoadMoreFooter.onLoading();
//                    mLoadMoreListener.onLoadMore();
//                }

                //滚到最底了，可以看到"更多"
                Log.i("Jagger" , "滚到最底了，可以看到\"更多\"");
                if(mHFRefreshListener != null){
                    mHFRefreshListener.onBottomMoreShow();
                }
            }

//        }
    }

    private void updateVisibleItemPosition(){
        RecyclerView.LayoutManager layoutManager = getLayoutManager();

        if (layoutManagerType == null) {
            if (layoutManager instanceof LinearLayoutManager) {
                layoutManagerType = LayoutManagerType.LinearLayout;
            } else if (layoutManager instanceof GridLayoutManager) {
                layoutManagerType = LayoutManagerType.GridLayout;
            } else if (layoutManager instanceof StaggeredGridLayoutManager) {
                layoutManagerType = LayoutManagerType.StaggeredGridLayout;
            } else {
                throw new RuntimeException(
                        "Unsupported LayoutManager used. Valid ones are LinearLayoutManager, GridLayoutManager and StaggeredGridLayoutManager");
            }
        }

        switch (layoutManagerType) {
            case LinearLayout:
                firstVisibleItemPosition = ((LinearLayoutManager) layoutManager).findFirstVisibleItemPosition();
                lastVisibleItemPosition = ((LinearLayoutManager) layoutManager).findLastVisibleItemPosition();
                break;
            case GridLayout:
                firstVisibleItemPosition = ((GridLayoutManager) layoutManager).findFirstVisibleItemPosition();
                lastVisibleItemPosition = ((GridLayoutManager) layoutManager).findLastVisibleItemPosition();
                break;
            case StaggeredGridLayout:
                StaggeredGridLayoutManager staggeredGridLayoutManager = (StaggeredGridLayoutManager) layoutManager;
                if (lastPositions == null) {
                    lastPositions = new int[staggeredGridLayoutManager.getSpanCount()];
                }
                staggeredGridLayoutManager.findLastVisibleItemPositions(lastPositions);
                lastVisibleItemPosition = findMax(lastPositions);
                staggeredGridLayoutManager.findFirstCompletelyVisibleItemPositions(lastPositions);
                firstVisibleItemPosition = findMax(lastPositions);
                break;
        }
    }

    private int findMax(int[] lastPositions) {
        int max = lastPositions[0];
        for (int value : lastPositions) {
            if (value > max) {
                max = value;
            }
        }
        return max;
    }

    /**
     * 计算当前是向上滑动还是向下滑动
     */
    private void calculateScrollUpOrDown(int firstVisibleItemPosition, int dy) {
//        android.util.Log.i("Jagger" , "calculateScrollUpOrDown: " + firstVisibleItemPosition + ",dy" + dy + ",mIsScrollDown:" + mIsScrollDown);
        if (null != mHFScrollListener) {
            if (firstVisibleItemPosition == 0) {
                if (!mIsScrollDown) {
                    mIsScrollDown = true;
                    mHFScrollListener.onScrollDown();
                }
            } else {
                if (mDistance > HIDE_THRESHOLD && mIsScrollDown) {
                    mIsScrollDown = false;
                    mHFScrollListener.onScrollUp();
                    mDistance = 0;
                } else if (mDistance < -HIDE_THRESHOLD && !mIsScrollDown) {
                    mIsScrollDown = true;
                    mHFScrollListener.onScrollDown();
                    mDistance = 0;
                }
            }
        }

        if ((mIsScrollDown && dy > 0) || (!mIsScrollDown && dy < 0)) {
            mDistance += dy;
        }
    }
}
