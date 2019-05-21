package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

/**
 * Created by Hardy on 2019/3/14.
 */
public abstract class HangoutGiftListBaseAdapter extends BaseRecyclerViewAdapter<GiftItem,
        HangoutGiftListBaseAdapter.HangoutGiftListBaseViewHolder> {

    public HangoutGiftListBaseAdapter(Context context) {
        super(context);
    }

    @Override
    public void initViewHolder(final HangoutGiftListBaseViewHolder holder) {
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(HangoutGiftListBaseViewHolder holder, GiftItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    public static class HangoutGiftListBaseViewHolder extends BaseViewHolder<GiftItem> {

        public ImageView mIvIcon;
        public TextView mTvCredits;

        public HangoutGiftListBaseViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mIvIcon = f(R.id.item_hang_out_gift_iv_icon);
            mTvCredits = f(R.id.item_hang_out_gift_tv_credits);
        }

        @Override
        public void setData(GiftItem item, int position) {
            // 信用点
            mTvCredits.setText(context.getString(R.string.live_Credits,
                    ApplicationSettingUtil.formatCoinValue(item.credit)));

            // 图片
            if (!TextUtils.isEmpty(item.middleImgUrl)) {
                PicassoLoadUtil.loadUrl(mIvIcon, item.middleImgUrl, R.drawable.ic_default_gift);
            } else {
                mIvIcon.setImageResource(R.drawable.ic_default_gift);
            }
        }

        public void showGiftFlag(GiftItem item, View view) {
            //是否大礼物
            if (item.giftType != GiftItem.GiftType.Celebrate) {
                //判断是否是大礼物
                if (item.giftType == GiftItem.GiftType.Advanced) {
                    view.setVisibility(View.VISIBLE);
                } else {
                    view.setVisibility(View.GONE);
                }
            }
        }
    }
}

