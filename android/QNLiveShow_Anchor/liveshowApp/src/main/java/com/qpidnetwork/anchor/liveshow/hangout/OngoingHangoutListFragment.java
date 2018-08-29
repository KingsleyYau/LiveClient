package com.qpidnetwork.anchor.liveshow.hangout;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Message;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.framework.base.BaseListFragment;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetOngoingHangoutCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutItem;
import com.qpidnetwork.anchor.liveshow.liveroom.HangOutRoomTransActivity;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.utils.DisplayUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter Mun on 2018/5/14.
 */

public class OngoingHangoutListFragment extends BaseListFragment {

    private static final int GET_HANGOUT_KNOCKABLE_CALLBACK = 1;

    private OngoingHangoutListAdapter mAdapter;
    private List<AnchorHangoutItem> mAnchorHangoutList;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mAnchorHangoutList = new ArrayList<AnchorHangoutItem>();
        mAdapter = new OngoingHangoutListAdapter(getActivity(), mAnchorHangoutList);
        mAdapter.setOnOngoingHangoutListClickListener(new OngoingHangoutListAdapter.OnOngoingHangoutListClickListener() {
            @Override
            public void onKnockClick(AnchorHangoutItem item) {
                //点击敲门按钮
                mContext.startActivity(HangOutRoomTransActivity.getKnowHangOutRoomIntent(mContext, item.userId, item.nickName, item.photoUrl, item.roomId));
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
        getPullToRefreshListView().setDivider(new ColorDrawable(getResources().getColor(R.color.hangout_divider_color)));
        getPullToRefreshListView().setDividerHeight(DisplayUtil.dip2px(getActivity(), 2f));

        //请求获取列表
        showLoadingProcess();
        queryHangoutList(false);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        HttpRespObject response = (HttpRespObject)msg.obj;
        if(getActivity() == null){
            return;
        }
        switch (msg.what){
            case GET_HANGOUT_KNOCKABLE_CALLBACK:{
                hideLoadingProcess();
                if(response.isSuccess){
                    if(!(msg.arg1 == 1)){
                        mAnchorHangoutList.clear();
                    }
                    AnchorHangoutItem[] anchorHangoutItemArray = (AnchorHangoutItem[])response.data;
                    //处理更多
                    if(anchorHangoutItemArray != null && anchorHangoutItemArray.length < Default_Step){
                        //关闭下拉更多
                        closePullUpRefresh(true);
                    }else{
                        //满一页开启下拉更多
                        closePullUpRefresh(false);
                    }

                    if(anchorHangoutItemArray != null) {
                        mAnchorHangoutList.addAll(Arrays.asList(anchorHangoutItemArray));
                    }

                    mAdapter.notifyDataSetChanged();
                    //无数据
                    if(mAnchorHangoutList == null || mAnchorHangoutList.size() == 0){
                        showEmptyView();
                    }else{
                        hideNodataPage();
                    }
                }else{
                    if(mAnchorHangoutList.size()>0){
                        if(null != getActivity() && getActivity() instanceof BaseFragmentActivity){
                            BaseFragmentActivity activity = (BaseFragmentActivity)getActivity();
                            activity.showToast(response.errMsg);
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
        queryHangoutList(false);
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.hangout_list_empty_desc));
            setDefaultEmptyButtonText("");
        }
        showNodataPage();
//        if(null != getActivity()){
//            //初始化错误页
//            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.hangout_list_empty_desc),
//                    R.drawable.hangout_knock_list_empty ,
//                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
//                    mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
//            );
//
//            setDefaultEmptyButtonText("");
//            setDefaultEmptyIconVisible(View.INVISIBLE);
//        }
//        showNodataPage();
    }

    /**
     * 获取主播发来邀请列表(等待用户处理)
     * @param isLoadMore
     */
    private void queryHangoutList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mAnchorHangoutList.size();
        }
        LiveRequestOperator.getInstance().GetOngoingHangoutList(start, Default_Step, new OnGetOngoingHangoutCallback() {
                    @Override
                    public void onGetOngoingHangout(boolean isSuccess, int errCode, String errMsg, AnchorHangoutItem[] anchorList) {
                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, anchorList);
                        Message msg = Message.obtain();
                        msg.what = GET_HANGOUT_KNOCKABLE_CALLBACK;
                        msg.arg1 = isLoadMore?1:0;
                        msg.obj = response;
                        sendUiMessage(msg);
                    }
                });
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryHangoutList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryHangoutList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryHangoutList(false);
    }
}
