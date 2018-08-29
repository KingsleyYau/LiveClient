package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
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
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.httprequest.item.UserType;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.IMShowEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMProgramInfoItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.guide.GuideActivity;
import com.qpidnetwork.livemodule.liveshow.home.menu.DrawerAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.message.MessageContactListActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.liveshow.personal.tickets.MyTicketsActivity;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;

public class MainFragmentActivity extends BaseActionBarFragmentActivity implements ScheduleInvitePackageUnreadManager.OnUnreadListener,
        ViewPager.OnPageChangeListener , IAuthorizationListener, IMShowEventListener, ShowUnreadManager.OnShowUnreadListener,IMOtherEventListener {

    private static final String LAUNCH_URL = "launchUrl";
    private static final String LAUNCH_PARAMS_LISTTYPE = "listType";
    private static final int OFF_SCREEN_PAGE_LIMIT = 2;    //VP预加载页面(2是为了避免用户疯狂切换，导致Fragment不断Create的问题)

    //tab相关常量
//    private int TAB_SUM = 4;
//    private int TAB_INDEX_DISCOVER = 0;
//    private int TAB_INDEX_FOLLOW = 1;
//    private int TAB_INDEX_CALENDAR = 2;
//    private int TAB_INDEX_ME = 3;

    //UIHandler常量
    private final int UI_LOGIN_SUCCESS = 3001;
    private final int UI_LOGIN_FAIL = 3002;

    //控件
//    private BottomNavigationViewEx mNavView;
//    private QBadgeView mQBadgeViewUnReadMe , mQBadgeViewUnReadCalendar;
    private RelativeLayout mRlLoginLoading;
    private LinearLayout mLoginLoading , mLoginFail;
    private ButtonRaised mBtnRelogin;
//    private BubbleDialog mBubbleDialogCalendar;
    private ViewPager viewPagerContent;
//    private MainFragmentPagerAdapter mAdapter;
    private TabPageIndicator tabPageIndicator;
    private MainFragmentPagerAdapter4Top mAdapter;
    private DrawerLayout mDrawerLayout;
    private RecyclerView mRvDrawer;
    private DrawerAdapter mDrawerAdapter;

    //内容
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;
    private boolean mNeedShowGuide = true;

    private int mCurrentPageIndex = 0;

    private boolean mIsDrawerOpen = false;          //抽屉是否打开标志

    private boolean hasItemClicked = false;//防止多次点击

    //管理信用点及返点
    public LiveRoomCreditRebateManager mLiveRoomCreditRebateManager;

  /**
     * 外部启动Url跳转
     * @param context
     * @param url
     * @return
     */
    public static void launchActivityWIthUrl(Context context, String url){
        Intent intent = new Intent(context, MainFragmentActivity.class);
        intent.putExtra(LAUNCH_URL, url);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        if(context instanceof Activity){
            ((Activity)context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
        }
    }

    /**
     * 内部启动或者返回
     * @param context
     * @param listType
     */
    public static void launchActivityWithListType(Context context, int listType){
        Intent intent = new Intent(context, MainFragmentActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(LAUNCH_PARAMS_LISTTYPE, listType);
        context.startActivity(intent);
        if(context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.anim_activity_fade_in, R.anim.anim_activity_fade_out);
        }
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_live_main);
        //
//        setTitle(getString(R.string.live_main_title), R.color.theme_default_black);
        setTitleVisible(View.GONE);

        TAG = MainFragmentActivity.class.getSimpleName();

        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        initView();

        parseIntent(getIntent());
        //服务启动
        if(LiveService.getInstance() == null){
            //crash异常启动退回home页面
            finish();
        }else{
            LiveService.getInstance().onServiceStart();
        }

        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
        setCenterUnReadNumAndStyle();

        //del by Jagger 2018-2-6 samson说不需要了
        //引导页
//        if(mNeedShowGuide){
//            showGuideView();
//        }

        //监听登录
        LoginManager.getInstance().register(this);

        IMManager.getInstance().registerIMShowEventListener(this);
        IMManager.getInstance().registerIMOtherEventListener(this);

        //根据数据 刷新UI
        refreshUI();

        //红点未读
        ShowUnreadManager.getInstance().registerUnreadListener(this);

        //GA统计
        onAnalyticsPageSelected(1, mCurrentPageIndex);

        mLiveRoomCreditRebateManager = LiveRoomCreditRebateManager.getInstance();
    }

    @Override
    protected void onResume() {
        super.onResume();
        hasItemClicked = false;
        Log.d(TAG,"onResume-hasItemClicked:"+hasItemClicked);
        //界面返回，判断有为显示的bubble时，显示冒泡
        if(mIMProgramInfoItem != null){
            refreshShowUnreadStatus(true);
            mIMProgramInfoItem = null;
            mProgramPlayNoticeMessage = "";
        }
        ShowUnreadManager.getInstance().refreshUnReadData();
        updateCredit();
    }

    /**
     * 更新信用点余额
     */
    public void updateCredit(){
        LiveRequestOperator.getInstance().GetAccountBalance(new OnGetAccountBalanceCallback() {
            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, final double balance) {
                if(isSuccess){
                    mLiveRoomCreditRebateManager.setCredit(balance);
                    runOnUiThread(new Thread(){
                        @Override
                        public void run() {
                            if(null != mDrawerAdapter){
                                mDrawerAdapter.updateCreditsView();
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        //del by Jagger 2018-7-24由ServiceManager控制服务暂时的时机
        //服務結束
//        if(LiveService.getInstance() != null) {
//            LiveService.getInstance().onServiceEnd();
//        }
        super.onDestroy();
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
        LoginManager.getInstance().unRegister(this);
        IMManager.getInstance().unregisterIMShowEventListener(this);
        IMManager.getInstance().unregisterIMOtherEventListener(this);
        ShowUnreadManager.getInstance().unregisterUnreadListener(this);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        parseIntent(intent);
    }

    /**
     * 启动后，处理初始化数据
     * @param intent
     */
    private void parseIntent(Intent intent){
        Log.d(TAG,"parseIntent");
        Bundle bundle = intent.getExtras();
        String url = "";
        int defaultPage = 0;
        if(bundle != null){
            if(bundle.containsKey(LAUNCH_URL)){
                url = bundle.getString(LAUNCH_URL);
            }
            if(bundle.containsKey(LAUNCH_PARAMS_LISTTYPE)){
                defaultPage = bundle.getInt(LAUNCH_PARAMS_LISTTYPE);
            }
        }

        URL2ActivityManager manager = URL2ActivityManager.getInstance();
        //根据Url执行跳转
        if(!TextUtils.isEmpty(url) && !URL2ActivityManager.isHomeMainPage(url)){
            //url非指向当前main界面
            manager.URL2Activity(this, url);
            mNeedShowGuide = false;
        }else{
            defaultPage = manager.getMainListType(Uri.parse(url));
            mNeedShowGuide = true;
        }

        //切换默认页
        if(defaultPage > 0 && defaultPage < getResources().getStringArray(R.array.topTabs).length){
            viewPagerContent.setCurrentItem(defaultPage);
        }else{
            viewPagerContent.setCurrentItem(0);
        }
    }

    private void initView(){
        Log.d(TAG,"initView");

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
        mDrawerLayout = (DrawerLayout)findViewById(R.id.dl_main);
        mDrawerLayout.addDrawerListener(new DrawerLayout.DrawerListener() {
            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                Log.d(TAG,"onDrawerSlide");
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                Log.d(TAG,"onDrawerOpened");
                //更新左侧导航菜单栏未读红点数据
                if(null != mDrawerAdapter){
                    updateUnReadDataOnLeftMenu();
                }
                //柜桶是否打开标志
                mIsDrawerOpen = true;
                // 统计左侧页
                onAnalyticsPageSelected(0);
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                Log.d(TAG,"onDrawerStateChanged");
                if(mIsDrawerOpen) {
                    //柜桶是否打开标志
                    mIsDrawerOpen = false;
                    // 统计主界面页
                    onAnalyticsPageSelected(1, mCurrentPageIndex);
                }
            }

            @Override
            public void onDrawerStateChanged(int newState) {
                Log.d(TAG,"onDrawerStateChanged-newState:"+newState);
            }
        });


        mRvDrawer = (RecyclerView) findViewById(R.id.rv_drawer);
        mRvDrawer.setLayoutManager(new LinearLayoutManager(this));
        mRvDrawer.setAdapter(mDrawerAdapter);

        //登录遮罩
        mRlLoginLoading = (RelativeLayout)findViewById(R.id.rl_login_loading);
        mRlLoginLoading.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //什么都不用做, 只是为了不让用户点到后面的列表
            }
        });
        mLoginLoading = (LinearLayout)findViewById(R.id.ll_main_login);
        mLoginFail = (LinearLayout)findViewById(R.id.ll_main_login_fail);
        mBtnRelogin = (ButtonRaised)findViewById(R.id.btn_reload);
        mBtnRelogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLoging();

                LoginManager.getInstance().reLogin();
            }
        });
    }

    //------------------ 登录遮罩 --------------------
    private void showLoging(){
        mRlLoginLoading.setVisibility(View.VISIBLE);
        mLoginLoading.setVisibility(View.VISIBLE);
        mLoginFail.setVisibility(View.GONE);
    }

    private void showLoginFail(){
        mRlLoginLoading.setVisibility(View.VISIBLE);
        mLoginLoading.setVisibility(View.GONE);
        mLoginFail.setVisibility(View.VISIBLE);
    }

    private void showLoginSuccess(){
        mRlLoginLoading.setVisibility(View.GONE);
        mLoginLoading.setVisibility(View.VISIBLE);
        mLoginFail.setVisibility(View.GONE);
    }
    //----------------end 登录遮罩 --------------------


    /**
     * drawer(左则菜单) item 点击事件
     */
    private class MyOnItemClickListener implements DrawerAdapter.OnItemClickListener {

        @Override
        public void itemClick(DrawerAdapter.DrawerItemNormal drawerItemNormal) {
            switch (drawerItemNormal.id) {
                case DrawerAdapter.ITEM_ID_MESSAGE: {
                    showMessageListActivity();
                }break;
                case DrawerAdapter.ITEM_ID_MAIL:
                    showEmfListWebView();
                    break;
                case DrawerAdapter.ITEM_ID_GREETS://意向信
                    showLoiListWebView();
                    break;
                case DrawerAdapter.ITEM_ID_SHOWTICKETS:
                    if(!hasItemClicked) {
                        hasItemClicked = true;
                        MyTicketsActivity.launchMyTicketsActivity(MainFragmentActivity.this,0);
                    }
                    break;
                case DrawerAdapter.ITEM_ID_BOOKS:
                    if(!hasItemClicked) {
                        hasItemClicked = true;
                        ScheduleInviteActivity.launchScheduleListActivity(MainFragmentActivity.this,0);
                    }
                    break;
                case DrawerAdapter.ITEM_ID_BACKPACK:
                    if(!hasItemClicked) {
                        hasItemClicked = true;
                        MyPackageActivity.launchMyPackageActivity(MainFragmentActivity.this,0);
                    }
                    break;

            }

            postUiRunnableDelayed(new Runnable() {
                @Override
                public void run() {
                    mDrawerLayout.closeDrawer(GravityCompat.START);
                    onMenuClickDrawerCloseAnalytics();
                }
            }, 1000);
        }

        @Override
        public void onChangeWebsiteClicked() {
            doChangeWebsite();
        }

        @Override
        public void onShowMyProfileClicked() {
            if(!hasItemClicked){
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
            if(!hasItemClicked){
                hasItemClicked = true;
                showMyLevelDetailWebView();
            }
        }

        @Override
        public void onWebSiteChoose(WebSiteBean webSiteBean) {
            if(webSiteBean != null && !hasItemClicked){
                hasItemClicked = true;
                LiveService.getInstance().doChangeWebSite(webSiteBean);
            }
        }
    }

    /**
     * 点击买点响应
     */
    public void addCredits(){
        if(!hasItemClicked){
            hasItemClicked = true;
            NoMoneyParamsBean params = new NoMoneyParamsBean();
            params.clickFrom = "B30";
            LiveService.getInstance().onAddCreditClick(params);
        }
    }

    public void showMessageListActivity() {
        if(!hasItemClicked){
            hasItemClicked = true;
            //私信
            Intent intent = new Intent(MainFragmentActivity.this, MessageContactListActivity.class);
            startActivity(intent);
        }
    }

    /**
     * 跳转用户等级说明界面
     */
    private void showMyLevelDetailWebView(){
        if(LoginManager.getInstance().getSynConfig() != null){
            startActivity(WebViewActivity.getIntent(this,
                    getResources().getString(R.string.my_level_title),
                    WebViewActivity.UrlIntent.View_Audience_Level,
                    null,true));
        }
    }

    /**
     * 跳转到意向信列表界面
     */
    public void showLoiListWebView() {
        if(LoginManager.getInstance().getSynConfig() != null && !hasItemClicked){
            hasItemClicked = true;
            startActivity(WebViewActivity.getIntent(MainFragmentActivity.this,
                    getResources().getString(R.string.live_webview_greet_mail_title),
                    WebViewActivity.UrlIntent.View_Loi_List,
                    null,
                    true));
        }
    }

    /**
     * 查看主播来信
     */
    public void showEmfListWebView(){
        if(LoginManager.getInstance().getSynConfig() != null && !hasItemClicked){
            hasItemClicked = true;
            startActivity(WebViewActivity.getIntent(MainFragmentActivity.this,
                    getResources().getString(R.string.live_webview_mail_title),
                    WebViewActivity.UrlIntent.View_Emf_List,
                    null,
                    true));
        }
    }

    /**
     * 根据数据 刷新UI
     */
    private void refreshUI(){
        //如果登录中, 只看到loading
        if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logining){
            showLoging();
        }else if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Default){
            showLoginFail();
        }else{
            showLoginSuccess();
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
    private void setCenterUnReadNumAndStyle(){
        //刷新邀请未读数目
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        //刷新背包未读数目
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();


//        if(null == inviteItem || inviteItem.total == 0) {
//            if(null == packageItem || packageItem.total == 0){
//                setUnReadHide(mQBadgeViewUnReadMe);
//            }else {
//                //没指定数目时,显示一个小小的红点
//                setUnReadTag(mQBadgeViewUnReadMe);
//            }
//        }else {
//            //大于99时,显示99+
//            String strUnreadText = inviteItem.total > 99? "99+":String.valueOf(inviteItem.total);
//            //因为要在Nav画好后,才可以取得NavItem的宽, 所以要重设置位置
//            setUnReadText(mQBadgeViewUnReadMe, strUnreadText);
//        }
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
     * @param pageId
     */
    public void setCurrentPager(int pageId){
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
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            //按返回键回桌面
            moveTaskToBack(true);
            //发送广播，模似HOME键，BaseFragment要处理HOME键事件
            sendBroadcast(new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS));
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 被踢提示
     */
    private void showKickOffDialog(){
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setCancelable(false);
        dialog.setMessage("Your account logined on another device. Please login again.");
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainFragmentActivity.this, PeacockActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                finish();
            }
        }));
        dialog.show();
    }

    /**
     * 显示引导页
     */
    private void showGuideView(){
        Log.d(TAG,"showGuideView");
        if(LoginManager.getInstance().getLoginItem()!=null && LoginManager.getInstance().getLoginItem().userType == UserType.AllRoom){
            GuideActivity.show(mContext , GuideActivity.GuideType.MAIN_A);
        }else{
            GuideActivity.show(mContext , GuideActivity.GuideType.MAIN_B);
        }
    }

//    /**
//     * 显示节目提醒气泡
//     */
//    private void showCalendarBubble(View view , String msg){
//        //自定义布局
//        View dialogMain = getLayoutInflater().inflate(R.layout.view_calendar_bubble, null);
//        TextView dialogText = (TextView) dialogMain.findViewById(R.id.tv_bubble_title);
////        dialogText.setText(getString(R.string.live_calendar_bubble_tips, anchorName));
//        dialogText.setText(msg);
//        dialogText.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                //add by Jagger 2018--5-19
//                viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_INDEX_CALENDAR.ordinal());
//            }
//        });
//
//        //气泡样式
//        BubbleLayout bl = new BubbleLayout(this);
//        bl.setBubbleColor(getResources().getColor(R.color.live_calendar_bubble_bg));
//        bl.setLookLength(36);   //箭头高度
//
//        //现隐藏旧的未收起的dialog
//        hideCalendarBubble();
//
//        //气泡属性
//        mBubbleDialogCalendar = new BubbleDialog(mContext)
//                .addContentView(dialogMain)
//                .setClickedView(view)
//                .setBubbleLayout(bl)
//                .calBar(true)
//                .setTransParentBackground()
//                .setOffsetY(8)  //向下偏移
//                .setOffsetX(-30)    //负:向左偏移
//                .setThroughEvent(true, false) //第一个参数isThroughEvent设置是否穿透Dialog手势交互。第二个参数cancelable 点击空白是否能取消Dialog，只有当"isThroughEvent = false"时才有效
//                .setPosition(BubbleDialog.Position.TOP);
//        mBubbleDialogCalendar.show();
//    }
//
//    /**
//     * 隐藏气泡
//     */
//    private void hideCalendarBubble(){
//        if(mBubbleDialogCalendar != null && mBubbleDialogCalendar.isShowing()){
//            mBubbleDialogCalendar.dismiss();
//        }
//    }

    /**
     * 换站
     * （QN换站弹出框）
     */
    private void doChangeWebsite(){
        if(!hasItemClicked) {
            hasItemClicked = true;
            LiveService.getInstance().onChangeWebsiteDialogShow(this);
        }
    }

    /**
     * 打开QN个人资料
     */
    private void doShowMyProfile(){
        LiveService.getInstance().onShowQNMyProfile(this);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            //登录成功
            case UI_LOGIN_SUCCESS: {
                showLoginSuccess();
                if (mAdapter.getCurrentFragment() instanceof HotListFragment) {
                    ((HotListFragment) mAdapter.getCurrentFragment()).reloadData();
                }
                //更新头像昵称ID
                if(null != mDrawerAdapter){
                    mDrawerAdapter.updateHeaderView();
                }
            }break;
            case UI_LOGIN_FAIL:
                showLoginFail();
                break;
        }
    }

    /*******************************  预约邀请及背包未读更新   ******************************************/
    @Override
    public void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item) {
        Log.d(TAG,"onScheduleInviteUnreadUpdate-item:"+item);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setCenterUnReadNumAndStyle();
            }
        });
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {
        Log.d(TAG,"onPackageUnreadUpdate-item:"+item);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setCenterUnReadNumAndStyle();
            }
        });
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
        if(isSuccess){
            //监听一次即可
            LoginManager.getInstance().unRegister(this);

            //更新UI
            sendEmptyUiMessage(UI_LOGIN_SUCCESS);

        }else {
            //更新UI
            sendEmptyUiMessage(UI_LOGIN_FAIL);
        }
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    /************************************  节目未读事件通知  *******************************************/
    private boolean mIsProgramHasUnread = false;        //标记节目是否有未读

    /**
     * 获取节目未读状态
     * @return
     */
    public boolean getProgramHasUnread(){
        return mIsProgramHasUnread;
    }

    /**
     * 刷新节目未读状态
     * @param isHasShowTicketsUnRead
     */
    public void refreshShowUnreadStatus(boolean isHasShowTicketsUnRead){
        Log.d(TAG,"refreshShowUnreadStatus-isHasShowTicketsUnRead:"+isHasShowTicketsUnRead);
        mIsProgramHasUnread = isHasShowTicketsUnRead;
//        if(unreadNum > 0){
//            setUnReadTag(mQBadgeViewUnReadCalendar);
//        }else{
//            setUnReadHide(mQBadgeViewUnReadCalendar);
//        }
        tabPageIndicator.updateTabDiginalHint(2,mIsProgramHasUnread,true,0);
    }

    /************************************  节目开始结束退票事件通知  *******************************************/
    private IMProgramInfoItem mIMProgramInfoItem;
    private String mProgramPlayNoticeMessage = "";

    @Override
    public void OnRecvProgramPlayNotice(final IMProgramInfoItem showinfo, final IMClientListener.IMProgramPlayType type, final String msg) {
        Log.d(TAG,"OnRecvProgramPlayNotice-showinfo:"+showinfo+" type:"+type+" msg:"+msg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(type != IMClientListener.IMProgramPlayType.Unknown && (showinfo != null)){
                    //收到关注开播处理
                    //Modify by Harry 2018年8月3日 15:54:29 按照原型:
                    // 推送购票/关注节目开播通知时同时出现未读红点
                    // （若刚好停留在calendar页，红点仍会显示，切换到其他tab重新进入或下拉刷新列表后红点消失）
//                    if(mCurrentPageIndex != 2){
                        if(isActivityVisible()){
                            refreshShowUnreadStatus(true);
                        }else{
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
    public void onMenuClickDrawerCloseAnalytics(){
        if(mIsDrawerOpen){
            mIsDrawerOpen = false;
            // 统计主界面页
            onAnalyticsPageSelected(1, mCurrentPageIndex);
        }
    }

    //=================================红点未读展示逻辑===================================

    private void updateUnReadDataOnLeftMenu(){
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
    }

    @Override
    public void onUnReadDataUpdate() {
        Log.d(TAG,"onUnReadDataUpdate");
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateUnReadDataOnLeftMenu();
            }
        });
    }

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnLogin-errType:"+errType+" errMsg:"+errMsg);
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
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
