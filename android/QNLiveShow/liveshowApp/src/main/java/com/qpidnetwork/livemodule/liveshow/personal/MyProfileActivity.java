package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.LSLeftCreditItem;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HorizontalLineDecoration;
import com.qpidnetwork.livemodule.liveshow.adapter.MyProfileFollowsAdapter;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentPagerAdapter4Top;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.UserInfoUtil;
import com.qpidnetwork.livemodule.view.ProfileItemView;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 个人中心——直播
 * 2018/09/18 Hardy
 */
//public class MyProfileActivity extends BaseFragmentActivity implements IAuthorizationListener {
public class MyProfileActivity extends BaseUserIconUploadActivity implements IAuthorizationListener {

    private static final int GET_FOLLOWING_CALLBACK = 1;    // 获取个人关注列表
    private static final int GET_PROFILE_CALLBACK = 2;      // 获取个人信息

    private SimpleDraweeView mIvUserIcon;
    private TextView mTvUserName;
    private TextView mTvUserAge;
    private ImageButton mIvIconUpload;

    private RecyclerView mRvFollowView;
    private MyProfileFollowsAdapter mFollowsAdapter;

    private ProfileItemView mItemFollowView;
    private ProfileItemView mItemProfileDetails;
    private ProfileItemView mItemCBView;
    private ProfileItemView mItemLVView;
    private ProfileItemView mItemSettingsView;

    public static void lanchAct(Context context) {
        Intent intent = new Intent(context, MyProfileActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_profile_live);

        initView();
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        LoginManager.getInstance().unRegister(this);
    }

    /**
     * 初始化各种 View
     */
    private void initView() {
        LoginManager.getInstance().register(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            LinearLayout rlImageHeader = (LinearLayout) findViewById(R.id.my_profile_titleBar_ll);
            ((LinearLayout.LayoutParams) rlImageHeader.getLayoutParams()).topMargin += DisplayUtil.getStatusBarHeight(mContext);
        }

        View mLLHeadView = findViewById(R.id.my_profile_head_ll);
        mLLHeadView.setLayerType(View.LAYER_TYPE_SOFTWARE, null); //头像网络慢有时为黑:https://blog.csdn.net/huyawenz/article/details/78863636
        mLLHeadView.setOnClickListener(this);

        ImageButton mBtnBack = (ImageButton) findViewById(R.id.my_profile_buttonCancel);
        mBtnBack.setOnClickListener(this);

        mIvUserIcon = findViewById(R.id.my_profile_iv_userIcon);
        mIvUserIcon.setOnClickListener(this);

        mIvIconUpload = findViewById(R.id.my_profile_iv_upload);
        mIvIconUpload.setOnClickListener(this);

        mTvUserName = (TextView) findViewById(R.id.my_profile_tv_userName);
        mTvUserAge = (TextView) findViewById(R.id.my_profile_tv_userAge);

        // 关注列表
        mItemFollowView = (ProfileItemView) findViewById(R.id.my_profile_ll_my_follow);
        mItemFollowView.setOnClickListener(this);
        mItemFollowView.setTextLeft("My Follows");
        mItemFollowView.setRightIcon2Arrow();
        mItemFollowView.showBottomLine(false);

        // recyclerView
        mRvFollowView = (RecyclerView) findViewById(R.id.my_profile_rl_my_follow);
        mRvFollowView.setLayoutManager(new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false));
        // 每个头像 icon 的左右间距
        int dexSize = getResources().getDimensionPixelSize(R.dimen.live_size_16dp);
        // 最多1行，不可滚动，并且最多展示 5 个，就有 6 个间隙
        int iconWh = (DisplayUtil.getScreenWidth(mContext) - dexSize * 6) / 5;
        Log.i("info", "dexSize: " + dexSize + "----> iconWh: " + iconWh);
        mRvFollowView.addItemDecoration(new HorizontalLineDecoration(dexSize));
        // 2018/9/19 set adapter
        mFollowsAdapter = new MyProfileFollowsAdapter(mContext);
        mFollowsAdapter.setUserIconWH(iconWh);
        mFollowsAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v, int position) {
                // 2018/9/19  点击头像打开主播资料页
                FollowingListItem item = mFollowsAdapter.getItemBean(position);
                if (item != null) {
                    AnchorProfileActivity.launchAnchorInfoActivty(mContext, getResources().getString(R.string.live_webview_anchor_profile_title),
                            item.userId, false, AnchorProfileActivity.TagType.Album);
                }
            }
        });
        mRvFollowView.setAdapter(mFollowsAdapter);
        // alpha anim
        mRvFollowView.setVisibility(View.GONE);
        mFollowsAdapter.registerAdapterDataObserver(new RecyclerView.AdapterDataObserver() {
            @Override
            public void onChanged() {
                super.onChanged();

                if (mFollowsAdapter.getItemCount() > 0 && mRvFollowView.getVisibility() == View.GONE) {
                    mRvFollowView.setAlpha(0);
                    mRvFollowView.setVisibility(View.VISIBLE);
                    mRvFollowView.animate().alpha(1).setDuration(800).start();
                }
            }
        });


        // 信用点
        mItemCBView = (ProfileItemView) findViewById(R.id.my_profile_ll_Credit_Balance);
        mItemCBView.setOnClickListener(this);
        mItemCBView.setTextLeft(R.string.person_center_credit_balance);
        mItemCBView.setBottomLineLeftMarginDefault();

        // 试用卷
        mItemLVView = (ProfileItemView) findViewById(R.id.my_profile_ll_Live_Vouchers);
        mItemLVView.setOnClickListener(this);
        mItemLVView.setTextLeft(R.string.person_center_my_vouchers);

        // 设置
        mItemSettingsView = (ProfileItemView) findViewById(R.id.my_profile_ll_setting);
        mItemSettingsView.setOnClickListener(this);
        mItemSettingsView.setTextLeft(R.string.person_center_settings);
        mItemSettingsView.setRightIcon2Arrow();

        // ProfileDetails
        mItemProfileDetails = (ProfileItemView) findViewById(R.id.my_profile_ll_Profile_Details);
        mItemProfileDetails.setOnClickListener(this);
        mItemProfileDetails.setTextLeft(R.string.person_center_profile_detail);
        mItemProfileDetails.setRightIcon2Arrow();
    }

    /**
     * 获取本地或者服务器数据
     */
    private void initData() {
        // load from local
        setUserInfoLocalData();

        //初始化信息
        double credits = LiveRoomCreditRebateManager.getInstance().getCredit();
        if(credits > 0){
            mItemCBView.setTextRight(ApplicationSettingUtil.formatCoinValue(credits));
        }else{
            mItemCBView.setTextRight("-");
        }
        int vouchers = LiveRoomCreditRebateManager.getInstance().getCoupon() + LiveRoomCreditRebateManager.getInstance().getLiveChatCount();
        if(vouchers > 0){
            mItemLVView.setTextRight(vouchers + "");
        }else{
            mItemLVView.setTextRight("-");
        }

        // load from net
        getMyProfile();
        queryFollowingList();
        loadCredits();
    }


    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case GET_FOLLOWING_CALLBACK:
                HttpRespObject response = (HttpRespObject) msg.obj;
                if (response.isSuccess) {
                    FollowingListItem[] followingArray = (FollowingListItem[]) response.data;
                    List<FollowingListItem> list = null;
                    if (followingArray != null) {
                        list = new ArrayList<>();
                        list.addAll(Arrays.asList(followingArray));
                    }
                    mFollowsAdapter.setData(list);
                } else {
                    mFollowsAdapter.setData(null);
                }
                break;

            case GET_PROFILE_CALLBACK:
                HttpRespObject responseProfile = (HttpRespObject) msg.obj;

                if (responseProfile.isSuccess) {
                    LSProfileItem mProfileItem = (LSProfileItem) responseProfile.data;
                    if (mProfileItem != null) {
                        // 缓存数据
                        MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                        // 设置父类的数据缓存
                        setLsProfileItem(mProfileItem);
                        mIvIconUpload.setVisibility(mProfileItem.showUpload() ? View.VISIBLE : View.GONE);
                        setIconUrl(mProfileItem);
                        mTvUserAge.setText(mProfileItem.manid);
                        mTvUserName.setText(UserInfoUtil.getUserFullName(mProfileItem.firstname, mProfileItem.lastname));
                    }
                }
                break;


            default:
                break;
        }
    }


    //===================== upload  icon    =========================================
    @Override
    protected void onUploadIconSuccess() {
        // 暂时不做任何处理
    }

    @Override
    protected void onLoadUserInfo() {
        getMyProfile();
    }

    @Override
    protected boolean isRegisterGetUserInfoBroadcast() {
        return true;
    }
    //===================== upload  icon    =========================================

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.my_profile_buttonCancel) {
            finish();
        } else if (id == R.id.my_profile_head_ll || id == R.id.my_profile_ll_Profile_Details) {
            // 2018/9/19 跳转到 my profile 资料页
            MyProfileDetailNewLiveActivity.startAct(this);

        } else if (id == R.id.my_profile_iv_userIcon) {
            // 2018/9/19 头像大图,通知 QN 打开大图
            openIconAct();

        } else if (id == R.id.my_profile_iv_upload) {

            //  2019/8/13 打开图片选择弹窗
            showIconUploadDialog();

        } else if (id == R.id.my_profile_ll_my_follow) {
            // 2018/9/19 点击my follows列表回到首页并将标签定位至Follow

            MainFragmentActivity.launchActivityWithListType(mContext, MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_FOLLOW);
            finish();

        } else if (id == R.id.my_profile_ll_Credit_Balance) {
            // 2018/9/19  credit blance点击跳转至买点页面，android买点进入信用点订单B

            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlAddCredit = LiveUrlBuilder.createAddCreditUrl("", "B30", "");
            new AppUrlHandler(mContext).urlHandle(urlAddCredit);

        } else if (id == R.id.my_profile_ll_Live_Vouchers) {
            // 2018/9/19 live vouchers入口，点击打开my backpack并定位至voucher标签
            // 打开试用券，是否回到home再进背包列表（不是，直接Push背包列表界面）

            MyPackageActivity.launchMyPackageActivity(mContext, 1);

        } else if (id == R.id.my_profile_ll_setting) {
            // 2018/9/19 跳转到设置界面
            SettingsActivity.startAct(mContext);
        }

    }

    private void setUserInfoLocalData() {
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (loginItem != null) {
            setIconUrl(loginItem.photoUrl);

            mTvUserName.setText(loginItem.nickName);
            mTvUserAge.setText(loginItem.userId);
        }
    }

    private void setIconUrl(String iconUrl) {
        if (TextUtils.isEmpty(iconUrl)) {
            return;
        }

        int wh = DisplayUtil.dip2px(mContext, 100);

        /*
            2019/8/20 Hardy
            由于更换头像后，接口返回 url 地址是不变的，防止加载图片读取缓存，
            导致新图显示不成功，故这里清除该图片的内存缓存和磁盘缓存。
         */
        FrescoLoadUtil.cleanUrlCache(iconUrl);

        FrescoLoadUtil.loadUrl(mContext, mIvUserIcon, iconUrl, wh,
                R.drawable.ic_default_photo_man, true,
                getResources().getDimensionPixelSize(R.dimen.live_size_4dp),
                ContextCompat.getColor(mContext, R.color.white));
    }

    private void setIconUrl(LSProfileItem item) {
        if (item == null || !item.showPhoto()) {
            // 加载默认资源图
            FrescoLoadUtil.loadRes(mContext, mIvUserIcon, R.drawable.ic_default_photo_man,
                    R.drawable.ic_default_photo_man, true,
                    getResources().getDimensionPixelSize(R.dimen.live_size_4dp),
                    ContextCompat.getColor(mContext, R.color.white));
        } else {
            setIconUrl(item.photoURL);
        }
    }

    /**
     * 设置信用点、试用劵数据
     *
     * @param credits
     */
    private void setTextMoneyData(double credits, int coupon) {
        mItemCBView.setTextRight(ApplicationSettingUtil.formatCoinValue(credits));
        mItemLVView.setTextRight(coupon + "");
    }

    /**
     * 获取个人信息
     */
    private void getMyProfile() {
        LiveDomainRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
            @Override
            public void onGetMyProfile(boolean isSuccess, int errno, String errmsg, LSProfileItem item) {
                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, item);
                msg.what = GET_PROFILE_CALLBACK;
                msg.obj = obj;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 获取信用点、试用劵数据
     */
    private void loadCredits() {
        LiveRequestOperator.getInstance().GetAccountBalance(new OnGetAccountBalanceCallback() {
            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, final LSLeftCreditItem creditItem) {
                if (isSuccess && creditItem != null) {
                    // 更新本地信用点
                    LiveRoomCreditRebateManager.getInstance().setCredit(creditItem.balance);
                    LiveRoomCreditRebateManager.getInstance().setCoupon(creditItem.coupon);
                    LiveRoomCreditRebateManager.getInstance().setLiveChatCount(creditItem.liveChatCount);

                    runOnUiThread(new Thread() {
                        @Override
                        public void run() {
                            setTextMoneyData(creditItem.balance, creditItem.coupon + creditItem.liveChatCount);
                        }
                    });
                }
            }
        });
    }

    /**
     * 获取关注列表数据
     */
    private void queryFollowingList() {
        int start = 0;
        LiveRequestOperator.getInstance().GetFollowingLiveList(start, 5, new OnGetFollowingListCallback() {
            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, followingList);
                Message msg = Message.obtain();
                msg.what = GET_FOLLOWING_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

    }

    @Override
    public void onLogout(boolean isMannual) {
        finish();
    }
}
