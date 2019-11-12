package com.qpidnetwork.anchor.framework.services;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.imagepipeline.core.ImagePipelineConfig;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.CommonConstant;
import com.qpidnetwork.anchor.bean.MainModuleConfig;
import com.qpidnetwork.anchor.framework.fresco.TrusAllSSLHttpsUrlConnNetFetcher;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.RequestJni;
import com.qpidnetwork.anchor.im.IMClient;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.anchor.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.anchor.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.anchor.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.anchor.liveshow.manager.ChangeVideoPushManager;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.liveshow.pushmanager.PushManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;

import net.qdating.LSConfig;

/**
 * Created by Jagger on 2017/9/18.
 */

public class LiveService {

    private static final String TAG = LiveService.class.getName();

    private static Application mApplicationContext;
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
            //配置处理推流播流器demo环境打开log
            LSConfig.LOG_LEVEL = android.util.Log.DEBUG;
            LSConfig.LOGDIR = FileCacheManager.getInstance().GetPublisherPlayerLogLocalPath();
        }
        else {
            Log.SetLevel(android.util.Log.ERROR);
            //配置处理推流播流器正式环境关闭Log
            LSConfig.LOG_LEVEL = android.util.Log.ERROR;
            LSConfig.LOGDIR = "";
        }

        // 初始化GA管理器
        AnalyticsManager instance = AnalyticsManager.newInstance();
//        if (isDebug) {
//            instance.init(mApplicationContext, R.xml.live_tracker_demo);
//        }
//        else {
//            instance.init(mApplicationContext, R.xml.live_tracker);
//        }

        //初始化LoginManager
        LoginManager loginManager = LoginManager.newInstance(mApplicationContext);

        //初始化IMManager
        IMManager imManager = IMManager.newInstance(mApplicationContext);
        loginManager.addListener(imManager);

        //初始化推流转换器
        ChangeVideoPushManager.newInstance();

        //Fresco库初始化--忽略所有https证书验证
        ImagePipelineConfig config = ImagePipelineConfig.newBuilder(context)
                .setDownsampleEnabled(true)
                .setNetworkFetcher(new TrusAllSSLHttpsUrlConnNetFetcher()) // 这里设置自定义类
                .build();
        Fresco.initialize(mApplicationContext,config);

        //http请求工具类
        LiveRequestOperator.newInstance(mApplicationContext);

//        //接入公共模块
//        ServiceManager.getInstance(mApplicationContext).registerService(LiveService.getInstance(mApplicationContext));

        //初始化pushManager
        PushManager.newInstance(mApplicationContext);


        //本地环境根据配置获取入口同步配置的host地址
        RequestJni.SetConfigSite(mApplicationContext.getResources().getString(R.string.webHost));
//        RequestJni.SetConfigSite("172.25.32.17:8817");
    }

    public boolean openUrl(Context context, String url) {
        //传递Url给MainFragmentActivity
        Log.i(TAG, "openUrl url:%s ", url);
        MainFragmentActivity.launchActivityWIthUrl(context, url);
        return true;
    }

    /**
     * 打开App
     * @param context
     * @param url
     */
    public void openAppWithUrl(Context context, String url){
        //关掉其它界面
        context.sendBroadcast(new Intent(CommonConstant.ACTION_KICKED_OFF));

        Intent intent = new Intent(context, LiveLoginActivity.class);
        intent.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, url);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    public void setForTest(boolean isForTest) {
        Log.i(TAG, "setForTest isForTest: " + isForTest);
        this.isForTest = isForTest;
        if (isForTest) {
            Log.SetLevel(android.util.Log.DEBUG);
        }
        else {
            Log.SetLevel(android.util.Log.ERROR);
        }
    }

    public boolean stopService() {
        IMManager.getInstance().stopLiveServiceLocal();
        return true;
    }

    /**
     * 添加买点跳转由主模块处理
     */
    public void onAddCreditClick(Context context){
        Log.i(TAG, "onAddCreditClick event");
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

    /***************************** 服务状态统计  *****************************************/
    /**
     * 检测url是否与当前模块冲突
     * @param url
     * @return
     */
    public boolean checkServiceConflict(String url){
        //直播处理过程中，任何url处理都需要停止当前直播服务
        return IMManager.getInstance().isCurrentInLive();
    }

    /**
     * 服务冲突提示
     * @param url
     * @return
     */
    public String getServiceConflictTips(String url) {
        Log.d(TAG,"getServiceConflictTips-url:"+url);
        //如果是hangout直播间邀请类型
        if(URL2ActivityManager.getInstance().isHangOutRoom(url)){
            IMUserBaseInfoItem userInfo = URL2ActivityManager.getInstance().getUserBaseInfo(url);
            if(null != userInfo && !TextUtils.isEmpty(userInfo.nickName)){
                return mApplicationContext.getResources().getString(R.string.hangout_serving_conflict_tips,userInfo.nickName);
            }
        }
        //其他类型一律按照私密邀请提示来
        return mApplicationContext.getResources().getString(R.string.live_serving_conflict_tips);
    }

    /**
     * push点击，主模块接收后，通知子模块完成GA统计，仅用于GA统计
     * @param url
     */
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
}
