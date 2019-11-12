package com.qpidnetwork.livemodule.liveshow.sayhi;


import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetResponseSayHiListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniSayHi;
import com.qpidnetwork.livemodule.httprequest.item.SayHiBaseListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResponseListInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResponseListItem;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.sayhi.view.SayHiListEmptyView;
import com.qpidnetwork.livemodule.liveshow.sayhi.view.SayHiListResponseFilterView;
import com.qpidnetwork.livemodule.view.dialog.CommonThreeBtnTipDialog;

import java.util.List;

/**
 * 2019/5/30 Hardy
 * <p>
 * Say Hi 列表 response 标签
 */
public class SayHiListResponseFragment extends SayHiBaseListFragment implements ShowUnreadManager.OnShowUnreadListener,
        OnGetResponseSayHiListCallback {

    /*
        默认【未读优先】
        提供【最新优先】
     */
    private RequestJniSayHi.SayHiListOperateType requestDataType = RequestJniSayHi.SayHiListOperateType.UnRead;

    private CommonThreeBtnTipDialog commonThreeBtnTipDialog;
    private LocalPreferenceManager localPreferenceManager;

    private SayHiListResponseFilterView mBottomFilterView;

    public SayHiListResponseFragment() {
        // Required empty public constructor
    }

    @Override
    protected void initView(View view) {
        ShowUnreadManager.getInstance().registerUnreadListener(this);

        super.initView(view);

        // 添加底部过滤按钮
        mBottomFilterView = (SayHiListResponseFilterView) LayoutInflater.from(mContext)
                .inflate(R.layout.layout_say_hi_response_filter, fl_baseContainer, false);
        fl_baseContainer.addView(mBottomFilterView);
        mBottomFilterView.setVisibility(View.GONE);     // 先隐藏
        // 过滤方式监听
        mBottomFilterView.setOnResponseListFilterListener(new SayHiListResponseFilterView.OnResponseListFilterListener() {
            @Override
            public void onFilterChange(RequestJniSayHi.SayHiListOperateType type) {
                requestDataType = type;

                // 先滚动到顶部
                refreshRecyclerView.getRecyclerView().smoothScrollToPosition(0);
                // 显示下拉刷新动画
//                refreshRecyclerView.getSwipeRefreshLayout().setRefreshing(true);
                // 2019/7/25 Hardy
                refreshRecyclerView.showRefreshing();

                // 延时加载，是为了显示下拉刷新的动画出来，防止接口响应快，动画闪一下就消失
                refreshRecyclerView.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        // 下拉刷新、需要刷新推荐主播数据
                        loadListData(false, true);
                    }
                }, 1500);
            }
        });

        // 获取上次记录的过滤方式
        requestDataType = mBottomFilterView.getResponseFilterType();
    }

    @Override
    protected void initData() {
        super.initData();

    }

    @Override
    public void onDestroy() {
        ShowUnreadManager.getInstance().unregisterUnreadListener(this);

        super.onDestroy();

        if (commonThreeBtnTipDialog != null) {
            commonThreeBtnTipDialog.destroy();
            commonThreeBtnTipDialog = null;
        }
    }

    @Override
    protected SayHiListEmptyView.EmptyViewType getEmptyViewType() {
        return SayHiListEmptyView.EmptyViewType.VIEW_RESPONSE;
    }

    @Override
    protected void loadListData(final boolean isLoadMore, int startSize) {
        // 刷新未读数小红点
        ShowUnreadManager.getInstance().refreshUnReadData();

        LiveRequestOperator.getInstance().GetResponseSayHiList(startSize, Default_Step, requestDataType, this);
    }

    @Override
    protected void onListItemClick(SayHiBaseListItem item, int pos) {
        SayHiResponseListItem subItem = (SayHiResponseListItem) item;
        if (!subItem.hasRead && !subItem.isFree &&
                !getLocalPreferenceManager().hasShowSayHiListResponse()) {  // 是否第一次点击
            showItemDialog();
        } else {
            openSayHiDetailAct(item);
        }
    }

    @Override
    protected void openSayHiDetailAct(SayHiBaseListItem item) {
        if (item == null) {
            return;
        }
        // 2019/5/30  跳转详情
        SayHiResponseListItem subItem = (SayHiResponseListItem) item;
        SayHiDetailsActivity.launch(mContext, subItem.avatar, subItem.nickName, subItem.age, subItem.sayHiId, subItem.responseId);
    }

    @Override
    protected void onItemDataChange() {
        if (mAdapter.getItemCount() == 0) {
            mBottomFilterView.setVisibility(View.GONE);
        } else {
            mBottomFilterView.setVisibility(View.VISIBLE);
        }
    }


    private void showItemDialog() {
        if (commonThreeBtnTipDialog == null) {
            commonThreeBtnTipDialog = new CommonThreeBtnTipDialog(mContext) {
                @Override
                public void onClickOK() {
                    openSayHiDetailAct(mCurItem);
                }

                @Override
                public void onClickCancel() {

                }

                @Override
                public void onClickDontAsk() {
                    // 记录，下次点击不再弹出询问窗口
                    getLocalPreferenceManager().saveHasShowSayHiListResponse(true);

                    openSayHiDetailAct(mCurItem);
                }
            };
        }

        commonThreeBtnTipDialog.show();
    }

    private LocalPreferenceManager getLocalPreferenceManager() {
        if (localPreferenceManager == null) {
            localPreferenceManager = new LocalPreferenceManager(mContext);
        }
        return localPreferenceManager;
    }

    @Override
    public void onGetResponseSayHiList(boolean isSuccess, int errCode, String errMsg, SayHiResponseListInfoItem responseItem) {
        List<SayHiBaseListItem> list = null;

        if (responseItem != null) {
            setDataTotalCount(responseItem.totalCount);
            list = getFormatDataList(responseItem.responseList);
        }

        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, list);

        Message msg = Message.obtain();
        msg.what = GET_LIST_CALLBACK;
        msg.obj = response;

        sendUiMessage(msg);
    }


    //============================  未读数 =====================================================
    @Override
    public void onShowUnreadUpdate(int unreadNum) {
        // 已过时,不用处理
    }

    @Override
    public void onUnReadDataUpdate() {
        // 更新到 UI 线程
        refreshRecyclerView.post(new Runnable() {
            @Override
            public void run() {
                if (mOnUnReadChangeListener != null) {
                    mOnUnReadChangeListener.onUnReadChange(ShowUnreadManager.getInstance().getSayHiUnreadNum());
                }
            }
        });
    }
    //============================  未读数 =====================================================

    //============================  interface   ====================================
    private OnUnReadChangeListener mOnUnReadChangeListener;

    public void setOnUnReadChangeListener(OnUnReadChangeListener mOnUnReadChangeListener) {
        this.mOnUnReadChangeListener = mOnUnReadChangeListener;
    }

    public interface OnUnReadChangeListener {
        void onUnReadChange(int count);
    }
}
