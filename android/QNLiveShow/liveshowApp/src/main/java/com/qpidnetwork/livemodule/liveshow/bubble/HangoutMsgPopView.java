package com.qpidnetwork.livemodule.liveshow.bubble;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;

import com.github.rubensousa.gravitysnaphelper.GravityPagerSnapHelper;
import com.github.rubensousa.gravitysnaphelper.GravitySnapHelper;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HorizontalLineDecoration;
import com.qpidnetwork.livemodule.liveshow.bubble.anim.SlideInOrOutRightAnimator;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.List;

/**
 * Created by Hardy on 2019/3/5.
 * home 主页的冒泡 view
 */
public class HangoutMsgPopView extends LinearLayout {

    private static final String TAG = HangoutMsgPopView.class.getName();

    // 秒
    private static final int SECONDS_ONE = 1000;
    // 倒计时最大的秒数
    public static final int HANG_OUT_PROGRESS_MAX = 100;
    // 自动滚动的 5s 倒计时
    public static final int HANG_OUT_AUTO_SCROLL_INTERVAL = 5 * SECONDS_ONE;
    private static final int HANG_OUT_AUTO_SCROLL_MSG = 5;


    private RecyclerView mRecyclerView;
    private HangoutMsgPopViewAdapter mAdapter;

    private GravityPagerSnapHelper snapHelper;
    private HangoutMsgPopViewHelper cardAdapterHelper;

    private IOnHangoutMsgPopListener iOnHangoutMsgPopListener;

    private Context mContext;
    private int mCurPosition;
    private boolean isScrollStop;

    public HangoutMsgPopView(Context context) {
        this(context, null);
    }

    public HangoutMsgPopView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public HangoutMsgPopView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        mContext = context;

        // 左对齐，露右边头，需求原型
        snapHelper = new GravityPagerSnapHelper(Gravity.START, true, snapListener);
        //
        cardAdapterHelper = new HangoutMsgPopViewHelper(context);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mRecyclerView = findViewById(R.id.view_hang_out_msg_pop_recyclerView);
        // 设置 layoutManager
        LinearLayoutManager manager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, true);
        mRecyclerView.setLayoutManager(manager);
        // 设置 item 居左对齐，露出右边 item 的尾部
        snapHelper.attachToRecyclerView(mRecyclerView);
        // 设置 item 的间隔
        HorizontalLineDecoration horizontalLineDecoration = new HorizontalLineDecoration(DisplayUtil.dip2px(mContext,
                HangoutMsgPopViewHelper.PADDING_LEFT_RIGHT));
        mRecyclerView.addItemDecoration(horizontalLineDecoration);
        // 设置动画
        mRecyclerView.setItemAnimator(new SlideInOrOutRightAnimator());
        // 设置 adapter
        mAdapter = new HangoutMsgPopViewAdapter(mContext);
        // 设置 adapter 的数据操作监听
        mAdapter.registerAdapterDataObserver(mAdapterDataObserver);
        // 设置 adapter 的 item 点击事件
        mAdapter.setOnItemClickListener(mOnItemClickListener);
        // 绑定 adapter
        mRecyclerView.setAdapter(mAdapter);
    }

    /**
     * item 的 hang out 点击事件
     */
    BaseRecyclerViewAdapter.OnItemClickListener mOnItemClickListener = new BaseRecyclerViewAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {
            if (iOnHangoutMsgPopListener != null) {
                iOnHangoutMsgPopListener.onHandoutClick(position);
            }
        }
    };

    /**
     * 滚动过程中选中哪个 item 的回调
     */
    GravitySnapHelper.SnapListener snapListener = new GravitySnapHelper.SnapListener() {
        @Override
        public void onSnap(int position) {
            Log.i(TAG, "--------SnapListener: ------> " + position);
            mCurPosition = position;
            if (iOnHangoutMsgPopListener != null) {
                iOnHangoutMsgPopListener.onScrollItemChange(mCurPosition);
            }
        }
    };

    /**
     * item 删除、增加操作成功后的回调
     */
    RecyclerView.AdapterDataObserver mAdapterDataObserver = new RecyclerView.AdapterDataObserver() {
        @Override
        public void onItemRangeInserted(int positionStart, int itemCount) {
            super.onItemRangeInserted(positionStart, itemCount);
            Log.i(TAG, "HangoutMsgPopView onItemRangeInserted positionStart: " + positionStart + "  itemCount: " + itemCount);

            setVisibility(VISIBLE);

            handlerOneItemWidth();

            // 自动滚动到最新一条消息，即最左侧
            snapHelper.smoothScrollToPosition(getLastPosition());
        }

        @Override
        public void onItemRangeRemoved(int positionStart, int itemCount) {
            super.onItemRangeRemoved(positionStart, itemCount);
            Log.i(TAG, "HangoutMsgPopView onItemRangeRemoved positionStart: " + positionStart + "  itemCount: " + itemCount);

            handlerOneItemWidth();

            // 2019/3/5 如果 item 个数为 0 ，隐藏该 pop
            // 延时，是为了退场动画可以展示完全后再隐藏布局
            if (mAdapter.getItemCount() == 0) {
                mRecyclerView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        setVisibility(GONE);
                    }
                }, 600);
            }
        }
    };

    /**
     * 只有一个 item 的情况先，设置 recyclerView 的宽度，兼容单个 item 居中显示
     */
    private void handlerOneItemWidth() {
        int count = mAdapter.getItemCount();
        LayoutParams layoutParams = (LayoutParams) mRecyclerView.getLayoutParams();
        if (count == 1) {
            if (layoutParams.width != cardAdapterHelper.getItemWidthOne()) {
                layoutParams.width = cardAdapterHelper.getItemWidthOne();
            }
        } else {
            if (layoutParams.width != LayoutParams.MATCH_PARENT) {
                layoutParams.width = LayoutParams.MATCH_PARENT;
            }
        }
    }

    /**
     * position 是否有效
     *
     * @param pos
     * @return
     */
    public boolean isValidPosition(int pos) {
        return pos >= 0 && pos < mAdapter.getItemCount();
    }

    /**
     * 滚动过程中，停止后的 item position
     *
     * @return
     */
    public int getCurPosition() {
        return mCurPosition;
    }

    /**
     * 最后一个 item 的 position
     *
     * @return
     */
    public int getLastPosition() {
        int pos = mAdapter.getItemCount() - 1;
        return pos < 0 ? 0 : pos;
    }

    public void setOnHangoutMsgPopListener(IOnHangoutMsgPopListener iOnHangoutMsgPopListener) {
        this.iOnHangoutMsgPopListener = iOnHangoutMsgPopListener;
    }

    /**
     * 获取当前的 ViewHolder
     *
     * @param pos
     * @return
     */
    private HangoutMsgPopViewAdapter.HangoutMsgPopViewHolder getViewHolder(int pos) {
        HangoutMsgPopViewAdapter.HangoutMsgPopViewHolder viewHolder = null;
        if (isValidPosition(pos)) {
            viewHolder = (HangoutMsgPopViewAdapter.HangoutMsgPopViewHolder) mRecyclerView.findViewHolderForAdapterPosition(pos);
        }
        return viewHolder;
    }

    /**
     * 获取当前倒计时的进度
     *
     * @param pos
     * @return
     */
    public int getProgress(int pos) {
        if (isValidPosition(pos)) {
            HangoutMsgPopViewAdapter.HangoutMsgPopViewHolder viewHolder = getViewHolder(pos);
            if (viewHolder != null) {
                return viewHolder.getProgress();
            }
        }
        return 0;
    }

    /**
     * 改变倒计时进度
     *
     * @param pos
     * @param progress
     */
    public void changeProgress(int pos, int progress) {
        if (isValidPosition(pos)) {
            // TODO: 2019/3/6   更新数据集

            HangoutMsgPopViewAdapter.HangoutMsgPopViewHolder viewHolder = getViewHolder(pos);
            if (viewHolder != null) {
                viewHolder.changeHangoutProgress(progress);
            }
        }
    }

    public void onDestroy() {
        if (iOnHangoutMsgPopListener != null) {
            iOnHangoutMsgPopListener = null;
        }
    }

    //========================  item 增加 =============================

    /**
     * 通知刷新
     */
    public void notifyAdapterDataChange(){
        mAdapter.notifyDataSetChanged();
    }

    public void addMsg(List<BubbleMessageBean> list) {
        mAdapter.setData(list);
    }

    /**
     * 增加冒泡消息，添加在 item list 尾，即列表滚动 ui 的头部
     *
     * @param data
     */
    public void addMsg(BubbleMessageBean data) {
        mAdapter.addData(mAdapter.getItemCount(), data);

        // 自动滚动到最新一条消息，即最左侧
//        snapHelper.smoothScrollToPosition(getLastPosition());
    }

    //========================  item 增加 =============================

    //========================  item 删除 =============================

    public BubbleMessageBean getItem(int pos){
        return mAdapter.getItemBean(pos);
    }

    public void removeMsg(int position) {
        mAdapter.removeItem(position);
    }

    public void removeRange(int startPos, int count){
        mAdapter.removeRange(startPos, count);
    }

    public void removeMsgFirst() {
        removeMsg(0);
    }

    public void removeMsgLast() {
        removeMsg(getLastPosition());
    }
    //========================  item 删除 =============================

    //========================  item 滚动 =============================
    public void scroll2Position(int position) {
        if (isValidPosition(position)) {
            snapHelper.smoothScrollToPosition(position);
        }
    }

    public void scroll2First() {
        snapHelper.smoothScrollToPosition(0);
    }

    public void scroll2Last() {
        int pos = getLastPosition();
        if (isValidPosition(pos)) {
            snapHelper.smoothScrollToPosition(pos);
        }
    }

}
