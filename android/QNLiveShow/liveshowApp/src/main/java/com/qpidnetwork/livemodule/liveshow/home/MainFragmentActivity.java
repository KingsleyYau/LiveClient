package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.view.GravityCompat;
import android.support.v4.view.ViewPager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.listener.DialogUIListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSOtherVersionCheckItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.IMShowEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMProgramInfoItem;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechat.contact.OnChatUnreadUpdateCallback;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.RegisterActivity;
import com.qpidnetwork.livemodule.liveshow.home.menu.DrawerAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigerManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.manager.VersionCheckManager;
import com.qpidnetwork.livemodule.liveshow.personal.SettingsActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.util.BroadcastManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import io.reactivex.functions.Consumer;

public class MainFragmentActivity extends BaseFragmentActivity implements ViewPager.OnPageChangeListener,
        IAuthorizationListener, IMShowEventListener, ShowUnreadManager.OnShowUnreadListener,
        IMOtherEventListener, OnChatUnreadUpdateCallback {

    private static final String LAUNCH_URL = "launchUrl";
    private static final String CHANGE_WITE_TOKEN = "token";
    private static final String LAUNCH_PARAMS_LISTTYPE = "listType";
    private static final int OFF_SCREEN_PAGE_LIMIT = 2;    //VP预加载页面(2是为了避免用户疯狂切换，导致Fragment不断Create的问题)
    private final double DRAWER_WIDTH_IN_SCREEN = 0.85;     //左则菜单占屏幕宽度比

    //tab相关常量
//    private int TAB_SUM = 4;
//    private int TAB_INDEX_DISCOVER = 0;
//    private int TAB_INDEX_FOLLOW = 1;
//    private int TAB_INDEX_CALENDAR = 2;
//    private int TAB_INDEX_ME = 3;

    //UIHandler常量
    private final int UI_LOGIN_SUCCESS = 3001;
    private final int UI_LOGIN_FAIL = 3002;
    private final int UI_LOGOUT = 3003;

    //控件
//    private BottomNavigationViewEx mNavView;
//    private QBadgeView mQBadgeViewUnReadMe , mQBadgeViewUnReadCalendar;
//    private RelativeLayout mRlLoginLoading;
//    private LinearLayout mLoginLoading, mLoginFail;
//    private ButtonRaised mBtnRelogin;
    //    private BubbleDialog mBubbleDialogCalendar;
    private ViewPager viewPagerContent;
    //    private MainFragmentPagerAdapter mAdapter;
    private TabPageIndicator tabPageIndicator;
    private MainFragmentPagerAdapter4Top mAdapter;
    //控件－－左则菜单
    private DrawerLayout mDrawerLayout;
    private LinearLayout mLLDrawer;
    private RecyclerView mRvDrawer;
    private DrawerAdapter mDrawerAdapter;
    private LinearLayout mLLHeaderRoot;
    private CircleImageView mImgDrawerUserPhoto;
    public TextView mTvDrawerUserName;
    public TextView mTvDrawerUserId;
    public ImageView mImgDrawerUserLevel, mImgDrawerSetting;
    private View mViewDrawerChangeWebSite, mViewDrawerAddCredit;
    private TextView mTVDrawerAddCredits, mTvCurrCredits;

    //内容
    private boolean mNeedShowGuide = true;

    private int mCurrentPageIndex = 0;

    private boolean mIsDrawerOpen = false;          //抽屉是否打开标志

    private boolean hasItemClicked = false;//防止多次点击

    private String mQnToken = "";   //QN换站传入的Token

    //管理信用点及返点
    public LiveRoomCreditRebateManager mLiveRoomCreditRebateManager;

    /**
     * 外部启动Url跳转
     *
     * @param context
     * @param url
     * @return
     */
    public static void launchActivityWIthUrl(Context context, String token, String url) {
        Intent intent = new Intent(context, MainFragmentActivity.class);
        intent.putExtra(LAUNCH_URL, url);
        intent.putExtra(CHANGE_WITE_TOKEN, token);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
        }
    }

    /**
     * 内部启动或者返回
     *
     * @param context
     * @param listType
     */
    public static void launchActivityWithListType(Context context, int listType) {
        Intent intent = new Intent(context, MainFragmentActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(LAUNCH_PARAMS_LISTTYPE, listType);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
        }
    }

    /**
     * 外部启动Url跳转
     *
     * @param context
     * @return
     */
    public static void launchActivityWIthKickoff(Context context, String strKickOffTips) {
        //先回到MAIN
        Intent intent = new Intent(context, MainFragmentActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
        }
        //再去登录
        RegisterActivity.launchRegisterActivityWithDialog(context, strKickOffTips);
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setContentView(R.layout.activity_live_main);
        //
//        setTitle(getString(R.string.live_main_title), R.color.theme_default_black);
//        setTitleVisible(View.GONE);

        TAG = MainFragmentActivity.class.getSimpleName();

        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        //add by Jagger 2018-11-30
        //原本是在登录结果回调检测更新,
        //后来HOT LIST会调取同步配置接口, 同时会取得版本信息,
        //所以改在HOT LIST 初始化之前先监听同步配置, 检测更新, 提高优先级
        SynConfigerManager.getInstance(mContext).setSynConfigResultObserver(new Consumer<SynConfigerManager.ConfigResult>() {
            @Override
            public void accept(SynConfigerManager.ConfigResult configResult) throws Exception {
                doCheckUpdate();
            }
        });

        initView();

        parseIntent(getIntent());

//        setCenterUnReadNumAndStyle();

        //del by Jagger 2018-2-6 samson说不需要了
        //引导页
//        if(mNeedShowGuide){
//            showGuideView();
//        }

        //监听登录
        LoginManager.getInstance().register(this);

        IMManager.getInstance().registerIMShowEventListener(this);
        IMManager.getInstance().registerIMOtherEventListener(this);

        // 2018/9/28 Hardy
//        PushSettingManager.getInstance().registerLoginOrIMEvent();

        //根据数据 刷新UI
        refreshUI();

        initData();
    }

    /**
     *
     */
    private void initData(){
        //红点未读
        ShowUnreadManager.getInstance().registerUnreadListener(this);

        // 2018/11/20 Hardy
        ContactManager.getInstance().registerChatUnreadUpdateUpdate(this);

        //GA统计
        onAnalyticsPageSelected(1, mCurrentPageIndex);

        mLiveRoomCreditRebateManager = LiveRoomCreditRebateManager.getInstance();

        //判断是否根activity，否则通知关闭其他activity
        if (!isTaskRoot()) {
            Intent intent = new Intent(CommonConstant.ACTION_ACTIVITY_CLOSE);
//            sendBroadcast(intent);
            BroadcastManager.sendBroadcast(mContext,intent);
        }

        //自动登录
        doAutoLogin();
    }

    @Override
    protected void onResume() {
        super.onResume();
        hasItemClicked = false;
        Log.d(TAG, "onResume-hasItemClicked:" + hasItemClicked);
        //界面返回，判断有为显示的bubble时，显示冒泡
        if (mIMProgramInfoItem != null) {
            refreshShowUnreadStatus(true);
            mIMProgramInfoItem = null;
            mProgramPlayNoticeMessage = "";
        }

        //add by Jagger 2018-10-18 登录才刷新,减少请求数
        if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
            ShowUnreadManager.getInstance().refreshUnReadData();
            updateCredit();
            // 2018/11/20 Hardy
            updateChatUnread();
        }
    }

    /**
     * 更新信用点余额
     */
    public void updateCredit() {
        LiveRequestOperator.getInstance().GetAccountBalance(new OnGetAccountBalanceCallback() {
            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, final double balance, int coupon) {
                if (isSuccess) {
                    mLiveRoomCreditRebateManager.setCredit(balance);
                    // 2018/9/27 Hardy
                    mLiveRoomCreditRebateManager.setCoupon(coupon);

                    runOnUiThread(new Thread() {
                        @Override
                        public void run() {
//                            if (null != mDrawerAdapter) {
//                                mDrawerAdapter.updateCreditsView();
//                            }
                            doUpdateCreditView(true);
                        }
                    });
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        LoginManager.getInstance().unRegister(this);
        IMManager.getInstance().unregisterIMShowEventListener(this);
        IMManager.getInstance().unregisterIMOtherEventListener(this);
        ShowUnreadManager.getInstance().unregisterUnreadListener(this);

        // 2018/11/20 Hardy
        ContactManager.getInstance().unregisterChatUnreadUpdateUpdata(this);

        super.onDestroy();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        //解释参数
        parseIntent(intent);

        //自动登录
        doAutoLogin();
    }

    /**
     * 启动后，处理初始化数据
     *
     * @param intent
     */
    private void parseIntent(Intent intent) {
        Log.d(TAG, "parseIntent");
        Bundle bundle = intent.getExtras();
        String url = "";
        int defaultPage = 0;
        if (bundle != null) {
            if (bundle.containsKey(LAUNCH_URL)) {
                url = bundle.getString(LAUNCH_URL);
            }
            if (bundle.containsKey(LAUNCH_PARAMS_LISTTYPE)) {
                defaultPage = bundle.getInt(LAUNCH_PARAMS_LISTTYPE);
            }
            if (bundle.containsKey(CHANGE_WITE_TOKEN)) {
                mQnToken = bundle.getString(CHANGE_WITE_TOKEN);
                Log.i("Jagger", "MainFragmentActivity parseIntent mQnToken:" + mQnToken);
            }
        }

        //根据Url执行跳转
        if (!TextUtils.isEmpty(url)) {
            //url非指向当前main界面
            new AppUrlHandler(mContext).urlHandle(url);
            mNeedShowGuide = false;
        } else {

            // 2018/9/26 Hardy
            if (defaultPage > 0) {
                // nothing to do
            } else {
                defaultPage = URL2ActivityManager.getInstance().getMainListType(Uri.parse(url));
            }

            mNeedShowGuide = true;
        }

        //切换默认页
        if (defaultPage > 0 && defaultPage < getResources().getStringArray(R.array.topTabs).length) {
            viewPagerContent.setCurrentItem(defaultPage);
        } else {
            viewPagerContent.setCurrentItem(0);
        }
    }

    private void initView() {
        Log.d(TAG, "initView");

        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);
        viewPagerContent = (ViewPager) findViewById(R.id.viewPagerContent);
        //初始化viewpager
//        mAdapter = new MainFragmentPagerAdapter(this);
//        viewPagerContent.setAdapter(mAdapter);
//        //防止间隔点击会出现回收，导致Fragment onresume走出现刷新异常
//        viewPagerContent.setOffscreenPageLimit(2);
//
//        //新版本
//        //TAB
//        mNavView = (BottomNavigationViewEx)findViewById(R.id.navigation);
//        mNavView.enableAnimation(false);
//        mNavView.enableShiftingMode(false);
//        mNavView.enableItemShiftingMode(false);
//        mNavView.setIconUseSelector();
//        initEvent();
//
//        //ME未读数
//        mQBadgeViewUnReadMe = new QBadgeView(mContext);
//        //设置一些公共样式
//        mQBadgeViewUnReadMe
//                .setBadgeNumber(0)  //先隐藏, 因为初始化时取不到准确的坐标,会在右上角先显示一个图标,不好看
//                .setBadgeGravity(Gravity.END | Gravity.TOP)
//                .setShowShadow(false)//不要阴影
//                .bindTarget(mNavView.getBottomNavigationItemView(MainFragmentPagerAdapter.TABS.TAB_INDEX_ME.ordinal()));
//                //打开拖拽消除模式并设置监听
////                .setOnDragStateChangedListener(new Badge.OnDragStateChangedListener() {
////                    @Override
////                    public void onDragStateChanged(int dragState, Badge badge, View targetView) {
//////                        if (Badge.OnDragStateChangedListener.STATE_SUCCEED == dragState)
//////                            Toast.makeText(BadgeViewActivity.this, R.string.tips_badge_removed, Toast.LENGTH_SHORT).show();
////                    }
////                });
//
//        //Calendar未读数
//        mQBadgeViewUnReadCalendar = new QBadgeView(mContext);
//        //设置一些公共样式
//        mQBadgeViewUnReadCalendar
//                .setBadgeNumber(0)  //先隐藏, 因为初始化时取不到准确的坐标,会在右上角先显示一个图标,不好看
//                .setBadgeGravity(Gravity.END | Gravity.TOP)
//                .setShowShadow(false)//不要阴影
//                .bindTarget(mNavView.getBottomNavigationItemView(MainFragmentPagerAdapter.TABS.TAB_INDEX_CALENDAR.ordinal()));

        //初始化ViewPage Adapter
        mAdapter = new MainFragmentPagerAdapter4Top(this);
        viewPagerContent.setAdapter(mAdapter);
        //防止间隔点击会出现回收，导致Fragment onresume走出现刷新异常
        viewPagerContent.setOffscreenPageLimit(OFF_SCREEN_PAGE_LIMIT);

        //初始化Tab
        tabPageIndicator.setViewPager(viewPagerContent);
        //设置每个ITEM宽与字体相同,注:一定要在setIndicatorMode前
        tabPageIndicator.setSameLine(true);
        // 设置控件的模式，一定要先设置模式
        tabPageIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_NOWEIGHT_EXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tabPageIndicator.setDividerColor(Color.TRANSPARENT);
        //设置页面切换处理
        tabPageIndicator.setOnPageChangeListener(this);
        findViewById(R.id.fl_menu).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mDrawerLayout.openDrawer(GravityCompat.START);
            }
        });

        //左则菜单
        mDrawerAdapter = new DrawerAdapter(mContext);
        mDrawerAdapter.setOnItemClickListener(new MyOnItemClickListener());
        mDrawerLayout = (DrawerLayout) findViewById(R.id.dl_main);
        mDrawerLayout.addDrawerListener(new DrawerLayout.DrawerListener() {
            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                Log.d(TAG, "onDrawerSlide");
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                Log.d(TAG, "onDrawerOpened");
                //更新左侧导航菜单栏未读红点数据
                if (null != mDrawerAdapter) {
                    updateUnReadDataOnLeftMenu();

                    // 2018/11/20 Hardy
                    updateChatUnread();
                }
                //柜桶是否打开标志
                mIsDrawerOpen = true;
                // 统计左侧页
                onAnalyticsPageSelected(0);
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                Log.d(TAG, "onDrawerStateChanged");
                if (mIsDrawerOpen) {
                    //柜桶是否打开标志
                    mIsDrawerOpen = false;
                    // 统计主界面页
                    onAnalyticsPageSelected(1, mCurrentPageIndex);
                }
            }

            @Override
            public void onDrawerStateChanged(int newState) {
                Log.d(TAG, "onDrawerStateChanged-newState:" + newState);
            }
        });

        //左则菜单－－整个布局
        mLLDrawer = (LinearLayout) findViewById(R.id.ll_drawer);
        ViewGroup.LayoutParams paraDrawer = mLLDrawer.getLayoutParams();
        paraDrawer.width = (int) (DisplayUtil.getScreenWidth(mContext) * DRAWER_WIDTH_IN_SCREEN);
        mLLDrawer.setLayoutParams(paraDrawer);

        //左则菜单－－列表
        mRvDrawer = (RecyclerView) findViewById(R.id.rv_drawer);
        mRvDrawer.setLayoutManager(new LinearLayoutManager(this));
        mRvDrawer.setAdapter(mDrawerAdapter);

        //左则菜单－－ 个人资料
        mLLHeaderRoot = (LinearLayout) findViewById(R.id.ll_header_root);
        mLLHeaderRoot.setLayerType(View.LAYER_TYPE_SOFTWARE, null); //头像网络慢有时为黑:https://blog.csdn.net/huyawenz/article/details/78863636
        //留出状态栏高度
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            ((LinearLayout.LayoutParams) mLLHeaderRoot.getLayoutParams()).topMargin += DisplayUtil.getStatusBarHeight(mContext);
        }
        mLLHeaderRoot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doShowMyProfile();
            }
        });

        //左则菜单－－人头
        mImgDrawerUserPhoto = (CircleImageView) findViewById(R.id.civ_userPhoto);

        //左则菜单－－个人资料
        mImgDrawerSetting = (ImageView) findViewById(R.id.img_setting);
        mImgDrawerSetting.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doShowSetting();
            }
        });
        mTvDrawerUserName = (TextView) findViewById(R.id.tv_userName);
        mTvDrawerUserId = (TextView) findViewById(R.id.tv_userId);
        mImgDrawerUserLevel = (ImageView) findViewById(R.id.iv_userLevel);
        mImgDrawerUserLevel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showMyLevelDetailWebView();
            }
        });

        //左则菜单－－换站
        mViewDrawerChangeWebSite = findViewById(R.id.ll_changeWebSite);
        mViewDrawerChangeWebSite.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doChangeWebsite();
            }
        });

        //左则菜单－－买点
        mViewDrawerAddCredit = findViewById(R.id.ll_credit_drawer);
        mViewDrawerAddCredit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                addCredits();
            }
        });
        mTVDrawerAddCredits = (TextView) findViewById(R.id.tv_addCredits);
        mTVDrawerAddCredits.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                addCredits();
            }
        });
        mTvCurrCredits = (TextView) findViewById(R.id.tv_currCredits);

//        //登录遮罩
//        mRlLoginLoading = (RelativeLayout) findViewById(R.id.rl_login_loading);
//        mRlLoginLoading.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                //什么都不用做, 只是为了不让用户点到后面的列表
//            }
//        });
//        mLoginLoading = (LinearLayout) findViewById(R.id.ll_main_login);
//        mLoginFail = (LinearLayout) findViewById(R.id.ll_main_login_fail);
//        mBtnRelogin = (ButtonRaised) findViewById(R.id.btn_reload);
//        mBtnRelogin.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                showLoging();
//
//                LoginManager.getInstance().reLogin();
//            }
//        });
    }

    //------------------ 登录遮罩 --------------------
//    private void showLoging() {
//        mRlLoginLoading.setVisibility(View.VISIBLE);
//        mLoginLoading.setVisibility(View.VISIBLE);
//        mLoginFail.setVisibility(View.GONE);
//    }
//
//    private void showLoginFail() {
//        mRlLoginLoading.setVisibility(View.VISIBLE);
//        mLoginLoading.setVisibility(View.GONE);
//        mLoginFail.setVisibility(View.VISIBLE);
//    }
//
//    private void showLoginSuccess() {
//        mRlLoginLoading.setVisibility(View.GONE);
//        mLoginLoading.setVisibility(View.VISIBLE);
//        mLoginFail.setVisibility(View.GONE);
//    }
    //----------------end 登录遮罩 --------------------

    /**
     * 自动登录
     */
    private void doAutoLogin() {
        //token登录
        if (!TextUtils.isEmpty(mQnToken)) {
            LoginManager.getInstance().loginByToken(mQnToken);
            mQnToken = "";
        } else {
            //自动登录
            LoginManager.getInstance().autoLogin();
        }
    }


    /**
     * drawer(左则菜单) item 点击事件
     */
    private class MyOnItemClickListener implements DrawerAdapter.OnItemClickListener {

        @Override
        public void itemClick(DrawerAdapter.DrawerItemNormal drawerItemNormal) {
            switch (drawerItemNormal.id) {
                case DrawerAdapter.ITEM_ID_CHAT:
                    showChatListActivity();
                    break;

                case DrawerAdapter.ITEM_ID_MESSAGE: {
                    showMessageListActivity();
                }
                break;
                case DrawerAdapter.ITEM_ID_MAIL: {
                    showEmfListWebView();
                }
                break;
                case DrawerAdapter.ITEM_ID_GREETS: {//意向信
                    showLoiListWebView();
                }
                break;
                case DrawerAdapter.ITEM_ID_SHOWTICKETS:
                    if (!hasItemClicked) {
                        hasItemClicked = true;
//                        MyTicketsActivity.launchMyTicketsActivity(MainFragmentActivity.this,0);

                        //edit by Jagger 2018-9-21 使用URL方式跳转
                        String urlMyTickets = URL2ActivityManager.createMyTickets(0);
                        new AppUrlHandler(mContext).urlHandle(urlMyTickets);
                    }
                    break;
                case DrawerAdapter.ITEM_ID_BOOKS:
                    if (!hasItemClicked) {
                        hasItemClicked = true;
//                        ScheduleInviteActivity.launchScheduleListActivity(MainFragmentActivity.this,0);

                        //edit by Jagger 2018-9-21 使用URL方式跳转
                        String urlMyBooking = URL2ActivityManager.createScheduleInviteActivity(1);
                        new AppUrlHandler(mContext).urlHandle(urlMyBooking);
                    }
                    break;
                case DrawerAdapter.ITEM_ID_BACKPACK:
                    if (!hasItemClicked) {
                        hasItemClicked = true;
//                        MyPackageActivity.launchMyPackageActivity(MainFragmentActivity.this,0);

                        //edit by Jagger 2018-9-21 使用URL方式跳转
                        String urlMyBackpack = URL2ActivityManager.createMyBackpackActivity(0);
                        new AppUrlHandler(mContext).urlHandle(urlMyBackpack);
                    }
                    break;

            }

//            postUiRunnableDelayed(new Runnable() {
//                @Override
//                public void run() {
//                    mDrawerLayout.closeDrawer(GravityCompat.START);
//                    onMenuClickDrawerCloseAnalytics();
//                }
//            }, 1000);
            delayDismissDrawableLayout();
        }

        @Override
        public void onChangeWebsiteClicked() {
            doChangeWebsite();
        }

        @Override
        public void onShowMyProfileClicked() {
            if (!hasItemClicked) {
                hasItemClicked = true;
                doShowMyProfile();
            }
        }

        @Override
        public void onAddCreditsClicked() {
            addCredits();
        }

        @Override
        public void onShowLevelDetailClicked() {
            if (!hasItemClicked) {
                hasItemClicked = true;
                showMyLevelDetailWebView();
            }
        }

        @Override
        public void onWebSiteChoose(WebSiteBean webSiteBean) {
            if (webSiteBean != null && !hasItemClicked) {
                hasItemClicked = true;
                LiveModule.getInstance().doChangeWebSite(webSiteBean);
            }
        }
    }

    private void delayDismissDrawableLayout() {
        postUiRunnableDelayed(new Runnable() {
            @Override
            public void run() {
                mDrawerLayout.closeDrawer(GravityCompat.START);
                onMenuClickDrawerCloseAnalytics();
            }
        }, 1000);
    }

    /**
     * 点击买点响应
     */
    public void addCredits() {
        if (!hasItemClicked) {
            hasItemClicked = true;
            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlAddCredit = URL2ActivityManager.createAddCreditUrl("", "B30", "");
            new AppUrlHandler(this).urlHandle(urlAddCredit);
        }
    }

    public void showMessageListActivity() {
        if (!hasItemClicked) {
            hasItemClicked = true;
            //私信
//            Intent intent = new Intent(MainFragmentActivity.this, MessageContactListActivity.class);
//            startActivity(intent);

            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlMessageList = URL2ActivityManager.createMessageListUrl();
            new AppUrlHandler(this).urlHandle(urlMessageList);
        }
    }

    public void showChatListActivity() {
        if (!hasItemClicked) {
            hasItemClicked = true;

            //edit by Hardy 2018-11-17 使用URL方式跳转
            String urlMessageList = URL2ActivityManager.createLiveChatListUrl();
            new AppUrlHandler(this).urlHandle(urlMessageList);

            //test
//            LiveChatTalkActivity.launchChatActivity(mContext, "1" , "name", "");
        }
    }


    /**
     * 跳转用户等级说明界面
     */
    private void showMyLevelDetailWebView() {
        if (LoginManager.getInstance().getSynConfig() != null) {
            startActivity(WebViewActivity.getIntent(this,
                    getResources().getString(R.string.my_level_title),
                    WebViewActivity.UrlIntent.View_Audience_Level,
                    null, true));
        }
    }

    /**
     * 跳转到意向信列表界面
     */
    public void showLoiListWebView() {
        if (!hasItemClicked) {
            hasItemClicked = true;
//            startActivity(WebViewActivity.getIntent(MainFragmentActivity.this,
//                    getResources().getString(R.string.live_webview_greet_mail_title),
//                    WebViewActivity.UrlIntent.View_Loi_List,
//                    null,
//                    true));

            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlLoiList = URL2ActivityManager.createGreetMailList();
            new AppUrlHandler(this).urlHandle(urlLoiList);
        }
    }

    /**
     * 查看主播来信
     */
    public void showEmfListWebView() {
        if (!hasItemClicked) {
            hasItemClicked = true;
//            startActivity(WebViewActivity.getIntent(MainFragmentActivity.this,
//                    getResources().getString(R.string.live_webview_mail_title),
//                    WebViewActivity.UrlIntent.View_Emf_List,
//                    null,
//                    true));

            //edit by Jagger 2018-9-21 使用URL方式跳转
            String urlMailList = URL2ActivityManager.createMailList();
            new AppUrlHandler(this).urlHandle(urlMailList);
        }
    }

    /**
     * 根据数据 刷新UI
     */
    private void refreshUI() {
        //如果登录中, 只看到loading
        if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logining) {
//            showLoging();
            doUpdateHeaderView(false);
            doUpdateCreditView(false);
        } else if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Default) {
//            showLoginFail();
            doUpdateHeaderView(false);
            doUpdateCreditView(false);
        } else {
//            showLoginSuccess();
            doUpdateHeaderView(true);
            doUpdateCreditView(true);
        }
    }

    /**
     * viewpager与nav之间的事件
     */
//    private void initEvent() {
//        // set listener to change the current item of view pager when click bottom nav item
//        mNavView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
//            private int previousItemId = -1;
//
//            @Override
//            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
//                // you can write as above.
//                // I recommend this method. You can change the item order or counts without update code here.
//                int tempItemId = item.getItemId();
//                if (previousItemId != tempItemId) {
//                    // only set item when item changed
//                    previousItemId = tempItemId;
//
//                    if(previousItemId == R.id.navigation_discover){
//                        viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_INDEX_DISCOVER.ordinal());
//                        return true;
//                    }else if(previousItemId == R.id.navigation_follow){
//                        viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_INDEX_FOLLOW.ordinal());
//                        return true;
//                    }
//                    else if(previousItemId == R.id.navigation_me){
//                        viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_INDEX_ME.ordinal());
//                        //代表每次切换到PersonalCenterFragment都要刷新数据
//                        //要配合MainFragmentPagerAdapter.getItemPosition()实现
//                        //del by Jagger 移到setUserVisibleHint处理
////                        mAdapter.notifyDataSetChanged();
//                        return true;
//                    }else if(previousItemId == R.id.navigation_calendar){
//                        viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_INDEX_CALENDAR.ordinal());
//                        return true;
//                    }
//                }
//                return true;
//            }
//        });
//
//        // set listener to change the current checked item of bottom nav when scroll view pager
//        viewPagerContent.addOnPageChangeListener(this);
//    }

    /**
     * 显示未读数目
     */
    private void setCenterUnReadNumAndStyle() {
//        //刷新邀请未读数目
//        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
//        //刷新背包未读数目
//        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
//
//
////        if(null == inviteItem || inviteItem.total == 0) {
////            if(null == packageItem || packageItem.total == 0){
////                setUnReadHide(mQBadgeViewUnReadMe);
////            }else {
////                //没指定数目时,显示一个小小的红点
////                setUnReadTag(mQBadgeViewUnReadMe);
////            }
////        }else {
////            //大于99时,显示99+
////            String strUnreadText = inviteItem.total > 99? "99+":String.valueOf(inviteItem.total);
////            //因为要在Nav画好后,才可以取得NavItem的宽, 所以要重设置位置
////            setUnReadText(mQBadgeViewUnReadMe, strUnreadText);
////        }
    }

//    /**
//     * 隐藏 未读
//     */
//    private void setUnReadHide(QBadgeView qBadgeView){
//        //不显示
//        qBadgeView.setBadgeNumber(0);
//    }
//
//    /**
//     * 未读显示为 红点
//     */
//    private void setUnReadTag(QBadgeView qBadgeView){
//        //因为要在Nav画好后,才可以取得NavItem的宽, 所以要重设置位置
//        qBadgeView.setGravityOffset(getUnReadNumOffset("0"), 5, true)
//                .setBadgePadding(5, true);
//
//        qBadgeView.setBadgeText("");
//    }
//
//    /**
//     * 未读显示 内容
//     * @param text
//     */
//    private void setUnReadText(QBadgeView qBadgeView, String text){
//        //重设部分样式
//        //因为要在Nav画好后,才可以取得NavItem的宽, 所以要重设置位置
//        qBadgeView.setGravityOffset(getUnReadNumOffset(text), 5, true)
//                .setBadgeTextSize(10 ,true)
//                .setBadgePadding(2 , true);
//
//        qBadgeView.setBadgeText(text);
//    }
//
//    /**
//     * 计算未读红点 右偏移, 以文字内容大小向左移
//     * @return
//     */
//    private int getUnReadNumOffset(String text){
//        Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
//        int textWidth = (int)textPaint.measureText(text);
//
//        int offset = 0;
//        //取其中一个TabItem的宽来计算
//        BottomNavigationItemView v = mNavView.getBottomNavigationItemView(MainFragmentPagerAdapter.TABS.TAB_INDEX_ME.ordinal());
//        offset = v.getWidth()/3 - textWidth;    //画在居右1/3的位置
//        offset = DisplayUtil.px2dip(mContext , offset);
//        return offset;
//    }

    /**
     * 切换到页
     *
     * @param pageId
     */
    public void setCurrentPager(int pageId) {
        viewPagerContent.setCurrentItem(pageId);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        //换站
        if (i == R.id.btn_main_title_back) {
//            finish();
            doChangeWebsite();
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            //按返回键回桌面
            moveTaskToBack(true);
            //发送广播，模似HOME键，BaseFragment要处理HOME键事件
            // 2018/12/19 Hardy 这里不需修改成 App 广播，由于该 aciton 是监听系统 home 键的点击事件，故这里不做处理
            sendBroadcast(new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS));
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 被踢提示
     */
    private void showKickOffDialog() {
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setCancelable(false);
        dialog.setMessage("Your account logined on another device. Please login again.");
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainFragmentActivity.this, PeacockActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                finish();
            }
        }));
        dialog.show();
    }

    /**
     * 换站
     * （QN换站弹出框）
     */
    private void doChangeWebsite() {
        if (!hasItemClicked) {
            hasItemClicked = true;
            LiveModule.getInstance().onChangeWebsiteDialogShow(this);
        }
    }

    /**
     * 打开QN个人资料
     */
    private void doShowMyProfile() {
        if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
            // 2018/9/18 Hardy
            //edit by Jagger 2018-9-28 使用URL方式跳转
            String urlMyProfileList = URL2ActivityManager.createMyProfile();
            URL2ActivityManager.getInstance().URL2Activity(mContext, urlMyProfileList);
        } else {
            RegisterActivity.launchRegisterActivity(mContext, null);
        }
        delayDismissDrawableLayout();
    }

    /**
     * 打开设置
     */
    private void doShowSetting() {
        SettingsActivity.startAct(this);
        delayDismissDrawableLayout();
    }

    /**
     * 更新左则菜单个人资料
     *
     * @param isLogin
     */
    private void doUpdateHeaderView(boolean isLogin) {
        if (isLogin) {
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            if (null != loginItem) {
//                Picasso.with(mContext).load(loginItem.photoUrl)
//                        .resize(DisplayUtil.dip2px(mContext, 70),DisplayUtil.dip2px(mContext, 70))  //imageView是68DP,压缩时比它大一点点
//                        .centerCrop()
//                        .error(R.drawable.ic_default_photo_man)
//                        .memoryPolicy(MemoryPolicy.NO_CACHE)
//                        .noPlaceholder()
//                        .into(mImgDrawerUserPhoto);
                int wh = DisplayUtil.dip2px(mContext, 70);
                PicassoLoadUtil.loadUrlNoMCache(mImgDrawerUserPhoto, loginItem.photoUrl, R.drawable.ic_default_photo_man, wh, wh);

                mTvDrawerUserName.setText(loginItem.nickName);
                mTvDrawerUserName.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                    }
                });
                mTvDrawerUserId.setText(loginItem.userId);
                mImgDrawerUserLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(mContext, loginItem.level));
            }
        } else {
            mTvDrawerUserName.setText(getString(R.string.txt_login));
            mTvDrawerUserName.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    RegisterActivity.launchRegisterActivity(mContext);
                }
            });
            mTvDrawerUserId.setText("");
            mImgDrawerUserLevel.setImageDrawable(null);
//            mImgDrawerUserPhoto.setImageResource(R.drawable.ic_default_photo_man);
//            Picasso.with(mContext).load(R.drawable.ic_default_photo_man).into(mImgDrawerUserPhoto);
            PicassoLoadUtil.loadRes(mImgDrawerUserPhoto, R.drawable.ic_default_photo_man);

        }
    }

    /**
     * 更新左则菜单信用点
     *
     * @param isLogin
     */
    private void doUpdateCreditView(boolean isLogin) {
        if (isLogin) {
            LiveRoomCreditRebateManager liveRoomCreditRebateManager = LiveRoomCreditRebateManager.getInstance();
            String currCredits = ApplicationSettingUtil.formatCoinValue(liveRoomCreditRebateManager.getCredit());
            mTvCurrCredits.setText(mContext.getResources().getString(R.string.left_menu_credits_balance, currCredits));
        } else {
            mTvCurrCredits.setText(mContext.getResources().getString(R.string.left_menu_credits_balance, "0"));
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            //登录成功
            case UI_LOGIN_SUCCESS: {
//                showLoginSuccess();
                if (mAdapter.getCurrentFragment() instanceof HotListFragment) {
                    ((HotListFragment) mAdapter.getCurrentFragment()).reloadData();
                }
                //更新头像昵称ID
//                if(null != mDrawerAdapter){
//                    mDrawerAdapter.updateHeaderView();
//                }
                doUpdateHeaderView(true);
                doUpdateCreditView(true);

                //检测更新(因为登录时才会去拿同步配置)
//                doCheckUpdate();
            }
            break;
            case UI_LOGOUT:
//                showLoginFail();

                //更新头像昵称ID
                doUpdateHeaderView(false);
                doUpdateCreditView(false);
                break;
        }
    }


    /************************************  ViewPager切换事件  *******************************************/
    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        //记录当前选中页
        mCurrentPageIndex = position;
//        if(mCurrentPageIndex == 2){
//            //当前选中calendar，清除冒泡
//            hideCalendarBubble();
//        }

        //viewpager与tab事件绑定
//        mNavView.setCurrentItem(position);

        //GA统计
        onAnalyticsPageSelected(1, position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }

    /************************************  认证登录事件回调  *******************************************/
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        if (isSuccess) {
//            //监听一次即可
//            LoginManager.getInstance().unRegister(this);

            //更新UI
            sendEmptyUiMessage(UI_LOGIN_SUCCESS);
        }
//        }
// else {
//            //更新UI
//            sendEmptyUiMessage(UI_LOGIN_FAIL);
//        }
    }

    @Override
    public void onLogout(boolean isMannual) {
        //更新UI
        sendEmptyUiMessage(UI_LOGOUT);
    }

    /************************************  节目未读事件通知  *******************************************/
    private boolean mIsProgramHasUnread = false;        //标记节目是否有未读

    /**
     * 获取节目未读状态
     *
     * @return
     */
    public boolean getProgramHasUnread() {
        return mIsProgramHasUnread;
    }

    /**
     * 刷新节目未读状态
     *
     * @param isHasShowTicketsUnRead
     */
    public void refreshShowUnreadStatus(boolean isHasShowTicketsUnRead) {
        Log.d(TAG, "refreshShowUnreadStatus-isHasShowTicketsUnRead:" + isHasShowTicketsUnRead);
        mIsProgramHasUnread = isHasShowTicketsUnRead;
//        if(unreadNum > 0){
//            setUnReadTag(mQBadgeViewUnReadCalendar);
//        }else{
//            setUnReadHide(mQBadgeViewUnReadCalendar);
//        }
        tabPageIndicator.updateTabDiginalHint(2, mIsProgramHasUnread, true, 0);
    }

    /************************************  节目开始结束退票事件通知  *******************************************/
    private IMProgramInfoItem mIMProgramInfoItem;
    private String mProgramPlayNoticeMessage = "";

    @Override
    public void OnRecvProgramPlayNotice(final IMProgramInfoItem showinfo, final IMClientListener.IMProgramPlayType type, final String msg) {
        Log.d(TAG, "OnRecvProgramPlayNotice-showinfo:" + showinfo + " type:" + type + " msg:" + msg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (type != IMClientListener.IMProgramPlayType.Unknown && (showinfo != null)) {
                    //收到关注开播处理
                    //Modify by Harry 2018年8月3日 15:54:29 按照原型:
                    // 推送购票/关注节目开播通知时同时出现未读红点
                    // （若刚好停留在calendar页，红点仍会显示，切换到其他tab重新进入或下拉刷新列表后红点消失）
//                    if(mCurrentPageIndex != 2){
                    if (isActivityVisible()) {
                        refreshShowUnreadStatus(true);
                    } else {
                        //不在当前界面，存放本地数据用于返回显示即可
                        mIMProgramInfoItem = showinfo;
                        mProgramPlayNoticeMessage = msg;
                    }
//                    }
                }
            }
        });
    }

    /**
     * 解决点击菜单跳转功能页面时，调用closeDrawer会出现延迟回调onDrawerClosed（activity resume时才回调），
     * 导致GA统计异常
     */
    public void onMenuClickDrawerCloseAnalytics() {
        if (mIsDrawerOpen) {
            mIsDrawerOpen = false;
            // 统计主界面页
            onAnalyticsPageSelected(1, mCurrentPageIndex);
        }
    }

    /**
     * 检测更新
     */
    private void doCheckUpdate() {
        final LSOtherVersionCheckItem versionCheckItem = VersionCheckManager.getInstance(mContext).getVersionInfoCache();
        if (versionCheckItem != null) {
            //如果有更新信息
            if (versionCheckItem.isForceUpdate) {
                if (versionCheckItem.verCode > SystemUtils.getVersionCode(mContext)) {
                    VersionCheckManager.getInstance(mContext).showUpdateDialog(this, new DialogUIListener() {
                        @Override
                        public void onPositive() {
                            finish();
                            System.exit(9);
                        }

                        @Override
                        public void onNegative() {
                            Uri uri = Uri
                                    .parse(versionCheckItem.storeUrl);
                            Intent intent = new Intent();
                            intent.setAction(Intent.ACTION_VIEW);
                            intent.setData(uri);
                            startActivity(intent);
                            finish();
                            System.exit(9);
                        }
                    });
                }
            }
        }
    }

    //=================================红点未读展示逻辑===================================

    private void updateUnReadDataOnLeftMenu() {
        //del by Jagger 2018-10-26 登录/注销都要刷新界面
//        if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
        int unreadNum = ShowUnreadManager.getInstance().getMsgUnReadNum();
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_MESSAGE, unreadNum);
        unreadNum = ShowUnreadManager.getInstance().getMailUnReadNum();
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_MAIL, unreadNum);
        unreadNum = ShowUnreadManager.getInstance().getGreetMailUnReadNum();
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_GREETS, unreadNum);
        unreadNum = ShowUnreadManager.getInstance().getShowTicketUnreadNum();
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_SHOWTICKETS, unreadNum);
        unreadNum = ShowUnreadManager.getInstance().getBackpackUnreadNum();
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_BACKPACK, unreadNum);
        unreadNum = ShowUnreadManager.getInstance().getBookingUnReadNum();
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_BOOKS, unreadNum);

        // 2018/11/16 Hardy
//        unreadNum = ShowUnreadManager.getInstance().getBookingUnReadNum();
//        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_CHAT, unreadNum);
//        }
    }

    @Override
    public void onUnReadDataUpdate() {
        Log.d(TAG, "onUnReadDataUpdate");
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateUnReadDataOnLeftMenu();
            }
        });
    }


    //===================   2018/11/20  Hardy   LiveChat 未读数刷新逻辑 ================
    private void updateChatUnread(int unreadChatCount, int unreadInviteCount) {
        mDrawerAdapter.showUnReadNum(DrawerAdapter.ITEM_ID_CHAT, unreadChatCount);
    }

    private void updateChatUnread() {
        updateChatUnread(ContactManager.getInstance().getAllUnreadCount(),
                ContactManager.getInstance().getInviteListSize());
    }

    @Override
    public void onUnreadUpdate(final int unreadChatCount, final int unreadInviteCount) {
        Log.d(TAG, "onUnreadUpdate: ");
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateChatUnread(unreadChatCount, unreadInviteCount);
            }
        });
    }
    //===================   2018/11/20  Hardy   LiveChat 未读数刷新逻辑 ================

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG, "OnLogin-errType:" + errType + " errMsg:" + errMsg);
        if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //断线重登陆刷新本地未读红点数据到主界面
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    updateCredit();
                }
            });
        }
    }

    @Override
    public void OnRecvCancelProgramNotice(IMProgramInfoItem showinfo) {

    }

    @Override
    public void OnRecvRetTicketNotice(IMProgramInfoItem showinfo, double leftCredit) {

    }

    @Override
    public void onShowUnreadUpdate(int unreadNum) {

    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {

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
}
