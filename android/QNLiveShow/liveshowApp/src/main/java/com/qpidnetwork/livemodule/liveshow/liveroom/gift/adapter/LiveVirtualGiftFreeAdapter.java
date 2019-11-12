package com.qpidnetwork.livemodule.liveshow.liveroom.gift.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialogHelper;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.view.RedCircleView;

/**
 * Created by Hardy on 2019/9/3.
 * Free 标签列表下的 adapter
 */
public class LiveVirtualGiftFreeAdapter extends BaseRecyclerViewAdapter<PackageGiftItem,
        LiveVirtualGiftFreeAdapter.LiveVirtualGiftFreeViewHolder> {

    //dialog数据共享帮助类
    private LiveGiftDialogHelper mGiftDialogHelper;
    private RoomGiftManager roomGiftManager;

    public LiveVirtualGiftFreeAdapter(Context context, LiveGiftDialogHelper mGiftDialogHelper,
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
    public LiveVirtualGiftFreeViewHolder getViewHolder(View itemView, int viewType) {
        return new LiveVirtualGiftFreeViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final LiveVirtualGiftFreeViewHolder holder) {
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
    public void convertViewHolder(LiveVirtualGiftFreeViewHolder holder, PackageGiftItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    static class LiveVirtualGiftFreeViewHolder extends BaseViewHolder<PackageGiftItem> {

        private ImageView mIvIconBg;
        private ImageView mIvIcon;
        private ImageView mIvTagAdvance;
        private ImageView mIvTagLock;
        private TextView mTvCredits;
        private RedCircleView mRedCircleView;

        private LiveGiftDialogHelper mGiftDialogHelper;
        private RoomGiftManager roomGiftManager;

        public LiveVirtualGiftFreeViewHolder(View itemView) {
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

            mIvTagAdvance.setVisibility(View.GONE);
        }

        public void setGiftDialogHelper(LiveGiftDialogHelper mGiftDialogHelper) {
            this.mGiftDialogHelper = mGiftDialogHelper;
        }

        public void setRoomGiftManager(RoomGiftManager roomGiftManager) {
            this.roomGiftManager = roomGiftManager;
        }

        @Override
        public void setData(PackageGiftItem data, int position) {
            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(data.giftId);

            // free
            mTvCredits.setText(GiftTypeItem.FREE);

            if (giftItem != null) {
                // 设置礼物 icon
                PicassoLoadUtil.loadUrl(mIvIcon, giftItem.middleImgUrl, R.drawable.ic_default_gift);
            }

            // 房间是否可发送
            // 判断级别是否达标
//            if (!roomGiftManager.checkGiftSendable(data.giftId) ||
//                    (giftItem != null && !mGiftDialogHelper.checkGiftSendable(giftItem))) {
//                mIvTagLock.setVisibility(View.VISIBLE);
//            } else {
//                mIvTagLock.setVisibility(View.GONE);
//            }

            // 数量
            if (data.num > 0) {
                mRedCircleView.showText(data.num > 99 ?
                        context.getResources().getString(R.string.live_gift_maxnum) :
                        String.valueOf(data.num));

                mIvIcon.setImageAlpha(255);
                mIvIconBg.getBackground().setAlpha(255);
            } else {
                //  数量减少至0时，数字消失，礼物样式变为 50% 透明度
                mRedCircleView.hide();

                mIvIcon.setImageAlpha(128);
                mIvIconBg.getBackground().setAlpha(128);
            }
        }
    }
}
