package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.view.indicator.CommonStringTabEntity;
import com.qpidnetwork.livemodule.view.indicator.CommonTabLayout;
import com.qpidnetwork.livemodule.view.indicator.CustomTabEntity;
import com.qpidnetwork.livemodule.view.indicator.OnTabSelectListener;
import com.qpidnetwork.qnbridgemodule.view.blur_500px.BlurringView;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2019/3/13.
 * Hang out 礼物弹窗的根 Layout
 */
public class HangoutGiftDialogLayout extends FrameLayout implements View.OnClickListener {

    private static final String TAG = "info";

    public static final int TAB_BAR = 0;
    public static final int TAB_GIFT_STORE = 1;
    public static final int TAB_CELEB = 2;

    private View mListContentView;
    private BlurringView mIvBgBlur;
    private CommonTabLayout mTabLayout;
    private HangoutGiftAnchorLayout mAnchorLayout;

    private TextView mTvCredits;
    private TextView mTvCelebTip;
    private Button mBtnAddCredits;

    private HangoutGiftListBarLayout mGiftBarLayout;
    private HangoutGiftListStoreLayout mGiftStoreLayout;
    private HangoutGiftListCircleLayout mGiftCelebLayout;

    private View mLLLoading;
    private View mLLEmpty;
    private View mLLRetry;

    public HangoutGiftDialogLayout(Context context) {
        this(context, null);
    }

    public HangoutGiftDialogLayout(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public HangoutGiftDialogLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        init(context);
    }

    private void init(Context context) {

    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mListContentView = findViewById(R.id.dialog_ho_gift_ll_content);
        mIvBgBlur = findViewById(R.id.dialog_ho_gift_iv_blur);
        mTabLayout = findViewById(R.id.dialog_ho_gift_tab);
        mAnchorLayout = findViewById(R.id.dialog_ho_gift_anchor_layout);

        mTvCredits = findViewById(R.id.dialog_ho_gift_tv_credits);
        mTvCelebTip = findViewById(R.id.dialog_ho_gift_tv_celeb_tip);
        mBtnAddCredits = findViewById(R.id.dialog_ho_gift_btn_credits_add);

        mLLLoading = findViewById(R.id.dialog_ho_gift_ll_loading);
        mLLEmpty = findViewById(R.id.dialog_ho_gift_ll_emptyData);
        mLLRetry = findViewById(R.id.dialog_ho_gift_ll_errorRetry);

        mGiftBarLayout = findViewById(R.id.dialog_ho_gift_list_bar);
        mGiftStoreLayout = findViewById(R.id.dialog_ho_gift_list_giftStore);
        mGiftCelebLayout = findViewById(R.id.dialog_ho_gift_list_celeb);

        mBtnAddCredits.setOnClickListener(this);
        mLLRetry.setOnClickListener(this);

        // 设置用户信用点
        setCredits(LiveRoomCreditRebateManager.getInstance().getCredit());
        // 设置 tab 数据
        initTabData();
        // 设置礼物列表
        initList();

        // 显示默认界面
        mTabLayout.setCurrentTab(TAB_BAR);
        showBarView();
        showContentView(false);
    }

    public void setCredits(double credits){
        mTvCredits.setText(ApplicationSettingUtil.formatCoinValue(credits));
    }

    private void initList() {

    }

    private void initTabData() {
        int[] colors = {ContextCompat.getColor(getContext(), R.color.live_ho_orange_deep),
                ContextCompat.getColor(getContext(), R.color.live_ho_orange_light)};
        // 设置 tab 导航条渐变色
        mTabLayout.setIndicatorGradientColor(colors);

        // 设置 tab 点击监听
        mTabLayout.setOnTabSelectListener(onTabSelectListener);

        // 设置 tab title
        ArrayList<CustomTabEntity> tabList = new ArrayList<>();
        // bar
        CommonStringTabEntity entity = new CommonStringTabEntity(getContext().getString(R.string.hangout_gift_tab_bar));
        tabList.add(entity);
        // gift store
        entity = new CommonStringTabEntity(getContext().getString(R.string.hangout_gift_tab_giftstore));
        tabList.add(entity);
        // celeb
        entity = new CommonStringTabEntity(getContext().getString(R.string.hangout_gift_tab_celeb));
        tabList.add(entity);
        mTabLayout.setTabData(tabList);
    }

    OnTabSelectListener onTabSelectListener = new OnTabSelectListener() {
        @Override
        public void onTabSelect(int position) {
            switch (position) {
                case TAB_BAR:
                    showBarView();
                    break;

                case TAB_GIFT_STORE:
                    showStoreView();
                    break;

                case TAB_CELEB:
                    showCelebView();
                    break;

                default:
                    break;
            }

            if (mOnHangoutGiftLayoutOperaListener != null) {
                mOnHangoutGiftLayoutOperaListener.onTabClick(position);
            }
        }

        @Override
        public void onTabReselect(int position) {
            // 点击同一个 tab ，不做处理
        }
    };


    private void showBarView() {
        showContentView(true);
        mAnchorLayout.setVisibility(VISIBLE);
        mGiftBarLayout.setVisibility(VISIBLE);

        mTvCelebTip.setVisibility(GONE);
        mGiftStoreLayout.setVisibility(GONE);
        mGiftCelebLayout.setVisibility(GONE);
    }

    private void showStoreView() {
        showContentView(true);
        mAnchorLayout.setVisibility(VISIBLE);
        mGiftStoreLayout.setVisibility(VISIBLE);

        mTvCelebTip.setVisibility(GONE);
        mGiftBarLayout.setVisibility(GONE);
        mGiftCelebLayout.setVisibility(GONE);
    }

    private void showCelebView() {
        showContentView(true);
        mTvCelebTip.setVisibility(VISIBLE);
        mGiftCelebLayout.setVisibility(VISIBLE);

        mAnchorLayout.setVisibility(GONE);
        mGiftBarLayout.setVisibility(GONE);
        mGiftStoreLayout.setVisibility(GONE);
    }

    /**
     * 展示中间区域礼物列表的 view
     *
     * @param isShow
     */
    private void showContentView(boolean isShow) {
        mListContentView.setVisibility(isShow ? VISIBLE : GONE);
    }

    /**
     * 展示当前数据获取请求状态
     */
    public void showDataTipsViewByStatus(boolean isLoading, boolean isEmpty, boolean isError) {
        if (!isLoading && !isEmpty && !isError) {
            // 若 3 种状态都不展示，则显示 tab 对应的 view
            showContentView(true);
        } else {
            showContentView(false);
        }

        mLLLoading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        mLLEmpty.setVisibility(isEmpty ? View.VISIBLE : View.GONE);
        mLLRetry.setVisibility(isError ? View.VISIBLE : View.GONE);
    }

    public void setBarData(List<GiftItem> list) {
        mGiftBarLayout.setData(list);
    }

    public void setStoreData(List<GiftItem> list) {
        mGiftStoreLayout.setData(list);
    }

    public void setCelebData(List<GiftItem> list) {
        mGiftCelebLayout.setData(list);
    }

    /**
     * 获取当前选中的 tab index
     *
     * @return
     */
    public int getCurTab() {
        return mTabLayout.getCurrentTab();
    }

    public boolean isSendSecretly() {
        return mAnchorLayout.isSendSecretly();
    }

    public List<String> getSend2AnchorId() {
        return mAnchorLayout.getSend2AnchorId();
    }

    public boolean hasAnchorBroadcasters() {
        return mAnchorLayout.hasAnchorBroadcasters();
    }

    public boolean hasSelectAnchor() {
        return mAnchorLayout.hasSelectAnchor();
    }

    public void setBlurBgView(View view){
        mIvBgBlur.setBlurredView(view);
        mIvBgBlur.invalidate();
    }

    public void addAnchor(boolean isAnchorMain, HangoutAnchorInfoItem mAnchorItem) {
        mAnchorLayout.addAnchor(isAnchorMain, mAnchorItem);
    }

    public void hideAnchor(String anchorId) {
        mAnchorLayout.hideAnchor(anchorId);
    }

    /**
     * 延时 1s 后，才允许点击，避免在礼物按钮连续快速点击 2 次时，导致礼物弹窗瞬间弹出，并且再弹出买点弹窗的不好体验
     */
    public void enabledAddCreditsBtnDelay(){
        mBtnAddCredits.setEnabled(false);

        mBtnAddCredits.postDelayed(new Runnable() {
            @Override
            public void run() {
                mBtnAddCredits.setEnabled(true);
            }
        },1000);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.dialog_ho_gift_btn_credits_add) {
            // 个人信用点的弹窗
            if (mOnHangoutGiftLayoutOperaListener != null) {
                mOnHangoutGiftLayoutOperaListener.onAddCreditsClick();
            }
        } else if (id == R.id.dialog_ho_gift_ll_errorRetry) {
            // 出错重试
            if (mOnHangoutGiftLayoutOperaListener != null) {
                mOnHangoutGiftLayoutOperaListener.onErrorRetry();
            }
        }
    }


    //===================== interface   =========================================

    /**
     * 设置每个礼物列表的 item 点击事件监听
     *
     * @param onGiftItemClickListener
     */
    public void setOnGiftItemClickListener(HangoutGiftListBaseLayout.OnGiftItemClickListener onGiftItemClickListener) {
        mGiftBarLayout.setOnGiftItemClickListener(onGiftItemClickListener);
        mGiftStoreLayout.setOnGiftItemClickListener(onGiftItemClickListener);
        mGiftCelebLayout.setOnGiftItemClickListener(onGiftItemClickListener);
    }


    private OnHangoutGiftLayoutOperaListener mOnHangoutGiftLayoutOperaListener;

    public void setOnHangoutGiftLayoutOperaListener(OnHangoutGiftLayoutOperaListener mOnHangoutGiftLayoutOperaListener) {
        this.mOnHangoutGiftLayoutOperaListener = mOnHangoutGiftLayoutOperaListener;
    }

    /**
     * 界面的其它事件监听
     */
    public interface OnHangoutGiftLayoutOperaListener {
        /**
         * 出错重试
         */
        void onErrorRetry();

        /**
         * 增加信用点的点击
         */
        void onAddCreditsClick();

        /**
         * tab 点击切换
         *
         * @param pos
         */
        void onTabClick(int pos);
    }
    //===================== interface   =========================================
}
