package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
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
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.UserInfoUtil;
import com.qpidnetwork.livemodule.view.ProfileItemView;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 个人中心——直播
 * 2018/09/18 Hardy
 */
public class MyProfileActivity extends BaseFragmentActivity implements IAuthorizationListener {

    private static final int GET_FOLLOWING_CALLBACK = 1;    // 获取个人关注列表
    private static final int GET_PROFILE_CALLBACK = 2;      // 获取个人信息

    private SimpleDraweeView mIvUserIcon;
    private TextView mTvUserName;
    private TextView mTvUserAge;

    private RecyclerView mRvFollowView;
    private MyProfileFollowsAdapter mFollowsAdapter;


    private ProfileItemView mItemFollowView;
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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
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
//                    mRvFollowView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
//                    int height = mRvFollowView.getMeasuredHeight();
//                    Log.logD("info", "height:----->" + height);
//                    mRvFollowView.setTranslationY(-height);

                    mRvFollowView.setAlpha(0);
                    mRvFollowView.setVisibility(View.VISIBLE);
                    mRvFollowView.animate().alpha(1).setDuration(800).start();
                }
            }
        });


        // 信用点
        mItemCBView = (ProfileItemView) findViewById(R.id.my_profile_ll_Credit_Balance);
        mItemCBView.setOnClickListener(this);
        mItemCBView.setTextLeft("Credit Balance");
        mItemCBView.setBottomLineLeftMarginDefault();

        // 试用卷
        mItemLVView = (ProfileItemView) findViewById(R.id.my_profile_ll_Live_Vouchers);
        mItemLVView.setOnClickListener(this);
        mItemLVView.setTextLeft("Live Vouchers");

        // 设置
        mItemSettingsView = (ProfileItemView) findViewById(R.id.my_profile_ll_setting);
        mItemSettingsView.setOnClickListener(this);
        mItemSettingsView.setTextLeft("Settings");
        mItemSettingsView.setRightIcon2Arrow();
    }

    /**
     * 获取本地或者服务器数据
     */
    private void initData() {
        // load from local
        setUserInfoData();
        setTextMoneyData(LiveRoomCreditRebateManager.getInstance().getCredit(),
                LiveRoomCreditRebateManager.getInstance().getCoupon());

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
                boolean isGetProfileSuccess = false;

                if (responseProfile.isSuccess) {
                    LSProfileItem mProfileItem = (LSProfileItem) responseProfile.data;
                    if (mProfileItem != null) {
                        // 缓存数据
                        MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                        mTvUserName.setText(UserInfoUtil.getUserFullName(mProfileItem.firstname, mProfileItem.lastname));

                        isGetProfileSuccess = true;
                    }
                }

                // 如果获取不到，则取 firstName 显示
                if (!isGetProfileSuccess) {
                    LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                    if (loginItem != null) {
                        mTvUserName.setText(loginItem.nickName);
                    }
                }
                break;


            default:
                break;
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.my_profile_buttonCancel) {
            finish();
        } else if (id == R.id.my_profile_head_ll) {
            // 2018/9/19 跳转到 my profile 资料页
            MyProfileDetailNewLiveActivity.startAct(this);

        } else if (id == R.id.my_profile_iv_userIcon) {
            // TODO: 2018/9/19 头像大图,通知 QN 打开大图
//        if (mProfileItem == null) return;
//
////		if ( mProfileItem.showUpload() || !mProfileItem.showPhoto() ){
////			onClickImageViewTakePhoto(view);
////			return;
////		}
//
//        Intent intent = new Intent(this, MyProfilePhotoActivity.class);
//        if (mProfileItem != null) {
//            intent.putExtra("profile", mProfileItem);
////			intent.putExtra(MyProfilePhotoActivity.PHOTO_URL, mProfileItem.photoURL);
////			intent.putExtra(MyProfilePhotoActivity.TIPS, "")
//        }
//
//        startActivity(intent);
        } else if (id == R.id.my_profile_ll_my_follow) {
            // 2018/9/19 点击my follows列表回到首页并将标签定位至Follow

//            MainFragmentActivity.launchActivityWithListType(mContext, 1);
            MainFragmentActivity.launchActivityWithListType(mContext, MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_FOLLOW);
            finish();

        } else if (id == R.id.my_profile_ll_Credit_Balance) {
            // 2018/9/19  credit blance点击跳转至买点页面，android买点进入信用点订单B

            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlAddCredit = URL2ActivityManager.createAddCreditUrl("", "B30", "");
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

    private void setUserInfoData() {
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (loginItem != null) {
//            PicassoLoadUtil.loadUrl(mIvUserIcon, loginItem.photoUrl, R.drawable.ic_default_photo_man);
            //edit by Jagger 2018-11-9 压缩图片,以免网络慢显示时会黑
//            Picasso.with(mContext).load(loginItem.photoUrl)
//                    .resize(DisplayUtil.dip2px(mContext, 100),DisplayUtil.dip2px(mContext, 100))  //imageView是96DP,压缩时比它大一点点
//                    .centerCrop()
//                    .error(R.drawable.ic_default_photo_man)
//                    .memoryPolicy(MemoryPolicy.NO_CACHE)
//                    .noPlaceholder()
//                    .into(mIvUserIcon);
            int wh = DisplayUtil.dip2px(mContext, 100);
//            PicassoLoadUtil.loadUrlNoMCache(mIvUserIcon, loginItem.photoUrl, R.drawable.ic_default_photo_man, wh, wh);
            FrescoLoadUtil.loadUrl(mContext, mIvUserIcon, loginItem.photoUrl, wh,
                    R.drawable.ic_default_photo_man, true,
                    getResources().getDimensionPixelSize(R.dimen.live_size_4dp),
                    ContextCompat.getColor(mContext, R.color.white));

//            mTvUserName.setText(loginItem.nickName);  // 由接口获取全名
            mTvUserAge.setText(loginItem.userId);
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
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, final double balance, final int coupon) {
                if (isSuccess) {
                    // 更新本地信用点
                    LiveRoomCreditRebateManager.getInstance().setCredit(balance);
                    LiveRoomCreditRebateManager.getInstance().setCoupon(coupon);

                    runOnUiThread(new Thread() {
                        @Override
                        public void run() {
                            setTextMoneyData(balance, coupon);
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
//        if(isLoadMore){
//            start = mFollowingList.size();
//        }
        LiveRequestOperator.getInstance().GetFollowingLiveList(start, 5, new OnGetFollowingListCallback() {
            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, followingList);
                Message msg = Message.obtain();
                msg.what = GET_FOLLOWING_CALLBACK;
//                msg.arg1 = isLoadMore?1:0;
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
