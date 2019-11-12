package com.qpidnetwork.livemodule.liveshow.sayhi;


import android.os.Message;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.item.SayHiAllListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiBaseListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResponseListItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.sayhi.adapter.SayHiBaseListAdapter;
import com.qpidnetwork.livemodule.liveshow.sayhi.view.SayHiListEmptyView;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;

/**
 * 2019/5/29 Hardy
 * <p>
 * Say Hi 列表的 all 和 response 标签的基类 Fragment
 * <p>
 * 1.onResume 每次都下拉刷新
 * 2.response 列表下拉刷新 和 加载更多，都调用获取 SayHi 未读数小红点的接口
 * 3.下拉刷新后，如果无数据，则显示无数据界面，并且调用推荐主播接口
 */
public abstract class SayHiBaseListFragment extends BaseRecyclerViewFragment {

    protected static final String TAG = "SayHiBaseListFragment";

    protected static final int GET_LIST_CALLBACK = 1;

    protected SayHiBaseListAdapter mAdapter;
    protected SayHiListEmptyView sayHiListEmptyView;

    protected SayHiBaseListItem mCurItem;       // 记录当前点击的 item

    private int mPageIndex;
    private int mTotalCount;
    protected boolean isLoadMore;

    private boolean isFirstResume = true;

    public SayHiBaseListFragment() {
        // Required empty public constructor
    }

    /**
     * 初始化 View
     */
    protected void initView(View view) {
        super.initView(view);

        setRootContentBackgroundColor(R.color.white);

        // 设置 recyclerView
        mAdapter = new SayHiBaseListAdapter(mContext);
        // 设置 item 点击事件
        mAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v, int position) {
                SayHiBaseListItem item = mAdapter.getItemBean(position);
                if (item != null) {
                    // 记录当前点击的 item
                    mCurItem = item;

                    onListItemClick(item, position);
                }
            }
        });
        // 设置 item 数据改变事件
        mAdapter.registerAdapterDataObserver(new RecyclerView.AdapterDataObserver() {
            @Override
            public void onChanged() {
                super.onChanged();

                Log.i(TAG, "=========AdapterDataObserver===============----- onChanged   ----------------");

                onItemDataChange();
            }
        });
        LinearLayoutManager lin = new LinearLayoutManager(mContext);
        refreshRecyclerView.getRecyclerView().setLayoutManager(lin);
        refreshRecyclerView.getRecyclerView().setHasFixedSize(true);
        refreshRecyclerView.setAdapter(mAdapter);

        // 设置无数据页面
        View emptyView = LayoutInflater.from(mContext).inflate(R.layout.layout_say_hi_list_empty_view, fl_baseContainer, false);
        sayHiListEmptyView = emptyView.findViewById(R.id.layout_say_hi_list_empty_root_view);
        sayHiListEmptyView.setEmptyViewType(getEmptyViewType());
        sayHiListEmptyView.setVisibility(View.GONE);    // 先隐藏，内部加载推荐主播时，最后会自动显示
        setCustomEmptyViewHasRefresh(emptyView);
        hideNodataPage();
    }

    /**
     * 初始化数据
     */
    protected void initData() {
        super.initData();

        // 第一次进来，先显示 loading
        showLoadingProcess();
    }

    @Override
    public void onResume() {
        super.onResume();
        // 下拉刷新
        loadListData(false, isFirstResume);
        if (isFirstResume) {
            isFirstResume = false;
        }
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        // 下拉刷新
        loadListData(false, true);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        // 上拉加载更多
        loadListData(true, true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        // 无数据界面的下拉刷新
        loadListData(false, true);
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        // 展示 loading
        showLoadingProcess();
        // 出错重试
        loadListData(false, true);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject response = (HttpRespObject) msg.obj;

        List<SayHiBaseListItem> list = (List<SayHiBaseListItem>) response.data;

        switch (msg.what) {
            case GET_LIST_CALLBACK: {
                // 隐藏 loading
                hideLoadingProcess();

                if (response.isSuccess) {
                    if (ListUtils.isList(list)) {
                        hideNodataPage();
                        hideErrorPage();

                        mAdapter.updateData(list, isLoadMore);
                    } else if (mAdapter.getItemCount() == 0) {
                        mAdapter.setData(null);
                        // 展示空数据页
                        loadAndShowEmptyView();
                    }
                } else {
                    if (mAdapter.getItemCount() == 0) {
                        // 展示出错页
                        showErrorPage();
                    } else {
                        // 出错，暂时提示
                        ToastUtil.showToast(getContext(), response.errMsg);
                    }
                }

                // 恢复初始化状态
                onRefreshComplete();
            }
            break;

            default:
                break;
        }
    }

    /**
     * 显示无数据的页面，并且请求推荐主播
     */
    protected void loadAndShowEmptyView() {
        showNodataPage();

        // 加载推荐主播的数据
        sayHiListEmptyView.loadRecommendAnchor();
    }

    /**
     * 请求接口数据
     *
     * @param isLoadMore 是否上拉加载更多
     */
    protected void loadListData(boolean isLoadMore, boolean isNeedLoadRecommendData) {
        sayHiListEmptyView.setNeedLoadRecommendData(isNeedLoadRecommendData);

        this.isLoadMore = isLoadMore;

        if (isLoadMore) {
            mPageIndex += 1;
        } else {
            mPageIndex = 0;
        }

        int startSize = mPageIndex * Default_Step;
        boolean isCanLoadMore = startSize < mTotalCount;
        if (!isLoadMore || isCanLoadMore) {
            loadListData(isLoadMore, startSize);
        } else {
            // 初始化上拉加载更多时的值
            mPageIndex--;
            if (mPageIndex < 0) {
                mPageIndex = 0;
            }

            onRefreshComplete();
        }
    }

    /**
     * 设置数据总数
     */
    protected void setDataTotalCount(int mTotalCount) {
        this.mTotalCount = mTotalCount;
    }

    protected List<SayHiBaseListItem> getFormatDataList(SayHiAllListItem[] list) {
        List<SayHiBaseListItem> newList = null;

        if (list != null && list.length > 0) {
            newList = new ArrayList<>();

            for (SayHiAllListItem item : list) {
                newList.add(item);
            }
        }

        return newList;
    }

    protected List<SayHiBaseListItem> getFormatDataList(SayHiResponseListItem[] list) {
        List<SayHiBaseListItem> newList = null;

        if (list != null && list.length > 0) {
            newList = new ArrayList<>();

            for (SayHiResponseListItem item : list) {
                newList.add(item);
            }
        }

        return newList;
    }

    /**
     * 无数据页面的 ui 类型
     * 子类重写
     */
    protected abstract SayHiListEmptyView.EmptyViewType getEmptyViewType();

    /**
     * 加载列表数据
     */
    protected abstract void loadListData(final boolean isLoadMore, int startSize);

    /**
     * item 的点击事件
     */
    protected abstract void onListItemClick(SayHiBaseListItem item, int pos);

    /**
     * 打开详情
     */
    protected abstract void openSayHiDetailAct(SayHiBaseListItem item);

    /**
     * 列表 item 数据改变的回调
     */
    protected abstract void onItemDataChange();
}
