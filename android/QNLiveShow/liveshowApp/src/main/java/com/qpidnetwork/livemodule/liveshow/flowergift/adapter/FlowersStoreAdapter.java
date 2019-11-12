package com.qpidnetwork.livemodule.liveshow.flowergift.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersGiftUtil;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersTypeBean;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersTypeNameItemView;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Hardy on 2019/10/9.
 */
public class FlowersStoreAdapter extends BaseRecyclerViewAdapter<LSFlowerGiftItem, BaseViewHolder> {

    private int FLOWERS_ICON_WH;
    private Map<String, FlowersTypeBean> mTypeMap;

    public FlowersStoreAdapter(Context context) {
        super(context);

        FLOWERS_ICON_WH = DisplayUtil.getScreenWidth(context) / 2;
        mTypeMap = new HashMap<>();
    }

    public void setTypeMap(Map<String, FlowersTypeBean> mTypeMap) {
        this.mTypeMap.clear();
        if (mTypeMap != null && mTypeMap.size() > 0) {
            this.mTypeMap.putAll(mTypeMap);
        }
    }

    @Override
    public int getItemViewType(int position) {
        int type = LSFlowerGiftItem.FlowerGiftViewType.VIEW_ITEM_NORMAL.ordinal();

        LSFlowerGiftItem item = getItemBean(position);
        if (item != null && item.giftViewType != null) {
            type = item.giftViewType.ordinal();
        }

        return type;
    }

    @Override
    public int getLayoutId(int viewType) {
        LSFlowerGiftItem.FlowerGiftViewType giftViewType = LSFlowerGiftItem.FlowerGiftViewType.values()[viewType];

        int layoutResId;
        switch (giftViewType) {
            case VIEW_ITEM_GROUP_TITLE:
                layoutResId = R.layout.layout_flowers_type_name_item;
                break;

            default:
                layoutResId = R.layout.item_flowers_store;
                break;
        }

        return layoutResId;
    }

    @Override
    public BaseViewHolder getViewHolder(View itemView, int viewType) {
        LSFlowerGiftItem.FlowerGiftViewType giftViewType = LSFlowerGiftItem.FlowerGiftViewType.values()[viewType];

        BaseViewHolder holder;
        switch (giftViewType) {
            case VIEW_ITEM_GROUP_TITLE:
                holder = new FlowersStoreGroupTitleViewHolder(itemView);
                break;

            default:
                holder = new FlowersStoreViewHolder(itemView);
                break;
        }

        return holder;
    }

    @Override
    public void initViewHolder(final BaseViewHolder holder) {
        if (holder instanceof FlowersStoreGroupTitleViewHolder) {
//            FlowersStoreGroupTitleViewHolder groupTitleViewHolder = (FlowersStoreGroupTitleViewHolder) holder;

        } else {
            FlowersStoreViewHolder flowersStoreViewHolder = (FlowersStoreViewHolder) holder;
            flowersStoreViewHolder.setFlowersIconWH(FLOWERS_ICON_WH);

            flowersStoreViewHolder.mIvAdd.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mOnFlowersStoreListener != null) {
                        mOnFlowersStoreListener.onFlowersAddClick(getPosition(holder));
                    }
                }
            });

            flowersStoreViewHolder.mFlowersBg.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mOnFlowersStoreListener != null) {
                        mOnFlowersStoreListener.onFlowersDetailClick(getPosition(holder));
                    }
                }
            });
        }
    }

    @Override
    public void convertViewHolder(BaseViewHolder holder, LSFlowerGiftItem data, int position) {
        if (holder instanceof FlowersStoreGroupTitleViewHolder) {
            ((FlowersStoreGroupTitleViewHolder) holder).setFlowersTypeBean(mTypeMap.get(data.typeId));
        }

        holder.setData(data, position);
    }


    /**
     * 判断 item 是否占满整个屏幕宽度
     */
    @Override
    protected boolean isGridItemFullSpan(int position) {
        boolean isFull = false;

        LSFlowerGiftItem item = getItemBean(position);
        if (item != null && item.giftViewType != LSFlowerGiftItem.FlowerGiftViewType.VIEW_ITEM_NORMAL) {
            isFull = true;
        }

        return isFull;
    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     */
    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        super.onViewRecycled(holder);
        if (holder instanceof FlowersStoreViewHolder) {
            FlowersStoreViewHolder viewHolder = (FlowersStoreViewHolder) holder;
            if (viewHolder.mIvBg.getController() != null) {
                viewHolder.mIvBg.getController().onDetach();
            }
        }
    }


    //=====================     interface   =================================
    private OnFlowersStoreListener mOnFlowersStoreListener;

    public void setOnFlowersStoreListener(OnFlowersStoreListener mOnFlowersStoreListener) {
        this.mOnFlowersStoreListener = mOnFlowersStoreListener;
    }

    public interface OnFlowersStoreListener {
        void onFlowersAddClick(int pos);

        void onFlowersDetailClick(int pos);
    }
    //=====================     interface   =================================

    /**
     * 普通 holder
     */
    public static class FlowersStoreViewHolder extends BaseViewHolder<LSFlowerGiftItem> {

        public View mFlowersBg;
        public ImageView mIvAdd;

        public SimpleDraweeView mIvBg;
        private ImageView mIvNew;

        private TextView mTvName;
        private TextView mTvPriceRed;
        private TextView mTvPriceGrey;

        private int FLOWERS_ICON_WH;

        public FlowersStoreViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mFlowersBg = f(R.id.item_flowers_store_fl_top);
            mIvAdd = f(R.id.item_flowers_store_iv_add);

            mIvBg = f(R.id.item_flowers_store_iv_bg);
            mIvNew = f(R.id.item_flowers_store_iv_new);

            mTvName = f(R.id.item_flowers_store_tv_name);
            mTvPriceRed = f(R.id.item_flowers_store_tv_money_red);
            mTvPriceGrey = f(R.id.item_flowers_store_tv_money_grey);

            FrescoLoadUtil.setHierarchy(context, mIvBg, R.color.black4, false);
        }

        @Override
        public void setData(LSFlowerGiftItem data, int position) {
            FrescoLoadUtil.loadUrl(context, mIvBg, data.giftImg, FLOWERS_ICON_WH, R.color.black4, false);

            mIvNew.setVisibility(data.isNew ? View.VISIBLE : View.GONE);
            mTvName.setText(data.giftName);

            FlowersGiftUtil.handlerFlowersStoreListPrice(mTvPriceRed, mTvPriceGrey, data);
        }

        public void setFlowersIconWH(int FLOWERS_ICON_WH) {
            this.FLOWERS_ICON_WH = FLOWERS_ICON_WH;
        }
    }

    /**
     * 分组标题 holder
     */
    static class FlowersStoreGroupTitleViewHolder extends BaseViewHolder<LSFlowerGiftItem> {

        private FlowersTypeNameItemView flowersTypeNameItemView;

        private FlowersTypeBean flowersTypeBean;

        public FlowersStoreGroupTitleViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            flowersTypeNameItemView = (FlowersTypeNameItemView) itemView;
            flowersTypeNameItemView.showIcon(false);
            flowersTypeNameItemView.showLineTop(true);
            flowersTypeNameItemView.showLineBottom(false);
        }

        @Override
        public void setData(LSFlowerGiftItem data, int position) {
            flowersTypeNameItemView.setName(data.giftName); // 外层将 typeName 赋值给 giftName
            flowersTypeNameItemView.showFreeCard(flowersTypeBean != null &&
                    flowersTypeBean.hasGreetingCard);
        }

        public void setFlowersTypeBean(FlowersTypeBean flowersTypeBean) {
            this.flowersTypeBean = flowersTypeBean;
        }
    }
}
