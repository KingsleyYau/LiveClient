package com.qpidnetwork.livemodule.liveshow.login;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.adapter.TieAdapter;
import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.listener.DialogUIItemListener;
import com.facebook.CallbackManager;
import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.FacebookSDKManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.manager.SynConfigManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.manager.UpdateManager;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.Dialogs.DialogNormal;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.functions.Consumer;

import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_FACEBOOK_EXIST_QN_MAILBOX;
import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX;
import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.LOCAL_ERR_FACEBOOL_LOGIN_FAIL;

/**
 * 登录界面
 * Created by Jagger on 2017/12/19.
 */
public class LiveLoginActivity extends BaseFragmentActivity implements IAuthorizationListener {

    public static final String KEY_OPEN_TYPE = "liveLoginActivity.KEY_OPEN_TYPE";
    public static final String KEY_OPEN_MESSAGE_DESC = "open_message";
    public static final int OPEN_TYPE_NORMAL = 1000;
    public static final int OPEN_TYPE_LOGOUT = 1001;
    public static final int OPEN_TYPE_FORCE_UPDATE = 1002;
    public static final int OPEN_TYPE_AUTO_LOGIN = 1003;
    public static final int OPEN_TYPE_KICK_OFF = 1004;

    public static final String ACTION_AUTO_LOGIN = "com.qpidnetwork.livemodule.liveshow.ACTION_AUTO_LOGIN";
    public static final String ACTION_CLOSE = "com.qpidnetwork.livemodule.liveshow.ACTION_CLOSE";

    //控件
    private FrameLayout mFlFaceBook , mFlMail;
    private TextView mTextViewLink;

    //变量
    private String mStrBgFileName = "login_bg.webp";
    private CallbackManager callbackManager;
//    private FacebookCallback facebookCallback;
    private int mOpenType = OPEN_TYPE_NORMAL;   //打开方式
    private String mOpenMessage = "";           //打开携带显示信息
    private String launchModule = "";           //记录外部传入参数

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_login);
        TAG = LiveLoginActivity.class.getSimpleName();
        initView();
        initLaunchData();
        initData();
        doForNewIntent();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        setIntent(intent);
        initLaunchData();
        doForNewIntent();
    }

    /**
     * 启动
     * @param context
     */
    public static void show(Context context ){
        show(context , OPEN_TYPE_NORMAL, "");
    }

    /**
     * 启动
     * @param context
     * @param openType  启动方式
     */
    public static void show(Context context, int openType, String message){
        Intent i  = new Intent(context , LiveLoginActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
        i.putExtra(KEY_OPEN_TYPE , openType);
        i.putExtra(KEY_OPEN_MESSAGE_DESC , message);
        context.startActivity(i);
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(myReceiver);
    }

    private void initView(){
        //背景
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_ASSET_SCHEME)
                .path(mStrBgFileName)
                .build();
        SimpleDraweeView simpleDraweeView = (SimpleDraweeView)findViewById(R.id.main_sdv5);
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setAutoPlayAnimations(true)
                .build();
        simpleDraweeView.setController(controller);

        //按钮
        mFlFaceBook= (FrameLayout)findViewById(R.id.fl_login_facebook);
        mFlFaceBook.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedFaceBook();
            }
        });
        mFlMail= (FrameLayout)findViewById(R.id.fl_login_email);
        mFlMail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedEmail();
            }
        });

        //底部文字
        mTextViewLink = (TextView)findViewById(R.id.txt_guide_link);
        //底部连接文字
        SpannableString spanTextTU=new SpannableString(getString(R.string.live_login_tips2));
        spanTextTU.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.WHITE);       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                ConfigItem configItem = SynConfigManager.getSynConfigItem();
                Log.d(TAG,"termsOfUse-onClick-configItem:"+configItem);
                if(null != configItem && !TextUtils.isEmpty(configItem.termsOfUse)){
                    onClickedLink(getString(R.string.live_login_tips2),configItem.termsOfUse);
                }

            }
        }, 0 , spanTextTU.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

        SpannableString spanTextPP=new SpannableString(getString(R.string.live_login_tips3));
        spanTextPP.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.WHITE);       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                ConfigItem configItem = LoginManager.getInstance().getSynConfig();
                Log.d(TAG,"privacyPolicy-onClick-configItem:"+configItem);
                if(null != configItem && !TextUtils.isEmpty(configItem.privacyPolicy)){
                    onClickedLink(getString(R.string.live_login_tips3),configItem.privacyPolicy);
                }
            }
        }, 0 , spanTextPP.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

        mTextViewLink.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        mTextViewLink.append(" ");
        mTextViewLink.append(spanTextTU);
        mTextViewLink.append(" and ");
        mTextViewLink.append(spanTextPP);
        mTextViewLink.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件
    }

    private void initData(){
        //Facebook用到
        callbackManager = FacebookSDKManager.getInstance().getCallbackManager();
//        facebookCallback = FacebookSDKManager.getInstance().getLoginFacebookCallback();
//        FacebookSDKManager.getInstance().registerLoginCallBack(this);

        //不需要监听注销广播
        setKickedOffReceiverEnable(false);

        //注册广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_AUTO_LOGIN);
        filter.addAction(ACTION_CLOSE);
        registerReceiver(myReceiver, filter);

    }

    /**
     * 初始化外部初始化参数
     */
    private void initLaunchData(){
        Intent i_getvalue = getIntent();
        String action = i_getvalue.getAction();
        if(Intent.ACTION_VIEW.equals(action)){
            Uri uri = i_getvalue.getData();
            if(uri != null){
//		    	launchModule = uri.getQueryParameter("module")

                // 增加GA跟踪代码
                String moduleName = uri.getQueryParameter("module");
                String ladyID = uri.getQueryParameter("ladyid");
                String source = uri.getQueryParameter("source");
                launchModule = URL2ActivityManager.uriToUrl(uri);


                //serviceManager检测fortest字段
                boolean isForTest = URL2ActivityManager.readForTestFlags(launchModule);
                LiveService.getInstance().setForTest(isForTest);

                String gaAction = !TextUtils.isEmpty(source) ? source : "unknow";
                String gaLabel = !TextUtils.isEmpty(moduleName) ? moduleName : "index";
                String gaCategory = getString(R.string.OpenApp_Category);

                // 统计activity event
                AnalyticsManager.newInstance().ReportEvent(gaCategory, gaAction, gaAction + getString(R.string.OpenApp_Label) + gaLabel);
            }
        }else{
            Bundle extra = getIntent().getExtras();
            if(extra != null){
                if(extra.containsKey(CommonConstant.KEY_PUSH_NOTIFICATION_URL)){
                    launchModule = extra.getString(CommonConstant.KEY_PUSH_NOTIFICATION_URL);
                }

                if(extra.containsKey(KEY_OPEN_TYPE)){
                    mOpenType = extra.getInt(KEY_OPEN_TYPE);
                }

                if(extra.containsKey(KEY_OPEN_MESSAGE_DESC)){
                    mOpenMessage = extra.getString(KEY_OPEN_MESSAGE_DESC);
                }
            }
        }
    }

    /**
     * 处理传入参数
     */
    private void doForNewIntent(){
        Log.i("Jagger" , "LiveLoginActivity doForNewIntent mOpenType:" + mOpenType );

        //根据启动方式去处理
        if(mOpenType == OPEN_TYPE_NORMAL){
            //同步配置
            doGetSynConfig();
        }else if(mOpenType == OPEN_TYPE_AUTO_LOGIN){
            //自动登录
            autoLogin();
        }else if(mOpenType == OPEN_TYPE_FORCE_UPDATE){
            //强制更新
            Log.i("Jagger" , "LiveLoginActivity:强制更新" );
            showForceUpdateDialog();
        }else if(mOpenType == OPEN_TYPE_LOGOUT){
            //注销
            Log.i("Jagger" , "LiveLoginActivity:注销" );
            showToast(getString(R.string.live_logout_tips));
        }else if(mOpenType == OPEN_TYPE_KICK_OFF){
            //被踢
            Log.i("Jagger" , "LiveLoginActivity:被踢" );
            if(!TextUtils.isEmpty(mOpenMessage)){
                showToast(mOpenMessage);
            }else{
                showToast(getString(R.string.session_timeout_kick_off_tips));
            }
        }else{
            doGetSynConfig();
        }
    }

    /**
     * 自动登录
     */
    private void autoLogin(){
        if(!LoginManager.getInstance().isCanAutoLogin()){
            return;
        }

        //注册监听管理器
        LoginManager.getInstance().addListener(this);
        //登录去
        LoginManager.getInstance().autoLogin();
        //test
        DialogUIUtils.showTie(this, "autoLogin...");
    }

    /**
     * 取同步配置
     */
    private void doGetSynConfig(){
        final SynConfigManager synConfigManager = new SynConfigManager(this);
        synConfigManager.setSynConfigResultObserver(new Consumer<SynConfigManager.ConfigResult>() {
            @Override
            public void accept(SynConfigManager.ConfigResult configResult) throws Exception {
                Log.d(TAG,"doGetSynConfig-accept:"+configResult);
                if(configResult.isSuccess){
                    //取同步配置成功
                    //设置app域名
                    RequestJni.SetWebSite(configResult.item.httpServerUrl);
                    //自动登录
                    autoLogin();
                }else {
                    //取同步配置失败
                    showToast(configResult.errMsg);
                }

                //取消监听
                synConfigManager.dispose();
            }
        }).doRequestSynConfig();
    }

    /**
     * 广播接收器
     */
    private BroadcastReceiver myReceiver = new BroadcastReceiver(){

        @Override
        public void onReceive(Context context, Intent intent) {
            // TODO Auto-generated method stub
            if(intent.getAction().equals(ACTION_AUTO_LOGIN)){
                autoLogin();
            }else if(intent.getAction().equals(ACTION_CLOSE)){
                //注册监听管理器
                LoginManager.getInstance().removeListener(LiveLoginActivity.this);
                //
                finish();
            }
        }

    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.i("Jagger" , "LiveLoginActivity onActivityResult");
        if(null != callbackManager){
            //不论通过callbackManager跟踪登陆结果，还是通过accessTokenTracker监听token变化，两种方式都需要调用
            //callbackManager.onActivityResult(requestCode,resultCode,data);以便将登录结果传递到callbackManager中
            //集成到facebook sdk登录或者分享功能的所有activity和fragment都应将onActivityResult转发到callbackManager
            callbackManager.onActivityResult(requestCode,resultCode,data);
        }
    }

    /**
     * 点击FaceBook
     */
    private void onClickedFaceBook(){
        //test
        DialogUIUtils.showTie(this, "login...");
        //注册监听管理器
        LoginManager.getInstance().addListener(this);
        //
        LoginManager.getInstance().authorizedLogin(LoginManager.LoginType.FACEBOOK , this);

        //GA统计，点击Facebook登录
        onAnalyticsEvent(getResources().getString(R.string.Live_Facebook_Category),
                getResources().getString(R.string.Live_Facebook_Action_Login),
                getResources().getString(R.string.Live_Facebook_Label_Login));
    }

    /**
     * 点击E-mail
     */
    private void onClickedEmail(){
        showEmailLoginMenu();
    }

    /**
     * 底部菜单--EmailLogin
     */
    private void onClickedMenuEmailLogin(){
        Intent i = new Intent(mContext , LiveEmailLoginActivity.class);
        i.putExtra(CommonConstant.KEY_PUSH_NOTIFICATION_URL, launchModule);
        startActivity(i);
    }

    /**
     * 底部菜单--EmailSingup
     */
    private void onClickedMenuEmailSingup(){
        Intent i = new Intent(mContext , LiveEmailSignUpActivity.class);
        startActivity(i);
    }

    /**
     * 点击连接
     */
    private void onClickedLink(String title, String url){
        Log.logD(TAG,"onClickedLink-title:"+title+" url:"+url);
        if(LoginManager.getInstance().getSynConfig() != null){
            startActivity(WebViewActivity.getIntent(this,
                    title,
                    IPConfigUtil.addCommonParamsToH5Url(url),
                    true));

        }
    }

    /**
     * Email菜单列表
     */
    private void showEmailLoginMenu(){
        //列表选项
        TieBean tieLogin = new TieBean(getString(R.string.live_login_with_email));
        tieLogin.setColor(getResources().getColor(R.color.common_bottom_item_simple));
        tieLogin.setGravity(Gravity.CENTER);

        TieBean tieSignup = new TieBean(getString(R.string.live_sign_up_with_email));
        tieSignup.setColor(getResources().getColor(R.color.common_bottom_item_simple));
        tieSignup.setGravity(Gravity.CENTER);

        TieBean tieCancel = new TieBean(getString(R.string.common_btn_cancel));
        tieCancel.setColor(getResources().getColor(R.color.common_bottom_item_cancel));
        tieCancel.setGravity(Gravity.CENTER);

        List<TieBean> listMenu = new ArrayList<>();
        listMenu.add(tieLogin);
        listMenu.add(tieSignup);
        listMenu.add(tieCancel);

        //对话框
        TieAdapter adapter = new TieAdapter(mContext, listMenu, true);
        BuildBean buildBean = DialogUIUtils.showMdBottomSheet(this, true, "", listMenu, 0, new DialogUIItemListener() {
            @Override
            public void onItemClick(CharSequence text, int position) {
                if(position == 0){
                    onClickedMenuEmailLogin();
                }else if(position == 1){
                    onClickedMenuEmailSingup();
                }
            }
        });
        buildBean.mAdapter = adapter;
        buildBean.show();

    }

    /**
     * 提示 强制更新
     * TODO:UI校对
     */
    private void showForceUpdateDialog(){
        final UpdateManager.UpdateMessage updateMessage = UpdateManager.getInstance(mContext).getUpdateMessage();

        DialogNormal.Builder builder = new DialogNormal.Builder()
                .setContext(mContext)
                .setTitle(getString(R.string.live_update_title))
                .setContent(updateMessage.forceUpdateMsg)
                .cancleable(false)
                .outsideTouchable(false)
                .btnRight(new DialogNormal.Button(
                        getString(R.string.common_btn_ok),
                        false,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if(!TextUtils.isEmpty(updateMessage.downloadAppUrl)){
                                    Uri uri = Uri.parse(updateMessage.downloadAppUrl);
                                    Intent intent = new Intent();
                                    intent.setAction(Intent.ACTION_VIEW);
                                    intent.setData(uri);
                                    startActivity(intent);

                                    finish();
                                }
                            }
                        }
                ));

        DialogNormal.setBuilder(builder).show();
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        DialogUIUtils.dismssTie();
        //反注册(点登录时添加监听就可以了,以免在其它界面有登录事件,会把通知通知到这里)
        LoginManager.getInstance().removeListener(this);

        if(isSuccess){
            //打开HOT列表
            MainFragmentActivity.launchActivityWIthUrl(this, launchModule);
            //暂时不关,为了方便测试
            finish();
        }else{
            HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
            if(errType == HTTP_LCC_ERR_FACEBOOK_NO_MAILBOX || errType == HTTP_LCC_ERR_FACEBOOK_EXIST_QN_MAILBOX){
                //Facebook没有邮箱 或 Facebook邮箱在QN注册过
                LiveFBAddEmailActivity.show(mContext);
            }else if(errType == LOCAL_ERR_FACEBOOL_LOGIN_FAIL){
                //不处理
            }else {
                //其它错误
                showToast(errMsg);
            }
        }
    }

    @Override
    public void onLogout(boolean isMannual) {

    }
}
