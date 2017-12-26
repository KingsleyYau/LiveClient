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
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule.ScheduleInviteType;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_NO_CREDIT;
import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING;

/**
 * 主播发来的待用户处理的预约邀请列表
 * Created by Hunter on 17/9/30.
 */

public class NewInviteFragment extends BaseListFragment{

    private static final int GET_NEW_INVITE_CALLBACK = 1;
    private static final int PROCESS_ANCHOR_INVITE_CALLBCAK = 2;

    private NewInviteAdapter mAdapter;
    private List<BookInviteItem> mNewInviteList;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        TAG = NewInviteFragment.class.getSimpleName();
        mNewInviteList = new ArrayList<BookInviteItem>();
        mAdapter = new NewInviteAdapter(getActivity(), mNewInviteList);
        mAdapter.setOnNewInviteClickListener(new NewInviteAdapter.OnNewInviteClickListener() {
            @Override
            public void onConfirmClick(BookInviteItem item) {
                //点击确认按钮
                prcessAnchorInvite(item.inviteId, true);
            }

            @Override
            public void onDeclineClick(BookInviteItem item) {
                //点击拒绝按钮
                prcessAnchorInvite(item.inviteId, false);
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
            queryNewInviteList(false);
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        HttpRespObject response = (HttpRespObject)msg.obj;
        switch (msg.what){
            case GET_NEW_INVITE_CALLBACK:{
                hideLoadingProcess();
                if(response.isSuccess){
                    //列表刷新成功，更新未读
                    ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

                    if(msg.arg1 != 1){
                        mNewInviteList.clear();
                    }
                    BookInviteItem[] bookInviteArray = (BookInviteItem[])response.data;
                    if(bookInviteArray != null) {
                        mNewInviteList.addAll(Arrays.asList(bookInviteArray));
                    }
                    mAdapter.notifyDataSetChanged();
                    //无数据
                    if(mNewInviteList == null || mNewInviteList.size() == 0){
                        showEmptyView(R.string.newinvite_empty_tips,R.string.invite_empty_hot_broadcasters);
                    }else{
                        hideNodataPage();
                    }
                }else{
                    if(mNewInviteList.size()>0){
                        if(null != mContext && mContext instanceof BaseFragmentActivity) {
                            BaseFragmentActivity mActivity = (BaseFragmentActivity) mContext;
                            mActivity.showToast(response.errMsg);
                        }
                    }else{
                        //无数据显示错误页，引导用户
                        showErrorPage();
                    }
                }
            }break;

            case PROCESS_ANCHOR_INVITE_CALLBCAK:{
                if(response.isSuccess){
                    //刷新列表
                    queryNewInviteList(false);
                    if(null != mContext && mContext instanceof BaseFragmentActivity){
                        BaseFragmentActivity mActivity = (BaseFragmentActivity)mContext;
                        mActivity.showThreeSecondTips(mActivity.getResources().getString(
                                1 == msg.arg1 ? R.string.newinvite_confirm_success_tips
                                        : R.string.newinvite_cancel_success_tips),
                                Gravity.CENTER);
                    }
                }else{
                    hideLoadingProcess();
                    if(null != mContext && mContext instanceof BaseFragmentActivity){
                        BaseFragmentActivity mActivity = (BaseFragmentActivity)mContext;
                        if(1 == msg.arg1){//确认出错
                            if(IntToEnumUtils.intToHttpErrorType(response.errCode) == HTTP_LCC_ERR_NO_CREDIT) {//扣费失败,信用点不足
                                mActivity.showCreditNoEnoughDialog(R.string.newinvite_confirm_nocredits_tips);
                            }
//                            else if(!TextUtils.isEmpty(response.errMsg)){//错过确认时间(预约时间4分钟前可确定),无法确认
//                                mActivity.showThreeSecondTips(response.errMsg,Gravity.CENTER);
//                            }
                            else{//其他错误10079
                                mActivity.showThreeSecondTips(response.errMsg,Gravity.CENTER);
//                                mActivity.showToast(getResources().getString(R.string.newinvite_confirm_failed_tips));
                            }
                        }else{//拒绝出错
//                            if(IntToEnumUtils.intToHttpErrorType(response.errCode) == HttpLccErrType.HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING){//失败,该预约已经确定
//                                mActivity.showThreeSecondTips(
//                                        getResources().getString(R.string.newinvite_cancel_failed_confirmed_tips),
//                                            Gravity.CENTER);
//                            }else if(IntToEnumUtils.intToHttpErrorType(response.errCode) == HttpLccErrType.HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING){//失败(已超过可确定的时机)
//                                mActivity.showThreeSecondTips(
//                                        getResources().getString(R.string.newinvite_cancel_failed_timeout_tips),
//                                        Gravity.CENTER);
//                            }else{//其他错误10074
//                                mActivity.showToast(getResources().getString(R.string.newinvite_cancel_failed_tips));
//                            }
                            if(!TextUtils.isEmpty(response.errMsg)){
                                mActivity.showThreeSecondTips(
                                        response.errMsg,
                                        Gravity.CENTER);
                            }else{
//                                mActivity.showToast(getResources().getString(R.string.newinvite_cancel_failed_tips));
                                mActivity.showToast("");
                            }
                        }
                    }
                }
            }break;

        }
        onRefreshComplete();
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

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        queryNewInviteList(false);
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(int tipsResId, int btnResId){
        if(null != getActivity()){
            setDefaultEmptyMessage(getActivity().getResources().getString(tipsResId));
            setDefaultEmptyButtonText(getActivity().getResources().getString(btnResId));
        }
        showNodataPage();
    }

    /**
     * 获取主播发来邀请列表(等待用户处理)
     * @param isLoadMore
     */
    private void queryNewInviteList(final boolean isLoadMore){
        Log.d(TAG,"queryNewInviteList-isLoadMore:"+isLoadMore);
        int start = 0;
        if(isLoadMore){
            start = mNewInviteList.size();
        }
        LiveRequestOperator.getInstance().GetScheduleInviteList(ScheduleInviteType.AudiencePending,
                start, Default_Step, new OnGetScheduleInviteListCallback() {
            @Override
            public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg, int total, BookInviteItem[] bookInviteList) {
                Log.d(TAG,"queryNewInviteList-onGetScheduleInviteList-isSuccess:"+isSuccess+" errCode:"+errCode
                    +" errMsg:"+errMsg+" total:"+total+" bookInviteList.length:"+(null != bookInviteList ? bookInviteList.length : 0));
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, bookInviteList);
                Message msg = Message.obtain();
                msg.what = GET_NEW_INVITE_CALLBACK;
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryNewInviteList(false);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onPullDownToRefresh();
        queryNewInviteList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        Log.d(TAG,"onPullUpToRefresh");
        queryNewInviteList(true);
    }

    /**
     * 处理主播发送的邀请
     * @param inviteId
     * @param isComfirm
     */
    private void prcessAnchorInvite(final String inviteId, final boolean isComfirm){
        if(isComfirm){
            showLoadingProcess();
            LiveRequestOperator.getInstance().HandleScheduledInvite(inviteId, isComfirm, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg){
                    HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
                    Message msg = Message.obtain();
                    msg.what = PROCESS_ANCHOR_INVITE_CALLBCAK;
                    msg.arg1 = isComfirm?1:0;
                    msg.obj = response;
                    sendUiMessage(msg);
                }
            });
        }else if(null != mContext && mContext instanceof BaseFragmentActivity){
            BaseFragmentActivity mActivity = (BaseFragmentActivity)mContext;
            mActivity.showSimpleTipsDialog(R.string.newinvite_cancel_tips,
                    R.string.live_inter_video_no,R.string.live_inter_video_yes,
                    new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                        @Override
                        public void onCancelBtnClick() {

                        }

                        @Override
                        public void onConfirmBtnClick() {
                            showLoadingProcess();
                            LiveRequestOperator.getInstance().HandleScheduledInvite(inviteId, isComfirm, new OnRequestCallback() {
                                @Override
                                public void onRequest(boolean isSuccess, int errCode, String errMsg){
                                    HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
                                    Message msg = Message.obtain();
                                    msg.what = PROCESS_ANCHOR_INVITE_CALLBCAK;
                                    msg.arg1 = isComfirm?1:0;
                                    msg.obj = response;
                                    sendUiMessage(msg);
                                }
                            });
                        }
                    });
        }

    }

}
