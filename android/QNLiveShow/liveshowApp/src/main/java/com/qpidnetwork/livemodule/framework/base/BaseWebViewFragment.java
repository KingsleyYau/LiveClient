package com.qpidnetwork.livemodule.framework.base;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
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
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.OpenFileWebChromeClient;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHotListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.CreditsTipsDialog;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.model.js.CallbackAppGAEventJSObj;
import com.qpidnetwork.livemodule.liveshow.model.js.JSCallbackListener;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Created by Harry52 on 18/8/16.
 */

public class BaseWebViewFragment extends BaseFragment implements IAuthorizationListener, JSCallbackListener {
    protected LinearLayout ll_webview;
    protected WebView mWebView;
    protected View view_errorpage;
    protected Button btnRetry;
    protected ProgressBar pb_loading;

    private CallbackAppGAEventJSObj mJSCallback;
    //chromeClient.支持图库及文件夹访问
    private OpenFileWebChromeClient mOpenFileWebChromeClient;
    //页面是否load成功 解决页面load未完成，物理返回键被hold住问题(js 无响应)
    private boolean mIsPageLoadFinish = false;
    private static final int LOGIN_CALLBACK = 10001;
    private static final int LOAD_FINISHED = 10002;
    private boolean isReload = false; //记录是否重新加载，重新加载成功需清除history
    protected boolean isLoadError = false;
    protected String mUrl = "";
    protected boolean hasViewCreated = false;

    /**
     * 接口消息
     */
    protected enum TypeUIRefresh {
        onPageFinished
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.activity_normal_webview,container,false);
        initView(view);
        initWebView();
        initViewData();
        LoginManager loginManager = LoginManager.getInstance();
        if(null != loginManager){
            loginManager.register(this);
        }
        hasViewCreated = true;
        return view;
    }

    private void initView(View view){
        Log.d(TAG,"initView");
        view_errorpage = view.findViewById(R.id.view_errorpage);
        view_errorpage.setVisibility(View.GONE);
        btnRetry = (Button) view.findViewById(R.id.btnRetry);
        btnRetry.setOnClickListener(this);
        pb_loading = (ProgressBar) view.findViewById(R.id.pb_loading);
        LinearLayout.LayoutParams webviewLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
        mWebView = new WebView(view.getContext());
        ll_webview = (LinearLayout) view.findViewById(R.id.ll_webview);
        ll_webview.addView(mWebView,webviewLp);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnRetry) {
            view_errorpage.setVisibility(View.GONE);
            loadUrl(true, false);
        }
    }

    /**
     * 初始化配置webview
     */
    protected void initWebView(){
        Log.d(TAG,"initWebView");
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
        webSettings.setAppCacheMaxSize(1024*1024*8);
        String appCachePath = mContext.getCacheDir().getAbsolutePath();
        Log.d(TAG,"initWebView-appCachePath:"+appCachePath);
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
        //以下设置为配合Chrome DevTools调试webview的h5页面
        // [setWebContentsDebuggingEnabled是静态方法，针对整个app的WebView]
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(LiveApplication.isDemo);
        }
        //Android 4.2以下存在漏洞问题,待解决
        mJSCallback = new CallbackAppGAEventJSObj(mContext);
        mJSCallback.setJSCallbackListener(this);
        mWebView.addJavascriptInterface(mJSCallback, "LiveApp");
//        mWebView.removeJavascriptInterface("searchBoxJavaBridge_");
//        mWebView.removeJavascriptInterface("accessibility");
//        mWebView.removeJavascriptInterface("accessibilityTraversal");
        mWebView.setWebViewClient(new MyWebViewClient());
        mOpenFileWebChromeClient = new OpenFileWebChromeClient(getActivity());
        mWebView.setWebChromeClient(mOpenFileWebChromeClient);
        //add by Jagger 针对视频的问题,加了些代码,并未使用.如有问题可使用试试效果
//        mWebView.getSettings().setPluginState(WebSettings.PluginState.ON);
//        mWebView.setWebChromeClient(new WebChromeClient());
    }

    /**
     * 同步webview cookie
     */
    private void syncCookie(){
        Log.d(TAG,"syncCookie");
        // Cookie 认证
        CookieSyncManager.createInstance(mContext);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.removeAllCookie();
        CookiesItem[] cookieList = RequestJni.GetCookiesItem();
        if(cookieList != null && cookieList.length > 0){
            for(CookiesItem item : cookieList){
                if(item != null){
                    String sessionString = item.cName + "=" + item.value;
                    cookieManager.setCookie(item.domain, sessionString);
                    Log.d(TAG,"syncCookie-domain:"+item.domain+" sessionString:"+sessionString);
                }
            }
        }
        CookieSyncManager.getInstance().sync();
    }

    /**
     * 读取外部传入数据
     */
    protected void initViewData(){
        Log.d(TAG,"initViewData");
    }

    /**
     * 事件处理
     * @param msg
     */
    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case LOAD_FINISHED: {
                //隐藏进度条
                pb_loading.setVisibility(View.GONE);
                //reload时清除历史
                if (isReload) {
                    mWebView.clearHistory();
                }
                /*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
                if (!isLoadError) {
                    view_errorpage.setVisibility(View.GONE);
                    if (null != mWebView) {
                        mWebView.setVisibility(View.VISIBLE);
                    }
                }
            }break;
            case LOGIN_CALLBACK:{
                pb_loading.setVisibility(View.GONE);
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //session 过期重新登陆
                    loadUrl(true, true);
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
    protected void loadUrl(boolean isReload, boolean isSessionTimeout){
        Log.logD(TAG,"loadUrl-isReload:"+isReload+" isSessionTimeout:"+isSessionTimeout);
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
    public void onDestroy() {
        super.onDestroy();
        LoginManager loginManager = LoginManager.getInstance();
        if(null != loginManager){
            loginManager.unRegister(this);
        }
        if(null != mWebView){
            //清除绑定，防止泄露
            if(mJSCallback != null){
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

    /**
     * 自定义webviewClient处理事件
     */
    public class MyWebViewClient extends WebViewClient {
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
            sendEmptyUiMessage(LOAD_FINISHED);
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
            Log.logD(TAG,"shouldOverrideUrlLoading-url:"+url);
            //url重定向以及点击页面中的某些链接(get)会执行该方法
            //复写该方法,使得load url时不会打开系统浏览器而是在mWebView中显示
            //协议拦截-参考文档<<App-Webview交互说明>>
            if(onShouldOverrideUrlLoading(view, url)){
                //子类已特殊显示
                return true;
            }

            if(url.equals("qpidnetwork://app/closewindow")){
                return true;
            }
            if(URL2ActivityManager.getInstance().URL2Activity(getActivity(),url)){
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
     * 子类是否捕捉特殊处理重定向事件
     * @return
     */
    public boolean onShouldOverrideUrlLoading(WebView view, String url) {
        return false;
    }

    /**
     * 加载网页，网络出错错误处理
     */
    protected void onLoadError() {
        isLoadError = true;
        view_errorpage.setVisibility(View.VISIBLE);
        mWebView.setVisibility(View.GONE);
    }

    /**
     * Fragment webview 监听返回键
     */
    public void onBackKeyDown() {
        if( mWebView.canGoBack() ) {
            mWebView.goBack();
        } else {
            //S通知页面，用户点击返回键（单页时需要网页处理返回键）
            String url = "javascript:notifyClickPhoneBack()";
            mWebView.loadUrl(url);
        }

    }

    /*************************** session过期重登陆  *****************************/
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Log.d(TAG,"onLogin-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
        Message msg = Message.obtain();
        msg.what = LOGIN_CALLBACK;
        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
        msg.obj = response;
        sendUiMessage(msg);
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    @Override
    public void onEventClose() {
    }

    @Override
    public void onEventPageError(final String errorcode, final String errMsg, final NoMoneyParamsBean params) {
            if(null != getActivity()){
                getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(!TextUtils.isEmpty(errorcode) && errorcode.equals(CallbackAppGAEventJSObj.WEBVIEW_SESSION_ERROR_NO)){
                            pb_loading.setVisibility(View.VISIBLE);
                            handleSessionTimeout();
                        }else if(!TextUtils.isEmpty(errorcode)
                                && errorcode.equals(CallbackAppGAEventJSObj.WEBVIEW_NOCREDIT_ERROR_NO)){
                            if(!TextUtils.isEmpty(errMsg)){
                                showCreditNoEnoughDialog(errMsg);
                            }else{
                                LiveService.getInstance().onAddCreditClick(params);
                                //GA统计点击充值
                                AnalyticsManager.getsInstance().ReportEvent(
                                        mContext.getResources().getString(R.string.Live_Global_Category),
                                        mContext.getResources().getString(R.string.Live_Global_Action_AddCredit),
                                        mContext.getResources().getString(R.string.Live_Global_Label_AddCredit));
                            }
                        }else{
                            loadUrl(false, false);
                        }
                    }
                });
            }
    }

    /**
     * 利用接口和webview共用cookie，通过接口cookie过期自动重登陆实现session过期重登陆，刷新cookie
     */
    private void handleSessionTimeout(){
        LiveRequestOperator.getInstance().GetHotLiveList(0, 10, false, false, new OnGetHotListCallback() {
            @Override
            public void onGetHotList(boolean isSuccess, int errCode, String errMsg, HotListItem[] hotList) {

            }
        });
    }

    //----------------------------金币余额不足充值提示-----------------------------
    protected CreditsTipsDialog creditsTipsDialog;
    public void showCreditNoEnoughDialog(int tipsResId){
        if(null == creditsTipsDialog){
            creditsTipsDialog = new CreditsTipsDialog(mContext);
        }
        if(!creditsTipsDialog.isShowing()){
            creditsTipsDialog.setCreditsTips(getResources().getString(tipsResId));
            creditsTipsDialog.show();
        }
    }

    public void showCreditNoEnoughDialog(String message){
        if(null == creditsTipsDialog){
            creditsTipsDialog = new CreditsTipsDialog(mContext);
        }
        if(!creditsTipsDialog.isShowing()){
            creditsTipsDialog.setCreditsTips(message);
            creditsTipsDialog.show();
        }
    }
}
