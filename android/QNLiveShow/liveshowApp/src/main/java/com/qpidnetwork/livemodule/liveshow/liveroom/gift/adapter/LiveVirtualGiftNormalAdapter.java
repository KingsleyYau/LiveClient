package com.qpidnetwork.livemodule.liveshow.liveroom.gift.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialogHelper;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.view.RedCircleView;

/**
 * Created by Hardy on 2019/9/3.
 * 一般标签列表下的 adapter
 */
public class LiveVirtualGiftNormalAdapter extends BaseRecyclerViewAdapter<GiftItem,
        LiveVirtualGiftNormalAdapter.LiveVirtualGiftNormalViewHolder> {

    //dialog数据共享帮助类
    private LiveGiftDialogHelper mGiftDialogHelper;
    private RoomGiftManager roomGiftManager;

    public LiveVirtualGiftNormalAdapter(Context context, LiveGiftDialogHelper mGiftDialogHelper,
                                        RoomGiftManager roomGiftManager) {
        super(context);

        this.mGiftDialogHelper = mGiftDialogHelper;
        this.roomGiftManager = roomGiftManager;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_live_virtual_gift;
    }

    @Override
    public LiveVirtualGiftNormalViewHolder getViewHolder(View itemView, int viewType) {
        return new LiveVirtualGiftNormalViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final LiveVirtualGiftNormalViewHolder holder) {
        holder.setGiftDialogHelper(mGiftDialogHelper);
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
    public void convertViewHolder(LiveVirtualGiftNormalViewHolder holder, GiftItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    static class LiveVirtualGiftNormalViewHolder extends BaseViewHolder<GiftItem> {

        private ImageView mIvIconBg;
        private ImageView mIvIcon;
        private ImageView mIvTagAdvance;
        private ImageView mIvTagLock;
        private TextView mTvCredits;
        private RedCircleView mRedCircleView;

        private LiveGiftDialogHelper mGiftDialogHelper;
        private RoomGiftManager roomGiftManager;

        public LiveVirtualGiftNormalViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mIvIconBg = f(R.id.item_live_virtual_gift_iv_icon_bg);
            mIvIcon = f(R.id.item_live_virtual_gift_iv_icon);
            mIvTagAdvance = f(R.id.item_live_virtual_gift_iv_tag_advance);
            mIvTagLock = f(R.id.item_live_virtual_gift_iv_tag_lock);
            mTvCredits = f(R.id.item_live_virtual_gift_tv_credits);
            mRedCircleView = f(R.id.item_live_virtual_gift_red_circle);

            mRedCircleView.setVisibility(View.GONE);
        }

        public void setGiftDialogHelper(LiveGiftDialogHelper mGiftDialogHelper) {
            this.mGiftDialogHelper = mGiftDialogHelper;
        }

        public void setRoomGiftManager(RoomGiftManager roomGiftManager) {
            this.roomGiftManager = roomGiftManager;
        }

        @Override
        public void setData(GiftItem data, int position) {
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

            // 锁，判断级别是否达标
//            if (!mGiftDialogHelper.checkGiftSendable(data)) {
//                // 等级或亲密度不够
//                mIvTagLock.setVisibility(View.VISIBLE);
//            } else {
//                mIvTagLock.setVisibility(View.GONE);
//            }
        }
    }
}
