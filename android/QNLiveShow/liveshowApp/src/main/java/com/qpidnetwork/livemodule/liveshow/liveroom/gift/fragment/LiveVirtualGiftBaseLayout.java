package com.qpidnetwork.livemodule.liveshow.liveroom.gift.fragment;

import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.support.annotation.NonNull;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomVirtualGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialogHelper;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.SpacingDecoration;

/**
 * Created by Hardy on 2019/9/3.
 * 直播间礼物弹窗的列表
 */
public abstract class LiveVirtualGiftBaseLayout extends FrameLayout implements View.OnClickListener {

    protected static final int LOADING_DELAY_TIME = 1500;

    private ImageView mIvLoading;
    private View mLLEmpty;
    private View mLLRetry;

    protected RecyclerView mRvView;
    private BaseRecyclerViewAdapter mAdapter;

    // 礼物标签分类
    protected GiftTypeItem giftTypeItem;
    //房间礼物管理器
    protected RoomGiftManager mRoomGiftManager;
    protected RoomVirtualGiftManager mRoomVirtualGiftManager;
    //dialog数据共享帮助类
    protected LiveGiftDialogHelper mGiftDialogHelper;

    protected Context mContext;

    protected int mClickPos;

    public LiveVirtualGiftBaseLayout(@NonNull Context context,
                                     LiveGiftDialogHelper giftDialogHelper,
                                     RoomGiftManager roomGiftManager,
                                     RoomVirtualGiftManager mRoomVirtualGiftManager,
                                     GiftTypeItem giftTypeItem) {
        super(context);

        this.mContext = context;
        this.giftTypeItem = giftTypeItem;
        this.mGiftDialogHelper = giftDialogHelper;
        this.mRoomGiftManager = roomGiftManager;
        this.mRoomVirtualGiftManager = mRoomVirtualGiftManager;

        init();
    }

    private void init() {
        //del by Jagger BUG#20737 移到初始化中赋值
//        mContext = getContext();

        View view = createView();

        initView(view);
        initData();
    }

    private View createView() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.fragment_live_virtual_gift_base, this, false);

        this.addView(view);

        return view;
    }

    protected void initView(View v) {
        mIvLoading = v.findViewById(R.id.dialog_live_virtual_gift_iv_loading);
        mLLEmpty = v.findViewById(R.id.dialog_ho_gift_ll_emptyData);
        mLLRetry = v.findViewById(R.id.dialog_ho_gift_ll_errorRetry);

        mLLRetry.setOnClickListener(this);

        mRvView = v.findViewById(R.id.dialog_live_virtual_gift_recyclerView);
        int count = 4;
        mRvView.setLayoutManager(new GridLayoutManager(mContext, count));

        int vSpace = DisplayUtil.dip2px(mContext, 13);
        SpacingDecoration gridMarginDecoration = new SpacingDecoration(0, vSpace, true);
        mRvView.addItemDecoration(gridMarginDecoration);

        mRvView.setHasFixedSize(true);
        mRvView.setFocusable(false);
        // set adapter
        mAdapter = getAdapter();
        mAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v, int position) {
                mClickPos = position;

                onGiftItemClick(position);
            }
        });
        mRvView.setAdapter(mAdapter);
    }

    protected void initData() {

    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.dialog_ho_gift_ll_errorRetry) {
            onErrorRetryClick();
        }
    }

    /**
     * 加载礼物列表数据
     */
    public void loadGiftData(){
        showStatusLoadingView(true);

    }

    public int getClickPos() {
        return mClickPos;
    }

    public void notifyDataPosition(int pos){
        mAdapter.notifyItemChanged(pos);
    }

    /**
     * 礼物列表加载中
     */
    protected void showStatusLoadingView(boolean isShow) {
        mLLEmpty.setVisibility(View.GONE);
        mLLRetry.setVisibility(View.GONE);

        if (isShow) {
            mIvLoading.setVisibility(View.VISIBLE);
            startLoadingView(true);
        } else {
            startLoadingView(false);
            mIvLoading.setVisibility(View.GONE);
        }
    }

    private void startLoadingView(boolean isStart) {
        if (isStart) {
            AnimationDrawable progressDrawable = (AnimationDrawable) mIvLoading.getDrawable();
            if (!progressDrawable.isRunning()) {
                progressDrawable.start();
            }
        } else {
            AnimationDrawable progressDrawable = (AnimationDrawable) mIvLoading.getDrawable();
            if (progressDrawable.isRunning()) {
                progressDrawable.stop();
            }
        }
    }

    /**
     * 礼物列表无数据
     */
    protected void showStatusEmptyView(boolean isShow) {
        startLoadingView(false);
        mIvLoading.setVisibility(View.GONE);
        mLLRetry.setVisibility(View.GONE);

        mLLEmpty.setVisibility(isShow ? View.VISIBLE : View.GONE);
    }

    /**
     * 礼物列表出错重试
     */
    protected void showStatusErrorView(boolean isShow) {
        startLoadingView(false);
        mIvLoading.setVisibility(View.GONE);
        mLLEmpty.setVisibility(View.GONE);

        mLLRetry.setVisibility(isShow ? View.VISIBLE : View.GONE);
    }

    protected void hideAllStatusView(){
        showStatusLoadingView(false);
        showStatusEmptyView(false);
        showStatusErrorView(false);
    }
    //==========================    public  ======================================

    /**
     * 出错重试的回调
     */
//    protected abstract void onErrorRetryClick();
    protected void onErrorRetryClick(){
        showStatusLoadingView(true);

        mRvView.postDelayed(new Runnable() {
            @Override
            public void run() {

                if (mOnVirtualGiftListListener != null) {
                    mOnVirtualGiftListListener.onErrorClick();
                }else {
                    showStatusLoadingView(false);
                }
            }
        }, LOADING_DELAY_TIME);
    }

    /**
     * 获取列表 adapter
     */
    protected abstract BaseRecyclerViewAdapter getAdapter();

    /**
     * 礼物列表 item 的点击事件回调
     */
    protected abstract void onGiftItemClick(int pos);

    /**
     * 礼物列表 adapter 的刷新通知
     */
    public abstract void notifyGiftListDataChange();


    //===============================   interface   =======================================================
    protected OnVirtualGiftListListener mOnVirtualGiftListListener;

    public void setOnVirtualGiftListListener(OnVirtualGiftListListener mOnVirtualGiftListListener) {
        this.mOnVirtualGiftListListener = mOnVirtualGiftListListener;
    }

    public interface OnVirtualGiftListListener {
        void onGiftClick(boolean isPackage, GiftTypeItem giftTypeItem, String giftId, int pos);

        void onErrorClick();
    }
}
