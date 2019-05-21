package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.FragmentManager;
import android.support.v7.widget.LinearLayoutManager;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutOnlineAnchorCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniHangout;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginNewActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.HangoutTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutDetailDialogFragment;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutFriendsDetailDialog;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.view.HangOutHeaderViewHelper;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * hang-out列表
 * @author Jagger 2019-3-5
 */
public class HangOutFragment extends BaseRecyclerViewFragment implements HangOutAdapter.OnHangOutListItemEventListener {

    //请求返回
    private static final int GET_HANGOUT_LIST_CALLBACK = 1;
    //每页刷新数据条数
    private static final int STEP_PAGE_SIZE = 50;

    //控件
    private HangOutHeaderViewHelper headerView;
    private HangOutAdapter mAdapter;

    //变量
    private List<HangoutOnlineAnchorItem> mData = new ArrayList<>();
    private boolean mIsShowMore = false;   //是否需要显示“更多”

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        TAG = HangOutFragment.class.getSimpleName();
        Log.d(TAG,"onCreateView");
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        refreshRecyclerView.getRecyclerView().setLayoutManager(manager);

        mAdapter = new HangOutAdapter(getContext());
        mAdapter.setOnEventListener(this);
        refreshRecyclerView.setAdapter(mAdapter);

        headerView = new HangOutHeaderViewHelper(getContext(), refreshRecyclerView.getRecyclerView());

        //刷新数据
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
        if(getActivity() != null){
            if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
                //已登录
                showLoadingProcess();
                refreshByData(true);
            }else{
                //未登录,去登录
                LoginNewActivity.launchRegisterActivity(mContext);
                //add by Jagger 这个无数据登录页不能消失
                showLoginView();
            }

        }
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        refreshByData(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        refreshByData(true);
    }

    @Override
    public void onBgClicked(HangoutOnlineAnchorItem anchorInfoItem) {
//        Log.i("Jagger" , "点击主播：" + anchorInfoItem.anchorId);
        AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                anchorInfoItem.anchorId, false, AnchorProfileActivity.TagType.Album);
    }

    @Override
    public void onFriendClicked(HangoutAnchorInfoItem anchorInfoItem) {
//        Log.i("Jagger" , "点击好友：" + anchorInfoItem.anchorId);
        HangOutFriendsDetailDialog.showCheckMailSuccessDialog(getContext(),anchorInfoItem);
    }

    @Override
    public void onStartClicked(HangoutOnlineAnchorItem anchorInfoItem) {
//        Log.i("Jagger" , "点击开始：" + anchorInfoItem.anchorId);
        FragmentManager fragmentManager = getActivity().getSupportFragmentManager();
        HangOutDetailDialogFragment.showDialog(fragmentManager, anchorInfoItem, new HangOutDetailDialogFragment.OnDialogClickListener() {
            @Override
            public void onStartHangoutClick(HangoutOnlineAnchorItem anchorItem) {
//                //生成被邀请的主播列表（这里是目标主播一人）
//                ArrayList<IMUserBaseInfoItem> anchorList = new ArrayList<>();
//                anchorList.add(new IMUserBaseInfoItem(anchorItem.anchorId, anchorItem.nickName, anchorItem.avatarImg));
//                //过渡页
//                Intent intent = HangoutTransitionActivity.getIntent(
//                        getContext(),
//                        anchorList,
//                        "",
//                        anchorItem.coverImg,
//                        "");
//                getActivity().startActivity(intent);
                String url = URL2ActivityManager.createHangoutTransitionActivity(anchorItem.anchorId, anchorItem.nickName);
                new AppUrlHandler(getActivity()).urlHandle(url);
            }
        });
    }

    private void refreshByData(final boolean isMore){

        //未登录,引导去登录
        if(LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined) {
            //隐藏列表头
            headerView.hide();
            //显示登录
            showLoginView();
            return;
        }

        if(!isMore) {
            headerView.reset();
            hideNodataPage();
            hideErrorPage();
        }

        //起始条目
//        int startIndex = 0;
//        if(isMore){
//            startIndex = mData.size();
//        }

        //
        RequestJniHangout.GetHangoutOnlineAnchor(new OnGetHangoutOnlineAnchorCallback() {
            @Override
            public void onGetHangoutOnlineAnchor(boolean isSuccess, int errCode, String errMsg, HangoutOnlineAnchorItem[] list) {
                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, list);
                Message msg = Message.obtain();
                msg.what = GET_HANGOUT_LIST_CALLBACK;
                msg.arg1 = isMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if (getActivity() == null) {
            return;
        }

        onRefreshComplete();
        HttpRespObject response = (HttpRespObject) msg.obj;

        switch (msg.what) {
            case GET_HANGOUT_LIST_CALLBACK: {
                boolean isMore = msg.arg1 == 1?true:false;
                //数据处理
                if(!isMore){
                    //下拉刷新

                    //成功才清空
                    //del by Jagger 2018-5-22 Samson说失败也清数据
//                    if(isSuccess){
                    mData.clear();

                }

                //判空处理
                if(response.data != null){
                    HangoutOnlineAnchorItem[] array = (HangoutOnlineAnchorItem[])response.data;

                    mData.addAll(Arrays.asList(array));

                    //是否需显示“更多”
                    if(array.length < STEP_PAGE_SIZE){
                        mIsShowMore = false;
                    }else {
                        mIsShowMore = true;
                    }
                }else {
                    //返回 无数据也不要“更多”
                    mIsShowMore = false;
                }

                //界面处理
                hideLoadingProcess();

                //刷新界面
                mAdapter.setData(mData);

                //失败但本来有数据显示Toast
                if (!response.isSuccess) {
                    if(mAdapter.getItemCount() > 0){
                        if(getActivity() != null && getActivity() instanceof BaseFragmentActivity && !TextUtils.isEmpty(response.errMsg)){
                            BaseFragmentActivity activity = (BaseFragmentActivity)getActivity();
                            activity.showToast(response.errMsg);
                            return;
                        }
                    }else{
                        showErrorPage();
                        //隐藏列表头
                        headerView.hide();
                        return;
                    }
                }

                if(mAdapter.getItemCount() == 0){
                    //无数据显示空页
                    showEmptyView();
                    //隐藏列表头
                    headerView.hide();
                }else{
                    headerView.reset();
                    //有数据 且 不是更多
                    if(msg.arg1 == 0){
                        //add by Jagger 2018-5-24 BUG#11063 刷新后回到顶部
                        refreshRecyclerView.getRecyclerView().getLayoutManager().scrollToPosition(0);
                    }

                }

                //是否需要显示更多
                if(mIsShowMore){
                    closePullUpRefresh(false);
                }else {
                    closePullUpRefresh(true);
                }
            }
            break;

        }
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            if(null != getActivity()){
                setDefaultEmptyMessage(getActivity().getResources().getString(R.string.hangout_list_empty_text));
                setDefaultEmptyButtonText("");
            }
            showNodataPage();
        }
    }

    /**
     * 显示登录页
     */
    private void showLoginView(){
        if(null != getActivity()){
            //清空列表
            mAdapter.setData(null);
            hideLoadingProcess();

            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.followinglist_logout_text));
            setDefaultEmptyButtonText(getActivity().getResources().getString(R.string.txt_login));
        }
        showNodataPage();
    }
}
