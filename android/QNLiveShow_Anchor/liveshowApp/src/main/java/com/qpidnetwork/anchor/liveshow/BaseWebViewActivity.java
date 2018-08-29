package com.qpidnetwork.anchor.liveshow;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
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
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.httprequest.RequestJni;
import com.qpidnetwork.anchor.httprequest.item.CookiesItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;

/**
 * Created by Hunter Mun on 2017/11/10.
 */

public class BaseWebViewActivity extends BaseFragmentActivity {

    private static final int LOGIN_CALLBACK = 10001;
    private static final int PAGE_ERROR_BUTTON_EVENT = 10002;

    public static final String WEB_URL = "web_url";
    public static final String WEB_TITLE = "web_title";
    public static final String WEB_TITLE_TITLE_TYPE = "webviewTitleType";

    /**
     * webview头部类型
     */
    public enum WebTitleType{
        Normal,
        Overflow
    }

    //views
    private FrameLayout flContent;
    protected LinearLayout ll_webview;
    protected WebView mWebView;
    //title
    protected View fl_commTitleBar;
    protected TextView tv_commTitle;
    protected ImageView iv_commBack;

    //errorPage
    protected View view_errorpage;
    protected Button btnRetry;
    protected ProgressBar pb_loading;

    //data
    //入参
    protected String mUrl = "";
    protected String mTitle = "";
    protected WebTitleType mWebTitleType = WebTitleType.Normal;

    //状态控制
    boolean isBlockLoadingNetworkImage = false; //图片懒加载
    protected boolean isLoadError = false;
    private boolean isReload = false; //记录是否重新加载，重新加载成功需清除history

    //页面是否load成功
    private boolean mIsPageLoadFinish = false;      //解决页面load未完成，物理返回键被hold住问题(js 无响应)

    //解决主播页操作后，中间跳转买点页面，返回主播页面由于removeAllCookie 导致页面cookie丢失
    private boolean mIsNeedResume = false;              //标志是否stop后返回

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
    }

    @Override
    protected void onResume() {
        super.onResume();
        //激活webview为活跃状态,能正常执行网页的响应
        mWebView.onResume();
        if(mIsNeedResume){
            syncCookie();
        }
        mIsNeedResume = false;
        //add by Jagger
//        try {
//            mWebView.getClass().getMethod("onResume" , new Class<?>[]{}).invoke(mWebView,(Object[])null);
//        }catch (Exception e){
//            Log.i("Jagger" , "直播webview onResume Exception: " + e.toString());
//        }
//        mWebView.resumeTimers();
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
        setContentView(R.layout.activity_normal_webview);
        //状态栏颜色
//        StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),0);

        flContent = (FrameLayout)findViewById(R.id.flContent);

        fl_commTitleBar = findViewById(R.id.fl_commTitleBar);
        tv_commTitle = (TextView) findViewById(R.id.tv_commTitle);
        iv_commBack = (ImageView) findViewById(R.id.iv_commBack);
        iv_commBack.setOnClickListener(this);

        view_errorpage = findViewById(R.id.view_errorpage);
        view_errorpage.setVisibility(View.GONE);
        btnRetry = (Button) findViewById(R.id.btnRetry);
        btnRetry.setOnClickListener(this);
        btnRetry.setText(getString(R.string.common_btn_tap_to_retry));
        pb_loading = (ProgressBar) findViewById(R.id.pb_loading);
        LinearLayout.LayoutParams webviewLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
        mWebView = new WebView(getApplicationContext());
        ll_webview = (LinearLayout) findViewById(R.id.ll_webview);
        ll_webview.addView(mWebView,webviewLp);
    }

    /**
     * 初始化配置webview
     */
    protected void initWebView(){
        syncCookie();
        WebSettings webSettings = mWebView.getSettings();
        //如果访问的页面中要同js进行交互,则webview必须设置支持js
        webSettings.setJavaScriptEnabled(true);
        //开启图片等懒加载逻辑
        webSettings.setRenderPriority(WebSettings.RenderPriority.HIGH);
        webSettings.setBlockNetworkImage(true);
        isBlockLoadingNetworkImage=true;
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
        webSettings.setAppCacheMaxSize(1024*1024*8);
        String appCachePath = getApplicationContext().getCacheDir().getAbsolutePath();
        Log.d(TAG,"initWebView-appCachePath:"+appCachePath);
        webSettings.setAppCachePath(appCachePath);
        webSettings.setAllowFileAccess(true);
        webSettings.setAppCacheEnabled(true);

        //Android 4.2以下存在漏洞问题,待解决
        mWebView.addJavascriptInterface(this, "LiveAnchorApp");
        mWebView.removeJavascriptInterface("searchBoxJavaBridge_");
        mWebView.removeJavascriptInterface("accessibility");
        mWebView.removeJavascriptInterface("accessibilityTraversal");
        mWebView.setWebViewClient(new MyWebViewClient());
        //add by Jagger 针对视频的问题,加了些代码,并未使用.如有问题可使用试试效果
//        mWebView.getSettings().setPluginState(WebSettings.PluginState.ON);
//        mWebView.setWebChromeClient(new WebChromeClient());
    }

    /**
     * 读取外部传入数据
     */
    protected void initViewData(){
        // 创建界面时候读取数据
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            mUrl = bundle.getString(WEB_URL,mUrl);
            //增加device和appver公共头
            if(!TextUtils.isEmpty(mUrl)){
                mUrl = packageWebViewUrl(mUrl);
            }
            Log.d(TAG,"initViewData-mUrl:"+mUrl);
            mTitle = bundle.getString(WEB_TITLE,mTitle);
            Log.d(TAG,"initViewData-mTitle:"+mTitle);
            if(bundle.containsKey(WEB_TITLE_TITLE_TYPE)){
                mWebTitleType = WebTitleType.values()[bundle.getInt(WEB_TITLE_TITLE_TYPE)];
            }
        }

        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams)flContent.getLayoutParams();
        if(mWebTitleType == WebTitleType.Overflow){
            params.topMargin = 0;
            findViewById(R.id.viewShadow).setVisibility(View.GONE);
        }else{
            //使用系统默认
            params.topMargin = DisplayUtil.dip2px(this, 56);
            findViewById(R.id.viewShadow).setVisibility(View.VISIBLE);
        }

        tv_commTitle.setText(mTitle);

        //初始化加载
        loadUrl(false, false);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnRetry) {
            view_errorpage.setVisibility(View.GONE);
            loadUrl(true, false);
        } else if(R.id.iv_commBack == i) {
            if( mWebView.canGoBack() ) {
                mWebView.goBack();
            } else {
                //交给页面处理
                finish();
            }
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN && mIsPageLoadFinish && !isLoadError) {
            if( mWebView.canGoBack() ) {
                mWebView.goBack();
            } else {
                //交给页面处理
//                onBackKeyDown();
                finish();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 事件处理
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case LOGIN_CALLBACK:{
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //session 过期重新登陆
                    loadUrl(true, true);
                }
            }break;

            case PAGE_ERROR_BUTTON_EVENT:{
                String errorCode = (String)msg.obj;
                if(!TextUtils.isEmpty(errorCode)
                        && errorCode.equals("10004")){
                    pb_loading.setVisibility(View.VISIBLE);
//                    handleSessionTimeout();
                }else{
                    loadUrl(false, false);
                }
            }break;

            default:
                break;
        }
    }

    /**
     * 加载Url或出错重新加载
     * @param isReload
     * @param isSessionTimeout
     */
    private void loadUrl(boolean isReload, boolean isSessionTimeout){
        isLoadError = false;
        this.isReload = isReload;
        if(!isReload || isSessionTimeout){
//            mWebView.clearCache(true);
            syncCookie();
            if(!TextUtils.isEmpty(mUrl)) {
                mWebView.loadUrl(mUrl);
            }
        }else{
            mWebView.reload();
        }
    }

    @Override
    protected void onDestroy() {
        if(null != mWebView){
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
        super.onDestroy();
    }

    /*************************** 对子类开放url重定向处理 ****************************/
    /**
     * 子类是否捕捉特殊处理重定向事件
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
        isLoadError = true;
        view_errorpage.setVisibility(View.VISIBLE);
        mWebView.setVisibility(View.GONE);
    }

    /*************************** webview JS交互 *********************************/

    /**
     * JS通知页面，用户点击返回键（单页时需要网页处理返回键）
     */
    public void onBackKeyDown() {
        String url = "javascript:notifyClickPhoneBack()";
        mWebView.loadUrl(url);
    }

    /*************************** webview相关 ************************************/
    /**
     * 同步webview cookie
     */
    private void syncCookie(){
        // Cookie 认证
        CookieSyncManager.createInstance(this);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.removeAllCookie();
        CookiesItem[] cookieList = RequestJni.GetCookiesItem();
        if(cookieList != null && cookieList.length > 0){
            for(CookiesItem item : cookieList){
                if(item != null){
                    String sessionString = item.cName + "=" + item.value;
                    cookieManager.setCookie(item.domain, sessionString);
                    Log.logD(TAG,"syncCookie-domain:"+item.domain+" sessionString:"+sessionString);
                }
            }
        }
        CookieSyncManager.getInstance().sync();
    }

    /**
     * 自定义webviewClient处理事件
     */
    private class MyWebViewClient extends WebViewClient{
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            //这里的url可能由于编码问题，在间接调用到String.format方法时会跑错
            //参考:http://blog.csdn.net/cyanflxy/article/details/46274003
            //因此使用System.out.print而非Log.d
            System.err.println("onPageStarted url:"+url);
            mIsPageLoadFinish = false;
            pb_loading.setVisibility(View.VISIBLE);
            super.onPageStarted(view, url, favicon);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            System.err.println("onPageFinished url:"+url);
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
            System.err.println("shouldOverrideUrlLoading-url:"+url);
            //url重定向以及点击页面中的某些链接(get)会执行该方法
            //复写该方法,使得load url时不会打开系统浏览器而是在mWebView中显示
            //协议拦截-参考文档<<App-Webview交互说明>>
            if(onShouldOverrideUrlLoading(view, url)){
                //子类已特殊显示
                return true;
            }

            if(url.equals("qpidnetwork://app/closewindow")){
                finish();
                return true;
            }
            if(URL2ActivityManager.getInstance().URL2Activity(BaseWebViewActivity.this,url)){
                return  true;
            }
            return super.shouldOverrideUrlLoading(view, url);
        }

        @Override
        public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
            System.err.println("onReceivedHttpAuthRequest-host:"+host+" realm:"+realm);
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
            System.err.println("onReceivedError-errorCode:"+errorCode+" description:"+description
                    +" failingUrl:"+failingUrl);
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
                System.err.println("onReceivedHttpError-errorResponse.mStatusCode:" + errorResponse.getStatusCode());
                //解决页内部http错误也会回调，导致页面加载成功部分且内容加载失败被误认为页面加载失败
                if (request != null && request.getUrl() != null) {
                    Uri tempUri = request.getUrl();
                    Uri pageUri = Uri.parse(mUrl);
                    if (tempUri.getScheme().equals(pageUri.getScheme())
                            && tempUri.getPath().equals(pageUri.getPath())) {
                        //Android 6.0以上
                        onLoadError();
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
                handler.proceed();//表示等待证书响应
                // handler.cancel//表示挂起连接-默认处理方式
                // handler.handleMessage(null)//可做其他处理
            }
        }
    }

    /**
     * 网页加载后 , UI处理
     */
    @SuppressLint("HandlerLeak")
    private Handler mHandler4UI = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch ( TypeUIRefresh.values()[msg.what] ) {
                case onPageFinished:
                    //隐藏进度条
                    pb_loading.setVisibility(View.GONE);

                    //添加延时加载
                    if (isBlockLoadingNetworkImage) {
                        if (mWebView != null) {
                            mWebView.getSettings().setBlockNetworkImage(false);
                        }
                        isBlockLoadingNetworkImage = false;
                    }

                    //reload时清除历史
                    if (isReload) {
                        mWebView.clearHistory();
                    }

                        /*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
                    if ((!isLoadError)) {
                        view_errorpage.setVisibility(View.GONE);
                        if (null != mWebView) {
                            mWebView.setVisibility(View.VISIBLE);
                        }
                        //                fl_commTitleBar.setVisibility(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
//                        setTitleVisible(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
                    } else {
                        //                fl_commTitleBar.setVisibility(View.VISIBLE);
//                        setTitleVisible(View.VISIBLE);
                    }
                    break;

                default:
                    break;
            }
        }
    };

    /*************************** session过期重登陆  *****************************/
    @JavascriptInterface
    public void callbackWebAuthExpired (String message){
        //需要严格按照文档生命方法类型、方法名、方法接受的参数，不然前端js回调不能触发
        Log.d(TAG, "callbackWebAuthExpired-message:"+message);
        //session过期通知，注销跳转到登录界面
        LoginManager.getInstance().onKickedOff(mContext.getResources().getString(R.string.session_timeout_kick_off_tips));
    }

    /*************************** 重新组装url增加device和appver字段  *****************************/
    /**
     * url添加公共头appver和device
     * @param url
     * @return
     */
    private String packageWebViewUrl(String url){
        StringBuilder sb = new StringBuilder(url);
        //增加device
        if(url.contains("?")){
            sb.append("&device=30");
        }else{
            sb.append("?device=30");
        }
        //增加appver
        sb.append("&appver=");
        int versionCode = SystemUtils.getVersionCode(this);
        sb.append(String.valueOf(versionCode));
        return sb.toString();
    }
}
