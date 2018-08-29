package com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetScheduleInviteListCallback;
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule;
import com.qpidnetwork.livemodule.httprequest.item.BookInviteItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Hunter on 17/9/30.
 */

public class ConfirmedInviteFragment extends BaseListFragment{

    private static final int GET_COMFIRMED_INVITE_CALLBACK = 1;

    //以毫秒为单位
    private static final int ONE_HOUR_TIMESTAMP =  60 * 60 * 1000;
    private static final int ONE_MINUTE_TIMESTAMP = 60 * 1000;
    private static final int ONE_SECOND_TIMESTAMP = 1000;
    private int mCurrentTimeStamp = ONE_HOUR_TIMESTAMP;
    private Timer mComfirmedInviteTimer;
    private TimerTask timerTask;

    private ComfirmedInviteAdapter mAdapter;
    private List<BookInviteItem> mComfirmedInviteList;
    //解决onResume和setUserVisibleHint同时被调用，导致刷新两次，未读数目错误
    private boolean mIsVisbleRefresh = false;
    private boolean mIsCurrentVisible = false;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mComfirmedInviteList = new ArrayList<BookInviteItem>();
        mAdapter = new ComfirmedInviteAdapter(getActivity(), mComfirmedInviteList);
        mAdapter.setOnComfirmedInviteClickListener(new ComfirmedInviteAdapter.OnComfirmedInviteEventListener() {
            @Override
            public void onStartEnterRoomClick(BookInviteItem item) {
                //开始私密聊天，直接进入房间
                if(item != null && !TextUtils.isEmpty(item.roomId)){
                    String anchorId = "";
                    LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                    if(loginItem != null && loginItem.userId.equals(item.fromId)){
                        anchorId = item.toId;
                    }else{
                        anchorId = item.fromId;
                    }
                    Intent intent = LiveRoomTransitionActivity.getIntent(getActivity(),
                            LiveRoomTransitionActivity.CategoryType.Schedule_Invite_Enter_Room,
                            anchorId, item.oppositeNickname, item.oppositePhotoUrl, item.roomId,null);
                    getActivity().startActivity(intent);

                    //GA统计预约到期，点击进入直播间
                    if(getActivity() != null && getActivity() instanceof AnalyticsFragmentActivity){
                        ((AnalyticsFragmentActivity)getActivity()).onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_PrivateBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_PrivateBroadcast));
                    }
                }
            }

            @Override
            public void onScheduleInvalidNotify(BookInviteItem item) {
                //预约邀请失效通知
                showLoadingProcess();
                queryComfirmedInviteList(false);
            }
        });
        getPullToRefreshListView().setAdapter(mAdapter);
        ViewGroup.LayoutParams rlvLp = refreshListview.getLayoutParams();
        rlvLp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        refreshListview.setLayoutParams(rlvLp);
        setBgColor(Color.parseColor("#f5f5f5"));
        //设置分割线
        getPullToRefreshListView().setBackgroundColor(Color.parseColor("#f5f5f5"));
        getPullToRefreshListView().setHeaderDividersEnabled(true);
        getPullToRefreshListView().setDivider(new ColorDrawable(Color.TRANSPARENT));
        getPullToRefreshListView().setDividerHeight(DisplayUtil.dip2px(getActivity(), 2f));
    }

    @Override
    public void onResume() {
        super.onResume();
        //点击开始视频返回后，重新刷新列表(添加标志为解决setUserVisibleHint／onResume 重复刷新问题)
        if(!mIsVisbleRefresh && mIsCurrentVisible){
            showLoadingProcess();
            queryComfirmedInviteList(false);
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        mIsVisbleRefresh = false;
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        //Fragment是否可见，用于viewpager切换时再加载
        mIsCurrentVisible = isVisibleToUser;
        if(isVisibleToUser){
            mIsVisbleRefresh = true;
            //切换到当前fragment
            showLoadingProcess();
            queryComfirmedInviteList(false);
            //开启倒计时定时器
            startTimerInternal(getCountDownStamp());
        }else{
            //不可见时停止定时器
            stopTimer();
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
            case GET_COMFIRMED_INVITE_CALLBACK:{
                hideLoadingProcess();
                if(response.isSuccess){
                    //列表刷新成功，更新未读
                    ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

                    if(!(msg.arg1 == 1)){
                        mComfirmedInviteList.clear();
                    }
                    BookInviteItem[] bookInviteArray = (BookInviteItem[])response.data;
                    if(bookInviteArray != null) {
                        mComfirmedInviteList.addAll(Arrays.asList(bookInviteArray));
                    }

                    //添加过滤，本地判断超时不显示，防止判断过期循环调用接口导致死循环及显示错误
                    List<BookInviteItem> tempInViteList = filterOvertimeSchedule(mComfirmedInviteList);
                    mComfirmedInviteList.clear();
                    mComfirmedInviteList.addAll(tempInViteList);

                    mAdapter.notifyDataSetChanged();
                    //无数据
                    if(mComfirmedInviteList == null || mComfirmedInviteList.size() == 0){
                        showEmptyView();
                    }else{
                        hideNodataPage();
                    }

                    //列表刷新成功，需重新计算倒数计时器
                    startTimerInternal(getCountDownStamp());
                }else{
                    if(mComfirmedInviteList.size()>0){
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
        queryComfirmedInviteList(false);
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
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.scheduled_empty_tips));
            setDefaultEmptyButtonText(getActivity().getString(R.string.invite_empty_hot_broadcasters));
        }
        showNodataPage();
    }

    /**
     * 获取主播发来邀请列表(等待用户处理)
     * @param isLoadMore
     */
    private void queryComfirmedInviteList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mComfirmedInviteList.size();
        }
        LiveRequestOperator.getInstance().GetScheduleInviteList(RequstJniSchedule.ScheduleInviteType.Confirmed,
                start, Default_Step, new OnGetScheduleInviteListCallback() {
            @Override
            public void onGetScheduleInviteList(boolean isSuccess, int errCode, String errMsg,
                                                int totel, BookInviteItem[] bookInviteList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, bookInviteList);
                Message msg = Message.obtain();
                msg.what = GET_COMFIRMED_INVITE_CALLBACK;
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryComfirmedInviteList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryComfirmedInviteList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryComfirmedInviteList(false);
    }

    /**
     * 启动定时器
     * @param timeStamp
     */
    private void startTimerInternal(final int timeStamp){
        boolean needRestart = true;
        if(mComfirmedInviteTimer != null && mCurrentTimeStamp == timeStamp){
            needRestart = false;
        }
        if(needRestart){
            mCurrentTimeStamp = timeStamp;
            if(mComfirmedInviteTimer != null){
                mComfirmedInviteTimer.cancel();
                mComfirmedInviteTimer = null;
            }
            if(null == mComfirmedInviteTimer){
                mComfirmedInviteTimer = new Timer();
                timerTask = new TimerTask() {
                    @Override
                    public void run() {
                        //定时执行刷新
                        if(getActivity() != null){
                            getActivity().runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    mAdapter.notifyDataSetChanged();
                                }
                            });
                        }
                        //处理是否需要重置定时器
                        startTimerInternal(getCountDownStamp());
                    }
                };
            }
            mComfirmedInviteTimer.schedule(timerTask, timeStamp , timeStamp);
        }
    }

    /**
     * 停止定时刷新逻辑
     */
    private void stopTimer(){
        if(mComfirmedInviteTimer != null){
            timerTask.cancel();
            timerTask = null;
            mComfirmedInviteTimer.cancel();
            mComfirmedInviteTimer = null;
        }
    }

    /**
     * 获取事件最小(修改默认每秒刷新一次)
     * @return
     */
    private int getCountDownStamp(){
        int timestamp = ONE_HOUR_TIMESTAMP; //默认适用最长间隔
        if(mComfirmedInviteList != null){
            int minStamp = 0;
            for(BookInviteItem item : mComfirmedInviteList){
                int currTime = (int)(System.currentTimeMillis()/1000);
                if(item.bookTime - currTime > 0){
                    if(minStamp == 0){
                        minStamp = item.bookTime - currTime;
                    }else {
                        minStamp = Math.min(minStamp, item.bookTime - currTime);
                    }
                }
            }
            if(minStamp >= 24 * 60 * 60){
                //大于1天
                timestamp = ONE_HOUR_TIMESTAMP;
            }else if(minStamp >= 60 * 60){
                timestamp = ONE_MINUTE_TIMESTAMP;
            }else{
                timestamp = ONE_SECOND_TIMESTAMP;
            }
        }
        return  ONE_SECOND_TIMESTAMP;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopTimer();
    }

    /**
     * 过滤去掉超时过期的预约邀请(过期条件为预约事件＋2分钟)
     * @param bookInviteList
     * @return
     */
    private List<BookInviteItem> filterOvertimeSchedule(List<BookInviteItem> bookInviteList){
        List<BookInviteItem> tempInviteList = new ArrayList<BookInviteItem>();
        if(bookInviteList != null){
            int currTime = (int)(System.currentTimeMillis()/1000);
            for(BookInviteItem item : bookInviteList){
                if(item.bookTime + 3 * 60 > currTime){
                    tempInviteList.add(item);
                }
            }
        }
        return tempInviteList;
    }

    /**
     * 系统时间改变通知，重置定时器，解决定时器由于系统时间改变挂起问题
     */
    public void onSystemTimeChange(){
        //充值定时器
        stopTimer();
        startTimerInternal(getCountDownStamp());
    }

}
