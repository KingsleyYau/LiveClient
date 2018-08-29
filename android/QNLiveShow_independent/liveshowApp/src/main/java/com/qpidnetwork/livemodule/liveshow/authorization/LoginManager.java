package com.qpidnetwork.livemodule.liveshow.authorization;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.ManBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.UserType;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.ILoginHandler;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.ILoginHandlerListener;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.onRegisterListener;
import com.qpidnetwork.livemodule.liveshow.authorization.loginHandler.FacebookLoginHandler;
import com.qpidnetwork.livemodule.liveshow.authorization.loginHandler.MailLoginHandler;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.manager.SpeedTestManager;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

import java.util.ArrayList;
import java.util.Iterator;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * 登录工具类
 * Created by Jagger on 2017/12/26.
 */

public class LoginManager implements ILoginHandlerListener {

    private static final String TAG = LoginManager.class.getName();

    private Context mContext;
    //登录工具类
//    private FacebookLoginHandler mFacebookLoginHandler;
//    private MailLoginHandler mMailLoginHandler;
    private ILoginHandler mLoginHandler;
    //登录类型
    private LoginType mLoginType;
    //监听器
    private ArrayList<IAuthorizationListener> mListListener = new ArrayList<>();
    //登录成功，本地数据
    private LoginItem mLoginItem;
    //同步配置信息
    private ConfigItem mConfigItem;     //同步配置返回信息
    //登录状态
    private LoginStatus mLoginStatus = LoginStatus.Logout;

    /**
     * 登录类型
     */
    public enum LoginType{
        EMAIL,
        FACEBOOK
    }

    /**
     * 登录状态
     */
    private enum LoginStatus{
        Logout,
        Logging,
        Logged
    }

    private static LoginManager singleton;

    public static LoginManager getInstance(){
        return singleton;
    }

    public static LoginManager newInstance(Context c) {
        if (singleton == null) {
            singleton = new LoginManager(c);
        }

        return singleton;
    }

    /**
     * 初始化
     * @param c
     */
    private LoginManager(Context c) {
        mContext = c.getApplicationContext();
    }

    /**
     * 取用户信息结果处理
     */
    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);

            if(msg.obj != null ){
                HttpRespObject response = (HttpRespObject)msg.obj;
                ManBaseInfoItem baseInfo = MainBaseInfoManager.getInstance().getLocalMainBaseInfo();

                if(response.isSuccess && (baseInfo != null)){
                    //保存这次登录方式
                    LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
                    localPreferenceManager.saveLoginType(mLoginType);

                    //构建登录信息，兼容旧版本LoginItem
                    Log.i("Jagger" , "mLoginType: " + mLoginType.name());
                    createLocalLoginItem(getLoginHandler(mLoginType).getSessionId(), baseInfo);



                    //提交GA统计ga_uid
                    if(!TextUtils.isEmpty(baseInfo.gaUid)) {
                        AnalyticsManager.newInstance().setGAUserId(baseInfo.gaUid);
                    }

                    //更新礼物配置信息
                    if(!NormalGiftManager.getInstance().isLocalAllGiftConfigExisted()){
                        NormalGiftManager.getInstance().getAllGiftItems(null);
                    }

                    //表情配置
                    ChatEmojiManager.getInstance().getEmojiList(null);

                    //刷新预约列表未读数目
                    ScheduleInvitePackageUnreadManager.getInstance().GetCountOfUnreadAndPendingInvite();

                    //测速
                    if(mConfigItem != null && mConfigItem.svrList != null && mConfigItem.svrList.length > 0){
                        SpeedTestManager.getInstance(mContext).doTest(mConfigItem.svrList);
                    }

                    //更新当前登录状态
                    doUpdateLoginStatus(LoginStatus.Logged);
                    doLoginResultCallBack(true , response.errCode , response.errMsg , mLoginItem);
                }else{
                    //更新当前登录状态
                    doUpdateLoginStatus(LoginStatus.Logout);
                    //如果错误
                    doLoginResultCallBack(false , response.errCode , response.errMsg , null);
//                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
//                    switch (errType){
//                        case :
//                            break;
//                        default:
//                            //请求错误
//                            break;
//                    }
                }
            }

        }
    };

    /**
     * 注册监听器
     * @param listener
     * @return
     */
    public boolean addListener(IAuthorizationListener listener){
        boolean result = false;
        synchronized(mListListener)
        {
            if (null != listener) {
                boolean isExist = false;

                for (Iterator<IAuthorizationListener> iter = mListListener.iterator(); iter.hasNext(); ) {
                    IAuthorizationListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mListListener.add(listener);
                }else {
                    com.qpidnetwork.livemodule.utils.Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist",
                            "OnLoginManagerListener", "addListener",
                            listener.getClass().getSimpleName()));
                }
            }
            else {
                com.qpidnetwork.livemodule.utils.Log.e(TAG, String.format("%s::%s() fail, listener is null",
                        "OnLoginManagerListener", "addListener"));
            }
        }
        return result;
    }

    /**
     * 注销监听器
     * @param listener
     * @return
     */
    public boolean removeListener(IAuthorizationListener listener){
        boolean result = false;
        synchronized(mListListener) {
            result = mListListener.remove(listener);
        }

        if (!result) {
            com.qpidnetwork.livemodule.utils.Log.e(TAG, String.format("%s::%s() fail, listener:%s",
                    "OnLoginManagerListener", "removeListener",
                    listener.getClass().getSimpleName()));
        }
        return result;
    }

    /**
     * 获取登录状态（是否登录了）
     * @return
     */
    public boolean isLogined(){
        return mLoginStatus == LoginStatus.Logged;
    }

    /**
     * 获取用户信息
     * @return
     */
    public LoginItem getLoginItem(){
        return mLoginItem;
    }

    /**
     * 获取同步配置配置内容
     * @return
     */
    public ConfigItem getSynConfig(){
        return SynConfigManager.getSynConfigItem();
    }

    /**
     * 获取登录记录信息
     * @param loginType
     * @return
     */
    public LoginAccount getLoginAccount(LoginType loginType){
        return getLoginHandler(loginType).getLoginAccount();
    }

    /**
     * 构建loginItem
     * @param session
     * @param baseInfoItem
     */
    public void createLocalLoginItem(String session, ManBaseInfoItem baseInfoItem){
        mLoginItem = new LoginItem(baseInfoItem.userId,
                                session,
                                baseInfoItem.nickName,
                                baseInfoItem.userlevel,
                                0,
                                baseInfoItem.photoUrl,
                                false,
                                null,
                                baseInfoItem.userType.ordinal());
    }

    /**
     * 第三方受权登录
     * @param activity
     */
    public void authorizedLogin(final LoginType loginType , final Activity activity){
        if(mLoginStatus == LoginStatus.Logging || mLoginStatus == LoginStatus.Logged){
            return;
        }

        mLoginType = loginType;

        final SynConfigManager synConfigManager = new SynConfigManager(mContext);
        synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
            @Override
            public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                if(configResult.isSuccess){
                    //取同步配置成功
                    mConfigItem = configResult.item;

                    //登录去
                    getLoginHandler(loginType).authorizedLogin(activity);
                }else {
                    //取同步配置失败
                    onLoginServer(false , HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal() , mContext.getString(R.string.liveroom_transition_audience_invite_network_error) ,null);
                }

                //取消监听
                synConfigManager.dispose();
            }
        }).doRequestSynConfig();
    }

    /**
     * 使用email登录
     */
    public void login(final LoginType loginType, final String email, final String password){
        if(mLoginStatus == LoginStatus.Logging || mLoginStatus == LoginStatus.Logged){
            return;
        }

        mLoginType = loginType;
        //更新当前登录状态
        doUpdateLoginStatus(LoginStatus.Logging);

        final SynConfigManager synConfigManager = new SynConfigManager(mContext);
        synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
            @Override
            public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                if(configResult.isSuccess){
                    //取同步配置成功
                    mConfigItem = configResult.item;

                    //登录去
                    getLoginHandler(loginType).login(email , password);
                }else {
                    //取同步配置失败
                    onLoginServer(false , HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal() , mContext.getString(R.string.liveroom_transition_audience_invite_network_error) ,null);
                }

                //取消监听
                synConfigManager.dispose();
            }
        }).doRequestSynConfig();

    }

    /**
     * 能否自动更新
     * @return
     */
    public boolean isCanAutoLogin(){
        //优先使用最近操作过的登录方式
        if(mLoginType != null){
            Log.i("Jagger" , "LoginManager isCanAutoLogin mLoginType:" + mLoginType.name());
            return getLoginHandler(mLoginType).isCanAutoLogin();
        }

        //再使用最近登录成功过的方式
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        LoginType loginType = localPreferenceManager.getLoginType();
        if(loginType != null){
            Log.i("Jagger" , "LoginManager isCanAutoLogin loginType:" + loginType.name());
            return getLoginHandler(loginType).isCanAutoLogin();
        }

        Log.i("Jagger" , "LoginManager isCanAutoLogin false");
        return false;
    }

    /**
     * 自动登录
     * @return 能否自动登录
     */
    public void autoLogin(){
        //优先使用最近操作过的登录方式
        if(mLoginType != null){
            Log.i("Jagger" , "LoginManager autoLogin mLoginType:" + mLoginType.name());
            autoLogin(mLoginType);
            return;
        }

        //再使用最近登录成功过的方式
        LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
        mLoginType = localPreferenceManager.getLoginType();
        if(mLoginType != null){
            Log.i("Jagger" , "LoginManager autoLogin loginType:" + mLoginType.name());
            autoLogin(mLoginType);
            return;
        }
    }

    /**
     * 自动登录(内部方法)
     * @param loginType
     */
    private void autoLogin(final LoginType loginType){
        if(mLoginStatus == LoginStatus.Logging || mLoginStatus == LoginStatus.Logged){
            return;
        }

        //更新当前登录状态
        doUpdateLoginStatus(LoginStatus.Logging);

        final SynConfigManager synConfigManager = new SynConfigManager(mContext);
        synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
            @Override
            public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                Log.i("Jagger" , "SynConfigManager onSynConfig:" + configResult.isSuccess + ",loginType:" + loginType.name());

                if(configResult.isSuccess){
                    //取同步配置成功
                    mConfigItem = configResult.item;

                    //自动登录去
                    getLoginHandler(loginType).autoLogin();
                }else {
                    //取同步配置失败
                    onLoginServer(false , HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal() , mContext.getString(R.string.liveroom_transition_audience_invite_network_error) ,null);
                }

                //取消监听
                synConfigManager.dispose();
            }
        }).doRequestSynConfig();
    }

    /**
     * 注销
     */
    public void logout(){
        Log.i("Jagger" , "logout");
        mLoginItem = null;
        //更新当前登录状态
        doUpdateLoginStatus(LoginStatus.Logout);
        //通知子模块注销
        getLoginHandler(mLoginType).logout(true);
        //回调到监听器
        doLogOutResultCallBack();
    }

    /**
     * 注册
     * @param loginType
     * @param email
     * @param password
     * @param gender
     * @param nickName
     * @param birthday
     * @param inviteCode
     * @param listener
     * @return
     */
    public void register(final LoginType loginType, final String email, final String password, final GenderType gender, final String nickName,
                            final String birthday, final String inviteCode , final onRegisterListener listener){
        //用于注册成功后,能使用正确的方式自动登录
        mLoginType = loginType;

        final SynConfigManager synConfigManager = new SynConfigManager(mContext);
        synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
            @Override
            public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                if(configResult.isSuccess){
                    //取同步配置成功
                    mConfigItem = configResult.item;

                    //注册去
                    getLoginHandler(loginType).register(email , password , gender , nickName , birthday , inviteCode , listener);
                }else {
                    //取同步配置失败
                    onLoginServer(false , HttpLccErrType.HTTP_LCC_ERR_FAIL.ordinal(), mContext.getString(R.string.liveroom_transition_audience_invite_network_error) ,null);
                }

                //取消监听
                synConfigManager.dispose();
            }
        }).doRequestSynConfig();
    }


    /**
     * 被踢下线处理
     * @param kickOffMsg
     */
    public void onKickedOff(String kickOffMsg){
        //注销
        logout();
        //打开登录界面
        LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_KICK_OFF, kickOffMsg);
        //关掉其它界面
        mContext.sendBroadcast(new Intent(CommonConstant.ACTION_KICKED_OFF));
    }

    /**
     * 取Facebook邮箱
     * @return
     */
    public String getAuthorizedEmail(LoginType loginType){
        String email = "";
        if(loginType == LoginType.FACEBOOK){
            ThirdPlatformUserInfo info = (ThirdPlatformUserInfo)getLoginHandler(LoginType.FACEBOOK).getAuthorizedUserInfo();
            if(info != null){
                email = info.email;
            }
        }
        return email;
    }

    /**
     * 取第三方平台资料--性别
     * @return
     */
    public GenderType getAuthorizedGender(LoginType loginType){
        GenderType genderType = GenderType.Man;
        if(loginType == LoginType.FACEBOOK) {
            ThirdPlatformUserInfo info = (ThirdPlatformUserInfo) getLoginHandler(LoginType.FACEBOOK).getAuthorizedUserInfo();
            if (info != null) {
                genderType = info.gender.equals("female") ? GenderType.Lady : GenderType.Man;
            }
        }
        return genderType;
    }

    /**
     * 取第三方平台资料--NickName
     * @return
     */
    public String getAuthorizedNickName(LoginType loginType){
        String name = "";
        if(loginType == LoginType.FACEBOOK) {
            ThirdPlatformUserInfo info = (ThirdPlatformUserInfo) getLoginHandler(LoginType.FACEBOOK).getAuthorizedUserInfo();
            if (info != null) {
                name = info.name;
            }
        }
        return name;
    }

    //--------------------------------------------------------------------------------
    //----------------------------------以下是内部方法----------------------------------
    //--------------------------------------------------------------------------------

    /**
     * 返回对应登录方法的工具类
     * @param loginType
     * @return
     */
    private ILoginHandler getLoginHandler(LoginType loginType){
//        if(loginType == LoginType.FACEBOOK){
//            if(mFacebookLoginHandler == null){
//                mFacebookLoginHandler = new FacebookLoginHandler (mContext);
//                mFacebookLoginHandler.addLoginListener(this);
//            }
//            return mFacebookLoginHandler;
//        }else {
//            //默认用邮箱
//            if(mMailLoginHandler == null){
//                mMailLoginHandler = new MailLoginHandler (mContext);
//                mMailLoginHandler.addLoginListener(this);
//            }
//            return mMailLoginHandler;
//        }

        if(loginType == LoginType.FACEBOOK){
            //Facebook
            if(mLoginHandler != null){
                if( mLoginHandler instanceof FacebookLoginHandler){
                    return mLoginHandler;
                }else{
                    mLoginHandler.destroy();
                }
            }

            Log.i("Jagger" , "LoginManager new FacebookLoginHandler");
            mLoginHandler = new FacebookLoginHandler (mContext);
            mLoginHandler.addLoginListener(this);
        }else {
            //默认用邮箱
            if(mLoginHandler != null){
                if( mLoginHandler instanceof MailLoginHandler){
                    return mLoginHandler;
                }else{
                    mLoginHandler.destroy();
                }
            }

            Log.i("Jagger" , "LoginManager new MailLoginHandler");
            mLoginHandler = new MailLoginHandler (mContext);
            mLoginHandler.addLoginListener(this);
        }
        return mLoginHandler;
    }

    /**
     * 取用户信息
     */
    private void doGetUserMsg(){

        MainBaseInfoManager.getInstance().getMainBaseInfoFromServ(new MainBaseInfoManager.OnGetMainBaseInfoListener() {
            @Override
            public void onGetMainBaseInfo(boolean isSuccess, int errCode, String errMsg) {
                Log.i("Jagger" , "LoginManager doGetUserMsg isSuccess:" + isSuccess + ",errCode:" + errCode + ",errMsg:" + errMsg);
                //到这里才是真正登录结果
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, MainBaseInfoManager.getInstance().getLocalMainBaseInfo());

                Message msg = new Message();
                msg.obj = response;
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 这里是Handler里 登录接口返回的结果,并不代表整个登录流程结束
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    @Override
    public void onLoginServer(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        //将结果封装一下
        final HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);

        //RxJava(这样不需要在mHandler里处理,不需要定义额外的结果代号造成混乱)
        //创建一个上游 Observable：
        Observable<HttpRespObject> observable = Observable.create(new ObservableOnSubscribe<HttpRespObject>() {
            @Override
            public void subscribe(ObservableEmitter<HttpRespObject> emitter) throws Exception {
                Log.i("Jagger" , "LoginManager onLoginServer 发射登录接口的结果");
                //发射登录接口的结果
                emitter.onNext(response);
                emitter.onComplete();
            }
        });

        //建立连接
        observable
                .observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
                .subscribe(getLoginServerResultObserver());
    }

    /**
     * 生成一个监听器,处理Handler里登录接口结果
     * RxJava
     * @return
     */
    private Observer<HttpRespObject> getLoginServerResultObserver (){
        //创建一个下游 Observer
        Observer<HttpRespObject> observer = new Observer<HttpRespObject>() {
            private Disposable mDisposable;

            @Override
            public void onSubscribe(Disposable d) {
                mDisposable = d;
            }

            @Override
            public void onNext(HttpRespObject response) {
                Log.i("Jagger" , "LoginManager getLoginServerResultObserver 接收的结果:" + response.isSuccess);

                if(response.isSuccess){
                    //登录接口返回成功, 下一步去获取用户信息

                    //保存这次登录方式
//                    LocalPreferenceManager localPreferenceManager = new LocalPreferenceManager(mContext);
//                    localPreferenceManager.saveLoginType(mLoginType);

                    //取用户信息
                    Log.i("Jagger" , "LoginManager 取用户信息");
                    doGetUserMsg();
                }else {
                    //更新当前登录状态
                    doUpdateLoginStatus(LoginStatus.Logout);
                    //登录接口返回失败, 就是真的失败了, 回调到外面
                    doLoginResultCallBack(response.isSuccess , response.errCode , response.errMsg , null);
                }
            }

            @Override
            public void onError(Throwable e) {
            }

            @Override
            public void onComplete() {
                //监听结束
                mDisposable.dispose();
            }
        };

        return observer;
    }

    @Override
    public void onLogout() {
        Log.i("Jagger" , "onLogout mListListener");
//        //
//        mLoginItem = null;
//        //回调到监听器
//        doLogOutResultCallBack();
//        //打开登录界面
//        LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_LOGOUT);
//        //关掉其它界面
//        mContext.sendBroadcast(new Intent(CommonConstant.ACTION_KICKED_OFF));
//        //更新当前登录状态
//        doUpdateLoginStatus(LoginStatus.Logout);
    }

    /**
     * 回调登录结果到外面
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    private void doLoginResultCallBack(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLogin(isSuccess , errCode , errMsg , item);
        }
    }

    /**
     * 回调注销结果到外面
     */
    private void doLogOutResultCallBack() {
        for(int i = 0 ; i < mListListener.size(); i ++){
            mListListener.get(i).onLogout(true);
        }
    }

    /**
     * 更新登录状态
     * @param loginStatus
     */
    private void doUpdateLoginStatus(LoginStatus loginStatus){
        mLoginStatus = loginStatus;
    }

}
