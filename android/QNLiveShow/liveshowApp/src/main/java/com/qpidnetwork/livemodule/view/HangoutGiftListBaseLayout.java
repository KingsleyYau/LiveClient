package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.gcssloop.widget.PagerConfig;
import com.gcssloop.widget.PagerGridLayoutManager;
import com.gcssloop.widget.PagerGridSnapHelper;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListBaseAdapter;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

import java.util.List;

/**
 * Created by Hardy on 2019/3/14.
 * Hangout 礼物弹窗——礼物列表的基类
 */
public abstract class HangoutGiftListBaseLayout extends LinearLayout {

    private static final String TAG = "info";

    private RecyclerView mRecyclerView;
    private HangoutGiftListBaseAdapter mAdapter;
    private LinearLayout mLLIndicator;

    protected Context mContext;

    private int currPageIndex = 0;


    public HangoutGiftListBaseLayout(Context context) {
        this(context, null);
    }

    public HangoutGiftListBaseLayout(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public HangoutGiftListBaseLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    protected void init(Context context) {
        mContext = context;

        // 设置滚动速度(滚动一英寸所耗费的微秒数，数值越大，速度越慢，默认为 60f)
        PagerConfig.setMillisecondsPreInch(90f);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        // 底部页数小圆点
        mLLIndicator = findViewById(R.id.layout_ho_gift_list_base_ll_indicator);

        // recyclerView
        mRecyclerView = findViewById(R.id.layout_ho_gift_list_base_recyclerView);
        // 1.水平分页布局管理器
        PagerGridLayoutManager layoutManager = new PagerGridLayoutManager(getRVRows(), getRVColumns(), PagerGridLayoutManager.HORIZONTAL);
        layoutManager.setPageListener(pageListener);
        mRecyclerView.setLayoutManager(layoutManager);
        // 2.设置滚动辅助工具
        PagerGridSnapHelper pageSnapHelper = new PagerGridSnapHelper();
        pageSnapHelper.attachToRecyclerView(mRecyclerView);
        // 3.创建 adapter
        mAdapter = createRecyclerAdapter();
        mAdapter.setOnItemClickListener(onItemClickListener);
        // 4.设置 adapter
        mRecyclerView.setAdapter(mAdapter);
    }

    /**
     * 礼物的点击事件
     */
    BaseRecyclerViewAdapter.OnItemClickListener onItemClickListener = new BaseRecyclerViewAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {
            GiftItem item = mAdapter.getItemBean(position);
            if (item != null) {
                // 回调各个继承的子类进行处理
                onGiftClick(position, item);

                // 回调外层 UI 进行处理
                if (mOnGiftItemClickListener != null) {
                    mOnGiftItemClickListener.onGiftClick(position, item);
                }
            }
        }
    };

    /**
     * 列表的页数事件回调
     */
    PagerGridLayoutManager.PageListener pageListener = new PagerGridLayoutManager.PageListener() {
        @Override
        public void onPageSizeChanged(int pageSize) {
            Log.i("info", "-----onPageSizeChanged----> pageSize: " + pageSize);

            // 2019/3/14 页数大小改变，改变底部的页数圆点总个数
            updateIndicatorView(pageSize);
        }

        @Override
        public void onPageSelect(int pageIndex) {
            Log.i("info", "-----onPageSelect----> pageIndex: " + pageIndex);

            // 2019/3/14 当前选中哪一页，改变底部的页数圆点选中状态
            updateIndicatorStatus(pageIndex);
        }
    };

    public HangoutGiftListBaseAdapter getAdapter() {
        return mAdapter;
    }


    public void setData(List<GiftItem> list) {
        mAdapter.setData(list);
    }

    //==============    底部页数圆点 ===========================

    /**
     * 更新指示器图标数量展示，当礼物数量发生变动的时候调用
     *
     * @param count 礼物页数
     */
    private void updateIndicatorView(int count) {
        mLLIndicator.setVisibility(VISIBLE);
        mLLIndicator.removeAllViews();

        final int pageCount = count;
        // post ,避免第一次调用时，绘制时机的问题导致不出现
        mLLIndicator.post(new Runnable() {
            @Override
            public void run() {
                int endIndex = pageCount - 1;
                int indicatorWidth = DisplayUtil.dip2px(mContext, 6f);
                int indicatorMargin = DisplayUtil.dip2px(mContext, 4f);

                for (int index = 0; index < pageCount; index++) {
                    ImageView indicator = new ImageView(getContext());

                    LinearLayout.LayoutParams lp_indicator = new LinearLayout.LayoutParams(indicatorWidth, indicatorWidth);
                    lp_indicator.gravity = Gravity.CENTER;
                    lp_indicator.leftMargin = 0 == index ? 0 : indicatorMargin;//px 需要转换成dip单位
                    lp_indicator.rightMargin = endIndex == index ? 0 : indicatorMargin;
                    indicator.setLayoutParams(lp_indicator);
                    indicator.setBackgroundDrawable(ContextCompat.getDrawable(mContext, R.drawable.selector_page_indicator));

                    mLLIndicator.addView(indicator);
                }

                // 更新 pos
                updateIndicatorStatus(0);

            }
        });
    }

    /**
     * 更新指示器状态
     *
     * @param selectedIndex 当前礼物页索引
     */
    private void updateIndicatorStatus(int selectedIndex) {
        currPageIndex = selectedIndex;

        int pageCount = mLLIndicator.getChildCount();

        for (int index = 0; index < pageCount; index++) {
            View view = mLLIndicator.getChildAt(index);
            if (null != view && View.VISIBLE == view.getVisibility()) {
                view.setSelected(selectedIndex == index);
            }
        }
    }
    //==============    底部页数圆点 ===========================


    //==============    abstract method ===========================

    /**
     * Grid 列表的行数
     *
     * @return
     */
    protected abstract int getRVRows();

    /**
     * Grid 列表的列数
     *
     * @return
     */
    protected abstract int getRVColumns();

    /**
     * 创建列表的 Adapter
     *
     * @return
     */
    protected abstract HangoutGiftListBaseAdapter createRecyclerAdapter();

    /**
     * 列表的礼物点击事件回调
     */
    protected abstract void onGiftClick(int pos, GiftItem giftItem);
    //==============    abstract method ===========================


    //==============    interface method ===========================

    private OnGiftItemClickListener mOnGiftItemClickListener;

    public void setOnGiftItemClickListener(OnGiftItemClickListener onGiftItemClickListener) {
        this.mOnGiftItemClickListener = onGiftItemClickListener;
    }

    public interface OnGiftItemClickListener {
        void onGiftClick(int pos, GiftItem giftItem);
    }
    //==============    interface method ===========================
}
