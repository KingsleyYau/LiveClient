package com.qpidnetwork.livemodule.framework.services;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.liveshow.ad.AD4QNActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.credit.BuyCreditActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.pushmanager.PushManager;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.bean.MainModuleConfig;
import com.qpidnetwork.qnbridgemodule.interfaces.IQNService;
import com.qpidnetwork.qnbridgemodule.interfaces.OnServiceEventListener;

/**
 * Created by Jagger on 2017/9/18.
 */

public class LiveService implements IQNService, ScheduleInvitePackageUnreadManager.OnUnreadListener {

    private static final String TAG = LiveService.class.getName();

    private static Application mApplicationContext;
    private MainModuleConfig mMainModuleConfig;
    private boolean isModuleServiceEnd = false;     //记录当前服务模块是否是当前模块
    private OnServiceEventListener mOnServiceStatusChangeListener;
    //判断是否demo环境
    public static boolean isDebug = false;
    public static boolean isForTest = false;        //业务需要

    //是否第一次启动
    public static boolean mIsFirstLaunch = false;

    public static LiveService newInstance(Application c){
        if(mQNService == null){
            mQNService = new LiveService(c);
        }

        return mQNService;
    }

    public static LiveService getInstance(){
        return mQNService;
    }

    private static LiveService mQNService;
    private LiveService(Application c){
        initWithinApplication(c);
    }


    private void initWithinApplication(Application context){
        mApplicationContext =  context;
        mIsFirstLaunch = true;

        // 设置log级别（demo环境才打印log）
//        if (ApplicationSettingUtil.isDemoEnviroment(this)) {
//            Log.SetLevel(android.util.Log.DEBUG);
//        }
//        else {
//            Log.SetLevel(android.util.Log.ERROR);
//        }

        //FileCacheManager 单例初始化
        FileCacheManager.newInstance(mApplicationContext);
        //
        FileDownloadManager.init(mApplicationContext,true);

        //http请求Jni初始化
        try {

            PackageManager pm = mApplicationContext.getPackageManager();
            PackageInfo pi = pm.getPackageInfo(mApplicationContext.getPackageName(), PackageManager.GET_ACTIVITIES);
            if (pi != null) {
                //是否demo环境
                isDebug = pi.versionName.matches(".*[a-zA-Z].*");
                //本地文件Log存放地址
                RequestJni.SetLogDirectory(FileCacheManager.getInstance().getLogPath());
                //IM本地log
                IMClient.IMSetLogDirectory(FileCacheManager.getInstance().getIMLogPath());
//                RequestJni.SetWebSite(IPConfigUtil.getTestWebSiteUrl());
//                RequestJni.SetPhotoUploadSite("http://172.25.32.17:82");
//                RequestJni.SetWebSite("http://192.168.88.90:8881");
                // 版本号
                RequestJni.SetVersionCode(String.valueOf(pi.versionCode));
                // 设备Id
                TelephonyManager tm = (TelephonyManager) mApplicationContext.getSystemService(Context.TELEPHONY_SERVICE);
                RequestJni.SetDeviceId(SystemUtils.getDeviceId(mApplicationContext));
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        // 设置log级别（demo环境才打印log）
        if (isDebug) {
            Log.SetLevel(android.util.Log.DEBUG);
        }
        else {
            Log.SetLevel(android.util.Log.ERROR);
        }

        // 初始化GA管理器
        if (isDebug) {
            AnalyticsManager.newInstance().init(mApplicationContext, R.xml.live_tracker_demo);
        }
        else {
            AnalyticsManager.newInstance().init(mApplicationContext, R.xml.live_tracker);
        }

        //初始化LoginManager
        LoginManager loginManager = LoginManager.newInstance(mApplicationContext);

        //初始化IMManager
        IMManager imManager = IMManager.newInstance(mApplicationContext);
        loginManager.addListener(imManager);

        //Fresco库初始化
        Fresco.initialize(mApplicationContext);

        //http请求工具类
        LiveRequestOperator.newInstance(mApplicationContext);

//        //接入公共模块
//        ServiceManager.getInstance(mApplicationContext).registerService(LiveService.getInstance(mApplicationContext));

        //背包及预约邀请等未读管理器
        ScheduleInvitePackageUnreadManager unreadManager = ScheduleInvitePackageUnreadManager.getInstance();
        unreadManager.registerUnreadListener(this);

        //初始化pushManager
        PushManager.newInstance(mApplicationContext);


        //本地环境根据配置获取入口同步配置的host地址
        RequestJni.SetConfigSite(mApplicationContext.getResources().getString(R.string.webHost));
    }

    @Override
    public void onMainServiceLogin(boolean isSucess, String userId, String token, String ga_uid, String configDomain) {
        Log.i(TAG, "onMainServiceLogin isSucess:%d userId:%s token:%s ga_uid:%s configDomain:%s", isSucess?1:0, userId, token, ga_uid, configDomain);
//        String domain = "http://demo-live.charmdate.com:3007";      //客户端https支持有问题，先写死http环境
//        RequestJni.SetConfigSite(configDomain);
//        LoginManager.getInstance().onMainMoudleLogin(isSucess, userId, token, ga_uid);
    }

    @Override
    public void onMainServiceLogout(LogoutType type, String tips) {
        Log.i(TAG, "onMainServiceLogout LogoutType:%s tips:%s ", type.name(), tips);
//        LoginManager.getInstance().onMainMoudleLogout(type, tips);
    }

    @Override
    public void onAppKickoff(String tips) {
        //无需处理，根据主模块注销注销即可
    }

    @Override
    public String getServiceName() {
        return URL2ActivityManager.KEY_URL_SERVICE_NAME_LIVE ;
    }

    /**
     * 对外开放模块入口url，外部可通过url打开模块
     * @return
     */
    @Override
    public String getServiceEnterUrl(){
        return URL2ActivityManager.getInstance().createServiceEnter();
    }

    @Override
    public void openUrl(Context context, String url) {
        //传递Url给MainFragmentActivity
        Log.i(TAG, "openUrl url:%s ", url);
        MainFragmentActivity.launchActivityWIthUrl(context, url);
    }

    /**
     * 打开App
     * @param context
     * @param url
     */
    public void openAppWithUrl(Context context, String url){
        Intent intent = new Intent(context, LiveLoginActivity.class);
        intent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, url);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    /**
     * 检查url是否需要登录后才可以操作
     * @param url
     * @return
     */
    @Override
    public boolean checkNeedLogin(String url){
        //整个板块都需要登录
        return true;
    }

    @Override
    public void setForTest(boolean isForTest) {
        Log.i(TAG, "setForTest isForTest: " + isForTest);
        this.isForTest = isForTest;
    }

    /**
     * 同步系统通知设置
     */
    public void synSystemNotificationSetting(MainModuleConfig config){
        this.mMainModuleConfig = config;
    }

    /**
     * 获取系统设置
     * @return
     */
    public MainModuleConfig getmMainModuleConfig(){
//        return mMainModuleConfig;
        //修改push设置本地设置
        return new MainModuleConfig();
    }

    /**
     * 启动界面广告
      * @param context
     */
    @Override
    public void launchAdvertActivity(Context context){
        Intent intent = new Intent(context, AD4QNActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    /***************************** 服务状态统计  *****************************************/
    /**
     * 检测url是否与当前模块冲突
     * @param url
     * @return
     */
    @Override
    public boolean checkServiceConflict(String url){
        //直播处理过程中，任何url处理都需要停止当前直播服务
        return IMManager.getInstance().isCurrentInLive();
    }

    @Override
    public String getServiceConflictTips() {
        return mApplicationContext.getResources().getString(R.string.live_serving_conflict_tips);
    }

    @Override
    public boolean stopService() {
        IMManager.getInstance().stopLiveServiceLocal();
        return true;
    }

    /**
     * 检测主播邀请是否通知（在直播模块，且不再直播过程中才推送）
     * @param anchorId
     * @return
     */
    public boolean checkAnchorInviteNotify(String anchorId){
        boolean notify = true;
        String liveAnchorId = IMManager.getInstance().getCurrentLivingAnchorId();
        if(isModuleServiceEnd){
            notify = false;
        }else{
            if(IMManager.getInstance().isCurrentInLive()){
                //直播中非当前主播立即私密邀请不push
                if(anchorId.equals(liveAnchorId)){
                    notify = true;
                }else{
                    notify = false;
                }
            }else{
                notify = true;
            }
        }
        Log.i("hunter", "checkAnchorInviteNotify anchorId: " + anchorId + " isModuleServiceEnd: " + isModuleServiceEnd + " mTargetId: " + liveAnchorId + " notify: " + notify);
        return notify;
    }

    /**
     * push点击，主模块接收后，通知子模块完成GA统计，仅用于GA统计
     * @param url
     */
    @Override
    public void onPushClickGAReport(String url){
        Log.i(TAG, "onPushClickGAReport url:%s ", url);
        String moduleName = URL2ActivityManager.getInstance().getModuleNameByUrl(url);
        if(moduleName.equals(URL2ActivityManager.KEY_URL_MODULE_NAME_LIVE_ROOM)){
            AnalyticsManager instance = AnalyticsManager.getsInstance();
            if(instance != null) {
                if(TextUtils.isEmpty(URL2ActivityManager.getInstance().getRoomIdByUrl(url))){
                    //房间号为空，则为主播邀请
                    instance.ReportEvent(mApplicationContext.getResources().getString(R.string.Live_Global_Category),
                            mApplicationContext.getResources().getString(R.string.Live_Global_Action_ClickInvitation),
                            mApplicationContext.getResources().getString(R.string.Live_Global_Label_ClickInvitation));
                }else{
                    //预约到期
                    instance.ReportEvent(mApplicationContext.getResources().getString(R.string.Live_Global_Category),
                            mApplicationContext.getResources().getString(R.string.Live_Global_Action_ClickBookingStart),
                            mApplicationContext.getResources().getString(R.string.Live_Global_Label_ClickBookingStart));
                }
            }
        }
    }

    /******************************  事件统计分发   **************************************/

    /**
     * 获取是否为test使用
     * @return
     */
    public boolean getForTest(){
        Log.i(TAG, "getForTest isForTest: " + isForTest);
        return isForTest;
    }
    /**
     * 服務狀態改變監聽器
     * @param onServiceStatusListener
     */
    @Override
    public void setOnServiceStatusChangeListener(OnServiceEventListener onServiceStatusListener) {
        this.mOnServiceStatusChangeListener = onServiceStatusListener;
    }

    /**
     * 模块session过期处理
     */
    public void onModuleSessionOverTime() {
        Log.i(TAG, "onModuleSessionOverTime event");
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onTokenExpired(this);
        }
    }

    /**
     * 模块被踢
     */
    public void onModuleKickoff() {
        Log.i(TAG, "onModuleKickoff event");
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onKickOffNotify(this);
        }
    }

    /**
     * 模块开始
     */
        public void onMoudleServiceStart() {
        Log.i(TAG, "onMoudleServiceStart event");
        isModuleServiceEnd = false;
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onServiceStart(this);
        }
    }

    /**
     * 模块结束
     */
    public void onModuleServiceEnd() {
        Log.i(TAG, "onModuleServiceEnd event");
        isModuleServiceEnd = true;
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onServiceEnd(this);
        }
    }

    /**
     * 添加买点跳转由主模块处理
     */
    public void onAddCreditClick(Context context){
        Log.i(TAG, "onAddCreditClick event");
//        if(mOnServiceStatusChangeListener != null){
//            mOnServiceStatusChangeListener.onAddCreditClick(this);
//        }
        Intent intent = new Intent(context, BuyCreditActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    /**
     * 通知主模块是否显示广告
     * @param isShow
     */
    public void onAdvertShowNotify(boolean isShow){
        Log.i(TAG, "onAdvertShowNotify event isShow: " + isShow);
        if(mOnServiceStatusChangeListener != null){
            Log.i(TAG, "onAdvertShowNotify isShow");
            mOnServiceStatusChangeListener.onAdvertShowNotify(this, isShow);
        }
    }

    /**
     * 模块未读通知
     */
    public void onModuleUnreadNotify(){
        ScheduleInvitePackageUnreadManager manager = ScheduleInvitePackageUnreadManager.getInstance();
        PackageUnreadCountItem packageUnreadItem = manager.getPackageUnreadCountItem();
        ScheduleInviteUnreadItem scheduleInviteItem = manager.getScheduleInviteUnreadItem();
        boolean needShow = false;
        if((scheduleInviteItem != null && scheduleInviteItem.total > 0)){
            needShow = true;
        }
        Log.i(TAG, "onModuleUnreadNotify event needShow: " + needShow);
        if(mOnServiceStatusChangeListener != null){
            Log.i(TAG, "onModuleUnreadNotify needShow");
            mOnServiceStatusChangeListener.onModudleUnreadFlagsNotify(this, needShow);
        }
    }

    /*********************************** 统计直播模块未读标志  **********************************************/
    @Override
    public void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item) {
        onModuleUnreadNotify();
    }

    @Override
    public void onPackageUnreadUpdate(PackageUnreadCountItem item) {
//        onModuleUnreadNotify();
    }
}
