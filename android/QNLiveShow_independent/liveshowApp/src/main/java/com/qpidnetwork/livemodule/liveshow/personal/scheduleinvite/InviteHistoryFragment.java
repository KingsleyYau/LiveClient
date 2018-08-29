package com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Message;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetScheduleInviteListCallback;
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter on 17/9/30.
 */

public class InviteHistoryFragment extends BaseListFragment{

    private static final int GET_INVITE_HISTORY_CALLBACK = 1;

    private InviteHistoryAdapter mAdapter;
    private List<BookInviteItem> mInviteHistoryList;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mInviteHistoryList = new ArrayList<BookInviteItem>();
        mAdapter = new InviteHistoryAdapter(getActivity(), mInviteHistoryList);
        getPullToRefreshListView().setAdapter(mAdapter);
        //设置分割线
        getPullToRefreshListView().setBackgroundColor(Color.parseColor("#f5f5f5"));
        getPullToRefreshListView().setHeaderDividersEnabled(true);
        getPullToRefreshListView().setDivider(new ColorDrawable(Color.TRANSPARENT));
        getPullToRefreshListView().setDividerHeight(DisplayUtil.dip2px(getActivity(), 2f));
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        //Fragment是否可见，用于viewpager切换时再加载
        if(isVisibleToUser){
            //切换到当前fragment
            showLoadingProcess();
            queryInviteHistoryList(false);
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        HttpRespObject response = (HttpRespObject)msg.obj;
        if(getActivity() == null){
            return;
        }
        switch (msg.what){
            case GET_INVITE_HISTORY_CALLBACK:{
                hideLoadingProcess();
                if(response.isSuccess){
                    //列表刷新成功，更新未读
                    ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

                    if(!(msg.arg1 == 1)){
                        mInviteHistoryList.clear();
                    }
                    BookInviteItem[] bookInviteArray = (BookInviteItem[])response.data;
                    if(bookInviteArray != null) {
                        mInviteHistoryList.addAll(Arrays.asList(bookInviteArray));
                    }
                    mAdapter.notifyDataSetChanged();
                    //无数据
                    if(mInviteHistoryList == null || mInviteHistoryList.size() == 0){
                        showEmptyView();
                    }else{
                        hideNodataPage();
                    }
                }else{
                    if(mInviteHistoryList.size()>0){
                        if(null != mContext && mContext instanceof BaseFragmentActivity){
                            BaseFragmentActivity mActivity = (BaseFragmentActivity)mContext;
                            mActivity.showToast(response.errMsg);
                        }
                    }else{
                        //无数据显示错误页，引导用户
                        showErrorPage();
                    }
                }
            }break;

        }
        onRefreshComplete();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        queryInviteHistoryList(false);
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
        if(null != getActivity()){
            Intent intent = new Intent( getActivity(), MainFragmentActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
            getActivity().startActivity(intent);
            getActivity().finish();
            ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();
        }
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.history_empty_tips));
            setDefaultEmptyButtonText(getActivity().getResources().getString(R.string.invite_empty_hot_broadcasters));
        }
        showNodataPage();
    }

    /**
     * 获取主播发来邀请列表(等待用户处理)
     * @param isLoadMore
     */
    private void queryInviteHistoryList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mInviteHistoryList.size();
        }
        LiveRequestOperator.getInstance().GetScheduleInviteList(RequstJniSchedule.ScheduleInviteType.History,
                start, Default_Step, new OnGetScheduleInviteListCallback() {
            @Override
            public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg,
                                                int totel, BookInviteItem[] bookInviteList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, bookInviteList);
                Message msg = Message.obtain();
                msg.what = GET_INVITE_HISTORY_CALLBACK;
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryInviteHistoryList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryInviteHistoryList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryInviteHistoryList(false);
    }
}