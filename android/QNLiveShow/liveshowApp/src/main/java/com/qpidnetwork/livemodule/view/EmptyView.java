package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.ballRefresh.ThreeBallHeader;
import com.scwang.smartrefresh.layout.SmartRefreshLayout;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshListener;

/**
 * 列表空数据界面
 *
 * @author Jagger 2018-7-10
 */
public class EmptyView extends LinearLayout implements OnRefreshListener {

    private Context mContext;

    private ImageView ivNodata;
    private TextView tvEmptyDesc;
    private Button btnGuide;
    private SmartRefreshLayout swipeRefreshLayoutEmpty;

    private OnClickedEventsListener mOnClickedEventsListener;

    /**
     * view内点击事件
     */
    public interface OnClickedEventsListener {
        void onRetry();

        void onGuide();
    }

    public EmptyView(Context context) {
        super(context);
        mContext = context;
        createView();
    }

    public EmptyView(Context context, AttributeSet attrs) {
        super(context, attrs);
        createView();
    }

    private void createView() {

        View v = LayoutInflater.from(getContext()).inflate(
                R.layout.live_layout_empty_page, this, false);

        ivNodata = (ImageView) v.findViewById(R.id.ivNodata);
        btnGuide = (Button) v.findViewById(R.id.btnGuide);
        btnGuide.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mOnClickedEventsListener != null) {
                    mOnClickedEventsListener.onGuide();
                }
            }
        });
        tvEmptyDesc = (TextView) v.findViewById(R.id.tvEmptyDesc);
        btnGuide = (Button) v.findViewById(R.id.btnGuide);
        swipeRefreshLayoutEmpty = v.findViewById(R.id.swipeRefreshLayoutEmpty);
        swipeRefreshLayoutEmpty.setOnRefreshListener(this);
        swipeRefreshLayoutEmpty.setRefreshHeader(new ThreeBallHeader(getContext()));
        swipeRefreshLayoutEmpty.setEnableAutoLoadMore(false);
        swipeRefreshLayoutEmpty.setEnableLoadMore(false);

        this.setGravity(Gravity.CENTER);
        this.addView(v);
    }

    @Override
    public void onRefresh(@NonNull RefreshLayout refreshLayout) {
        if (mOnClickedEventsListener != null) {
            mOnClickedEventsListener.onRetry();
        }
    }

    /**
     * 重加载数据完成时调用
     */
    public void onReloadComplete() {
//        swipeRefreshLayoutEmpty.setRefreshing(false);
        swipeRefreshLayoutEmpty.finishRefresh();
    }

    /**
     * 关闭下拉刷新功能
     */
    public void closePullDownRefresh() {
        swipeRefreshLayoutEmpty.setEnabled(false);
    }

    /**
     * @param listener
     */
    public void setOnClickedEventsListener(OnClickedEventsListener listener) {
        this.mOnClickedEventsListener = listener;
    }

    /**
     * 设置默认无数据页样式中文字
     *
     * @param message
     */
    public void setDefaultEmptyMessage(String message) {
        if (tvEmptyDesc != null) {
            tvEmptyDesc.setText(message);
        }
    }

//    /**
//     * 设置默认无数据页样式中文字
//     *
//     * @param message
//     */
//    public void setDefaultEmptyMessage(String message, @DrawableRes int drawableLeftId, int widthPx, int heightPx) {
//        if (tvEmptyDesc != null) {
//            tvEmptyDesc.setText(message);
//            Drawable drawableLeft = mContext.getResources().getDrawable(drawableLeftId);
//            // 这一步必须要做，否则不会显示。
//            drawableLeft.setBounds(0,
//                    0,
//                    widthPx,
//                    heightPx);// 设置图片宽高
//            tvEmptyDesc.setCompoundDrawables(drawableLeft, null, null, null);
//            tvEmptyDesc.setCompoundDrawablePadding(8);//设置图片和text之间的间距
//        }
//    }

    /**
     * 设置默认无数据页图标
     *
     * @param visible
     */
    public void setDefaultEmptyIconVisible(int visible) {
        ivNodata.setVisibility(visible);
    }
}
