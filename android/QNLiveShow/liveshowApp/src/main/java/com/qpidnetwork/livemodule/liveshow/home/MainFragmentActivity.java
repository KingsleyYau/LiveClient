package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.liveshow.guide.GuideActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.personal.PersonalCenterActivity;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

public class MainFragmentActivity extends BaseFragmentActivity implements ScheduleInvitePackageUnreadManager.OnUnreadListener,
        ViewPager.OnPageChangeListener{

    private static final String LAUNCH_URL = "launchUrl";
    private static final String LAUNCH_PARAMS_LISTTYPE = "listType";

    //头部
    private FrameLayout btnBack;
    private TabPageIndicator tabPageIndicator;
    private TextView tv_centerUnReadNum;

    //内容
    private ViewPager viewPagerContent;
    private MainFragmentPagerAdapter mAdapter;
    private ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

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
        intent.putExtra(LAUNCH_PARAMS_LISTTYPE, listType);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setContentView(R.layout.activity_live_main);
        TAG = MainFragmentActivity.class.getSimpleName();

        //GA统计，设置Activity不需要report
        SetPageActivity(true);

        initView();
        parseIntent(getIntent());
        //服务启动
        LiveService.getInstance().onMoudleServiceStart();
        mScheduleInvitePackageUnreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        mScheduleInvitePackageUnreadManager.registerUnreadListener(this);
        mScheduleInvitePackageUnreadManager.GetCountOfUnreadAndPendingInvite();
        mScheduleInvitePackageUnreadManager.GetPackageUnreadCount();
        setCenterUnReadNumAndStyle();
    }

    @Override
    protected void onResume() {
        super.onResume();

    }

    @Override
    protected void onDestroy() {
        //服務結束
        LiveService.getInstance().onModuleServiceEnd();
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
            URL2ActivityManager.URL2Activity(this, url);
        }else{
            defaultPage = URL2ActivityManager.getMainListType(Uri.parse(url));
        }

        //切换默认页
        if(defaultPage > 0){
            viewPagerContent.setCurrentItem(1);
        }else{
            viewPagerContent.setCurrentItem(0);
        }
    }

    private void initView(){
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
        //引导页
        showGuideView();
        tv_centerUnReadNum = (TextView) findViewById(R.id.tv_centerUnReadNum);
    }

    private void setCenterUnReadNumAndStyle(){
        //刷新邀请未读数目
        ScheduleInviteUnreadItem inviteItem = mScheduleInvitePackageUnreadManager.getScheduleInviteUnreadItem();
        //刷新背包未读数目
        PackageUnreadCountItem packageItem = mScheduleInvitePackageUnreadManager.getPackageUnreadCountItem();
        if((null == inviteItem || inviteItem.total==0) && (null == packageItem || packageItem.total==0)){
            tv_centerUnReadNum.setVisibility(View.GONE);
        }else{
            tv_centerUnReadNum.setVisibility(View.VISIBLE);
        }
        if(inviteItem != null && inviteItem.total>0){
            if(inviteItem.total>=9){
                tv_centerUnReadNum.setText(String.valueOf(9));
            }else{
                tv_centerUnReadNum.setText(String.valueOf(inviteItem.total));
            }
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
        //SP
        SharedPreferences sharedPreferences = getSharedPreferences("guideSetting", MODE_PRIVATE);

        //小于指定版本号　则显示引导
        int version = sharedPreferences.getInt("guideVersion", 0);
        if(version < SystemUtils.getVersionCode(mContext)){ // < 可以改为某个版本号，不然每次更新都会显示引导页
//            startActivity(new Intent(mContext , GuideActivity.class));
            startActivity(GuideActivity.getIntent(mContext , GuideActivity.GuideType.ALL));

            //保存版本号，表示已经看过
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putInt("guideVersion", SystemUtils.getVersionCode(mContext));
            editor.commit();
        }

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
