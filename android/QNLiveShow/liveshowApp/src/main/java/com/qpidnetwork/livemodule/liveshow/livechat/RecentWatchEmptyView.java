package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.annotation.DrawableRes;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.EmptyView;

/**
 * 列表空数据界面
 * @author Jagger 2018-7-10
 */
public class RecentWatchEmptyView extends LinearLayout implements SwipeRefreshLayout.OnRefreshListener {

    private Context mContext;

    private ImageView ivNodata;
    private SwipeRefreshLayout swipeRefreshLayoutEmpty;
    private OnClickedEventsListener mOnClickedEventsListener;
    /**
     * view内点击事件
     */
    public interface OnClickedEventsListener{
        void onRetry();
    }


    public RecentWatchEmptyView(Context context) {
        super(context);
        mContext = context;
        createView();
    }

    public RecentWatchEmptyView(Context context , AttributeSet attrs) {
        super(context, attrs);
        createView();
    }

    private void createView() {

        View v = LayoutInflater.from(getContext()).inflate(
                R.layout.recent_watch_layout_empty_page, null);

        ivNodata = (ImageView)v.findViewById(R.id.ivNodata);
        swipeRefreshLayoutEmpty = (SwipeRefreshLayout)v.findViewById(R.id.swipeRefreshLayoutEmpty);
        swipeRefreshLayoutEmpty.setOnRefreshListener(this);

        this.setGravity(Gravity.CENTER);
        this.addView(v);
    }

    @Override
    public void onRefresh() {
        if(mOnClickedEventsListener != null){
            mOnClickedEventsListener.onRetry();
        }
    }

    /**
     * 重加载数据完成时调用
     */
    public void onReloadComplete(){
        swipeRefreshLayoutEmpty.setRefreshing(false);
    }

    /**
     * 关闭下拉刷新功能
     */
    public void closePullDownRefresh(){
        swipeRefreshLayoutEmpty.setEnabled(false);
    }

    /**
     *
     * @param listener
     */
    public void setOnClickedEventsListener(OnClickedEventsListener listener){
        this.mOnClickedEventsListener = listener;
    }

}
