package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;

/**
 * Created by Hardy on 2019/3/14.
 * 商店礼物 Adapter
 */
public class HangoutGiftListStoreAdapter extends HangoutGiftListBaseAdapter {

    public HangoutGiftListStoreAdapter(Context context) {
        super(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_hang_out_gift_bar_and_store;
    }

    @Override
    public HangoutGiftListBaseViewHolder getViewHolder(View itemView, int viewType) {
        return new HangoutGiftListStoreViewHolder(itemView);
    }

    /**
     * ViewHolder
     */
    static class HangoutGiftListStoreViewHolder extends HangoutGiftListBaseViewHolder {

        public ImageView mIvFlag;

        public HangoutGiftListStoreViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            super.bindItemView(itemView);

            mIvFlag = f(R.id.item_hang_out_gift_iv_flag);
        }

        @Override
        public void setData(GiftItem data, int position) {
            super.setData(data, position);

            showGiftFlag(data, mIvFlag);
        }
    }
}
