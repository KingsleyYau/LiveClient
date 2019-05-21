package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListBarAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HangoutGiftListBaseAdapter;

/**
 * Created by Hardy on 2019/3/14.
 * 吧台礼物列表
 */
public class HangoutGiftListBarLayout extends HangoutGiftListBaseLayout {

    public HangoutGiftListBarLayout(Context context) {
        super(context);
    }

    public HangoutGiftListBarLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public HangoutGiftListBarLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
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
        HangoutGiftListBarAdapter adapter = new HangoutGiftListBarAdapter(mContext);
        return adapter;
    }

    @Override
    protected void onGiftClick(int pos, GiftItem giftItem) {

    }
}
