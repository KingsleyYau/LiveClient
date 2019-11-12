package com.qpidnetwork.livemodule.liveshow.liveroom.gift.fragment;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;

import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomVirtualGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.adapter.LiveVirtualGiftFreeAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialogHelper;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.List;

/**
 * Created by Hardy on 2019/9/3.
 * Free 标签列表
 */
public class LiveVirtualGiftFreeLayout extends LiveVirtualGiftBaseLayout {

    private LiveVirtualGiftFreeAdapter mAdapter;

    public LiveVirtualGiftFreeLayout(@NonNull Context context,
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
                List<PackageGiftItem> list = mRoomGiftManager.getLoaclRoomPackageGiftList();
                if (ListUtils.isList(list)) {
                    hideAllStatusView();
                    mAdapter.setData(list);
                } else {
                    if (mGiftDialogHelper.isPackageListSuccess()) {
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
            mAdapter = new LiveVirtualGiftFreeAdapter(mContext, mGiftDialogHelper, mRoomGiftManager);
        }

        return mAdapter;
    }

    @Override
    protected void onGiftItemClick(int pos) {
        PackageGiftItem bean = mAdapter.getItemBean(pos);
        if (bean != null) {
            if (mOnVirtualGiftListListener != null) {
                mOnVirtualGiftListListener.onGiftClick(true, giftTypeItem, bean.giftId, pos);
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
