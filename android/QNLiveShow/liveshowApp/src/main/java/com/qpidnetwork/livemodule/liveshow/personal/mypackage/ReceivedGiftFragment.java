package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.os.Bundle;
import android.os.Message;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseLoadingFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ballRefresh.ThreeBallHeader;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.scwang.smartrefresh.layout.SmartRefreshLayout;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshListener;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter on 17/9/26.
 */

public class ReceivedGiftFragment extends BaseLoadingFragment implements OnRefreshListener {

    private SmartRefreshLayout swipeRefreshLayout;
    private GridView mGridView;
    private List<PackageGiftItem> mPackageGifts;
    private PackageGiftsAdapter mAdapter;

    private boolean isVisibleToUser;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        setCustomContent(R.layout.fragment_package_gifts);
        swipeRefreshLayout = view.findViewById(R.id.swipeRefreshLayout);
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setRefreshHeader(new ThreeBallHeader(getContext()));
        swipeRefreshLayout.setEnableAutoLoadMore(false);
        swipeRefreshLayout.setEnableLoadMore(false);

        mGridView = (GridView) view.findViewById(R.id.gridView);
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mPackageGifts = new ArrayList<PackageGiftItem>();
        mAdapter = new PackageGiftsAdapter(getActivity(), mPackageGifts);
        mGridView.setAdapter(mAdapter);

        // 2018/10/26 Hardy
        if (isVisibleToUser) {
            loadDataWithLoading();
        }
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);

        //Fragment是否可见，用于viewpager切换时再加载
//        if(isVisibleToUser){
//            //切换到当前fragment
//            showLoadingProcess();
//            queryPackageGifts();
//        }

        // 2018/10/26 Hardy
        this.isVisibleToUser = isVisibleToUser;
        if (isVisibleToUser && isCreatedView()) {
            loadDataWithLoading();
        }
    }

    private void loadDataWithLoading() {
        showLoadingProcess();
        queryPackageGifts();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        onRefreshComplete();
        HttpRespObject response = (HttpRespObject) msg.obj;
        if (getActivity() == null) {
            return;
        }
        if (response.isSuccess) {
            //列表刷新成功，更新未读
            ScheduleInvitePackageUnreadManager.getInstance().GetPackageUnreadCount();

            mPackageGifts.clear();
            PackageGiftItem[] packageGifts = (PackageGiftItem[]) response.data;
            if (packageGifts != null) {
                mPackageGifts.addAll(Arrays.asList(packageGifts));
                //过滤本地是否已有礼物详情
                filterToCompleteGiftDetail();
            }
            mAdapter.notifyDataSetChanged();

            if (mPackageGifts.size() <= 0) {
                showEmptyView();
            } else {
                hideNodataPage();
                hideErrorPage();
            }
        } else {
            if (mPackageGifts != null && mPackageGifts.size() > 0) {
                if (getActivity() != null) {
                    ToastUtil.showToast(getActivity(), response.errMsg);
                }
            } else {
                showErrorPage();
            }
        }
    }

    /**
     * 检查本地礼物详情是否足够展示
     */
    private void filterToCompleteGiftDetail() {
        NormalGiftManager giftManager = NormalGiftManager.getInstance();
        for (PackageGiftItem packageGiftItem : mPackageGifts) {
            GiftItem item = giftManager.getLocalGiftDetail(packageGiftItem.giftId);
            if (item == null) {
                //本地没有，需要单独同步
                giftManager.getGiftDetail(packageGiftItem.giftId, new OnGetGiftDetailCallback() {
                    @Override
                    public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                        if (getActivity() != null) {
                            getActivity().runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    //获取礼物详情返回，刷新礼物列表
                                    mAdapter.notifyDataSetChanged();
                                }
                            });
                        }
                    }
                });
            }
        }
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
//        showLoadingProcess();
//        queryPackageGifts();
        loadDataWithLoading();
    }

    @Override
    protected void onEmptyGuideClicked() {
        super.onEmptyGuideClicked();
//        queryPackageGifts();
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView() {
        setDefaultEmptyMessage(getResources().getString(R.string.my_package_gift_empty_tips));
        setEmptyGuideButtonText("");
        showNodataPage();
    }

    /**
     * 获取背包礼物列表
     */
    private void queryPackageGifts() {
        LiveRequestOperator.getInstance().GetPackageGiftList(new OnGetPackageGiftListCallback() {
            @Override
            public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList, int totalCount) {
                Message msg = Message.obtain();
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, packageGiftList);
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 刷新完成UI
     */
    private void onRefreshComplete() {
//        swipeRefreshLayout.setRefreshing(false);
        swipeRefreshLayout.finishRefresh();
        hideLoadingProcess();
    }

    @Override
    public void onRefresh(@NonNull RefreshLayout refreshLayout) {
        super.onRefresh(refreshLayout);
        queryPackageGifts();
    }

    @Override
    public void onReloadDataInEmptyView() {
        queryPackageGifts();
    }
}
