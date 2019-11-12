package com.qpidnetwork.livemodule.liveshow.liveroom.gift.fragment;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomVirtualGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.adapter.LiveVirtualGiftNormalAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialogHelper;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.List;

/**
 * Created by Hardy on 2019/9/3.
 * 一般标签列表
 */
public class LiveVirtualGiftNormalLayout extends LiveVirtualGiftBaseLayout {

    private LiveVirtualGiftNormalAdapter mAdapter;

    public LiveVirtualGiftNormalLayout(@NonNull Context context,
                                       LiveGiftDialogHelper giftDialogHelper,
                                       RoomGiftManager roomGiftManager,
                                       RoomVirtualGiftManager mRoomVirtualGiftManager,
                                       GiftTypeItem giftTypeItem) {
        super(context, giftDialogHelper, roomGiftManager, mRoomVirtualGiftManager, giftTypeItem);
    }

    @Override
    protected void initView(View v) {
        super.initView(v);
    }

    @Override
    protected void initData() {
        super.initData();

        loadGiftData();
    }

    @Override
    public void loadGiftData() {
        super.loadGiftData();

        mRvView.postDelayed(new Runnable() {
            @Override
            public void run() {
                List<GiftItem> list = mRoomVirtualGiftManager.getGiftList(giftTypeItem);
                if (ListUtils.isList(list)) {
                    hideAllStatusView();
                    mAdapter.setData(list);
                } else {
                    if (mGiftDialogHelper.isSendableListSuccess()) {
                        showStatusEmptyView(true);
                    } else {
                        showStatusErrorView(true);
                    }
                }
            }
        }, LOADING_DELAY_TIME);
    }

    @Override
    protected void onErrorRetryClick() {
        super.onErrorRetryClick();

//        loadGiftData();
    }

    @Override
    protected BaseRecyclerViewAdapter getAdapter() {
        if (mAdapter == null) {
            mAdapter = new LiveVirtualGiftNormalAdapter(mContext, mGiftDialogHelper, mRoomGiftManager);
        }

        return mAdapter;
    }

    @Override
    protected void onGiftItemClick(int pos) {
        GiftItem bean = mAdapter.getItemBean(pos);
        if (bean != null) {
            if (mOnVirtualGiftListListener != null) {
                mOnVirtualGiftListListener.onGiftClick(false, giftTypeItem, bean.id, pos);
            }
        }
    }

    @Override
    public void notifyGiftListDataChange() {
        if (mAdapter != null) {
            mAdapter.notifyDataSetChanged();
        }
    }
}
