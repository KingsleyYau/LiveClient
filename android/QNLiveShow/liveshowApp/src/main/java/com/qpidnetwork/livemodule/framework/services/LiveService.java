package com.qpidnetwork.livemodule.framework.services;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.liveshow.ad.AD4QNActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.MainModuleConfig;
import com.qpidnetwork.qnbridgemodule.interfaces.IQNService;
import com.qpidnetwork.qnbridgemodule.interfaces.OnServiceEventListener;

/**
 * Created by Jagger on 2017/9/18.
 */

public class LiveService implements IQNService {

    private static Application mApplicationContext;
    private MainModuleConfig mMainModuleConfig;
    private boolean isModuleServiceEnd = false;     //记录当前服务模块是否是当前模块
    private OnServiceEventListener mOnServiceStatusChangeListener;
    //判断是否demo环境
    public static boolean isDebug = false;

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

        // 设置log级别（demo环境才打印log）
//        if (ApplicationSettingUtil.isDemoEnviroment(this)) {
//            Log.SetLevel(android.util.Log.DEBUG);
//        }
//        else {
//            Log.SetLevel(android.util.Log.ERROR);
//        }

        //FileCacheManager 单例初始化
        FileCacheManager.newInstance(mApplicationContext);
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
                RequestJni.SetWebSite(IPConfigUtil.getTestWebSiteUrl());
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

        // 初始化GA管理器
        if (isDebug) {
            AnalyticsManager.newInstance().init(mApplicationContext, R.xml.live_tracker_demo);
        }
        else {
            AnalyticsManager.newInstance().init(mApplicationContext, R.xml.live_tracker);
        }

        //初始化LoginManager单例
        LoginManager loginManager = LoginManager.newInstance(mApplicationContext);

        //初始化IMManager
        IMManager imManager = IMManager.newInstance(mApplicationContext);
        loginManager.register(imManager);

        //Fresco库初始化
        Fresco.initialize(mApplicationContext);

        //http请求工具类
        LiveRequestOperator.newInstance(mApplicationContext);

//        //接入公共模块
//        ServiceManager.getInstance(mApplicationContext).registerService(LiveService.getInstance(mApplicationContext));

        //背包及预约邀请等未读管理器
        ScheduleInvitePackageUnreadManager.getInstance();

        //初始化pushmanager
        PushManager.newInstance(mApplicationContext);
    }

    @Override
    public void onMainServiceLogin(boolean isSucess, String userId, String token, String ga_uid) {
        LoginManager.getInstance().onMainMoudleLogin(isSucess, userId, token, ga_uid);
    }

    @Override
    public void onMainServiceLogout(LogoutType type, String tips) {
        LoginManager.getInstance().onMainMoudleLogout(type, tips);
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
        MainFragmentActivity.launchActivityWIthUrl(context, url);
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
        return mMainModuleConfig;
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
    //是否正在直播中
    private boolean mIsInLive = false;
    private String mTargetId = "";

    /**
     * 检测url是否与当前模块冲突
     * @param url
     * @return
     */
    @Override
    public boolean checkServiceConflict(String url){
        //直播处理过程中，任何url处理都需要停止当前直播服务
        return mIsInLive;
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
     * 标记当前服务是否进行中（以在直播间过度页和直播间页为准）
     * @param isActive
     */
    public void setServiceActive(boolean isActive, String targetId){
        this.mIsInLive = isActive;
        this.mTargetId = targetId;
    }

    /**
     * 检测主播邀请是否通知（在直播模块，切不再直播过程中才推送）
     * @param anchorId
     * @return
     */
    public boolean checkAnchorInviteNotify(String anchorId){
        boolean notify = true;
        if(isModuleServiceEnd){
            notify = false;
        }else{
            notify = !(mIsInLive && anchorId.equals(mTargetId));
        }
        return notify;
    }

    /******************************  事件统计分发   **************************************/
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
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onTokenExpired(this);
        }
    }

    /**
     * 模块被踢
     */
    public void onModuleKickoff() {
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onKickOffNotify(this);
        }
    }

    /**
     * 模块开始
     */
    public void onMoudleServiceStart() {
        isModuleServiceEnd = false;
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onServiceStart(this);
        }
    }

    /**
     * 模块结束
     */
    public void onModuleServiceEnd() {
        isModuleServiceEnd = true;
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onServiceEnd(this);
        }
    }

    /**
     * 添加买点跳转由主模块处理
     */
    public void onAddCreditClick(){
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onAddCreditClick(this);
        }
    }

    /**
     * 通知主模块是否显示广告
     * @param isShow
     */
    public void onAdvertShowNotify(boolean isShow){
        if(mOnServiceStatusChangeListener != null){
            mOnServiceStatusChangeListener.onAdvertShowNotify(this, isShow);
        }
    }

}
