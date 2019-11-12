package com.qpidnetwork.livemodule.liveshow;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.JavascriptInterface;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.OpenFileWebChromeClient;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginNewActivity;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.model.js.CallbackAppGAEventJSObj;
import com.qpidnetwork.livemodule.liveshow.model.js.JSCallbackListener;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.MediaUtility;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.util.FileUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.WebviewSSLProcessHelper;

import java.io.File;

/**
 * Created by Hunter Mun on 2017/11/10.
 */

public class BaseWebViewActivity extends BaseActionBarFragmentActivity implements IAuthorizationListener, JSCallbackListener {

    public static final int HTTP_ERROR_CODE_UN_AUTH = 401;
    public static final String HTTP_EMPTY_PAGE = "about:blank";

    private static final int LOGIN_CALLBACK = 10001;
    private final int PIC_MAX_SIZE = 3000;

    public static final String WEB_URL = "web_url";
    public static final String WEB_TITLE = "web_title";
    public static final String WEB_TITLE_BAR_SHOW_LOADSUC = "showTitleBarWhenLoadSuc";

    //views
    protected LinearLayout ll_webview;
    protected WebView mWebView;
    //title
//    protected View fl_commTitleBar;
//    protected TextView tv_commTitle;
//    protected ImageView iv_commBack;
    //errorPage
    protected View view_errorpage, view_apiLimitPage;
    protected Button btnRetry, btnOk;
    protected ProgressBar pb_loading;

    //data
    //入参
    protected String mUrl = "";
    protected String mTitle = "";
    protected boolean showTitleBarWhenLoadSuc = true;

    //状态控制
    boolean isBlockLoadingNetworkImage = false; //图片懒加载
    protected boolean isLoadError = false;
    private boolean isReload = false; //记录是否重新加载，重新加载成功需清除history
    private CallbackAppGAEventJSObj mJSCallback;

    //页面是否load成功
    private boolean mIsPageLoadFinish = false;      //解决页面load未完成，物理返回键被hold住问题(js 无响应)

    //解决主播页操作后，中间跳转买点页面，返回主播页面由于removeAllCookie 导致页面cookie丢失
    private boolean mIsNeedResume = false;              //标志是否stop后返回

    private OpenFileWebChromeClient mOpenFileWebChromeClient;   //chromeClient.支持图库及文件夹访问

    //resume 调用js刷新界面标志位
    private boolean mResumecbFlags = false;

    /**
     * 接口消息
     */
    private enum TypeUIRefresh {
        onPageFinished
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TAG = WebViewActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        initView();
        initWebView();
        initViewData();
        LoginManager loginManager = LoginManager.getInstance();
        if (null != loginManager) {
            loginManager.register(this);
        }

    }

    @Override
    protected void onResume() {
        super.onResume();
        //激活webview为活跃状态,能正常执行网页的响应
        mWebView.onResume();
        if (mIsNeedResume) {
            syncCookie();
        }
        //add by Jagger
//        try {
//            mWebView.getClass().getMethod("onResume" , new Class<?>[]{}).invoke(mWebView,(Object[])null);
//        }catch (Exception e){
//            Log.i("Jagger" , "直播webview onResume Exception: " + e.toString());
//        }
//        mWebView.resumeTimers();

        fl_commTitleBar.getBackground().setAlpha(255);
        tv_commTitle.setAlpha(1f);

        //判断是否通知网页刷新
        if (mResumecbFlags && mIsNeedResume) {
            notifyResume();
        }

        //最后重置标志位
        mIsNeedResume = false;
    }

    @Override
    protected void onPause() {
        super.onPause();
        //当页面被失去焦点/被切换到后台不可见状态，需要执行onPause，通过onPause动作通知内核暂停所有动作，比如DOM的解析，
        //plugin的执行，Javascript的执行
        mWebView.onPause();
        mIsNeedResume = true;
        //add by Jagger
//        try {
//            mWebView.getClass().getMethod("onPause", new Class<?>[]{}).invoke(mWebView,  (Object[])null);
//        }catch (Exception e){
//            Log.i("Jagger" , "直播webview onPause Exception: " + e.toString());
//        }
        //暂停WebView在后台的JS活动
//        mWebView.pauseTimers();
    }

    /**
     * 初始化view
     */
    public void initView() {
        setCustomContentView(R.layout.activity_normal_webview);
        view_errorpage = findViewById(R.id.view_errorpage);
        view_errorpage.setVisibility(View.GONE);
        btnRetry = (Button) findViewById(R.id.btnRetry);
        btnRetry.setOnClickListener(this);

        view_apiLimitPage = findViewById(R.id.view_api_limit_page);
        view_apiLimitPage.setVisibility(View.GONE);
        btnOk = (Button) findViewById(R.id.btnOk);
        btnOk.setOnClickListener(this);

        pb_loading = (ProgressBar) findViewById(R.id.pb_loading);
        LinearLayout.LayoutParams webviewLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);

        // old  若网页创建系统弹窗时，由于 Application Context 不能创建，会导致 crash
//        mWebView = new WebView(getApplicationContext());
        // 2018/11/6  Hardy
        mWebView = new WebView(this);

        ll_webview = (LinearLayout) findViewById(R.id.ll_webview);
        ll_webview.addView(mWebView, webviewLp);
    }

    /**
     * 初始化配置webview
     */
    protected void initWebView() {
        syncCookie();
        WebSettings webSettings = mWebView.getSettings();
        //如果访问的页面中要同js进行交互,则webview必须设置支持js
        webSettings.setJavaScriptEnabled(true);
        //开启图片等懒加载逻辑
        webSettings.setRenderPriority(WebSettings.RenderPriority.HIGH);
//        webSettings.setBlockNetworkImage(true);
//        isBlockLoadingNetworkImage=true;
        //自适应屏幕,两者合用
        webSettings.setUseWideViewPort(true);
        webSettings.setLoadWithOverviewMode(true);
        //支持缩放，默认为true
        webSettings.setSupportZoom(true);
        //设置内置的缩放控件,若为false则该webview不支持缩放
        webSettings.setBuiltInZoomControls(true);
        //隐藏原生的缩放控件
        webSettings.setDisplayZoomControls(false);

        //参考http://www.jb51.net/article/67044.htm,fly那边需要增加以下设置
        // 开启DOM缓存，开启LocalStorage存储(html5的本地存储方式)
        webSettings.setDomStorageEnabled(true);
        webSettings.setAppCacheMaxSize(1024 * 1024 * 8);
        String appCachePath = getApplicationContext().getCacheDir().getAbsolutePath();
        Log.d(TAG, "initWebView-appCachePath:" + appCachePath);
        webSettings.setAppCachePath(appCachePath);
        //开启 Application Caches 功能
        webSettings.setAppCacheEnabled(true);
        //开启 database storage API 功能
        webSettings.setDatabaseEnabled(true);
        //设置可以访问文件
        webSettings.setAllowFileAccess(true);
        //支持通过JS打开新窗口
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        //支持自动加载图片
        webSettings.setLoadsImagesAutomatically(true);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            webSettings.setMediaPlaybackRequiresUserGesture(false);
        }
        //以下设置为配合Chrome DevTools调试webview的h5页面[setWebContentsDebuggingEnabled是静态方法，针对整个app的WebView]
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(LiveModule.mIsDebug);
        }
        //Android 4.2以下存在漏洞问题,待解决
//        mJSCallback = new CallbackAppGAEventJSObj(this.getApplicationContext());
        // 2018/11/6 Hardy
        mJSCallback = new CallbackAppGAEventJSObj(this);

        mJSCallback.setJSCallbackListener(this);
        mWebView.addJavascriptInterface(mJSCallback, "LiveApp");
        mWebView.addJavascriptInterface(this, "App");
//        mWebView.removeJavascriptInterface("searchBoxJavaBridge_");
//        mWebView.removeJavascriptInterface("accessibility");
//        mWebView.removeJavascriptInterface("accessibilityTraversal");
        mWebView.setWebViewClient(new MyWebViewClient());
        mOpenFileWebChromeClient = new OpenFileWebChromeClient(this);
        mWebView.setWebChromeClient(mOpenFileWebChromeClient);
        //add by Jagger 针对视频的问题,加了些代码,并未使用.如有问题可使用试试效果
//        mWebView.getSettings().setPluginState(WebSettings.PluginState.ON);
//        mWebView.setWebChromeClient(new WebChromeClient());
    }

    /**
     * 读取外部传入数据
     */
    protected void initViewData() {
        // 创建界面时候读取数据
        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            mUrl = bundle.getString(WEB_URL, mUrl);
            //增加device和appver公共头
            if (!TextUtils.isEmpty(mUrl)) {
                mUrl = CoreUrlHelper.packageWebviewUrl(this, mUrl);
            }
            Log.logD(TAG, "initViewData-mUrl:" + mUrl);
            mTitle = bundle.getString(WEB_TITLE, mTitle);
            Log.d(TAG, "initViewData-mTitle:" + mTitle);
            showTitleBarWhenLoadSuc = bundle.getBoolean(WEB_TITLE_BAR_SHOW_LOADSUC);
            Log.d(TAG, "initViewData-showTitleBarWhenLoadSuc:" + showTitleBarWhenLoadSuc);
        }

        //解析设置screenname
        setCurrentScreenName(URL2ActivityManager.parseScreenNameByUrl(mUrl));

        //读取resumecb标志位
        mResumecbFlags = URL2ActivityManager.getInstance().getResumecbFlags(mUrl);

        if (!TextUtils.isEmpty(mTitle)) {
//            tv_commTitle.setText(mTitle);
            //设置头
            setTitle(mTitle, R.color.theme_default_black);
        }

        //初始化加载
        loadUrl(false, false);
    }

    /**
     * api 19以下显示错误页
     */
    protected boolean checkApiLimit() {
        boolean apiOk = true;
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            view_apiLimitPage.setVisibility(View.VISIBLE);
            pb_loading.setVisibility(View.GONE);
            apiOk = false;
        }
        return apiOk;
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.btnRetry) {
            view_errorpage.setVisibility(View.GONE);
            onRetryClicked();
        } else if (R.id.btnOk == i) {
            finish();
        } else if (R.id.iv_commBack == i) {
//            finish();
            //修改原有的关闭为逐级退出
            if( mWebView.canGoBack() ) {
                mWebView.goBack();
            } else {
                //交给页面处理
                finish();
            }
            return;
        }
        super.onClick(v);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN && mIsPageLoadFinish && !isLoadError) {
            if( mWebView.canGoBack() ) {
                mWebView.goBack();
            } else {
                //交给页面处理
//            onBackKeyDown();
                finish();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 事件处理
     *
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case LOGIN_CALLBACK: {
                pb_loading.setVisibility(View.GONE);
                HttpRespObject response = (HttpRespObject) msg.obj;
                if (response.isSuccess) {
                    //session 过期重新登陆
                    loadUrl(true, true);
                }
            }
            break;

            default:
                break;
        }
    }

    /**
     * 点击错误页中重试按钮
     */
    protected void onRetryClicked() {
        loadUrl(true, false);
    }

    /**
     * 加载Url或出错重新加载
     *
     * @param isReload
     * @param isSessionTimeout
     */
    protected void loadUrl(boolean isReload, boolean isSessionTimeout) {
        Log.logD(TAG, "loadUrl-isReload:" + isReload + " isSessionTimeout:" + isSessionTimeout + " mUrl: " + mUrl);
        isLoadError = false;
        this.isReload = isReload;
        if (mWebView != null) {
            if (!isReload || isSessionTimeout) {
                //            mWebView.clearCache(true);
                syncCookie();
                if (!TextUtils.isEmpty(mUrl)) {
                    mWebView.loadUrl(mUrl);
                }
            } else {
                mWebView.reload();
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        LoginManager loginManager = LoginManager.getInstance();
        if (null != loginManager) {
            loginManager.unRegister(this);
        }
        if (null != mWebView) {
            //清除绑定，防止泄露
            if (mJSCallback != null) {
                mJSCallback.setJSCallbackListener(null);
            }
            //解决5.1以上webview内存泄漏问题
            ViewParent parent = mWebView.getParent();
            if (parent != null) {
                ((ViewGroup) parent).removeView(mWebView);
            }
            mWebView.stopLoading();
            // 退出时调用此方法，移除绑定的服务，否则某些特定系统会报错
            mWebView.getSettings().setJavaScriptEnabled(false);
//            mWebView.clearCache(true);
            mWebView.clearHistory();//清理历史记录
            mWebView.freeMemory();//释放内存
            mWebView.clearFormData();//仅仅清除自动完成填充的表单数据,并不会清理存储到本地的数据
            mWebView.clearMatches();
            mWebView.clearSslPreferences();
            mWebView.clearDisappearingChildren();
            mWebView.clearAnimation();
            mWebView.clearView();
            mWebView.removeAllViews();
            try {
                mWebView.destroy();
            } catch (Throwable ex) {
                ex.printStackTrace();
            }
            mWebView = null;
        }
    }

    /*************************** 对子类开放url重定向处理 ****************************/
    /**
     * 子类是否捕捉特殊处理重定向事件
     *
     * @return
     */
    public boolean onShouldOverrideUrlLoading(WebView view, String url) {
        return false;
    }

    /*************************** webview错误处理 *********************************/
    /**
     * 加载网页，网络出错错误处理
     */
    protected void onLoadError() {
        Log.i(TAG, "onLoadError");
        isLoadError = true;
        if (mWebView != null) {
            view_errorpage.setVisibility(View.VISIBLE);
            fl_commTitleBar.setVisibility(View.VISIBLE);
            mWebView.setVisibility(View.GONE);
        }
    }

    /**
     * 2019/4/12 Hardy
     * <p>
     * 处理 http 错误
     * https://blog.csdn.net/lsyz0021/article/details/56677132
     * <p>
     * 一般来说该错误消息表明您首先需要登录（输入有效的用户名和密码）。 如果你刚刚输入这些信息，立刻就看到一个 401 错误
     * https://baike.baidu.com/item/401%E9%94%99%E8%AF%AF/3720974?fr=aladdin
     * <p>
     * 方法执行顺序：
     * onReceivedHttpAuthRequest-host:demo.qpidnetwork.com realm:Web Site Test
     * |
     * onReceivedHttpError-errorResponse.mStatusCode:401
     *
     * @param httpCode
     */
    private void handlerHttpError(int httpCode) {
        if (httpCode == HTTP_ERROR_CODE_UN_AUTH && !isErrorUnAuthLoad) {    // test:5179 的 401 验证问题
            isErrorUnAuthLoad = true;

            mWebView.loadUrl(HTTP_EMPTY_PAGE);                              // 空白页，避免出现默认的错误界面
            onRetryClicked();                                               // 模拟重新加载页面
        } else {
            //Android 6.0以上
            onLoadError();
        }
    }

    private boolean isErrorUnAuthLoad;


    /**
     * 利用接口和webview共用cookie，通过接口cookie过期自动重登陆实现session过期重登陆，刷新cookie
     */
    private void handleSessionTimeout() {
        LiveRequestOperator.getInstance().GetFollowingLiveList(0, 10, new OnGetFollowingListCallback() {
            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {

            }
        });
    }

    /*************************** webview JS交互 *********************************/

    /**
     * JS通知页面，用户点击返回键（单页时需要网页处理返回键）
     */
    public void onBackKeyDown() {
        String url = "javascript:notifyClickPhoneBack()";
        if (mWebView != null) {
            mWebView.loadUrl(url);
        }
    }

    @Override
    public void onEventClose() {
        finish();
    }

    @Override
    public void onEventPageError(final String errorcode, final String errMsg, final NoMoneyParamsBean params) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!TextUtils.isEmpty(errorcode)
                        && errorcode.equals(CallbackAppGAEventJSObj.WEBVIEW_SESSION_ERROR_NO)) {
                    LoginManager.LoginStatus loginStatus = LoginManager.getInstance().getLoginStatus();
                    if (loginStatus != LoginManager.LoginStatus.Logined) {
                        LoginNewActivity.launchRegisterActivity(mContext);
                    } else {
                        pb_loading.setVisibility(View.VISIBLE);
                        handleSessionTimeout();
                    }
                } else if (!TextUtils.isEmpty(errorcode)
                        && errorcode.equals(CallbackAppGAEventJSObj.WEBVIEW_NOCREDIT_ERROR_NO)) {
                    if (!TextUtils.isEmpty(errMsg)) {
                        showCreditNoEnoughDialog(errMsg, params);
                    } else {
                        LiveModule.getInstance().onAddCreditClick(mContext, params);
                        //GA统计点击充值
                        AnalyticsManager.getsInstance().ReportEvent(
                                BaseWebViewActivity.this.getResources().getString(R.string.Live_Global_Category),
                                BaseWebViewActivity.this.getResources().getString(R.string.Live_Global_Action_AddCredit),
                                BaseWebViewActivity.this.getResources().getString(R.string.Live_Global_Label_AddCredit));
                    }
                } else {
                    loadUrl(false, false);
                }
            }
        });
    }

    @Override
    public void onEventShowNavigation(final String isShow) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!TextUtils.isEmpty(isShow)) {
                    if (isShow.equals("0")) {
                        setTitleVisible(View.GONE);
                    } else if (isShow.equals("1")) {
                        setTitleVisible(View.VISIBLE);
                    }
                }
            }
        });
    }

    @Override
    public void onShowHangoutAnchor(HangoutAnchorInfoItem item) {

    }

    /*************************** webview相关 ************************************/
    /**
     * 同步webview cookie
     */
    private void syncCookie() {
        // Cookie 认证
        CookieSyncManager.createInstance(this);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.removeAllCookie();
        CookiesItem[] cookieList = RequestJni.GetCookiesItem();
        if (cookieList != null && cookieList.length > 0) {
            for (CookiesItem item : cookieList) {
                if (item != null) {
                    String sessionString = item.cName + "=" + item.value;
                    cookieManager.setCookie(item.domain, sessionString);
                    Log.logD(TAG, "syncCookie-domain:" + item.domain + " sessionString:" + sessionString);
                }
            }
        }
        CookieSyncManager.getInstance().sync();
    }

    /**
     * 自定义webviewClient处理事件
     */
    private class MyWebViewClient extends WebViewClient {
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            //这里的url可能由于编码问题，在间接调用到String.format方法时会跑错
            //参考:http://blog.csdn.net/cyanflxy/article/details/46274003
            //因此使用System.out.print而非Log.d
            Log.logD(TAG, "onPageStarted url:" + url);
            mIsPageLoadFinish = false;
            pb_loading.setVisibility(View.VISIBLE);
            super.onPageStarted(view, url, favicon);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.logD(TAG, "onPageFinished url:" + url);
            mIsPageLoadFinish = true;

            //add by Jagger 2017-12-15
            //4.?的手机 , 通过onReceivedHttpAuthRequest后,回调回来会闪退
            Message msg = new Message();
            msg.what = TypeUIRefresh.onPageFinished.ordinal();
            mHandler4UI.sendMessage(msg);
            //del by Jagger 2017-12-15
            //隐藏进度条
//            pb_loading.setVisibility(View.GONE);

//            //添加延时加载
//            if(isBlockLoadingNetworkImage){
//                if(mWebView != null){
//                    mWebView.getSettings().setBlockNetworkImage(false);
//                }
//                isBlockLoadingNetworkImage = false;
//            }
//
//            //reload时清除历史
//            if(isReload){
//                mWebView.clearHistory();
//            }
//
//                /*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
//            if((!isLoadError)){
//                view_errorpage.setVisibility(View.GONE);
//                if(null != mWebView){
//                    mWebView.setVisibility(View.VISIBLE);
//                }
////                fl_commTitleBar.setVisibility(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
//                setTitleVisible(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
//            }else{
////                fl_commTitleBar.setVisibility(View.VISIBLE);
//                setTitleVisible(View.VISIBLE);
//            }
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Log.logD(TAG, "shouldOverrideUrlLoading-url:" + url);

            //读取resumecb标志位
            mResumecbFlags = URL2ActivityManager.getInstance().getResumecbFlags(mUrl);

            //url重定向以及点击页面中的某些链接(get)会执行该方法
            //复写该方法,使得load url时不会打开系统浏览器而是在mWebView中显示
            //协议拦截-参考文档<<App-Webview交互说明>>
            if (onShouldOverrideUrlLoading(view, url)) {
                //子类已特殊显示
                return true;
            }

            if (url.equals("qpidnetwork://app/closewindow")) {
                finish();
                return true;
            }
            if (new AppUrlHandler(BaseWebViewActivity.this).urlHandle(url)) {
                return true;
            }
            return super.shouldOverrideUrlLoading(view, url);
        }

        @Override
        public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
            Log.i(TAG, "onReceivedHttpAuthRequest-host:" + host + " realm:" + realm);
            //del by Jagger 2017-12-14 在6.0以下会死先去掉
            handler.proceed("test", "5179");
//            super.onReceivedHttpAuthRequest(view,handler,host,realm);
        }

        @Override
        public void onFormResubmission(WebView view, Message dontResend, Message resend) {
            resend.sendToTarget();
            super.onFormResubmission(view, dontResend, resend);
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
//            super.onReceivedError(view,errorCode,description,failingUrl);
            Log.i(TAG, "onReceivedError-errorCode:" + errorCode + " description:" + description
                    + " failingUrl:" + failingUrl);
            //普通页面错误
//            if(!TextUtils.isEmpty(failingUrl) && failingUrl.contains(mUrl)) {
            onLoadError();
//            }
        }

        //del by Jagger 2017-12-14 在6.0以下会死先去掉
        @TargetApi(Build.VERSION_CODES.M)
        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                super.onReceivedHttpError(view, request, errorResponse);
                Log.i(TAG, "onReceivedHttpError-errorResponse.mStatusCode:" + errorResponse.getStatusCode());
                //解决页内部http错误也会回调，导致页面加载成功部分且内容加载失败被误认为页面加载失败
                if (request != null && request.getUrl() != null) {
                    Uri tempUri = request.getUrl();
                    Uri pageUri = Uri.parse(mUrl);
                    if (tempUri.getScheme().equals(pageUri.getScheme())
                            && tempUri.getPath().equals(pageUri.getPath())) {

                        //Android 6.0以上
//                        onLoadError();

                        // 2019/4/12 Hardy
                        handlerHttpError(errorResponse.getStatusCode());
                    }
                }
            }
        }

        //Google Play过不了的话,不要重载onReceivedSslError函数 ，如果需要重载onReceivedSslError函数，那么 不要调用SslErrorHandler#proceed() 函数忽略错误
        //http://blog.csdn.net/amazing_alex/article/details/71410670
        @TargetApi(Build.VERSION_CODES.M)
        @Override
        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Log.d(TAG, "onReceivedSslError");
                //                super.onReceivedSslError(view, handler, error);
//                handler.proceed();//表示等待证书响应
                WebviewSSLProcessHelper.showWebviewSSLErrorTips(BaseWebViewActivity.this, view, handler, error);
                // handler.cancel//表示挂起连接-默认处理方式
                // handler.handleMessage(null)//可做其他处理
            }
        }
    }

    /**
     * 网页加载后 , UI处理
     */
    @SuppressLint("HandlerLeak")
    private Handler mHandler4UI = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (TypeUIRefresh.values()[msg.what]) {
                case onPageFinished:
                    //隐藏进度条
                    pb_loading.setVisibility(View.GONE);

//                    //添加延时加载
//                    if (isBlockLoadingNetworkImage) {
//                        if (mWebView != null) {
////                            mWebView.getSettings().setBlockNetworkImage(false);
//                        }
//                        isBlockLoadingNetworkImage = false;
//                    }

                    //reload时清除历史
                    if (isReload) {
                        if (mWebView != null) {
                            mWebView.clearHistory();
                        }
                    }

                    /*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
                    if ((!isLoadError)) {
                        view_errorpage.setVisibility(View.GONE);
                        if (null != mWebView) {
                            mWebView.setVisibility(View.VISIBLE);
                        }
                        //                fl_commTitleBar.setVisibility(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
                        setTitleVisible(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);

                        // 2018/11/24 Hardy
                        onWebPageLoadFinish();
                    } else {
                        //                fl_commTitleBar.setVisibility(View.VISIBLE);
                        setTitleVisible(View.VISIBLE);
                    }
                    break;

                default:
                    break;
            }
        }
    };

    /*************************** session过期重登陆  *****************************/
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Log.d(TAG, "onLogin-isSuccess:" + isSuccess + " errCode:" + errCode + " errMsg:" + errMsg);
        Message msg = Message.obtain();
        msg.what = LOGIN_CALLBACK;
        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
        msg.obj = response;
        sendUiMessage(msg);
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    /*************************** 重新组装url增加device和appver字段  *****************************/
    /**
     * url添加公共头appver和device
     *
     * @param url
     * @return
     */
    private String packageWebViewUrl(String url) {
        StringBuilder sb = new StringBuilder(url);
        //增加device
        if (url.contains("?")) {
            sb.append("&device=30");
        } else {
            sb.append("?device=30");
        }
        //增加appver
        sb.append("&appver=");
        int versionCode = SystemUtils.getVersionCode(this);
        sb.append(String.valueOf(versionCode));
        return sb.toString();
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(TAG, "onActivityResult-requestCode:" + requestCode + " resultCode:" + resultCode);
        //onActivityResult 即拍照返回，无需重新更新cookie，防止异步更新cookie（先清除，后更新导致回调使用cookie异常，红米note拍砸返回上传session过期）
        mIsNeedResume = false;
        
        //需要回调onReceiveValue方法防止下次无法响应js方法
        if (resultCode != RESULT_OK) {
            if (mOpenFileWebChromeClient.mFilePathCallback != null) {
                mOpenFileWebChromeClient.mFilePathCallback.onReceiveValue(null);
                mOpenFileWebChromeClient.mFilePathCallback = null;
            }
            if (mOpenFileWebChromeClient.mFilePathCallbacks != null) {
                mOpenFileWebChromeClient.mFilePathCallbacks.onReceiveValue(null);
                mOpenFileWebChromeClient.mFilePathCallbacks = null;
            }
            return;
        }
        Uri result = intent == null ? null : intent.getData();
        Uri uri = null;
        if (result != null) {
            String path = MediaUtility.getPath(getApplicationContext(), result);
            Log.logD(TAG, "onActivityResult-result:" + result + " path:" + path);

            if (!TextUtils.isEmpty(path)) {
                uri = Uri.fromFile(new File(path));
            }
        }
        if (null == uri && requestCode == OpenFileWebChromeClient.REQUEST_CAPTURE_PHOTO) {
            //因为拍照在红米note2手机上返回的intent为null，因此需要自己处理uri
            uri = Uri.fromFile(new File(FileCacheManager.getInstance().GetTempCameraImageUrl()));
        }
        Log.logD(TAG, "onActivityResult-result:" + result + " uri:" + uri);

        // 2018/11/27 Hardy
        if (uri != null ){
            if(requestCode == OpenFileWebChromeClient.REQUEST_CAPTURE_PHOTO) {
                String scanPath = FileCacheManager.getInstance().GetTempCameraImageUrl();
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                    //5.0以下处理兼容,兼容部分手机由于文件名一样导致导致web收不到change导致连续拍照上传异常
                    String compatPath = renameCameraTempUrl();
                    if (!TextUtils.isEmpty(compatPath)) {
                        scanPath = compatPath;
                    }
                }
                //add by Jagger
                reSizePic(scanPath, scanPath);
                uri = Uri.fromFile(new File(scanPath));
                ImageUtil.SaveImageToGallery(this, scanPath);
            }else if(requestCode == OpenFileWebChromeClient.REQUEST_FILE_PICKER) {
                //add by Jagger 2019-7-5
                //如果取自相册，则压缩到合适上传的尺寸
                String scanPath = FileCacheManager.getInstance().GetTempImageUrl();
                reSizePic(uri.getPath(), scanPath);
                uri = Uri.fromFile(new File(scanPath));
            }
        }

        Log.logD(TAG,"Compat onActivityResult-result:"+result+" uri:"+uri);

        if (null != mOpenFileWebChromeClient.mFilePathCallback) {
            mOpenFileWebChromeClient.mFilePathCallback.onReceiveValue(uri);
            //避免下一次js执行无响应
            mOpenFileWebChromeClient.mFilePathCallback = null;
        }
        if (mOpenFileWebChromeClient.mFilePathCallbacks != null) {
            mOpenFileWebChromeClient.mFilePathCallbacks.onReceiveValue(null == uri ? null : new Uri[]{uri});
            //避免下一次js执行无响应
            mOpenFileWebChromeClient.mFilePathCallbacks = null;
        }
    }

    /**
     * 拷贝拍照临时文件（重命名解决找不到指定照片问题）
     * @return
     */
    private String renameCameraTempUrl(){
        String tempPath = "";
        String path = FileCacheManager.getInstance().GetTempCameraImageUrl();
        String compatPath = FileCacheManager.getInstance().GetWebviewCompatTempCameraImageUrl();
        FileUtil.renameFile(path, compatPath);
        File file = new File(compatPath);
        if(file.exists() && file.isFile()){
            tempPath = compatPath;
        }
        return tempPath;
    }

    /**
     * 通知页面用户返回
     */
    public void notifyResume() {
        String url = "javascript:notifyResume()";
        if (mWebView != null) {
            mWebView.loadUrl(url);
        }
    }

    /**
     * 压缩为合适上传的尺寸
     * @param filePath
     * @param savePath
     */
    private void reSizePic(String filePath, String savePath){
        //压缩 长边小于3000
        Bitmap bitmapResize = ImageUtil.decodeSampledBitmapFromFile(filePath, PIC_MAX_SIZE, PIC_MAX_SIZE);
        //覆盖原文件
        ImageUtil.saveBitmapToFile(savePath, bitmapResize, Bitmap.CompressFormat.JPEG, 70);
    }


    /**
     * 买点成功回调
     *
     * @param params
     */
    @JavascriptInterface
    public void notifyByCredit(String params) {
        Log.e(TAG, "notifyByCredit params： " + params);
        LiveModule.getInstance().onAppsFlyerEventNotify(params);
    }


    //===================   2018/11/24 Hardy   ==================================

    /**
     * 网页加载完成
     */
    protected void onWebPageLoadFinish() {

    }
    //===================   2018/11/24 Hardy   ==================================
}
