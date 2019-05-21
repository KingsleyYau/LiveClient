package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListBaseAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListCircleAdapter;

/**
 * Created by Hardy on 2019/3/14.
 * 庆祝礼物列表
 */
public class HangoutGiftListCircleLayout extends HangoutGiftListBaseLayout {

    public HangoutGiftListCircleLayout(Context context) {
        super(context);
    }

    public HangoutGiftListCircleLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public HangoutGiftListCircleLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected int getRVRows() {
        return 1;
    }

    @Override
    protected int getRVColumns() {
        return 3;
    }

    @Override
    protected HangoutGiftListBaseAdapter createRecyclerAdapter() {
        HangoutGiftListCircleAdapter adapter = new HangoutGiftListCircleAdapter(mContext);
        return adapter;
    }

    @Override
    protected void onGiftClick(int pos, GiftItem giftItem) {

    }
}
