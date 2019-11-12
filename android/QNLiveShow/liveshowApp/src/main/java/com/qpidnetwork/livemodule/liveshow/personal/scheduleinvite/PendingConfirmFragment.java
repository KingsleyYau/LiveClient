package com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.Gravity;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetScheduleInviteListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 用户发起等待主播处理列表
 * Created by Hunter on 17/9/30.
 */

public class PendingConfirmFragment extends BaseListFragment{

    private PendingConfirmAdapter mAdapter;
    private List<BookInviteItem> mNewInviteList;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mNewInviteList = new ArrayList<BookInviteItem>();
        mAdapter = new PendingConfirmAdapter(getActivity(), mNewInviteList);
        mAdapter.setOnPendingConfirmClickListener(new PendingConfirmAdapter.OnPendingConfirmClickListener() {
            @Override
            public void onInviteCancel(BookInviteItem item) {
                //取消已发出预约邀请
                cancelScheduledInvite(item.inviteId);
            }
        });
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
            queryPendingComfirmList(false);
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        hideLoadingProcess();
        HttpRespObject response = (HttpRespObject)msg.obj;
        if(getActivity() == null){
            return;
        }
        if(response.isSuccess){
            //列表刷新成功，更新未读
            ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

            if(!(msg.arg1 == 1)){
                mNewInviteList.clear();
            }
            BookInviteItem[] bookInviteArray = (BookInviteItem[])response.data;
            if(bookInviteArray != null) {
                mNewInviteList.addAll(Arrays.asList(bookInviteArray));
            }
            mAdapter.notifyDataSetChanged();
            //无数据
            if(mNewInviteList == null || mNewInviteList.size() == 0){
                showEmptyView();
            }else{
                hideNodataPage();
                hideErrorPage();
            }
        }else{
            if(mNewInviteList.size()>0){
                if(null != mContext && mContext instanceof BaseFragmentActivity){
                    BaseFragmentActivity mActivity = (BaseFragmentActivity)mContext;
                    mActivity.showToast(response.errMsg);
                }
            }else{
                //无数据显示错误页，引导用户
                showErrorPage();
            }
        }
        onRefreshComplete();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        queryPendingComfirmList(false);
    }

    @Override
    protected void onEmptyGuideClicked() {
        super.onEmptyGuideClicked();
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
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.sent_empty_tips));
            setEmptyGuideButtonText(getActivity().getResources().getString(R.string.invite_empty_hot_broadcasters));
        }
        showNodataPage();
    }

    /**
     * 获取主播发来邀请列表(等待用户处理)
     * @param isLoadMore
     */
    private void queryPendingComfirmList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mNewInviteList.size();
        }
        LiveRequestOperator.getInstance().GetScheduleInviteList(RequstJniSchedule.ScheduleInviteType.AnchorPending,
                start, Default_Step, new OnGetScheduleInviteListCallback() {
            @Override
            public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg,
                                                int totel, BookInviteItem[] bookInviteList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, bookInviteList);
                Message msg = Message.obtain();
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryPendingComfirmList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryPendingComfirmList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryPendingComfirmList(false);
    }

    /**
     * 取消已发出主播未确认的预约邀请
     * @param inviteId
     */
    private void cancelScheduledInvite(final String inviteId){
        if(null != mContext && mContext instanceof BaseFragmentActivity){
            BaseFragmentActivity mActivity = (BaseFragmentActivity)mContext;
            mActivity.showSimpleTipsDialog(R.string.sent_cancel_tips,
                    R.string.live_inter_video_no,R.string.live_inter_video_yes,
                    new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                        @Override
                        public void onCancelBtnClick() {}

                        @Override
                        public void onConfirmBtnClick() {
                            confirmCancelScheduledInvite(inviteId);
                        }
                    });
        }
    }

    private void confirmCancelScheduledInvite(String inviteId){
        showLoadingProcess();
        LiveRequestOperator.getInstance().CancelScheduledInvite(inviteId, new OnRequestCallback() {
            @Override
            public void onRequest(final boolean isSuccess,final int errCode, final String errMsg) {
                if(getActivity() != null){
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess){
                                queryPendingComfirmList(false);
                                if(null != mContext && mContext instanceof BaseFragmentActivity) {
                                    BaseFragmentActivity mActivity = (BaseFragmentActivity) mContext;
                                    mActivity.showThreeSecondTips(mActivity.getResources().getString(R.string.sent_cancel_success_tips), Gravity.CENTER);
                                }
                            }else{
                                hideLoadingProcess();
                                if(null != mContext && mContext instanceof BaseFragmentActivity) {
                                    BaseFragmentActivity mActivity = (BaseFragmentActivity) mContext;
                                    if(!TextUtils.isEmpty(errMsg)){
                                        mActivity.showThreeSecondTips(errMsg, Gravity.CENTER);
                                    }else{
//                                        mActivity.showToast(getResources().getString(R.string.sent_cancel_failed_tips));
                                        mActivity.showToast("");
                                    }
//                                    if(IntToEnumUtils.intToHttpErrorType(errCode) == HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION){
//                                        mActivity.showThreeSecondTips(mActivity.getResources().getString(
//                                                R.string.sent_cancel_failed_confirmed_tips), Gravity.CENTER);
//                                    }else{
//                                        mActivity.showToast(getResources().getString(R.string.sent_cancel_failed_tips));
//                                    }
                                }
                            }
                        }
                    });
                }
            }
        });
    }
}
