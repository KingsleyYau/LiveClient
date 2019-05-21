package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListBaseAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListStoreAdapter;

/**
 * Created by Hardy on 2019/3/14.
 * 商店礼物列表
 */
public class HangoutGiftListStoreLayout extends HangoutGiftListBaseLayout {

    public HangoutGiftListStoreLayout(Context context) {
        super(context);
    }

    public HangoutGiftListStoreLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public HangoutGiftListStoreLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected int getRVRows() {
        return 2;
    }

    @Override
    protected int getRVColumns() {
        return 4;
    }

    @Override
    protected HangoutGiftListBaseAdapter createRecyclerAdapter() {
        HangoutGiftListStoreAdapter adapter = new HangoutGiftListStoreAdapter(mContext);
        return adapter;
    }

    @Override
    protected void onGiftClick(int pos, GiftItem giftItem) {

    }
}
