package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.Animation;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.flowergift.adapter.FlowersTypeAdapter;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.NoDoubleOnClickListener;

import java.util.List;

/**
 * Created by Hardy on 2019/10/9.
 * 鲜花礼品的分类弹窗选择 Layout
 */
public class FlowersTypeLayout extends FrameLayout {

    private static final int MAX_ROW = 5;

    private View mBgView;
    private RecyclerView mRvView;
    private FlowersTypeAdapter mAdapter;

    private int LIST_VIEW_HEIGHT;

    public FlowersTypeLayout(@NonNull Context context) {
        this(context, null);
    }

    public FlowersTypeLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FlowersTypeLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        LIST_VIEW_HEIGHT = context.getResources().getDimensionPixelSize(R.dimen.flowers_type_name_height) * MAX_ROW;
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mBgView = findViewById(R.id.layout_flowers_type_bg);
        mBgView.setOnClickListener(new NoDoubleOnClickListener() {
            @Override
            public void onNoDoubleClick(View v) {
                if (isAnimRunning()) {
                    return;
                }

                hide();
            }
        });

        mRvView = findViewById(R.id.layout_flowers_type_recylerview);
        mRvView.setLayoutManager(new LinearLayoutManager(getContext()));
        mAdapter = new FlowersTypeAdapter(getContext());
        mAdapter.setOnItemClickListener(onItemClickListener);
        mRvView.setAdapter(mAdapter);
    }

    BaseRecyclerViewAdapter.OnItemClickListener onItemClickListener = new BaseRecyclerViewAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {
            FlowersTypeBean bean = mAdapter.getItemBean(position);
            if (bean != null) {
                changeItemSelectStatus(bean.typeId);

                // 隐藏
                hide();

                // 回调外层
                if (mOnFlowersTypeSelectListener != null) {
                    mOnFlowersTypeSelectListener.onTypeSelect(bean);
                }
            }
        }
    };

    public void setData(List<FlowersTypeBean> list) {
        if (ListUtils.isList(list)) {
            int size = list.size();

            // 设置最大高度
            FrameLayout.LayoutParams mListParams = (LayoutParams) mRvView.getLayoutParams();
            if (size >= MAX_ROW) {
                mListParams.height = LIST_VIEW_HEIGHT;
            } else {
                mListParams.height = LayoutParams.WRAP_CONTENT;
            }
            mRvView.setLayoutParams(mListParams);

            // 设置数据
            mAdapter.setData(list);
        }
    }

    public boolean isAnimRunning() {
        return getListView().getAnimation() != null &&
                getListView().getAnimation().hasStarted() &&
                !getListView().getAnimation().hasEnded();
    }

    /**
     * @param typeId 当前选中的分类
     *               如果传空字符，即显示第一个
     */
    public void show(String typeId) {
        int pos = changeItemSelectStatus(typeId);
        if (mAdapter.isValidPosition(pos)) {
            mRvView.smoothScrollToPosition(pos);
        }
        // 弹出动画
        FlowersGiftAnimUtils.showFlowerTypeViewAnim(this, showListener);
    }

    public void hide() {
        FlowersGiftAnimUtils.hideFlowerTypeViewAnim(this, hideListener);
    }

    Animation.AnimationListener showListener = new Animation.AnimationListener() {
        @Override
        public void onAnimationStart(Animation animation) {

        }

        @Override
        public void onAnimationEnd(Animation animation) {
        }

        @Override
        public void onAnimationRepeat(Animation animation) {

        }
    };
    Animation.AnimationListener hideListener = new Animation.AnimationListener() {
        @Override
        public void onAnimationStart(Animation animation) {

        }

        @Override
        public void onAnimationEnd(Animation animation) {
            setVisibility(GONE);
        }

        @Override
        public void onAnimationRepeat(Animation animation) {

        }
    };


    public View getBgView() {
        return mBgView;
    }

    public View getListView() {
        return mRvView;
    }

    public boolean isViewShow() {
        return getVisibility() == VISIBLE;
    }

    private int changeItemSelectStatus(String selectTypeId) {
        if (TextUtils.isEmpty(selectTypeId)) {
            selectTypeId = "";
        }

        int pos = -1;

        if (ListUtils.isList(mAdapter.getList())) {
            int size = mAdapter.getList().size();
            for (int i = 0; i < size; i++) {
                FlowersTypeBean typeBean = mAdapter.getList().get(i);
                if (selectTypeId.equals(typeBean.typeId)) {
                    pos = i;
                    typeBean.hasSelect = true;
                } else {
                    typeBean.hasSelect = false;
                }
            }

            if (pos < 0) {
                pos = 0;
                mAdapter.getList().get(0).hasSelect = true;
            }

            mAdapter.notifyDataSetChanged();
        }

        return pos;
    }

    //======================    interface   =======================================================
    private OnFlowersTypeSelectListener mOnFlowersTypeSelectListener;

    public void setOnFlowersTypeSelectListener(OnFlowersTypeSelectListener mOnFlowersTypeSelectListener) {
        this.mOnFlowersTypeSelectListener = mOnFlowersTypeSelectListener;
    }

    public interface OnFlowersTypeSelectListener {
        void onTypeSelect(FlowersTypeBean flowersTypeBean);
    }
    //======================    interface   =======================================================
}
