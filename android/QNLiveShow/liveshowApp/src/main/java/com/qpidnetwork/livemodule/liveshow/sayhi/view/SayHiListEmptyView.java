package com.qpidnetwork.livemodule.liveshow.sayhi.view;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetSayHiAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.SayHiRecommendAnchorItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentPagerAdapter4Top;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.HotItemStyleManager;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

/**
 * Created by Hardy on 2019/5/30.
 * <p>
 * SayHi 列表，无数据的 View
 */
public class SayHiListEmptyView extends LinearLayout implements View.OnClickListener {

    private TextView mTvDesc;
    private ButtonRaised mBtnSearch;

    private FrameLayout mLeftView;
    private FrameLayout mRightView;

    private LayoutInflater layoutInflater;

    private boolean isNeedLoadRecommendData = true;

    /**
     * 无数据的 ui 类型
     */
    public enum EmptyViewType {
        VIEW_ALL,
        VIEW_RESPONSE
    }

    public SayHiListEmptyView(Context context) {
        this(context, null);
    }

    public SayHiListEmptyView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SayHiListEmptyView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        layoutInflater = LayoutInflater.from(getContext());
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mTvDesc = findViewById(R.id.layout_say_hi_list_empty_tv_desc);
        mBtnSearch = findViewById(R.id.layout_say_hi_list_empty_btn_search);
        mBtnSearch.setOnClickListener(this);

        mLeftView = findViewById(R.id.layout_say_hi_list_empty_fl_left);
        mRightView = findViewById(R.id.layout_say_hi_list_empty_fl_right);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.layout_say_hi_list_empty_btn_search) {
            // 跳转主界面的 discover 标签
            MainFragmentActivity.launchActivityWithListType(getContext(), MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_DISCOVER);
            ((Activity) getContext()).finish();
        }
    }

    public void setEmptyViewType(EmptyViewType type) {
        if (type == EmptyViewType.VIEW_ALL) {
            mTvDesc.setText(R.string.say_hi_list_all_empty_tip);
        } else {
            mTvDesc.setText(R.string.say_hi_list_response_empty_tip);
        }
    }

    public void setNeedLoadRecommendData(boolean needLoadRecommendData) {
        isNeedLoadRecommendData = needLoadRecommendData;
    }

    /**
     * 请求推荐主播数据接口
     */
    public void loadRecommendAnchor() {
        // 2019/5/30 如果推荐主播上已经有了，则不需要再次请求接口
        if (!isNeedLoadRecommendData) {
            return;
        }

        LiveRequestOperator.getInstance().GetSayHiAnchorList(new OnGetSayHiAnchorListCallback() {
            @Override
            public void onGetSayHiAnchorList(final boolean isSuccess, final int errCode,
                                             final String errMsg, final SayHiRecommendAnchorItem[] RecommendList) {
                mTvDesc.post(new Runnable() {
                    @Override
                    public void run() {
                        updateAnchorView(isSuccess, errCode, errMsg, RecommendList);
                    }
                });
            }
        });
    }

    /**
     * 更新推荐主播信息到 view 上
     */
    private void updateAnchorView(boolean isSuccess, int errCode, String errMsg, SayHiRecommendAnchorItem[] RecommendList) {
        this.setVisibility(VISIBLE);

        if (isSuccess && RecommendList != null) {
            // 先移除原有的 view
            mLeftView.removeAllViews();
            mRightView.removeAllViews();

            int len = RecommendList.length;
            for (int i = 0; i < len; i++) {
                SayHiRecommendAnchorItem item = RecommendList[i];
                if (i == 0) {
                    mLeftView.addView(makeAnchorView(item));
                } else if (i == 1) {
                    mRightView.addView(makeAnchorView(item));
                }
            }
        } else {
            ToastUtil.showToast(getContext(), errMsg);
        }
    }

    /**
     * 生成推荐单个主播的 view 和设置数据
     *
     * @param item
     * @return
     */
    private View makeAnchorView(final SayHiRecommendAnchorItem item) {
        View view = layoutInflater.inflate(R.layout.layout_say_hi_list_empty_anchor_recommended, this, false);

        TextView mTvName = view.findViewById(R.id.layout_say_hi_list_empty_iv_name);
        SimpleDraweeView mIvIcon = view.findViewById(R.id.layout_say_hi_list_empty_iv_icon);
        final ImageView mIvOnline = view.findViewById(R.id.layout_say_hi_list_empty_iv_online);

        // 设置名字
        mTvName.setText(item.nickName);

        // 设置主播封面图
        int topRadius = DisplayUtil.dip2px(getContext(), 3);
        FrescoLoadUtil.loadUrl(getContext(), mIvIcon, item.coverImg, DisplayUtil.dip2px(getContext(), 200),
                R.color.black4, false, topRadius, topRadius, 0, 0);

        // 设置在线状态
        if (item.onlineStatus == AnchorOnlineStatus.Online) {
            mIvOnline.setVisibility(View.VISIBLE);
            if (HotItemStyleManager.isLiveIng(item.roomType)) {
                HotItemStyleManager.setAndStartRoomTypeAnimation(item.roomType, mIvOnline);
            } else {
                mIvOnline.setImageResource(R.drawable.ic_livetype_room_online);
            }
        } else {
            mIvOnline.setVisibility(GONE);
        }

        // 打开主播资料页
        view.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                AnchorProfileActivity.launchAnchorInfoActivty(getContext(),
                        getContext().getResources().getString(R.string.live_webview_anchor_profile_title),
                        item.anchorId, false, AnchorProfileActivity.TagType.Album);
            }
        });

        return view;
    }
}
