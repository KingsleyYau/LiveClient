package com.qpidnetwork.livemodule.view.ballRefresh;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.HeaderAndFooterRecyclerViewEx;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;
import com.scwang.smartrefresh.layout.SmartRefreshLayout;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshLoadMoreListener;
import com.takwolf.android.hfrecyclerview.HeaderAndFooterRecyclerView;

/**
 * Created by Jagger on 2018/4/23.
 */
public class BallRefreshRecyclerView extends SmartRefreshLayout implements OnRefreshLoadMoreListener {

    private HeaderAndFooterRecyclerViewEx recyclerView;

    // local various
    private boolean is_loading = false;
    private boolean can_pull_up = true;
    private boolean can_pull_down = true;

    // callback
    private RefreshRecyclerView.OnPullRefreshListener mOnPullRefreshListener;
    private RefreshRecyclerView.RScrollLister mRScrollLister;


    public BallRefreshRecyclerView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

//    // new
    @Override
    public void onFinishInflate() {
        super.onFinishInflate();

        recyclerView = findViewById(R.id.recyclerView);

        setRefreshView();
    }

    private void setRefreshView() {
        /*
            属性配置文档
            https://github.com/scwang90/SmartRefreshLayout/blob/master/art/md_property.md
         */
        setRefreshHeader(new ThreeBallHeader(getContext()));
        setRefreshFooter(new ThreeBallFooter(getContext()));
        setEnableLoadMoreWhenContentNotFull(false);          //是否在列表不满一页时候开启上拉加载功能
        setOnRefreshLoadMoreListener(this);

        recyclerView.setHFScrollListener(new HeaderAndFooterRecyclerViewEx.HFScrollListener() {
            @Override
            public void onScrollUp() {
//				android.util.Log.i("Jagger" , "******************onScrollUp");
            }

            @Override
            public void onScrollDown() {
//				android.util.Log.i("Jagger" , "****************onScrollDown");
            }

            @Override
            public void onScrolled(int distanceX, int distanceY) {
//				android.util.Log.i("Jagger" , "onScrolled");
            }

            @Override
            public void onScrollStateChanged(int state) {
//				android.util.Log.i("Jagger" , "onScrollStateChanged");
                if (mRScrollLister != null) {
                    mRScrollLister.onScrollStateChanged(state);
                }
            }
        });

        recyclerView.setHFRefreshListner(new HeaderAndFooterRecyclerViewEx.HFRefreshListener() {
            @Override
            public void onTopRefreshShow() {
                if (mRScrollLister != null) {
                    mRScrollLister.onScrollToTop();
                }
            }

            @Override
            public void onBottomMoreShow() {
//                if (!can_pull_up)
//                    return;
//
//                if (is_loading)
//                    return;
//
//                is_loading = true;
//                //上拉更多时，不能下拉刷新
//                swipeRefreshLayout.setEnabled(false);
//                //显示更多
//                listFooter.setVisibility(View.VISIBLE);
//                listFooter.setPadding(0, 0, 0, 0);
//
//                if (mOnPullRefreshListener != null) {
//                    mOnPullRefreshListener.onPullUpToRefresh();
//                }
//                if (mRScrollLister != null) {
//                    mRScrollLister.onScrollToBottom();
//                }
            }
        });
    }

    /**
     * 自动刷新
     */
    public void showRefreshing() {
//        autoRefresh();        // 会自动回调到 onRefresh 方法做进一步的业务处理.
        autoRefreshAnimationOnly();//自动刷新，只显示动画不执行刷新
    }

    public void hideRefreshing(){
        finishRefresh();
    }

    public void setCanPullDown(boolean b) {
        can_pull_down = b;
        setEnableRefresh(b);
    }

    public boolean isRefreshEnable() {
        return can_pull_down;
    }

    public boolean isCanPullDown() {
        return can_pull_down;
    }

    public void setCanPullUp(boolean b) {
        can_pull_up = b;
    }

    public boolean isCanPullUp() {
        return can_pull_up;
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        recyclerView.setAdapter(adapter);
    }

    public HeaderAndFooterRecyclerView getRecyclerView() {
        return recyclerView;
    }

    public SmartRefreshLayout getSwipeRefreshLayout() {
//        return  swipeRefreshLayout;
        return  this;
    }

//    public FrameLayout getRootView() {
    public View getRootView() {
        return this;
    }

//    @Override
//    public void onRefresh() {
//        if (!can_pull_down)
//            return;
//        if (is_loading)
//            return;
//        is_loading = true;
//        if (mOnPullRefreshListener != null) {
//            mOnPullRefreshListener.onPullDownToRefresh();
//        }
//    }

    public void onRefreshComplete() {
        finishRefresh();
        finishLoadMore();

        is_loading = false;
        if (can_pull_down) {
            setEnableRefresh(true);
        }
    }

    public void setOnPullRefreshListener(RefreshRecyclerView.OnPullRefreshListener listener) {
        this.mOnPullRefreshListener = listener;
    }

    public void setRScrollLister(RefreshRecyclerView.RScrollLister listener) {
        this.mRScrollLister = listener;
    }

    @Override
    public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
        // 2019/7/25 new
        if (!can_pull_up || is_loading) {
            finishLoadMore();
            return;
        }

        is_loading = true;

//        //上拉更多时，不能下拉刷新
        setEnableRefresh(false);

        if (mOnPullRefreshListener != null) {
            mOnPullRefreshListener.onPullUpToRefresh();
        }
        if (mRScrollLister != null) {
            mRScrollLister.onScrollToBottom();
        }
    }

    @Override
    public void onRefresh(@NonNull RefreshLayout refreshLayout) {
        // 2019/7/25 new
        if (!can_pull_down || is_loading) {
            finishRefresh();
            return;
        }

        is_loading = true;
        if (mOnPullRefreshListener != null) {
            mOnPullRefreshListener.onPullDownToRefresh();
        }
    }

}
