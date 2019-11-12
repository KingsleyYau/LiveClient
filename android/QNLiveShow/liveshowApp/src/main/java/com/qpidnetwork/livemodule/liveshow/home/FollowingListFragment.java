package com.qpidnetwork.livemodule.liveshow.home;

import android.os.Message;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomListItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginNewActivity;
import com.qpidnetwork.livemodule.liveshow.manager.FollowManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiEditActivity;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.Arrays;
import java.util.Vector;

import io.reactivex.functions.Consumer;

/**
 * @author evening424 重做Follow列表
 * 2019-5-28
 */
public class FollowingListFragment extends BaseRecyclerViewFragment implements IAuthorizationListener {
    private static final int GET_FOLLOWING_CALLBACK = 1;
    private static final int GET_VOUCHER_CALLBACK = 2;
    private static final int GET_FAV_RESULT_CALLBACK = 3;

    private LiveRoomListAdapter mAdapter;
    private GridLayoutManager mLayoutManager;
    private Vector<LiveRoomListItem> mHotList = new Vector<>();
    private HotListVoucherHelper hotListVoucherHelper = new HotListVoucherHelper();
    private boolean isNeedRefresh = true;   //是否需要刷新列表 刷新逻辑可看BUG#13060
    private boolean mIsShowMore = false;   //是否需要显示“更多”
    private Consumer<FollowManager.FavResult> mConsumerFollow;


    @Override
    protected void initView(View view) {
        super.initView(view);

        TAG = HotListFragment.class.getSimpleName();
        mLayoutManager = new GridLayoutManager(mContext, 2, GridLayoutManager.VERTICAL, false);
        refreshRecyclerView.getRecyclerView().setLayoutManager(mLayoutManager);

        mAdapter = new LiveRoomListAdapter(getContext(), mHotList);
        mAdapter.setOnLiveRoomListEventListener(new LiveRoomListAdapter.onLiveRoomListEventListener() {
            @Override
            public void onFavClicked(final  LiveRoomListItem liveRoomListItem) {
                FollowManager.getInstance().summitFollow(liveRoomListItem, !liveRoomListItem.isFollow);
            }

            @Override
            public void onSayHiClicked(final LiveRoomListItem liveRoomListItem) {
                SayHiEditActivity.startAct(mContext, liveRoomListItem.userId, liveRoomListItem.nickName);
            }
        });
        refreshRecyclerView.getRecyclerView().setAdapter(mAdapter);

        // 2018/12/29 Hardy 滚动停止才加载图片
        refreshRecyclerView.getRecyclerView().addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    Fresco.getImagePipeline().resume();
                }else {
                    Fresco.getImagePipeline().pause();
                }
            }
        });
    }


    /**
     * 初始化数据
     */
    @Override
    protected void initData(){
        super.initData();

        mConsumerFollow = new Consumer<FollowManager.FavResult>() {
            @Override
            public void accept(FollowManager.FavResult favResult) throws Exception {
                //收藏/取消收藏成功
                HttpRespObject response = new HttpRespObject(true, -1, "", favResult.item);
                Message msg = Message.obtain();
                msg.what = GET_FAV_RESULT_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        };

        FollowManager.getInstance().registerSynFavResultObserver(mConsumerFollow);
        LoginManager.getInstance().register(this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        LoginManager.getInstance().unRegister(this);
        FollowManager.getInstance().unregisterSynFavResultObserver(mConsumerFollow);
    }

    @Override
    protected void onReVisible() {
        super.onReVisible();
        Log.d(TAG, "onReVisible");
        //切换到当前fragment
        if (isNeedRefresh) {
            Log.d(TAG, "onReVisible reloadData");
            //列表为空，切换刷一次
            doFullRefreshList();
        } else {
            //刷新试用券信息
            updateVoucherAvailableInfo();
        }
    }

    @Override
    protected void onBackFromHomeInTimeInterval() {
        super.onBackFromHomeInTimeInterval();
        Log.d(TAG, "onBackFromHomeInTimeInterval");
        doFullRefreshList();
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        doFullRefreshList();
    }

    @Override
    public void onLogout(boolean isMannual) {
        showLoginView();
    }

    /**
     * 刷新试用券信息
     */
    private void updateVoucherAvailableInfo() {
        Log.d(TAG, "updateVoucherAvailableInfo");
        //add by Jagger 2018-2-6 列表为空不刷新,减少请求次数
        //add by Jagger 2018-10-18 未登录不刷新,以免刷新失败又重登录导致死循环
        if (LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined || (mHotList == null) || mHotList.size() == 0) {
            Log.d(TAG, "**** cancel ****");
            //下拉刷新列表时，依赖试聊券刷新列表，减少刷新次数
            sendEmptyUiMessage(GET_VOUCHER_CALLBACK);
            return;
        }

        hotListVoucherHelper.updateVoucherAvailableInfo(new HotListVoucherHelper.OnGetVoucherAvailableInfoListener() {
            @Override
            public void onVoucherInfoUpdated(boolean isSuccess) {
                Log.d(TAG, "onGetVoucherInfo-isSuccess:" + isSuccess);
                if (isSuccess) {
                    synchronized (mHotList) {
                        for (LiveRoomListItem item : mHotList) {
                            item.isHasPublicVoucherFree = hotListVoucherHelper.checkVoucherFree(item.userId, true);
                            item.isHasPrivateVoucherFree = hotListVoucherHelper.checkVoucherFree(item.userId, false);
                        }

                        sendEmptyUiMessage(GET_VOUCHER_CALLBACK);
                    }
                }
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case GET_FAV_RESULT_CALLBACK:
                HttpRespObject responseFav = (HttpRespObject) msg.obj;
                if (responseFav.isSuccess) {
                    LiveRoomListItem listItem = (LiveRoomListItem) responseFav.data;

                    for (LiveRoomListItem liveRoomListItem : mHotList){
                        if(liveRoomListItem.userId.equals(listItem.userId)){
                            liveRoomListItem.isFollow = listItem.isFollow;
                            break;
                        }
                    }
                    mAdapter.notifyDataSetChanged();
                }
                break;
            case GET_VOUCHER_CALLBACK: {
                mAdapter.notifyDataSetChanged();
            }
            break;
            case GET_FOLLOWING_CALLBACK: {
                //Ps:msg.arg1 == 1 取更多; ==0 刷新
                hideLoadingProcess();
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess) {
                    //del by Jagger 2018-2-6 != 1 不就是0吗? 移下去了
//                    if(!(msg.arg1 == 1)){
//                        mFollowingList.clear();
//                    }

                    if (0 == msg.arg1) {
                        //add by Jagger 2018-2-6
                        mHotList.clear();
                        //add by Jagger 2018-2-6 取Banner. 因为把所有请求放在一起, 耗时太长有时会引起ARN错误, 所以改为分步请求
//                        updateBannerData();
                    }

                    FollowingListItem[] followingArray = (FollowingListItem[]) response.data;
                    if (followingArray != null) {
                        mHotList.addAll(Arrays.asList(followingArray));
                    }

                    //无数据
                    if (mHotList == null || mHotList.size() == 0) {
                        showEmptyView();
                        //返回 无数据也不要“更多”
                        mIsShowMore = false;
                    } else {
                        //防止无数据下拉刷新后，无数据页仍然存在
                        hideNodataPage();
                        hideErrorPage();
                        //是否需显示“更多”
                        if(mHotList.size() < Default_Step){
                            mIsShowMore = false;
                        }else {
                            mIsShowMore = true;
                        }
                    }

                    //刷新试用券信息
                    if(0 == msg.arg1) {
                        updateVoucherAvailableInfo();
                    }

                    //
                    mAdapter.notifyDataSetChanged();

                    //
                    isNeedRefresh = false;
                }else{
                    if(mHotList.size()>0){
                        if(getActivity() != null){
                            ToastUtil.showToast(getActivity(), response.errMsg);
                        }
                        isNeedRefresh = false;
                    }else{
                        //无数据显示错误页，引导用户
                        showErrorPage();
                        isNeedRefresh = true;
                    }
                }

                //是否需要显示更多
                if(mIsShowMore){
                    closePullUpRefresh(false);
                }else {
                    closePullUpRefresh(true);
                }
            }break;
        }
        onRefreshComplete();
    }

    /**
     * 刷新列表
     *
     * @param isLoadMore
     */
    private void queryFollowingList(final boolean isLoadMore) {
        //未登录,引导去登录
        if(LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined) {
            //显示登录
            showLoginView();
            return;
        }

        int start = 0;
        if(isLoadMore){
            start = mHotList.size();
        }
        LiveRequestOperator.getInstance().GetFollowingLiveList(start, Default_Step, new OnGetFollowingListCallback() {
            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, followingList);
                Message msg = Message.obtain();
                msg.what = GET_FOLLOWING_CALLBACK;
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 列表完整刷新
     */
    private void doFullRefreshList(){
        showLoadingProcess();
        queryFollowingList(false);
//        updateBannerData();
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        if(null != getActivity()){
            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.followinglist_empty_text));
            // 2019/8/8 Hardy
            setDefaultEmptyMessageBottom(getActivity().getResources().getString(R.string.followinglist_empty_text_bottom));

            // 2019/8/20 Hardy
            setEmptyGuideButtonText(getActivity().getResources().getString(R.string.live_common_btn_search));
//            setEmptyGuideButtonText(getActivity().getResources().getString(R.string.anchor_list_empty));
        }
        showNodataPage();
    }

    /**
     * 显示登录页
     */
    private void showLoginView(){
        if(null != getActivity()){
            //清空列表
            mHotList.clear();
            hideLoadingProcess();

            setDefaultEmptyMessage(getActivity().getResources().getString(R.string.followinglist_logout_text));
            setEmptyGuideButtonText(getActivity().getResources().getString(R.string.txt_login));
        }
        showNodataPage();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        doFullRefreshList();
    }

    @Override
    protected void onEmptyGuideClicked() {
        super.onEmptyGuideClicked();
        if(getActivity() != null && getActivity() instanceof  MainFragmentActivity){
            if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
                //已登录,应该是显示导向去HOTLIST的
                ((MainFragmentActivity) getActivity()).setCurrentPager(0);
                //add by Jagger 2018-8-10 BUG#13276 只是跳转到hotList,但这个无数据页不能消失
                showEmptyView();
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
        queryFollowingList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryFollowingList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryFollowingList(false);
    }

    @Override
    public void onRefreshComplete() {
        super.onRefreshComplete();
    }
}
