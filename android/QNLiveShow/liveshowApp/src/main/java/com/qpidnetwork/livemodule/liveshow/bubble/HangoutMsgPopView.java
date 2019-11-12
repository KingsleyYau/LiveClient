package com.qpidnetwork.livemodule.liveshow.bubble;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;

/**
 * Created by Hardy on 2019/3/5.
 * 直播主页的冒泡 view
 */
public class HangoutMsgPopView extends BubblePopView<BubbleMessageBean> {

    public HangoutMsgPopView(Context context) {
        super(context);
    }

    public HangoutMsgPopView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public HangoutMsgPopView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected int getRecyclerViewLayoutResId() {
        return R.id.view_hang_out_msg_pop_recyclerView;
    }

    @Override
    protected BaseRecyclerViewAdapter getAdapter() {
        return new HangoutMsgPopViewAdapter(mContext, cardAdapterHelper);
    }

}
