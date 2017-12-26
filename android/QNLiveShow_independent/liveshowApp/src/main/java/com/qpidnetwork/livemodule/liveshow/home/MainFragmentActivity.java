package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnBannerCallback;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.httprequest.item.UserType;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.guide.GuideActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.personal.PersonalCenterActivity;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.DotView.DotLayout;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

public class MainFragmentActivity extends BaseActionBarFragmentActivity implements ScheduleInvitePackageUnreadManager.OnUnreadListener,
        ViewPager.OnPageChangeListener{

    private static final String LAUNCH_URL = "launchUrl";
    private static final String LAUNCH_PARAMS_LISTTYPE = "listType";

    //头部
    private FrameLayout btnBack;
    private TabPageIndicator tabPageIndicator;
//    private TextView tv_centerUnReadNum;
    private DotLayout dl_UnReadNum;

    //内容
    private ViewPager viewPagerContent;
    private MainFragmentPagerAdapter mAdapter;
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;
    private boolean mNeedShowGuide = true;

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
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setCustomContentView(R.layout.activity_live_main);
        //
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
            LiveService.getInstance().onMoudleServiceStart();
        }

        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
        setCenterUnReadNumAndStyle();
        initData();

        //引导页
        if(mNeedShowGuide){
            showGuideView();
        }

        //test
//        showEditProfile();
    }

    private void initData(){
        Log.d(TAG,"initData");
        LiveRequestOperator.getInstance().Banner(new OnBannerCallback() {
            @Override
            public void onBanner(boolean isSuccess, int errCode, String errMsg,
                                 String bannerImg, String bannerLink, String bannerName) {
                Log.d(TAG,"onBanner-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" bannerImg:"+bannerImg+" bannerLink:"+bannerLink
                        +" bannerName:"+bannerName);
                if(isSuccess){
                    final BannerItem bannerItem = new BannerItem(bannerImg,bannerLink,bannerName);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(null != mAdapter){
                                mAdapter.notifyBannerImgChanged(bannerItem);
                            }
                        }
                    });
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        //服務結束
        if(LiveService.getInstance() != null) {
            LiveService.getInstance().onModuleServiceEnd();
        }
        super.onDestroy();
        mScheduleInvitePackageUnreadManager.unregisterUnreadListener(this);
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
        if(defaultPage > 0){
            viewPagerContent.setCurrentItem(1);
        }else{
            viewPagerContent.setCurrentItem(0);
        }
    }

    private void initView(){
        Log.d(TAG,"initView");
        btnBack = (FrameLayout) findViewById(R.id.btnBack);
        btnBack.setOnClickListener(this);
        tabPageIndicator = (TabPageIndicator) findViewById(R.id.tabPageIndicator);
        viewPagerContent = (ViewPager) findViewById(R.id.viewPagerContent);
        //初始化viewpager
        mAdapter = new MainFragmentPagerAdapter(this);
        viewPagerContent.setAdapter(mAdapter);
        tabPageIndicator.setViewPager(viewPagerContent);
        // 设置控件的模式，一定要先设置模式
        tabPageIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        // 设置两个标题之间的竖直分割线的颜色，如果不需要显示这个，设置颜色为透明即可
        tabPageIndicator.setDividerColor(Color.TRANSPARENT);
        //无未读条数
        tabPageIndicator.setHasDigitalHint(false);
        //设置中间竖线上下的padding值
        tabPageIndicator.setDividerPadding(DisplayUtil.dip2px(this, 10));

//        tv_centerUnReadNum = (TextView) findViewById(R.id.tv_centerUnReadNum);
        dl_UnReadNum = (DotLayout)findViewById(R.id.dl_UnReadNum);
    }

    private void setCenterUnReadNumAndStyle(){
        //刷新邀请未读数目
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        //刷新背包未读数目
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
//        if((null == inviteItem || inviteItem.total == 0) && (null == packageItem || packageItem.total == 0)){
////            tv_centerUnReadNum.setVisibility(View.GONE);
//            dl_UnReadNum.show(false);
//        }else{
////            tv_centerUnReadNum.setVisibility(View.VISIBLE);
//            dl_UnReadNum.show(true);    //没指定数目时,显示一个小小的红点
//        }
//        if(inviteItem != null && inviteItem.total>0){
////            if(inviteItem.total >= 99){
//////                tv_centerUnReadNum.setText(String.valueOf(99) + "+");
////            }else{
////                tv_centerUnReadNum.setText(String.valueOf(inviteItem.total));
//                dl_UnReadNum.show(true , inviteItem.total); //控件已控制 大于99时,显示99+
////            }
//        }else{
////            tv_centerUnReadNum.setText("");
//            dl_UnReadNum.show(true);
//        }


        if(null == inviteItem || inviteItem.total == 0) {
            if(null == packageItem || packageItem.total == 0){
                dl_UnReadNum.show(false);
            }else {
                dl_UnReadNum.show(true);    //没指定数目时,显示一个小小的红点
            }
        }else {
            dl_UnReadNum.show(true , inviteItem.total); //控件已控制 大于99时,显示99+
        }
    }

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
        if (i == R.id.btnBack) {
            finish();
        } else if (i == R.id.rlPersonalCenter) {
            Intent intent = new Intent(this, PersonalCenterActivity.class);
            startActivity(intent);
        }
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

    /**
     * 编写资料
     */
    private void showEditProfile(){
        EditProfileActivity.show(mContext);
    }

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

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {
        //GA统计
        onAnalyticsPageSelected(position);
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }
}
