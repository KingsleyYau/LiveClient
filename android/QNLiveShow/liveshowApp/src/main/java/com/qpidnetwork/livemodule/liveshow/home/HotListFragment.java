package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.os.Message;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseImmersedRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHotListCallback;
import com.qpidnetwork.livemodule.httprequest.OnLSAdWomanistAdvertCallback;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LSAdWomanListAdvertItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomListItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechat.contact.OnChatUnreadUpdateCallback;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.FollowManager;
import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigerManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiEditActivity;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiListActivity;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.BadgeHelper;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.blur_500px.BlurringView;

import java.util.Arrays;
import java.util.Vector;

import io.reactivex.functions.Consumer;
import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * @author Jagger 2018-6-28
 *
 * 取数据逻辑：
 *  1.取主播列表
 *  2.如果是下拉刷新，取广告
 *  3.取广告后，取试聊卷
 */
public class HotListFragment extends BaseImmersedRecyclerViewFragment implements ShowUnreadManager.OnShowUnreadListener,
        IMOtherEventListener, IAuthorizationListener, OnChatUnreadUpdateCallback {

    private static final int GET_FOLLOWING_CALLBACK = 1;
    private static final int GET_VOUCHER_CALLBACK = 2;
    private static final int GET_FAV_RESULT_CALLBACK = 3;
    private static final int GET_ADVERT_CALLBACK = 4;

    private final int AD_INDEX = 3; //列表广告位置

    /**
     * 顶部菜单选项类型
     */
    private enum TopMenuItemType {
        SayHi,
        Chat,
        Mail,
        Greetings,
        Hangout,
        AddCredit
    }


    private LiveRoomListAdapter mAdapter;

    private GridLayoutManager mLayoutManager;
    private Vector<LiveRoomListItem> mHotList = new Vector<>();
    private HotListVoucherHelper hotListVoucherHelper = new HotListVoucherHelper();
    private boolean isNeedRefresh = true;   //是否需要刷新列表 刷新逻辑可看BUG#13060
    private Consumer<FollowManager.FavResult> mConsumerFollow;

    //第三版
    private int mImgMaxWidth, mImgMaxHeight, mImgMinWidth, mImgMinHeight;
    private int mTxtMaxTopMargin, mTxtMinTopMargin;
    private float mTvMaxSize, mTvMinSize;
    private int mBadgeTextMaxSize, mBadgeTextMinSize, mBadgeTextSize;

    private FrameLayout flContent;
    private BlurringView mBlurringViewBg;
    private LinearLayout llSayHi, llMessage, llMail, llGreetings, llHangOut, llAddCredit;
    private FrameLayout flImgSayHi, flImgMessage, flImgMail, flImgGreetings, flImgHangout, flImgAddCredit;
    private ImageView imgSayHiBig, imgMessageBig, imgMailBig, imgGreetingBig, imgHangoutBig, imgAddCreditBig;
    private ImageView imgSayHiSmall, imgMessageSmall, imgMailSmall, imgGreetingSmall, imgHangoutSmall, imgAddCreditSmall;
    private TextView tvSayHi, tvMessage, tvMail, tvGreeting, tvHangOut, tvAddCredits;
    private Badge badgeSayHi, badgeMessage, badgeMail, badgeGreetingMail;
    //最近一次点击选中的tab类型 用户列表查询、界面跳转或界面展示
    private TopMenuItemType lastSelectedTopMenuItemType = null;
    //标识toolbar当前是否处于完全展开的状态
    private boolean istExpandedNow = false;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        TAG = HotListFragment.class.getSimpleName();
//        mLayoutManager = new LinearLayoutManager(getContext());
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
//                    Log.i("info","========== onScrollStateChanged =============== SCROLL_STATE_IDLE");
                    Fresco.getImagePipeline().resume();
                }else {
//                    Log.i("info","========== onScrollStateChanged =============== scroll");
                    Fresco.getImagePipeline().pause();
                }
            }
        });

        initData();
        refreshUIByAuth();
    }

    /**
     * 初始化数据
     */
    public void initData(){
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
        ShowUnreadManager.getInstance().unregisterUnreadListener(this);
        LoginManager.getInstance().unRegister(this);
        // 2018/11/20 Hardy
        ContactManager.getInstance().unregisterChatUnreadUpdateUpdata(this);
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
            reloadData();
        } else {
            //刷新试用券信息
            updateVoucherAvailableInfo();
        }
    }

    @Override
    protected void onBackFromHomeInTimeInterval() {
        super.onBackFromHomeInTimeInterval();
        Log.d(TAG, "onBackFromHomeInTimeInterval");
        reloadData();
    }

    /**
     * 更新未读数据
     */
    private void updateUnReadData() {
        Log.d(TAG, "updateUnReadData");
        //主界面未读 onResume读取本地判断刷新
//        showTopMenuUnread(TopMenuItemType.Message,ShowUnreadManager.getInstance().getMsgUnReadNum());
        showTopMenuUnread(TopMenuItemType.Mail, ShowUnreadManager.getInstance().getMailUnReadNum());
        showTopMenuUnread(TopMenuItemType.Greetings, ShowUnreadManager.getInstance().getGreetMailUnReadNum());
        showTopMenuUnread(TopMenuItemType.SayHi, ShowUnreadManager.getInstance().getSayHiUnreadNum());
    }

    private void updateChatUnreadData(int count) {
        // 2018/11/16 Hardy
        showTopMenuUnread(TopMenuItemType.Chat, count);
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
                            if(item.itemType == LiveRoomListItem.Type.ANCHOR){
                                item.isHasPublicVoucherFree = hotListVoucherHelper.checkVoucherFree(item.userId, true);
                                item.isHasPrivateVoucherFree = hotListVoucherHelper.checkVoucherFree(item.userId, false);
                            }
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
                //收藏操作结果 返回
                HttpRespObject responseFav = (HttpRespObject) msg.obj;
                if (responseFav.isSuccess) {
                    LiveRoomListItem listItem = (LiveRoomListItem) responseFav.data;
                    if(mHotList != null && listItem != null){
                        for (LiveRoomListItem liveRoomListItem : mHotList){
                            //需要先判断类型， 以免空指针
                            if(liveRoomListItem.itemType == LiveRoomListItem.Type.ANCHOR && liveRoomListItem.userId.equals(listItem.userId)){
                                liveRoomListItem.isFollow = listItem.isFollow;
                                break;
                            }
                        }
                        mAdapter.notifyDataSetChanged();
                    }
                }
                break;
            case GET_VOUCHER_CALLBACK:
                //试用券 返回
                mAdapter.notifyDataSetChanged();

                break;
            case GET_ADVERT_CALLBACK:
                //广告 返回
                // 在第4个格子插入广告
                HttpRespObject responseAd = (HttpRespObject) msg.obj;
                if (responseAd != null && responseAd.isSuccess) {
                    LSAdWomanListAdvertItem adWomanListAdvertItem = (LSAdWomanListAdvertItem)responseAd.data;
                    if(adWomanListAdvertItem != null && !TextUtils.isEmpty(adWomanListAdvertItem.id)){
                        LiveRoomListItem listItemAD = new LiveRoomListItem();
                        listItemAD.itemType = LiveRoomListItem.Type.ADVERT;
                        listItemAD.advertItem = adWomanListAdvertItem;

                        if (mHotList.size() > (AD_INDEX+1)) {
                            mHotList.add(AD_INDEX, listItemAD);
                        }else{
                            mHotList.add( listItemAD);
                        }
                    }
                }

                //取试聊卷
                updateVoucherAvailableInfo();

                break;
            case GET_FOLLOWING_CALLBACK: {
                //主播列表 返回
                //Ps:msg.arg1 == 1 取更多; ==0 刷新
                HttpRespObject response = (HttpRespObject) msg.obj;
                if (response.isSuccess) {

                    Log.d(TAG, "GET_FOLLOWING_CALLBACK mHotList size1:" + mHotList.size());
                    if (0 == msg.arg1) {
                        mHotList.clear();
                    }

                    HotListItem[] followingArray = (HotListItem[]) response.data;
                    if (followingArray != null) {
                        mHotList.addAll(Arrays.asList(followingArray));
                    }
                    Log.d(TAG, "GET_FOLLOWING_CALLBACK mHotList size2:" + mHotList.size());

                    //hot数据为空时只展示banner
                    if (mHotList == null || mHotList.size() == 0) {
                        showEmptyView();
                    }else {
                        //刷新试用券信息
                        if (0 == msg.arg1) {
                            getAd();
                        } else {
                            mAdapter.notifyDataSetChanged();
                        }
                    }

                    //
                    isNeedRefresh = false;
                } else {
                    if (mHotList.size() > 0) {
                        if (getActivity() != null) {
                            ToastUtil.showToast(getActivity(), response.errMsg);
                        }
                        isNeedRefresh = false;
                    } else {
                        //无数据显示错误页，引导用户
                        showErrorView();
                        isNeedRefresh = true;
                    }
                }
            }
            break;
        }
        onRefreshComplete();
    }

    /**
     * 刷新列表
     *
     * @param isLoadMore
     */
    private void queryHotList(final boolean isLoadMore) {
        //先取同步配置
        if (SynConfigerManager.getInstance().getConfigItemCache() == null) {
            SynConfigerManager.getInstance().setSynConfigResultObserver(new Consumer<SynConfigerManager.ConfigResult>() {
                @Override
                public void accept(SynConfigerManager.ConfigResult configResult) {
                    if (configResult.isSuccess && (configResult.item != null)) {
                        //同步配置成功，去取HOTLIST
                        getHotList(isLoadMore);
                    } else {
                        //即为取HOTLIST失败
                        HttpRespObject response = new HttpRespObject(false, -1, "", null);
                        Message msg = Message.obtain();
                        msg.what = GET_FOLLOWING_CALLBACK;
                        msg.arg1 = isLoadMore ? 1 : 0;
                        msg.obj = response;
                        sendUiMessage(msg);
                    }
                }
            }).getSynConfig();
        } else {
            getHotList(isLoadMore);
        }

    }

    /**
     * 刷新列表
     *
     * @param isLoadMore
     */
    private void getHotList(final boolean isLoadMore) {
        int start = 0;
        if (isLoadMore) {
            start = mHotList.size();
        }

        LiveRequestOperator.getInstance().GetHotLiveList(start, Default_Step, false, LiveModule.getInstance().getForTest(), new OnGetHotListCallback() {
            @Override
            public void onGetHotList(boolean isSuccess, int errCode, String errMsg, HotListItem[] followingList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, followingList);
                Message msg = Message.obtain();
                msg.what = GET_FOLLOWING_CALLBACK;
                msg.arg1 = isLoadMore ? 1 : 0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 取广告
     */
    private void getAd(){
        //列表为空不刷新,减少请求次数
        //未登录不刷新,以免刷新失败又重登录导致死循环
        if (LoginManager.getInstance().getLoginStatus() != LoginManager.LoginStatus.Logined || (mHotList == null) || mHotList.size() == 0) {
            Log.d(TAG, "**** cancel ****");
            //下拉刷新列表时，依赖试聊券刷新列表，减少刷新次数
            sendEmptyUiMessage(GET_ADVERT_CALLBACK);
            return;
        }

        String deviceId = SystemUtils.getDeviceId(mContext);
        LiveRequestOperator.getInstance().GetWomanListAdvert(deviceId, new OnLSAdWomanistAdvertCallback() {
            @Override
            public void onLSAdWomanistAdverte(boolean isSuccess, int errno, String errmsg, LSAdWomanListAdvertItem advert) {
                HttpRespObject response = new HttpRespObject(isSuccess, errno, errmsg, advert);
                Message msg = Message.obtain();
                msg.what = GET_ADVERT_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 重新刷新界面
     */
    public void reloadData() {
//        showLoadingProcess();
//        queryHotList(false);

        //  2019/7/24 Hardy
        refreshRecyclerView.showRefreshing();
        queryHotList(false);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        reloadData();
    }

    @Override
    public void onGuideInEmptyView() {
        super.onGuideInEmptyView();
        reloadData();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        reloadData();
    }

    @Override
    protected void onPullDown() {
        //取数据
        queryHotList(false);
    }

    @Override
    protected void onPullUp() {
        //取数据
        queryHotList(true);
    }

    @Override
    public void onClick(View v) {
        //add by Jagger 2018-7-10
        super.onClick(v);
        int viewId = v.getId();
        if (ButtonUtils.isFastDoubleClick(viewId)) {
            return;
        }
        if (viewId == R.id.llSayHi) {
            lastSelectedTopMenuItemType = TopMenuItemType.SayHi;
            Activity activity = getActivity();
            if (activity != null && activity instanceof MainFragmentActivity) {
                SayHiListActivity.startAct(mContext);
            }
        }else if (viewId == R.id.llMessage) {
//            lastSelectedTopMenuItemType = TopMenuItemType.Message;
            lastSelectedTopMenuItemType = TopMenuItemType.Chat;
            Activity activity = getActivity();
            if (activity != null && activity instanceof MainFragmentActivity) {
                MainFragmentActivity mainFragmentActivity = (MainFragmentActivity) activity;
//                mainFragmentActivity.showMessageListActivity();

                // 2018/11/16 Hardy
                mainFragmentActivity.showChatListActivity();
            }
        } else if (viewId == R.id.llMail) {
            lastSelectedTopMenuItemType = TopMenuItemType.Mail;
            Activity activity = getActivity();
            if (activity != null && activity instanceof MainFragmentActivity) {
                MainFragmentActivity mainFragmentActivity = (MainFragmentActivity) activity;
                mainFragmentActivity.showEmfListWebView();
            }
        } else if (viewId == R.id.llGreetings) {
            lastSelectedTopMenuItemType = TopMenuItemType.Greetings;
            Activity activity = getActivity();
            if (activity != null && activity instanceof MainFragmentActivity) {
                MainFragmentActivity mainFragmentActivity = (MainFragmentActivity) activity;
                mainFragmentActivity.showLoiListWebView();
            }
        } else if (viewId == R.id.llHangOut) {
            lastSelectedTopMenuItemType = TopMenuItemType.Hangout;
        } else if (viewId == R.id.llAddCredit) {
            lastSelectedTopMenuItemType = TopMenuItemType.AddCredit;
            Activity activity = getActivity();
            if (activity != null && activity instanceof MainFragmentActivity) {
                MainFragmentActivity mainFragmentActivity = (MainFragmentActivity) activity;
                mainFragmentActivity.addCredits();
            }
        } else {

        }
    }

    @Override
    protected void setFoldView() {
        Log.d(TAG, "setFoldView");
        viewFoldCustom = LayoutInflater.from(getActivity()).inflate(R.layout.view_live_main_top_menu_big_toolbar, null);
        flContent = (FrameLayout) viewFoldCustom.findViewById(R.id.fl_content);
        llSayHi = (LinearLayout) viewFoldCustom.findViewById(R.id.llSayHi);
        llSayHi.setOnClickListener(this);
        llMessage = (LinearLayout) viewFoldCustom.findViewById(R.id.llMessage);
        llMessage.setOnClickListener(this);
        llMail = (LinearLayout) viewFoldCustom.findViewById(R.id.llMail);
        llMail.setOnClickListener(this);
        llGreetings = (LinearLayout) viewFoldCustom.findViewById(R.id.llGreetings);
        llGreetings.setOnClickListener(this);
        llHangOut = (LinearLayout) viewFoldCustom.findViewById(R.id.llHangOut);
        llHangOut.setOnClickListener(this);
        llAddCredit = (LinearLayout) viewFoldCustom.findViewById(R.id.llAddCredit);
        llAddCredit.setOnClickListener(this);

        //毛玻璃
        mBlurringViewBg = (BlurringView) viewFoldCustom.findViewById(R.id.blurring_view_bg);
        mBlurringViewBg.setBlurredView(refreshRecyclerView.getRootView());
        refreshRecyclerView.getRecyclerView().addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                refreshBlurringView();
            }
        });

        //控制imageView大小
        flImgSayHi = (FrameLayout) viewFoldCustom.findViewById(R.id.flImgSayHi);
        flImgMessage = (FrameLayout) viewFoldCustom.findViewById(R.id.flImgMessage);
        flImgMail = (FrameLayout) viewFoldCustom.findViewById(R.id.flImgMail);
        flImgGreetings = (FrameLayout) viewFoldCustom.findViewById(R.id.flImgGreetings);
        flImgHangout = (FrameLayout) viewFoldCustom.findViewById(R.id.flImgHangOut);
        flImgAddCredit = (FrameLayout) viewFoldCustom.findViewById(R.id.flImgAddCredit);

        //大图标
        imgSayHiBig = (ImageView) viewFoldCustom.findViewById(R.id.imgSayHiBig);
        imgMessageBig = (ImageView) viewFoldCustom.findViewById(R.id.imgMessageBig);
        imgMailBig = (ImageView) viewFoldCustom.findViewById(R.id.imgMailBig);
        imgGreetingBig = (ImageView) viewFoldCustom.findViewById(R.id.imgGreetingsBig);
        imgHangoutBig = (ImageView) viewFoldCustom.findViewById(R.id.imgHangOutBig);
        imgAddCreditBig = (ImageView) viewFoldCustom.findViewById(R.id.imgAddCreditBig);

        //小图标
        imgSayHiSmall = (ImageView) viewFoldCustom.findViewById(R.id.imgSayHiSmall);
        imgMessageSmall = (ImageView) viewFoldCustom.findViewById(R.id.imgMessageSmall);
        imgMailSmall = (ImageView) viewFoldCustom.findViewById(R.id.imgMailSmall);
        imgGreetingSmall = (ImageView) viewFoldCustom.findViewById(R.id.imgGreetingSmall);
        imgHangoutSmall = (ImageView) viewFoldCustom.findViewById(R.id.imgHangOutSmall);
        imgAddCreditSmall = (ImageView) viewFoldCustom.findViewById(R.id.imgAddCreditSmall);

        //文字
        tvSayHi = (TextView) viewFoldCustom.findViewById(R.id.tvSayHi);
        tvMessage = (TextView) viewFoldCustom.findViewById(R.id.tvMessage);
        tvMail = (TextView) viewFoldCustom.findViewById(R.id.tvMail);
        tvGreeting = (TextView) viewFoldCustom.findViewById(R.id.tvGreeting);
        tvHangOut = (TextView) viewFoldCustom.findViewById(R.id.tvHangOut);
        tvAddCredits = (TextView) viewFoldCustom.findViewById(R.id.tvAddCredits);

        //图标最大尺寸
        mImgMaxWidth = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_image_view_max_width);
        mImgMaxHeight = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_image_view_max_height);
        //图标最小尺寸
        mImgMinWidth = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_image_view_min_width);
        mImgMinHeight = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_image_view_min_height);
        //tab title组件顶部间距
        mTxtMaxTopMargin = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_txt_top_margin_max);
        mTxtMinTopMargin = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_txt_top_margin_min);
        //未读文字尺寸
        mBadgeTextMaxSize = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_max);
        mBadgeTextMinSize = getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_min);

        //文字最大、最小尺寸
        mTvMaxSize = getResources().getDimensionPixelSize(R.dimen.live_size_13sp);
        mTvMinSize = getResources().getDimensionPixelSize(R.dimen.live_size_10sp);

        //未读红点
        initTopMenuUnread();

        //刷新毛玻璃
        refreshBlurringView();

        //红点未读
        ShowUnreadManager.getInstance().registerUnreadListener(this);
        updateUnReadData();

        // 2018/11/20 Hardy
        ContactManager.getInstance().registerChatUnreadUpdateUpdate(this);
        updateChatUnreadData(ContactManager.getInstance().getAllUnreadCount());
    }

    @Override
    protected void onAppBarLayoutOffsetChange(int totalScrollRange, float scrolledPercent) {
        //scrolledPercent->0 放大 向下滑动, scrolledPercent->1 缩小 向上滑动
        istExpandedNow = 0 == (int) scrolledPercent;
//        Log.i(TAG ,"onAppBarLayoutOffsetChange totalScrollRange:"+totalScrollRange+" scrolledPercent:"+scrolledPercent+" istExpandedNow:"+istExpandedNow);
        //大图标透明度渐变
        imgSayHiBig.setAlpha(1 - scrolledPercent);
        imgMessageBig.setAlpha(1 - scrolledPercent);
        imgMailBig.setAlpha(1 - scrolledPercent);
        imgGreetingBig.setAlpha(1 - scrolledPercent);
        imgHangoutBig.setAlpha(1 - scrolledPercent);
        imgAddCreditBig.setAlpha(1 - scrolledPercent);

        //小图标透明度渐变
        imgSayHiSmall.setAlpha(scrolledPercent);
        imgMessageSmall.setAlpha(scrolledPercent);
        imgMailSmall.setAlpha(scrolledPercent);
        imgGreetingSmall.setAlpha(scrolledPercent);
        imgHangoutSmall.setAlpha(scrolledPercent);
        imgAddCreditSmall.setAlpha(scrolledPercent);

        //图标尺寸渐变计算
        int width = (int) (mImgMaxWidth * (1 - scrolledPercent));
        int height = (int) (mImgMaxHeight * (1 - scrolledPercent));

        if (width <= mImgMinWidth) {
            width = mImgMinWidth;
        } else if (width >= mImgMaxWidth) {
            width = mImgMaxWidth;
        }

        if (height <= mImgMinHeight) {
            height = mImgMinHeight;
        } else if (height >= mImgMaxHeight) {
            height = mImgMaxHeight;
        }

        //图标尺寸渐变
        flImgSayHi.getLayoutParams().width = width;
        flImgSayHi.getLayoutParams().height = height;
        flImgMessage.getLayoutParams().width = width;
        flImgMessage.getLayoutParams().height = height;
        flImgMail.getLayoutParams().width = width;
        flImgMail.getLayoutParams().height = height;
        flImgGreetings.getLayoutParams().width = width;
        flImgGreetings.getLayoutParams().height = height;
        flImgHangout.getLayoutParams().width = width;
        flImgHangout.getLayoutParams().height = height;
        flImgAddCredit.getLayoutParams().height = height;

        //文字尺寸渐变
        dynamicModifyTabTxtViewPropert(tvSayHi, scrolledPercent);
        dynamicModifyTabTxtViewPropert(tvMessage, scrolledPercent);
        dynamicModifyTabTxtViewPropert(tvMail, scrolledPercent);
        dynamicModifyTabTxtViewPropert(tvGreeting, scrolledPercent);
        dynamicModifyTabTxtViewPropert(tvHangOut, scrolledPercent);
        dynamicModifyTabTxtViewPropert(tvAddCredits, scrolledPercent);

        //未读数字尺寸渐变
        mBadgeTextSize = (int) (mBadgeTextMaxSize * (1 - scrolledPercent));
        if (mBadgeTextSize <= mBadgeTextMinSize) {
            mBadgeTextSize = mBadgeTextMinSize;
        } else if (mBadgeTextSize >= mBadgeTextMaxSize) {
            mBadgeTextSize = mBadgeTextMaxSize;
        }


        if (badgeSayHi != null) {
            badgeSayHi.setBadgeTextSize(mBadgeTextSize, false);
        }
        if (badgeMessage != null) {
            badgeMessage.setBadgeTextSize(mBadgeTextSize, false);
        }
        if (badgeMail != null) {
            badgeMail.setBadgeTextSize(mBadgeTextSize, false);
        }
        if (badgeGreetingMail != null) {
            badgeGreetingMail.setBadgeTextSize(mBadgeTextSize, false);
        }

        //父控件向下移（因为在toolbar中，布局只能居中, 通过改变PaddingTop令整体布局总是靠下）
        dynamicModifyTabParentViewPropert(totalScrollRange, scrolledPercent);

        //毛玻璃在展开时隐藏
        if (istExpandedNow) {
            mBlurringViewBg.setVisibility(View.GONE);
        } else {
            mBlurringViewBg.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 动态修改四个tab父布局组件属性
     *
     * @param totalScrollRange
     * @param scrolledPercent
     */
    private void dynamicModifyTabParentViewPropert(int totalScrollRange, float scrolledPercent) {
        //整个布局上下移动
        flContent.setPadding(0, (int) (totalScrollRange * scrolledPercent), 0, 0);
    }

    /**
     * 动态修改顶部四tab标题组件的布局属性
     */
    private void dynamicModifyTabTxtViewPropert(TextView targetTv, float scrolledPercent) {
        float txtSize = mTvMinSize + (mTvMaxSize - mTvMinSize) * (1 - scrolledPercent);
        targetTv.setTextSize(TypedValue.COMPLEX_UNIT_PX, txtSize);
        LinearLayout.LayoutParams txtLp = (LinearLayout.LayoutParams) targetTv.getLayoutParams();
        txtLp.topMargin = (int) (mTxtMinTopMargin + (mTxtMaxTopMargin - mTxtMinTopMargin) * (1 - scrolledPercent));
    }

    /**
     * 刷新毛玻璃
     */
    private void refreshBlurringView() {
        if (!istExpandedNow) {
            if (mBlurringViewBg != null) {
                mBlurringViewBg.invalidate();
            }
        }
    }

    /**
     * 初始化未读红点
     */
    private void initTopMenuUnread() {
        badgeSayHi = new QBadgeView(mContext).bindTarget(flImgSayHi);
        badgeSayHi.setBadgeNumber(0);
        badgeSayHi.setBadgeGravity(Gravity.TOP | Gravity.END);
        BadgeHelper.setBaseStyle(mContext, badgeSayHi, mBadgeTextSize);

        badgeMessage = new QBadgeView(mContext).bindTarget(flImgMessage);
        badgeMessage.setBadgeNumber(0);
        badgeMessage.setBadgeGravity(Gravity.TOP | Gravity.END);
        BadgeHelper.setBaseStyle(mContext, badgeMessage, mBadgeTextSize);

        badgeMail = new QBadgeView(mContext).bindTarget(flImgMail);
        badgeMail.setBadgeNumber(0);
        badgeMail.setBadgeGravity(Gravity.TOP | Gravity.END);
        BadgeHelper.setBaseStyle(mContext, badgeMail, mBadgeTextSize);

        badgeGreetingMail = new QBadgeView(mContext).bindTarget(flImgGreetings);
        badgeGreetingMail.setBadgeNumber(0);
        badgeGreetingMail.setBadgeGravity(Gravity.TOP | Gravity.END);
        BadgeHelper.setBaseStyle(mContext, badgeGreetingMail, mBadgeTextSize);
    }

    /**
     * 未读
     *
     * @param menuType
     * @param readSum  0为隐藏;
     */
    private void showTopMenuUnread(TopMenuItemType menuType, int readSum) {
        Log.d(TAG, "showTopMenuUnread-menuType:" + menuType + " readSum:" + readSum);
//        if(menuType == TopMenuItemType.Message) {
        if (menuType == TopMenuItemType.Chat) {
            if (badgeMessage != null) {
//                if(readSum <= 99 ){
//                    badgeMessage.setBadgeText("");
//                    badgeMessage.setBadgeNumber(readSum);
//                }else{
//                    badgeMessage.setBadgeText("...");
//                }

                // 2018/11/20 Hardy
                // 初始化小红点样式
                BadgeHelper.setHotCircleStyle(badgeMessage,false);
                if (readSum > 99) {
                    badgeMessage.setBadgeText("...");
                } else if (readSum > 0) {
                    badgeMessage.setBadgeText("");
                    badgeMessage.setBadgeNumber(readSum);
                } else {
                    int inviteCount = ContactManager.getInstance().getInviteListSize();
                    if (inviteCount > 0) {
                        badgeMessage.setBadgeNumber(0);
                        badgeMessage.setBadgeText("");
                        // 小红点样式设置的特别处理
                        BadgeHelper.setHotCircleStyle(badgeMessage,true);
                    } else {
                        badgeMessage.setBadgeNumber(0);
                    }
                }

            }
        } else if (menuType == TopMenuItemType.Mail) {
            if (badgeMail != null) {
                if(readSum <= 99 ){
                    badgeMail.setBadgeText("");
                    badgeMail.setBadgeNumber(readSum);
                }else{
                    badgeMail.setBadgeText("...");
                }
            }
        } else if (menuType == TopMenuItemType.Greetings) {
            if (badgeGreetingMail != null) {
                if(readSum <= 99 ){
                    badgeGreetingMail.setBadgeText("");
                    badgeGreetingMail.setBadgeNumber(readSum);
                }else{
                    badgeGreetingMail.setBadgeText("...");
                }
            }
        }else if (menuType == TopMenuItemType.SayHi) {
            if (badgeSayHi != null) {
                if(readSum <= 99 ){
                    badgeSayHi.setBadgeText("");
                    badgeSayHi.setBadgeNumber(readSum);
                }else{
                    badgeSayHi.setBadgeText("...");
                }
            }
        }
    }

    /**
     * 根据权限刷新UI
     */
    private void refreshUIByAuth(){
        if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            if (null != loginItem && loginItem.userPriv != null) {
                //是否有SayHi权限
                if(loginItem.userPriv.isSayHiPriv){
                    llSayHi.setVisibility(View.VISIBLE);
                }else {
                    llSayHi.setVisibility(View.GONE);
                }
            }
        }else{
            llSayHi.setVisibility(View.GONE);
        }
    }

    @Override
    public void onUnreadUpdate(final int unreadChatCount, int unreadInviteCount) {
        Log.d(TAG, "onUnreadUpdate");
        if (null != getActivity()) {
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    updateChatUnreadData(unreadChatCount);
                }
            });
        }
    }

    @Override
    public void onUnReadDataUpdate() {
        Log.d(TAG, "onUnReadDataUpdate");
        if (null != getActivity()) {
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    updateUnReadData();
                }
            });
        }
    }

    @Override
    public void onShowUnreadUpdate(int unreadNum) {

    }

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //断线重登陆刷新本地未读红点数据到主界面
            onUnReadDataUpdate();
        }
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        //重回列表需要重新刷新
        isNeedRefresh = true;
    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit, IMClientListener.LCC_ERR_TYPE err) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {

    }

    @Override
    public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        if(isSuccess){
            refreshUIByAuth();
            reloadData();
        }
    }

    @Override
    public void onLogout(boolean isMannual) {
        //重回列表需要重新刷新
        isNeedRefresh = true;
        //
        reloadData();
        //
        refreshUIByAuth();
    }
}
