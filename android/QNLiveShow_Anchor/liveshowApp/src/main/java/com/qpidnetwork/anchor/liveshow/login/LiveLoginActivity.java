package com.qpidnetwork.anchor.liveshow.login;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.AccountInfoBean;
import com.qpidnetwork.anchor.bean.CommonConstant;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.httprequest.OnRequestGetVerificationCodeCallback;
import com.qpidnetwork.anchor.httprequest.RequestJni;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.anchor.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.anchor.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.liveshow.manager.UpdateManager;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;

import static com.qpidnetwork.anchor.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL;

/**
 * Created by Hunter Mun on 2018/3/5.
 */

public class LiveLoginActivity extends BaseFragmentActivity implements IAuthorizationListener {

    private static final int EVENT_VERIFICATION_CODE = 1;
    private static final int EVENT_LOGIN_CALLBACK = 2;

    public static final String KEY_OPEN_MESSAGE_DESC = "open_message";
    //打开方式
    public static final String KEY_OPEN_TYPE = "liveLoginActivity.KEY_OPEN_TYPE";
    public static final int OPEN_TYPE_NORMAL = 1000;
//    public static final int OPEN_TYPE_LOGOUT = 1001;
    public static final int OPEN_TYPE_FORCE_UPDATE = 1002;
    public static final int OPEN_TYPE_NORMAL_UPDATE = 1003;
    public static final int OPEN_TYPE_KICK_OFF = 1004;

    //最小屏幕宽
    private final int MIN_SCREEN_WIDTH = 720;

    private EditText etBroadcaterId;
    private EditText etPassword;
    private EditText etVerifyCode;
    private ImageView ivVerifyCode;
    private TextView btnLogin;

    private String launchModule = "";           //记录外部传入参数
    private int mOpenType = OPEN_TYPE_NORMAL;   //打开方式
    boolean isNormalUpdateShowing = false;

    /**登录按钮的location坐标的y值，用来计算软键盘弹出后rootview向上滑动的高度*/
    private int btnY = 0;

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
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        setContentView(R.layout.activity_live_login);
        LoginManager.getInstance().addListener(this);
        initView();
        initData();

        //del by Jagger 2018-4-12 不需要,整个布局都乱了, 可以用6P试试
        //输入法软键盘弹出时，把整个布局顶上去
//        View main_layout = findViewById(R.id.llContent);
//        controlKeyboardLayout(main_layout, btnLogin);

        //添加如果已经登录，自动关掉界面(解决外部连击点击打开已经开启的应用)
        if(LoginManager.getInstance().isLogined()){
            //已登录直接跳转打开进入主界面
            MainFragmentActivity.launchActivityWIthUrl(this, launchModule);
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        //
        doCheckSreenWidth();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        parseLaunchIntent(intent);
    }

    private void initView(){
        etBroadcaterId = (EditText)findViewById(R.id.etBroadcaterId);
        etPassword = (EditText)findViewById(R.id.etPassword);
        etVerifyCode = (EditText)findViewById(R.id.etVerifyCode);
        ivVerifyCode = (ImageView) findViewById(R.id.ivVerifyCode);
        btnLogin = (TextView)findViewById(R.id.btnLogin);
        ivVerifyCode.setOnClickListener(this);
        btnLogin.setOnClickListener(this);
    }

    private void initData(){
        AccountInfoBean accountInfo = LoginManager.getInstance().getLocalAccountInfo();
        if(accountInfo != null){
            etBroadcaterId.setText(accountInfo.broadcasterId);
            etPassword.setText(accountInfo.password);
        }

        parseLaunchIntent(getIntent());
    }

    private void parseLaunchIntent(Intent intent){
        String message = "";
        if(intent != null) {
            String action = intent.getAction();
            if (Intent.ACTION_VIEW.equals(action)) {
                Uri uri = intent.getData();
                if (uri != null) {
                    // 增加GA跟踪代码
                    String moduleName = uri.getQueryParameter("module");
                    String ladyID = uri.getQueryParameter("ladyid");
                    String source = uri.getQueryParameter("source");
                    launchModule = URL2ActivityManager.uriToUrl(uri);

                    //serviceManager检测fortest字段
                    boolean isForTest = URL2ActivityManager.readForTestFlags(launchModule);
                    LiveService.getInstance().setForTest(isForTest);

                    //设置代理
                    String proxy = URL2ActivityManager.getInstance().readHttpProxyFlags(launchModule);
                    if(!TextUtils.isEmpty(proxy)){
                        RequestJni.SetProxy(proxy);
                    }

                    String gaAction = !TextUtils.isEmpty(source) ? source : "unknow";
                    String gaLabel = !TextUtils.isEmpty(moduleName) ? moduleName : "index";
                    String gaCategory = getString(R.string.OpenApp_Category);

                    // 统计activity event
                    AnalyticsManager.getsInstance().ReportEvent(gaCategory, gaAction, gaAction + getString(R.string.OpenApp_Label) + gaLabel);
                }
            } else {
                Bundle extra = getIntent().getExtras();
                if (extra != null) {

                    if (extra.containsKey(CommonConstant.KEY_PUSH_NOTIFICATION_URL)) {
                        launchModule = extra.getString(CommonConstant.KEY_PUSH_NOTIFICATION_URL);
                    }

                    if (extra.containsKey(KEY_OPEN_MESSAGE_DESC)) {
                        message = extra.getString(KEY_OPEN_MESSAGE_DESC);
                    }

                    if(extra.containsKey(KEY_OPEN_TYPE)){
                        mOpenType = extra.getInt(KEY_OPEN_TYPE);
                    }
                }
            }
        }
        doForNewIntent(message);
    }

    /**
     * 处理传入参数
     */
    private void doForNewIntent(String message){
        //根据启动方式去处理
        if(mOpenType == OPEN_TYPE_NORMAL){
            //同步配置
            Log.i("Jagger" , "LiveLoginActivity:正常启动" );
            getVerficationCode();
        }else if(mOpenType == OPEN_TYPE_FORCE_UPDATE){
            //强制更新
            Log.i("Jagger" , "LiveLoginActivity:强制更新" );
            showForceUpdateDialog();
        }else if(mOpenType == OPEN_TYPE_NORMAL_UPDATE){
            //强制更新
            Log.i("Jagger" , "LiveLoginActivity:普通更新" );
            showNormalUpdateDialog();
        }
//        else if(mOpenType == OPEN_TYPE_LOGOUT){
//            //注销
//            Log.i("Jagger" , "LiveLoginActivity1:注销" );
//            showToast(getString(R.string.live_logout_tips));
//        }
        else if(mOpenType == OPEN_TYPE_KICK_OFF){
            //被踢
            getVerficationCode();
            if(!TextUtils.isEmpty(message)){
                showKickOffDialog(message);
            }
        }
        else{
            Log.i("Jagger" , "LiveLoginActivity:其它启动" );
            getVerficationCode();
        }
    }

    /**
     * @param root
     * 最外层布局，需要调整的布局
     * @param scrollToView
     * 被键盘遮挡的scrollToView，滚动root,使scrollToView在root可视区域的底部
     */
    private void controlKeyboardLayout(final View root, final View scrollToView) {
        // 注册一个回调函数，当在一个视图树中全局布局发生改变或者视图树中的某个视图的可视状态发生改变时调用这个回调函数。
        root.getViewTreeObserver().addOnGlobalLayoutListener(
                new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        Rect rect = new Rect();
                        // 获取root在窗体的可视区域
                        root.getWindowVisibleDisplayFrame(rect);
                        // 当前视图最外层的高度减去现在所看到的视图的最底部的y坐标
                        int rootInvisibleHeight = root.getRootView()
                                .getHeight() - rect.bottom;
                        Log.i("tag", "最外层的高度" + root.getRootView().getHeight());
                        Log.i("tag","bottom的高度" + rect.bottom);
                        // 若rootInvisibleHeight高度大于100，则说明当前视图上移了，说明软键盘弹出了
                        if (rootInvisibleHeight > 100) {
                            //软键盘弹出来的时候
                            int[] location = new int[2];
                            // 获取scrollToView在窗体的坐标
                            scrollToView.getLocationInWindow(location);

                            //btnY的初始值为0，一旦赋过一次值就不再变化
                            if (btnY == 0){
                                btnY = location[1];
                            }

                            // 计算root滚动高度，使scrollToView在可见区域的底部
                            int srollHeight = (btnY + scrollToView
                                    .getHeight()) - rect.bottom;

                            root.scrollTo(0, srollHeight);
                        } else {
                            // 软键盘没有弹出来的时候
                            root.scrollTo(0, 0);
                        }
                    }
                });
    }

    private AlertDialog mKickOffDialog;
    /**
     * 显示被踢dialog
     * @param message
     */
    private void showKickOffDialog(String message){
        if(!(mKickOffDialog != null && mKickOffDialog.isShowing())) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setMessage(message);
            builder.setPositiveButton(R.string.common_btn_ok, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {

                }
            });
            mKickOffDialog = builder.create();
            mKickOffDialog.show();
        }
    }

    /**
     * 提示 强制更新
     * TODO:UI校对
     */
    private void showForceUpdateDialog(){
        final UpdateManager.UpdateMessage updateMessage = UpdateManager.getInstance(mContext).getUpdateMessage();
        if(updateMessage == null){
            return;
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(getString(R.string.live_update_title));
        builder.setMessage(TextUtils.isEmpty(updateMessage.forceUpdateMsg)? "": updateMessage.forceUpdateMsg);
        builder.setCancelable(false);
        builder.setPositiveButton(R.string.live_update_summit, new DialogInterface.OnClickListener() {
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
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
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

        //不重复显示
        if(isNormalUpdateShowing){
            return;
        }
        isNormalUpdateShowing = true;

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
                isNormalUpdateShowing = false;
            }
        });
        dialog.show();
    }

    /**
     * 检测屏幕宽
     */
    private void doCheckSreenWidth(){
        if(DisplayUtil.getScreenWidth(mContext) < MIN_SCREEN_WIDTH){
            Intent i = new Intent(mContext , WarningActivity.class);
            startActivity(i);

            finish();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        LoginManager.getInstance().removeListener(this);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.ivVerifyCode:{
                ivVerifyCode.setClickable(false);
                getVerficationCode();
            }break;
            case R.id.btnLogin:{
                login();
            }break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        HttpRespObject response = (HttpRespObject)msg.obj;
        switch (msg.what){
            case EVENT_LOGIN_CALLBACK:{
                hideProgressDialog();
                btnLogin.setClickable(true);
                if(response.isSuccess){
                    //登录成功跳转
                    MainFragmentActivity.launchActivityWIthUrl(this, launchModule);
                    //关闭当前登录界面
                    finish();
                }else{
                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
//                    if(errType == HTTP_LCC_ERR_VERIFICATIONCODE){
                        //登录失败就重新刷新验证码
//                        getVerficationCode();
//                    }
                    if(errType != HTTP_LCC_ERR_CONNECTFAIL){
                        //登录失败且不是网络异常时就刷新验证码
                        getVerficationCode();
                    }
                    showToast(response.errMsg);
                }
            }break;
            case EVENT_VERIFICATION_CODE:{
                ivVerifyCode.setClickable(true);
                if(response.isSuccess){
                    byte[] data = (byte[])response.data;
                    if(data != null && data.length > 0){
                        Bitmap bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
                        ivVerifyCode.setImageBitmap(bitmap);
                    }
                }else{
                    ivVerifyCode.setImageResource(R.drawable.verification_code_default_error);
                }
            }break;
            default:
                break;
        }
    }

    /**
     * 取验证码
     */
    private void getVerficationCode(){
        LoginManager.getInstance().getVerificationCode(new OnRequestGetVerificationCodeCallback() {
            @Override
            public void onGetVerificationCode(boolean isSuccess, int errCode, String errMsg, byte[] date) {
                Message msg = Message.obtain();
                msg.what = EVENT_VERIFICATION_CODE;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, date);
                sendUiMessage(msg);
            }
        });
    }

    private void login(){
        String broadcasterId = etBroadcaterId.getText().toString().trim();
        String password = etPassword.getText().toString().trim();
        String verificationCode = etVerifyCode.getText().toString().trim();

        if(TextUtils.isEmpty(broadcasterId)){
            showToast(getResources().getString(R.string.live_login_param_account_null_tips));
            return;
        }

        if(TextUtils.isEmpty(password)){
            showToast(getResources().getString(R.string.live_login_param_password_null_tips));
            return;
        }

        if(TextUtils.isEmpty(verificationCode)){
            showToast(getResources().getString(R.string.live_login_param_verify_null_tips));
            return;
        }

        btnLogin.setClickable(false);
        showProgressDialog("");
        LoginManager.getInstance().login(broadcasterId, password, verificationCode);
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Message msg = Message.obtain();
        msg.what = EVENT_LOGIN_CALLBACK;
        msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, item);
        sendUiMessage(msg);
    }

    @Override
    public void onLogout(boolean isMannual) {

    }
}
