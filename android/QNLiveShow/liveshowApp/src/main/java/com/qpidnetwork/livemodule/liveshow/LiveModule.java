package com.qpidnetwork.livemodule.liveshow;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestGetValidateCodeCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestSidCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LSOrderType;
import com.qpidnetwork.livemodule.httprequest.item.LSValidateCodeType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechathttprequest.LivechatRequestOperator;
import com.qpidnetwork.livemodule.livemessage.LMClient;
import com.qpidnetwork.livemodule.livemessage.LMManager;
import com.qpidnetwork.livemodule.liveshow.authorization.DomainManager;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.liveshow.manager.ShowUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigerManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.manager.VersionCheckManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.pay.LiveBuyCreditActivity;
import com.qpidnetwork.livemodule.liveshow.pay.LiveBuyStampActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;
import com.qpidnetwork.qnbridgemodule.bean.RequestErrorCodeCommon;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.interfaces.IModule;
import com.qpidnetwork.qnbridgemodule.interfaces.IModuleListener;
import com.qpidnetwork.qnbridgemodule.interfaces.OnGetTokenCallback;
import com.qpidnetwork.qnbridgemodule.interfaces.OnGetVerifyCodeCallback;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import net.qdating.LSConfig;

import static com.qpidnetwork.livemodule.liveshow.authorization.LoginManager.LoginStatus.Default;
import static com.qpidnetwork.livemodule.liveshow.authorization.LoginManager.LoginStatus.Logined;

public class LiveModule implements IModule, IAuthorizationListener {

    private static final String TAG = LiveModule.class.getName();

    private Application mApplication;
    private IModuleListener mModuleListener;
    private Context mContext;

    //是否模块第一次启动
    public static boolean mIsFirstLaunch = false;
    //是否debug环境
    public static boolean mIsDebug = false;
    //外部链接打开传入用于调试参数
    private boolean mIsForTest = false;        //业务需要
    //是否被踢
//    private boolean mIsKickOff = false;
    //记录最顶部Activity
    private BaseFragmentActivity mTopActivity;

    /***************************************  单例模式  *************************************/
    private static LiveModule mLiveModule;
    public static LiveModule newInstance(Application c){
        if(mLiveModule == null){
            mLiveModule = new LiveModule(c);
        }
        return mLiveModule;
    }

    public static LiveModule getInstance(){
        return mLiveModule;
    }


    public LiveModule(Application context){
        mContext = context;
        initWithinApplication(context);
    }

    private void initWithinApplication(Application context){
        mIsFirstLaunch = true;
        mApplication = context;

        //登录管理类(跨域名)
        DomainManager.newInstance(context);

        //初始化下载器
        FileDownloadManager.init(context,true);

        //http请求Jni初始化
        try {
            PackageManager pm = context.getPackageManager();
            PackageInfo pi = pm.getPackageInfo(context.getPackageName(), PackageManager.GET_ACTIVITIES);
            if (pi != null) {
                //是否demo环境
                mIsDebug = pi.versionName.matches(".*[a-zA-Z].*");
                // 版本号
                RequestJni.SetVersionCode(String.valueOf(pi.versionCode));
                // 设备Id
//                TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
                // 设备Id
                RequestJni.SetDeviceId(SystemUtils.getDeviceId(context));
                // 设置appId
                RequestJni.SetAppId(context.getPackageName());
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        // 设置demo请求环境
        if( mIsDebug ) {
            RequestJni.SetAuthorization("test", "5179");
        }

        // 设置log级别（demo环境才打印log）
        if (mIsDebug) {
            //配置处理推流播流器demo环境打开log
            LSConfig.LOG_LEVEL = android.util.Log.WARN;
        }
        else {
            //配置处理推流播流器正式环境关闭Log
            LSConfig.LOG_LEVEL = android.util.Log.ERROR;
        }

        // 初始化GA管理器
        if (mIsDebug) {
            AnalyticsManager.newInstance().init(context, R.xml.live_tracker_demo,true);
        }
        else {
            AnalyticsManager.newInstance().init(context, R.xml.live_tracker,false);
        }

        //初始化LoginManager单例
        LoginManager loginManager = LoginManager.newInstance(context);
        loginManager.register(this);

        // LiveChat
        LiveChatManager liveChatManager = LiveChatManager.newInstance(mApplication);
        loginManager.register(liveChatManager);

        // 最近联系人
        ContactManager ctm = ContactManager.newInstance(mApplication);
        loginManager.register(ctm);

        //初始化私信
        LMManager lmManager = LMManager.newInstance(context);

        //初始化IMManager
        IMManager imManager = IMManager.newInstance(context);

        //未读初始化
        ShowUnreadManager showUnreadManager = ShowUnreadManager.newInstance(context);
        loginManager.register(showUnreadManager);
        lmManager.registerLMLiveRoomEventListener(showUnreadManager);

        //http请求工具类
        LiveRequestOperator.newInstance(context);
        LiveDomainRequestOperator.newInstance(context);
        LivechatRequestOperator.newInstance(context);

        //初始化同步配置
        SynConfigerManager.newInstance(context);

        //初始化版本检测单例
        VersionCheckManager.newInstance(context);

        //初始化pushManager
        PushManager.newInstance(mApplication);
    }

    @Override
    public void initOrResetModule(WebSiteBean website) {
        //本地文件Log存放地址
        RequestJni.SetLogDirectory(FileCacheManager.getInstance().GetLogPath());
        //IM本地log
        IMClient.IMSetLogDirectory(FileCacheManager.getInstance().getIMLogPath());
        //增加私信本地打印log路径
        LMClient.LMSetLogDirectory(FileCacheManager.getInstance().getLMLogPath());
        if(mIsDebug){
            LSConfig.LOGDIR = FileCacheManager.getInstance().GetPublisherPlayerLogLocalPath();
        }else{
            LSConfig.LOGDIR = "";
        }

        //同步配置域名
        String configSite = website.getWebSiteHost();
        RequestJni.SetConfigSite(configSite);
        //设置app域名
        String appDomainSite = website.getWebSiteHost();
        RequestJni.SetWebSite(appDomainSite);
        //设置app域名
        String profileDomain = website.getAppSiteHost();
        RequestJni.SetDomainSite(profileDomain);
    }

    @Override
    public boolean isModuleLogined() {
        return LoginManager.getInstance().getLoginStatus() != Default;
    }

    @Override
    public void getWebSiteToken(WebSiteConfigManager.WebSiteType targetWebsiteType, final OnGetTokenCallback callback) {
        WebSiteBean webSiteBean = WebSiteConfigManager.getInstance().getWebsiteByWebType(targetWebsiteType);
        if(webSiteBean != null){
            LiveRequestOperator.getInstance().GetAuthToken(webSiteBean.getSiteId(), new OnRequestSidCallback() {
                @Override
                public void onRequestSid(boolean isSuccess, int errCode, String errMsg, String memberId, String sid) {
                    String userId = "";
                    LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                    if(loginItem != null && !TextUtils.isEmpty(loginItem.userId)){
                        userId = loginItem.userId;
                    }
                    callback.onGetToken(sid, userId);
                }
            });
        }else{
            callback.onGetToken("", "");
        }
    }

    @Override
    public void login(String email, String password, String checkcode) {
        LoginManager.getInstance().loginByUsernamePassword(email, password, checkcode);
    }

    @Override
    public void loginByToken(String token, String memberId) {
        LoginManager.getInstance().loginByToken(memberId, token);
    }

    @Override
    public void getVerifyCode(final OnGetVerifyCodeCallback callback) {
        RequestJniAuthorization.GetValidateCode(LSValidateCodeType.login, new OnRequestGetValidateCodeCallback(){

            @Override
            public void OnGetValidateCode(boolean isSuccess, int errno, String errmsg, byte[] data) {
                if(callback != null){
                    callback.onGetVerifyCode(isSuccess, String.valueOf(errno), errmsg, data);
                }
            }
        });
    }

    @Override
    public void logout() {
        LoginManager.getInstance().logout(true);
    }

    @Override
    public void launchModuleWithUrl(String token, String url, boolean isNeedBackHome) {
        //待实现，打开模块
        if(mTopActivity != null){
            if(URL2ActivityManager.getInstance().doCheckModuleOpenNewPage(url) && !isNeedBackHome) {
                new AppUrlHandler(mTopActivity).urlHandle(url);
            }else{
                //启动home页再打开
                MainFragmentActivity.launchActivityWIthUrl(mApplication, token, url);
            }
        }else{
            //直播模块未启动
            MainFragmentActivity.launchActivityWIthUrl(mApplication, token, url);
        }
    }

    @Override
    public boolean checkServiceConflict(String url) {
        boolean isConflict = false;
        boolean isCurrentInLive = IMManager.getInstance().isCurrentInLive();
        if(isCurrentWebSite(url)){
            //url
            if(isCurrentInLive && URL2ActivityManager.getInstance().doCheckModuleConflict(url)){
                isConflict = true;
            }
        }else{
            //url跳转目标非当前模块
            isConflict = isCurrentInLive;
        }
        return isConflict;
    }

    @Override
    public String getServiceConflictTips(String url) {
        return mApplication.getResources().getString(R.string.live_serving_conflict_tips);
    }

    @Override
    public String getModuleServiceName() {
        return CoreUrlHelper.KEY_URL_SERVICE_NAME_LIVE;
    }

    @Override
    public boolean stopFunctions() {
        IMManager.getInstance().stopLiveServiceLocal();
        return true;
    }

    @Override
    public void setOnMoudleListener(IModuleListener moduleListener) {
        this.mModuleListener = moduleListener;
    }

    @Override
    public void setForTest(boolean isForTest) {
        this.mIsForTest  = isForTest;
    }

    @Override
    public void setProxy(String proxyUrl) {
        //设置http代理
        RequestJni.SetProxy(proxyUrl);
    }

    @Override
    public void onPushClickGAReport(String url) {
        Log.i(TAG, "onPushClickGAReport url:%s ", url);
        String moduleName = URL2ActivityManager.getInstance().getModuleNameByUrl(url);
        AnalyticsManager instance = AnalyticsManager.getsInstance();
        if(!TextUtils.isEmpty(moduleName) && (instance != null)){
            if(moduleName.equals(LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_ROOM)){
                if(!TextUtils.isEmpty(URL2ActivityManager.getInstance().getShowLiveIdByUrl(url))){
                    //节目push点击
                    instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Calendar_Category),
                            mApplication.getResources().getString(R.string.Live_Calendar_Action_showStart_click),
                            mApplication.getResources().getString(R.string.Live_Calendar_Label_showStart_click));
                }else if(TextUtils.isEmpty(URL2ActivityManager.getInstance().getRoomIdByUrl(url))){
                    //房间号为空，则为主播邀请
                    instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Global_Category),
                            mApplication.getResources().getString(R.string.Live_Global_Action_ClickInvitation),
                            mApplication.getResources().getString(R.string.Live_Global_Label_ClickInvitation));
                }else{
                    //预约到期
                    instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Global_Category),
                            mApplication.getResources().getString(R.string.Live_Global_Action_ClickBookingStart),
                            mApplication.getResources().getString(R.string.Live_Global_Label_ClickBookingStart));
                }
            }else if(moduleName.equals(LiveUrlBuilder.KEY_URL_MODULE_NAME_CHAT_LIST)
                    || moduleName.equals(LiveUrlBuilder.KEY_URL_MODULE_NAME_CHAT)){
                //push点击打开私信
                instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Message_Category),
                        mApplication.getResources().getString(R.string.Live_Message_Action_Push_Click),
                        mApplication.getResources().getString(R.string.Live_Message_Label_Push_Click));
            }else if(moduleName.equals(LiveUrlBuilder.KEY_URL_MODULE_NAME_MAIL_LIST)){
                //push点击打开mail
                instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Mail_Category),
                        mApplication.getResources().getString(R.string.Live_Mail_Action_Push_Click),
                        mApplication.getResources().getString(R.string.Live_Mail_Label_Push_Click));
            }else if(moduleName.equals(LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_CHAT)){
                //push点击打开Livechat
                instance.ReportEvent(mApplication.getResources().getString(R.string.Live_LiveChat_Category),
                        mApplication.getResources().getString(R.string.Live_LiveChat_Action_PushClick),
                        mApplication.getResources().getString(R.string.Live_LiveChat_Label_PushClick));
            }
        }
    }

    @Override
    public void onModuleGAEvent(String category, String action, String label) {
        //换站等公共统计逻辑
        AnalyticsManager.newInstance().ReportEvent(
                category
                , action
                , label);
    }

    /**************************************  模块内部登录注销事件回调  ***************************************/

    /**
     * 调用通知中心，发送push
     */
    public void showSystemNotification(NotificationTypeEnum type, String title, String tickerText, String pushActionUrl, boolean isAutoCancel){
        if(mModuleListener != null){
            mModuleListener.onPushNotification(type, title, tickerText, pushActionUrl, isAutoCancel);
        }
        //GA统计，收到主播邀请/预约到期
        AnalyticsManager instance = AnalyticsManager.getsInstance();
        if(instance != null) {
            if (type == NotificationTypeEnum.ANCHORINVITE_NOTIFICATION) {
                instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Global_Category),
                        mApplication.getResources().getString(R.string.Live_Global_Action_ShowInvitation),
                        mApplication.getResources().getString(R.string.Live_Global_Label_ShowInvitation));
            } else if (type == NotificationTypeEnum.SCHEDULEINVITE_NOFICATION) {
                instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Global_Category),
                        mApplication.getResources().getString(R.string.Live_Global_Action_ShowBookingStart),
                        mApplication.getResources().getString(R.string.Live_Global_Label_ShowBookingStart));
            } else if(type == NotificationTypeEnum.PROGRAMSTART_NOTIFICATION){
                instance.ReportEvent(mApplication.getResources().getString(R.string.Live_Calendar_Category),
                        mApplication.getResources().getString(R.string.Live_Calendar_Action_showStart_notify),
                        mApplication.getResources().getString(R.string.Live_Calendar_Label_showStart_notify));
            }
        }
    }

    /**
     * 清除指定类型的通知
     * @param type
     */
    public void cancelNotification(NotificationTypeEnum type){
        if(mModuleListener != null){
            mModuleListener.cancelNotification(type);
        }
    }

    /**
     * 清除通知中心所有通知
     */
    public void cancelAllNotification(){
        if(mModuleListener != null){
            mModuleListener.cancelAllNotification();
        }
    }

    /**
     * 去中心检测是否服务冲突或需要换站
     * @param url
     * @return
     */
    public boolean urlCoreInterrupt(String url){
        boolean isHandle = false;
        if(mModuleListener != null){
            isHandle = mModuleListener.onMoudleUrlHandle(url);
        }
        return isHandle;
    }


    /**
     * 判断是否当前站点
     * @param url
     * @return
     */
    private boolean isCurrentWebSite(String url){
        boolean isCurrentWebSite = true;
        String siteId = CoreUrlHelper.getUrlSiteId(url);
        WebSiteConfigManager.WebSiteType siteType = WebSiteConfigManager.getInstance().ParsingWebSite(siteId);
        if(siteType != null && siteType != WebSiteConfigManager.getInstance().getCurrentWebSiteType()){
            isCurrentWebSite = false;
        }
        return isCurrentWebSite;
    }

    /**
     * 获取是否为test使用
     * @return
     */
    public boolean getForTest(){
        Log.i(TAG, "getForTest isForTest: " + mIsForTest);
        return mIsForTest;
    }

    /**
     * 点击左侧选择站点换站处理
     * @param webSiteBean
     */
    public void doChangeWebSite(WebSiteBean webSiteBean){
        if(mModuleListener != null && webSiteBean != null){
            WebSiteConfigManager.WebSiteType webSiteType = WebSiteConfigManager.ParsingWebSiteLocalId(String.valueOf(webSiteBean.getSiteId()));
            mModuleListener.doChangeWebSite(webSiteType);
        }
    }
        //TODO


    /**
     * 在直播端 显示换站对话框
     */
    public void onChangeWebsiteDialogShow(Activity activityTarget){
        if(mModuleListener != null){
            mModuleListener.onChangeWebsiteDialogShow(activityTarget, true);
        }
    }

    /**
     * 买点通知提交AppsFlyer事件
     * @param params
     */
    public void onAppsFlyerEventNotify(String params){
        if(mModuleListener != null){
            mModuleListener.onAppsFlyerEventNotify(params);
        }
    }

    /**************************************  模块内部统一处理  ***************************************/

    /**
     * 没信用点统一错误处理
     */
    public void onAddCreditClick(Context context, NoMoneyParamsBean params){

        //容错处理
        int orderTypeIndex = 0;
        if(params != null && params.orderType != null){
            orderTypeIndex = params.orderType.ordinal();
        }
        //打开买点页
        if(orderTypeIndex == LSOrderType.stamp.ordinal()){
            LiveBuyStampActivity.lunchActivity(context, orderTypeIndex, params.clickFrom, params.number);
        }else{
            LiveBuyCreditActivity.lunchActivity(context, orderTypeIndex, params.clickFrom, params.number, params.orderNo);
        }
    }

    /**
     * 模块session过期处理
     */
    public void onModuleSessionOverTime() {
        //TODO

    }

    /**
     * 模块被踢
     */
    public void onModuleKickoff(String errMsg) {
        //TODO
        //参考QN QpidApplication : onApplicationKickOff
        LoginManager loginManager = LoginManager.getInstance();
        if(loginManager != null //&& !mIsKickOff
                && loginManager.getLoginStatus() == Logined ){
            //先注销再跳转
            loginManager.LogoutAndClean(true);

//            mIsKickOff = true;
//            QpidApplication.mKickOffDesc = desc;
//            QpidApplication.lastestKickoffTime = (int)(System.currentTimeMillis()/1000);

            String strKickOffTips = mContext.getString(R.string.live_kickoff_by_im);
            if(!TextUtils.isEmpty(errMsg)){
                strKickOffTips = errMsg;
            }

            if(SystemUtils.isBackground(mContext)){
                PushManager pushManager = PushManager.getInstance();
                if(pushManager != null){
                    pushManager.ShowNotification(NotificationTypeEnum.KICKOFF_NOTIFICATION, mContext.getString(R.string.app_name), strKickOffTips, "", true);
                }
            }

            //被踢跳转
            MainFragmentActivity.launchActivityWIthKickoff(mContext, strKickOffTips);
        }
    }

    /**************************************** 存储注销最顶部Activity **************************************/
    /**
     * 更新赋值
     * @param activity
     */
    public void updateLiveTopActivity(BaseFragmentActivity activity){
        this.mTopActivity = activity;
    }

    /**
     * 注销之前的赋予
     * @param activity
     */
    public void destroyTopActivity(BaseFragmentActivity activity){
        if(mTopActivity == activity){
            //地址完全匹配即可
            mTopActivity = null;
        }
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        if(mModuleListener != null){
            String errNo = "";
            String userId = "";
            if(item != null){
                userId = item.userId;
            }
            mModuleListener.onLogin(isSuccess, switchErroNoToCommon(errCode), errMsg, userId);
        }
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    /**
     * 转换错误码到公共，用于公共处理多模块差异化
     * @return
     */
    private String switchErroNoToCommon(int errCode){
        String errNo = "";
        HttpLccErrType lccErrType = IntToEnumUtils.intToHttpErrorType(errCode);
        switch (lccErrType) {
            case HTTP_LCC_ERR_CONNECTFAIL:{
                errNo = RequestErrorCodeCommon.COMMON_LOCAL_ERROR_CODE_TIMEOUT;
            }break;
            case HTTP_LCC_ERR_PLOGIN_PASSWORD_INCORRECT:{
                errNo = RequestErrorCodeCommon.COMMON_USERNAME_PASSWORD_ERROR;
            }break;
            case HTTP_LCC_ERR_PLOGIN_ENTER_VERIFICATION:
            case HTTP_LCC_ERR_PLOGIN_VERIFICATION_WRONG:{
                // 验证码无效
                errNo = RequestErrorCodeCommon.COMMON_VERIFYCODE_INVALID;
            }break;
            default:{
                errNo = RequestErrorCodeCommon.COMMON_LOCAL_ERROR_DEFAULT;
            }break;
        }
        return errNo;
    }
}
