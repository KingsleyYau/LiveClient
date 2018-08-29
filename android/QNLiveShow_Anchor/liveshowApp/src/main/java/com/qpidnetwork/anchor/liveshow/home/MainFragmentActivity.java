package com.qpidnetwork.anchor.liveshow.home;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Paint;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.design.internal.BottomNavigationItemView;
import android.support.design.widget.BottomNavigationView;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.ScheduleInviteUnreadItem;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.httprequest.OnRequestLSUploadCrashFileCallback;
import com.qpidnetwork.anchor.httprequest.RequestJniOther;
import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.liveroom.PublicTransitionActivity;
import com.qpidnetwork.anchor.liveshow.manager.CameraMicroPhoneCheckManager;
import com.qpidnetwork.anchor.liveshow.manager.NotifyKillManager;
import com.qpidnetwork.anchor.liveshow.manager.ProgramUnreadManager;
import com.qpidnetwork.anchor.liveshow.manager.ScheduleInviteManager;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.liveshow.manager.UpdateManager;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.qpidnetwork.anchor.view.BottomNavigationViewEx;
import com.qpidnetwork.anchor.view.MaterialDialogAlert;

import java.io.File;

import q.rorbin.badgeview.QBadgeView;

public class MainFragmentActivity extends BaseFragmentActivity implements ScheduleInviteManager.OnScheduleInviteChangeListener,
        ViewPager.OnPageChangeListener, CameraMicroPhoneCheckManager.OnCameraAndRecordAudioCheckListener,
        ProgramUnreadManager.OnProgramUnreadListener {

    private static final String LAUNCH_URL = "launchUrl";
    private static final String LAUNCH_PARAMS_LISTTYPE = "listType";
    private final int DEFAULT_REQUEST_ID  = -1;

    //UI msg
    private final int MSG_SHOW_UNREAD = 1;
    private static final int MSG_CHECK_PERMISSION_CALLBACK = 2;

    //控件
    private BottomNavigationViewEx mNavView;
    private QBadgeView mQBadgeViewNews, mQBadgeViewUnRead;
//    private FloatingActionButton mFloatingActionButtonCam;
    private ImageView mImgViewButtonCam;
    private MaterialDialogAlert mCrashDialog = null;

    //内容
    private ViewPager viewPagerContent;
    private MainFragmentPagerAdapter mAdapter;
    private ScheduleInviteManager mScheduleInviteManager;

    //变量
    private long mRequestId = DEFAULT_REQUEST_ID;

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
        setContentView(R.layout.activity_live_main);

        TAG = MainFragmentActivity.class.getSimpleName();


        initView();
        parseIntent(getIntent());
        //服务启动
        if(LiveService.getInstance() == null){
            //crash异常启动退回home页面
            finish();
        }

        //APP被杀清除通知栏
        NotifyKillManager.getInstance(mContext).init();

        mScheduleInviteManager = ScheduleInviteManager.getInstance();
        mScheduleInviteManager.registerScheduleInviteChangeListener(this);

        //绑定节目未读监听器
        ProgramUnreadManager.getInstance().registerUnreadListener(this);

        //检测本地升级
        checkNormalUpgate();
        //读取本地数据处理未读显示处理
        setCenterUnReadNumAndStyle();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        //APP被杀清除通知栏 服務結束
        NotifyKillManager.getInstance(mContext).unbind();
        //解绑预约未读数监听器
        mScheduleInviteManager.unregisterScheduleInviteChangeListener(this);
        //解绑节目未读数监听器
        ProgramUnreadManager.getInstance().unregisterUnreadListener(this);

        super.onDestroy();
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
        }else{
            defaultPage = manager.getMainListType(Uri.parse(url));
        }

        //切换默认页
        if(defaultPage > 0 && defaultPage < MainFragmentPagerAdapter.TABS.values().length){
            viewPagerContent.setCurrentItem(defaultPage);
        }else{
            viewPagerContent.setCurrentItem(0);
        }
    }

    private void initView(){

//        //状态栏颜色
//        StatusBarUtil.setColor(this, getResources().getColor(R.color.bg_light_blue),0);

        Log.d(TAG,"initView");
        viewPagerContent = (ViewPager) findViewById(R.id.viewPagerContent);
        //初始化viewpager
        mAdapter = new MainFragmentPagerAdapter(this);
        viewPagerContent.setAdapter(mAdapter);
        //防止间隔点击会出现回收，导致Fragment onresume走出现刷新异常
        viewPagerContent.setOffscreenPageLimit(2);

        //新版本
        //TAB
        mNavView = (BottomNavigationViewEx)findViewById(R.id.navigation);
        mNavView.enableAnimation(false);
        mNavView.enableShiftingMode(false);
        mNavView.enableItemShiftingMode(false);
        mNavView.setDrawingCacheEnabled(false);
        mNavView.setIconUseSelector();
//        mNavView.setItemPadding(MainFragmentPagerAdapter.TABS.TAB_HOME.ordinal() ,0,0,BottomNavigationViewEx.dp2px(mContext, 40),0);
//        mNavView.setItemPadding(MainFragmentPagerAdapter.TABS.TAB_ME.ordinal() ,BottomNavigationViewEx.dp2px(mContext, 40),0,0,0);
        initEvent();

        //TAB中间按钮
        mImgViewButtonCam = (ImageView) findViewById(R.id.navigation_cam);
        mImgViewButtonCam.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mImgViewButtonCam.setClickable(false);
                checkPermission();
            }
        });

        //未读数
        mQBadgeViewNews = new QBadgeView(mContext);
        //设置一些公共样式
        mQBadgeViewNews
                .setBadgeNumber(0)  //先隐藏, 因为初始化时取不到准确的坐标,会在右上角先显示一个图标,不好看
                .setBadgeGravity(Gravity.END | Gravity.TOP)
                .setShowShadow(false)//不要阴影
                .bindTarget(mNavView.getBottomNavigationItemView(MainFragmentPagerAdapter.TABS.TAB_HOME.ordinal()));

        //直接上传Crash log
//        showCheckCrashLogDialog();
        doCheckCrashLog();
    }

    /**
     * viewpager与nav之间的事件
     */
    private void initEvent() {
        // set listener to change the current item of view pager when click bottom nav item
        mNavView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            private int previousItemId = -1;

            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                // you can write as above.
                // I recommend this method. You can change the item order or counts without update code here.
                int tempItemId = item.getItemId();
                if (previousItemId != tempItemId) {
                    // only set item when item changed
                    previousItemId = tempItemId;

                    if(previousItemId == R.id.navigation_discover){
                        viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_HOME.ordinal());
                        //代表每次切换到PersonalCenterFragment都要刷新数据
                        //要配合MainFragmentPagerAdapter.getItemPosition()实现
                        //del by Jagger 2018-4-14 MainFragmentPagerAdapter.getItemPosition()同时也被删除了
//                        mAdapter.notifyDataSetChanged();
                        return true;
                    }
                    else if(previousItemId == R.id.navigation_me){
                        viewPagerContent.setCurrentItem(MainFragmentPagerAdapter.TABS.TAB_ME.ordinal());
                        return true;
                    }
                }
                return true;
            }
        });

        // set listener to change the current checked item of bottom nav when scroll view pager
        viewPagerContent.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                if (position >= (MainFragmentPagerAdapter.TABS.TAB_NULL.ordinal() ))// home后面的是中间的页
                    position++;// if page is 1, need set bottom item to 2, and the same to 2 ->3

                mNavView.setCurrentItem(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MSG_SHOW_UNREAD:
                setCenterUnReadNumAndStyle();
                break;
            case MSG_CHECK_PERMISSION_CALLBACK:{
                mImgViewButtonCam.setClickable(true);
                if(msg.arg1 == 1){
                    //检测成功
                    startActivity(new Intent(MainFragmentActivity.this, PublicTransitionActivity.class));
                }else{
                    //检测失败
                    String message = (String)msg.obj;
                    showPermissionNeedDialog(message);
                }
            }break;

            default:
                break;
        }
    }

    /**
     * 显示未读数目
     * 注:不要在界面未初始化完成前调用, 这样会计算不了控件大小而导致红点位置不准确
     */
    private void setCenterUnReadNumAndStyle(){
        //获取节目未读数目
        int programUnread = ProgramUnreadManager.getInstance().GetLocalShowNoRead();

        //刷新邀请未读数目
        ScheduleInviteUnreadItem inviteItem = mScheduleInviteManager.getScheduleInviteUnreadItem();
        if(((null == inviteItem) || inviteItem.confirmedUnreadCount == 0) && (programUnread <= 0)) {
            //未读预约数目为零
            setNewsHide();
        }else {
            //未读数目大于零,显示一个小小的红点
            setNewsTag();
        }
    }

    /**
     * 隐藏 新消息
     */
    private void setNewsHide(){
        //不显示
        mQBadgeViewNews.setBadgeNumber(0);
    }

    /**
     * 新消息显示为 红点
     */
    private void setNewsTag(){
        //因为要在Nav画好后,才可以取得NavItem的宽, 所以要重设置位置
        mQBadgeViewNews.setGravityOffset(getUnReadNumOffset("0"), 5, true)
                .setBadgePadding(5, true);

        mQBadgeViewNews.setBadgeText("");
    }

    /**
     * 计算未读红点 右偏移, 以文字内容大小向左移
     * @return
     */
    private int getUnReadNumOffset(String text){
        Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        int textWidth = (int)textPaint.measureText(text);

        int offset = 0;
        BottomNavigationItemView v = mNavView.getBottomNavigationItemView(0);
        offset = v.getWidth()/3 - textWidth;    //画在居右1/3的位置
        offset = DisplayUtil.px2dip(mContext , offset);
        return offset;
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
    }

    /**
     * 检测是否需要上传CrashLog
     */
    private void doCheckCrashLog(){
        File file = new File(FileCacheManager.getInstance().getCrashInfoPath());
        boolean bFlag = false;
        if (file.exists() && file.isDirectory() && file.list() != null
                && file.list().length > 0) {
            for (File item : file.listFiles()) {
                if (item != null && item.isFile()) {
                    // 有文件需要上传
                    bFlag = true;
                    break;
                }
            }
        }

        if (bFlag) {
            // 登录成功并且不在上传中
            if ((mRequestId == DEFAULT_REQUEST_ID)) {
                // 直接上传
                UploadCrashLog();
            }
        }
    }

    /**
     * 上传CrashLog
     */
    private void UploadCrashLog() {
        //开线程上传，解决Zip包打包时间过久导致卡死主线程(Crash文件过大过多)
        new Thread(new Runnable() {
            @Override
            public void run() {
                mRequestId = RequestJniOther.UploadCrashFile(SystemUtils.getDeviceId(MainFragmentActivity.this),
                        FileCacheManager.getInstance().getCrashInfoPath(),
                        FileCacheManager.getInstance().getTempPath(),
                        new OnRequestLSUploadCrashFileCallback() {
                            @Override
                            public void onUploadCrashFile(boolean isSuccess, int errCode, String errMsg) {
                                if (isSuccess) {
                                    FileCacheManager.getInstance().clearCrashLog();
                                }
                                mRequestId = DEFAULT_REQUEST_ID;
                            }
                        }
                );
            }
        }).start();
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


    /****************************** Camera和RecordAudio权限检测  ************************************/

    /**
     * 启动权限检测
     */
    private void checkPermission(){
        CameraMicroPhoneCheckManager manager = new CameraMicroPhoneCheckManager();
        manager.setOnCameraAndRecordAudioCheckListener(this);
        manager.checkStart();
    }

    /**
     * 显示权限设置提示dialog
     * @param messgae
     */
    public void showPermissionNeedDialog(String messgae){
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(messgae);
        builder.setNegativeButton(R.string.permission_check_dialog_button_cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            }
        });
        builder.setPositiveButton(R.string.permission_check_dialog_button_setttings, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                Intent intent = new Intent(Settings.ACTION_APPLICATION_SETTINGS);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });

        AlertDialog dialog = builder.create();
        if(isActivityVisible()) {
            dialog.show();
        }
    }

    @Override
    public void onCheckPermissionSuccess() {
        Message msg = Message.obtain();
        msg.what = MSG_CHECK_PERMISSION_CALLBACK;
        msg.arg1 = 1;
        sendUiMessage(msg);
    }

    @Override
    public void onCheckCameraPermissionDeny() {
        String errMsg = getResources().getString(R.string.permission_check_exception_camera);
        Message msg = Message.obtain();
        msg.what = MSG_CHECK_PERMISSION_CALLBACK;
        msg.arg1 = 0;
        msg.obj = errMsg;
        sendUiMessage(msg);
    }

    @Override
    public void onCheckRecordAudioPermissionDeny() {
        String errMsg = getResources().getString(R.string.permission_check_exception_record_audio);
        Message msg = Message.obtain();
        msg.what = MSG_CHECK_PERMISSION_CALLBACK;
        msg.arg1 = 0;
        msg.obj = errMsg;
        sendUiMessage(msg);
    }

    /********************************** 判断普通升级  ****************************************/
    /**
     * 普通升级提示
     */
    private void checkNormalUpgate(){
        ConfigItem configItem = LoginManager.getInstance().getSynConfig();
        if(configItem != null){
            //是否需要普通更新
            //因为普通更新不需要打断之前的请求, 所以把结果照常回调到外部
            UpdateManager.UpdateType updateType = UpdateManager.getInstance(mContext).getUpdateType(configItem);
            if(updateType == UpdateManager.UpdateType.NORMAL){
                showNormalUpdateDialog();
            }
        }
    }

    /**
     * 提示 普通更新
     * TODO:UI校对
     */
    private void showNormalUpdateDialog(){
        final UpdateManager.UpdateMessage updateMessage = UpdateManager.getInstance(mContext).getUpdateMessage();
        if(updateMessage == null){
            return;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.live_update_title));
        builder.setMessage(TextUtils.isEmpty(updateMessage.normalUpdateMsg)? "": updateMessage.normalUpdateMsg);
        builder.setPositiveButton(R.string.live_not_now, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                //取消这次使用过程中的更新提示
                UpdateManager.getInstance(mContext).setNormalUpdateCancel();
            }
        });
        builder.setNegativeButton(R.string.live_update, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if(!TextUtils.isEmpty(updateMessage.downloadAppUrl)){
                    Uri uri = Uri.parse(updateMessage.downloadAppUrl);
                    Intent intent = new Intent();
                    intent.setAction(Intent.ACTION_VIEW);
                    intent.setData(uri);
                    startActivity(intent);

                    finish();
                }
            }
        });
        AlertDialog dialog = builder.create();
        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {

            }
        });
        dialog.show();
    }

    /****************************** 预约邀请未读数目更新通知  ************************************/
    @Override
    public void onScheduleInviteUpdate(ScheduleInviteUnreadItem item, int scheduledInvite) {
        sendEmptyUiMessage(MSG_SHOW_UNREAD);
    }

    /****************************** 获取节目未读数目更新通知  ************************************/
    @Override
    public void onProgramUnreadUpdate(int unreadNum) {
        sendEmptyUiMessage(MSG_SHOW_UNREAD);
    }

}
