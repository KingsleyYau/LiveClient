package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

/**
 * Created by Hardy on 2019/3/14.
 * 庆祝礼物 Adapter
 */
public class HangoutGiftListCircleAdapter extends HangoutGiftListBaseAdapter {

    public HangoutGiftListCircleAdapter(Context context) {
        super(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_hang_out_gift_circle;
    }

    @Override
    public HangoutGiftListBaseViewHolder getViewHolder(View itemView, int viewType) {
        return new HangoutGiftListCircleViewHolder(itemView);
    }

    /**
     * ViewHolder
     */
    static class HangoutGiftListCircleViewHolder extends HangoutGiftListBaseViewHolder {

        public HangoutGiftListCircleViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            super.bindItemView(itemView);
        }

        @Override
        public void setData(GiftItem data, int position) {
            super.setData(data, position);

        }
    }
}
