package com.qpidnetwork.livemodule.liveshow.liveroom.gift.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

public class LiveVirtualGiftRecommandAdapter extends BaseRecyclerViewAdapter<GiftItem,
        LiveVirtualGiftRecommandAdapter.LiveRecommandVirtualGiftViewHolder> {

    //dialog数据共享帮助类
    private RoomGiftManager roomGiftManager;
    private int mItemWidth = 0;

    public LiveVirtualGiftRecommandAdapter(Context context, RoomGiftManager roomGiftManager, int itemWidth) {
        super(context);
        mItemWidth = itemWidth;
        this.roomGiftManager = roomGiftManager;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_live_recommand_virtual_gift;
    }

    @Override
    public LiveVirtualGiftRecommandAdapter.LiveRecommandVirtualGiftViewHolder getViewHolder(View itemView, int viewType) {
        return new LiveVirtualGiftRecommandAdapter.LiveRecommandVirtualGiftViewHolder(itemView, mItemWidth);
    }

    @Override
    public void initViewHolder(final LiveVirtualGiftRecommandAdapter.LiveRecommandVirtualGiftViewHolder holder) {
        holder.setRoomGiftManager(roomGiftManager);
        holder.mIvIconBg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(LiveVirtualGiftRecommandAdapter.LiveRecommandVirtualGiftViewHolder holder, GiftItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    static class LiveRecommandVirtualGiftViewHolder extends BaseViewHolder<GiftItem> {

        private ImageView mIvIconBg;
        private ImageView mIvIcon;
        private ImageView mIvTagAdvance;
        private TextView mTvCredits;

        private RoomGiftManager roomGiftManager;
        private int itemWidth = 0;

        public LiveRecommandVirtualGiftViewHolder(View itemView, int itemWidth) {
            super(itemView);
            this.itemWidth = itemWidth;
        }

        @Override
        public void bindItemView(View itemView) {
            mIvIconBg = f(R.id.item_live_virtual_gift_iv_icon_bg);
            mIvIcon = f(R.id.item_live_virtual_gift_iv_icon);
            mIvTagAdvance = f(R.id.item_live_virtual_gift_iv_tag_advance);
            mTvCredits = f(R.id.item_live_virtual_gift_tv_credits);
        }

        public void setRoomGiftManager(RoomGiftManager roomGiftManager) {
            this.roomGiftManager = roomGiftManager;
        }

        @Override
        public void setData(GiftItem data, int position) {

            //动态设置宽度
            if(itemWidth > 0) {
                LinearLayout llItemContent = f(R.id.llItemContent);
                RecyclerView.LayoutParams itemContentParams = (RecyclerView.LayoutParams) llItemContent.getLayoutParams();
                itemContentParams.width = itemWidth;

                FrameLayout flImageContent = f(R.id.flImageContent);
                LinearLayout.LayoutParams imageContentParams = (LinearLayout.LayoutParams) flImageContent.getLayoutParams();
                imageContentParams.width = itemWidth;
                imageContentParams.height = itemWidth;

                FrameLayout.LayoutParams iconLayoutParams = (FrameLayout.LayoutParams) mIvIcon.getLayoutParams();
                iconLayoutParams.width = (itemWidth * 2)/3;
                iconLayoutParams.width = (itemWidth * 2)/3;
            }

            // 设置礼物 icon
            PicassoLoadUtil.loadUrl(mIvIcon, data.middleImgUrl, R.drawable.ic_default_gift);

            // 设置信用点
            SendableGiftItem sendableGiftItem = roomGiftManager.getSendableGiftItem(data.id);
            if ((sendableGiftItem != null && sendableGiftItem.isFree) || data.credit <= 0) {
                // free
                mTvCredits.setText(GiftTypeItem.FREE);
            } else {
                // credits
                mTvCredits.setText(context.getResources().getString(R.string.live_gift_coins,
                        ApplicationSettingUtil.formatCoinValue(data.credit)));
            }

            // 豪华礼物
            if (data.giftType == GiftItem.GiftType.Advanced) {
                mIvTagAdvance.setVisibility(View.VISIBLE);
            } else {
                mIvTagAdvance.setVisibility(View.GONE);
            }
        }
    }
}
