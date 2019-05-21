package com.qpidnetwork.livemodule.liveshow.loi;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.ColorDrawable;
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
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.ObservableWebView;
import com.qpidnetwork.livemodule.framework.widget.OpenFileWebChromeClient;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
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
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.MediaUtility;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;

import static com.qpidnetwork.livemodule.liveshow.BaseWebViewActivity.HTTP_EMPTY_PAGE;
import static com.qpidnetwork.livemodule.liveshow.BaseWebViewActivity.HTTP_ERROR_CODE_UN_AUTH;

/**
 * Created by Hunter Mun on 2017/11/10.
 */

public class BaseAlphaBarWebViewActivity extends BaseAlphaBarWebViewFragmentActivity implements IAuthorizationListener, JSCallbackListener {

    private static final int LOGIN_CALLBACK = 10001;

    public static final String WEB_URL = "web_url";
    public static final String WEB_TITLE = "web_title";
    public static final String WEB_TITLE_BAR_SHOW_LOADSUC = "showTitleBarWhenLoadSuc";

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

    protected int topMargin = 0;

    private float lastTitleAlpha = 0f;
    private int lastCommTitleBar = 0;

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
        super.onCreate(savedInstanceState);
        TAG = BaseAlphaBarWebViewActivity.class.getSimpleName();
        //修改解决共享颜色资源导致修改资源alpha值，影响其他界面使用该资源的alpha值
        if(fl_commTitleBar != null) {
            fl_commTitleBar.setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.webview_title_bg)));
        }

        initWebView();
        initViewData();
        LoginManager loginManager = LoginManager.getInstance();
        if(null != loginManager){
            loginManager.register(this);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG,"onResume");
        //激活webview为活跃状态,能正常执行网页的响应
        owv_content.onResume();
        if(mIsNeedResume){
            syncCookie();
        }
        fl_commTitleBar.getBackground().setAlpha(lastCommTitleBar);
        tv_commTitle.setAlpha(lastTitleAlpha);

        //add by Jagger
//        try {
//            mWebView.getClass().getMethod("onResume" , new Class<?>[]{}).invoke(mWebView,(Object[])null);
//        }catch (Exception e){
//            Log.i("Jagger" , "直播webview onResume Exception: " + e.toString());
//        }
//        mWebView.resumeTimers();


        //判断是否通知网页刷新
        if(mResumecbFlags && mIsNeedResume){
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
        owv_content.onPause();
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
     * 初始化配置webview
     */
    protected void initWebView(){
        syncCookie();
        WebSettings webSettings = owv_content.getSettings();
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
        String appCachePath = getApplicationContext().getCacheDir().getAbsolutePath();
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
        //以下设置为配合Chrome DevTools调试webview的h5页面[setWebContentsDebuggingEnabled是静态方法，针对整个app的WebView]
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }

        //Android 4.2以下存在漏洞问题,待解决
//        mJSCallback = new CallbackAppGAEventJSObj(this.getApplicationContext());
        // 2018/11/6 Hardy
        mJSCallback = new CallbackAppGAEventJSObj(this);

        mJSCallback.setJSCallbackListener(this);
        owv_content.addJavascriptInterface(mJSCallback, "LiveApp");
//        owv_content.removeJavascriptInterface("searchBoxJavaBridge_");
//        owv_content.removeJavascriptInterface("accessibility");
//        owv_content.removeJavascriptInterface("accessibilityTraversal");
        owv_content.setWebViewClient(new MyWebViewClient());
        mOpenFileWebChromeClient = new OpenFileWebChromeClient(this);
        owv_content.setWebChromeClient(mOpenFileWebChromeClient);
        //add by Jagger 针对视频的问题,加了些代码,并未使用.如有问题可使用试试效果
//        mWebView.getSettings().setPluginState(WebSettings.PluginState.ON);
//        owv_content.setWebChromeClient(new WebChromeClient());

        owv_content.setOnScrollChangedCallback(new ObservableWebView.OnScrollChangedCallback(){
            @Override
            public void onPageEnd(int l, int t, int oldl, int oldt) {
                Log.d(TAG,"onPageEnd-l:"+l+" t:"+t+" oldl:"+oldl+" oldt:"+oldt);
//                mToolbar.setAlpha(1);
                lastCommTitleBar = 255;
                fl_commTitleBar.getBackground().setAlpha(lastCommTitleBar);
                lastTitleAlpha = 1f;
                tv_commTitle.setAlpha(lastTitleAlpha);
            }

            @Override
            public void onPageTop(int l, int t, int oldl, int oldt) {
                Log.d(TAG,"onPageTop-l:"+l+" t:"+t+" oldl:"+oldl+" oldt:"+oldt);
//                mToolbar.setAlpha(0);
                lastTitleAlpha = 0f;
                lastCommTitleBar = 0;
                fl_commTitleBar.getBackground().setAlpha(lastCommTitleBar);
                tv_commTitle.setAlpha(lastTitleAlpha);
            }

            @Override
            public void onScrollChanged(int l, int t, int oldl, int oldt) {
                Log.d(TAG,"onScrollChanged-l:"+l+" t:"+t+" oldl:"+oldl+" oldt:"+oldt);
                // alpha = 滑出去的高度/(screenHeight/3);
                float heightPixels = tb_titleBar.getHeight(); //getResources().getDisplayMetrics().heightPixels;
//                float scrollY = t;//该值 大于0
//                float alpha = scrollY/heightPixels;// 0~1 透明度是1~0
//                float alpha = scrollY/(heightPixels/3);// 0~1 透明度是1~0
                //这里选择的screenHeight的1/3 是alpha改变的速率 （根据你的需要你可以自己定义）

//                Log.i("Jagger" , "heightPixels:"+heightPixels +",scrollY:" + scrollY+",alpha:"+alpha);
//                mToolbar.setAlpha(alpha);

//                mRlToolbarBg.setAlpha(alpha);
//                int alphtBg =Float.valueOf(alpha*255).intValue();
//                Log.d(TAG,"onScrollChanged-alphtBg:"+alphtBg+" heightPixels:"+heightPixels);
                if(t>oldt || (t<oldt && oldt<=topMargin)){
                    float oldAlpha = tv_commTitle.getAlpha();
                    oldAlpha+=(t-oldt)/heightPixels;
                    Log.d(TAG,"onScrollChanged-oldAlpha1:"+oldAlpha+" heightPixels:"+heightPixels);
                    tv_commTitle.setAlpha(oldAlpha);
                    lastTitleAlpha = oldAlpha;
                    oldAlpha=oldAlpha*255;
                    Log.d(TAG,"onScrollChanged-oldAlpha2:"+oldAlpha+" heightPixels:"+heightPixels);
                    int currAlpha = Float.valueOf(oldAlpha).intValue();
                    if(currAlpha<=0){
                        currAlpha = 0;
                    }
                    if(currAlpha>=255){
                        currAlpha=255;
                    }
                    Log.d(TAG,"onScrollChanged-currAlpha:"+currAlpha+" heightPixels:"+heightPixels);
                    lastCommTitleBar = currAlpha;
                    fl_commTitleBar.getBackground().setAlpha(currAlpha);

                }
            }
        });

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
            if (!TextUtils.isEmpty(mUrl)) {
                mUrl = CoreUrlHelper.packageWebviewUrl(this, mUrl);
            }
            Log.d(TAG,"initViewData-mUrl:"+mUrl);
            mTitle = bundle.getString(WEB_TITLE,mTitle);
            Log.d(TAG,"initViewData-mTitle:"+mTitle);
            showTitleBarWhenLoadSuc = bundle.getBoolean(WEB_TITLE_BAR_SHOW_LOADSUC);
            Log.d(TAG,"initViewData-showTitleBarWhenLoadSuc:"+showTitleBarWhenLoadSuc);
        }

        //解析设置screenname
        setCurrentScreenName(URL2ActivityManager.parseScreenNameByUrl(mUrl));

        //读取resumecb标志位
        mResumecbFlags = URL2ActivityManager.getInstance().getResumecbFlags(mUrl);

        if(!TextUtils.isEmpty(mTitle)) {
//            tv_commTitle.setText(mTitle);
            //设置头
            setTitle(mTitle, R.color.theme_default_black);
        }
        topMargin = DisplayUtil.dip2px(this,56f);
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
            finish();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"onStop");
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN && mIsPageLoadFinish && !isLoadError) {
//            if( mWebView.canGoBack() ) {
//                mWebView.goBack();
//            } else {
                //交给页面处理
                onBackKeyDown();
//                finish();
//            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 事件处理
     * @param msg
     */
    protected void handleUiMessage(Message msg) {
        switch (msg.what) {
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
    private void loadUrl(boolean isReload, boolean isSessionTimeout){
        isLoadError = false;
        this.isReload = isReload;
        if(!isReload || isSessionTimeout){
//            mWebView.clearCache(true);
            syncCookie();
            if(!TextUtils.isEmpty(mUrl)) {
                owv_content.loadUrl(mUrl);
            }
        }else{
            owv_content.reload();
        }
    }

    @Override
    protected void onDestroy() {
        LoginManager loginManager = LoginManager.getInstance();
        if(null != loginManager){
            loginManager.unRegister(this);
        }
        if(null != owv_content){
            //清除绑定，防止泄露
            if(mJSCallback != null){
                mJSCallback.setJSCallbackListener(null);
            }
            //解决5.1以上webview内存泄漏问题
            ViewParent parent = owv_content.getParent();
            if (parent != null) {
                ((ViewGroup) parent).removeView(owv_content);
            }
            owv_content.stopLoading();
            // 退出时调用此方法，移除绑定的服务，否则某些特定系统会报错
            owv_content.getSettings().setJavaScriptEnabled(false);
//            mWebView.clearCache(true);
            owv_content.clearHistory();//清理历史记录
            owv_content.freeMemory();//释放内存
            owv_content.clearFormData();//仅仅清除自动完成填充的表单数据,并不会清理存储到本地的数据
            owv_content.clearMatches();
            owv_content.clearSslPreferences();
            owv_content.clearDisappearingChildren();
            owv_content.clearAnimation();
            owv_content.clearView();
            owv_content.removeAllViews();
            try {
                owv_content.destroy();
            } catch (Throwable ex) {
                ex.printStackTrace();
            }
            owv_content = null;
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
        fl_commTitleBar.setVisibility(View.VISIBLE);
        owv_content.setVisibility(View.GONE);
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
        if (httpCode == HTTP_ERROR_CODE_UN_AUTH && !isErrorUnAuthLoad) {  // test:5179 的 401 验证问题
            isErrorUnAuthLoad = true;

            owv_content.loadUrl(HTTP_EMPTY_PAGE);        // 空白页，避免出现默认的错误界面
            loadUrl(true, false); // 模拟重新加载页面
        } else {
            //Android 6.0以上
            onLoadError();
        }
    }

    private boolean isErrorUnAuthLoad;

    /**
     * 利用接口和webview共用cookie，通过接口cookie过期自动重登陆实现session过期重登陆，刷新cookie
     */
    private void handleSessionTimeout(){
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
        owv_content.loadUrl(url);
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
                if(!TextUtils.isEmpty(errorcode)
                        && errorcode.equals(CallbackAppGAEventJSObj.WEBVIEW_SESSION_ERROR_NO)){
                    LoginManager.LoginStatus loginStatus = LoginManager.getInstance().getLoginStatus();
                    if(loginStatus == LoginManager.LoginStatus.Logined){
                        LoginNewActivity.launchRegisterActivity(mContext);
                    }else{
                        pb_loading.setVisibility(View.VISIBLE);
                        handleSessionTimeout();
                    }
                }else if(!TextUtils.isEmpty(errorcode)
                        && errorcode.equals(CallbackAppGAEventJSObj.WEBVIEW_NOCREDIT_ERROR_NO)){
                    if(!TextUtils.isEmpty(errMsg)){
                        showCreditNoEnoughDialog(errMsg, params);
                    }else{
                        LiveModule.getInstance().onAddCreditClick(mContext, params);
                        //GA统计点击充值
                        AnalyticsManager.getsInstance().ReportEvent(
                                BaseAlphaBarWebViewActivity.this.getResources().getString(R.string.Live_Global_Category),
                                BaseAlphaBarWebViewActivity.this.getResources().getString(R.string.Live_Global_Action_AddCredit),
                                BaseAlphaBarWebViewActivity.this.getResources().getString(R.string.Live_Global_Label_AddCredit));
                    }
                }else{
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
                if (!TextUtils.isEmpty(isShow)){
                    if(isShow.equals("0")){
                        setTitleVisible(View.GONE);
                    }else if(isShow.equals("1")){
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

            //读取resumecb标志位
            mResumecbFlags = URL2ActivityManager.getInstance().getResumecbFlags(mUrl);

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
            if(new AppUrlHandler(BaseAlphaBarWebViewActivity.this).urlHandle(url)){
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
//                    if (isBlockLoadingNetworkImage) {
//                        if (owv_content != null) {
//                            owv_content.getSettings().setBlockNetworkImage(false);
//                        }
//                        isBlockLoadingNetworkImage = false;
//                    }

                    //reload时清除历史
                    if (isReload) {
                        owv_content.clearHistory();
                    }

                        /*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
                    if ((!isLoadError)) {
                        view_errorpage.setVisibility(View.GONE);
                        if (null != owv_content) {
                            owv_content.setVisibility(View.VISIBLE);
                        }
                        //                fl_commTitleBar.setVisibility(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
                        setTitleVisible(showTitleBarWhenLoadSuc ? View.VISIBLE : View.GONE);
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

    /*************************** 重新组装url增加device和appver字段  *****************************/

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(TAG,"onActivityResult-requestCode:"+requestCode+" resultCode:"+resultCode);
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
            if(!TextUtils.isEmpty(path)){
                uri = Uri.fromFile(new File(path));
            }
        }
        if(null == uri && requestCode == OpenFileWebChromeClient.REQUEST_CAPTURE_PHOTO){
            //因为拍照在红米note2手机上返回的intent为null，因此需要自己处理uri
            uri = Uri.fromFile(new File(FileCacheManager.getInstance().GetTempCameraImageUrl()));
        }
        Log.logD(TAG,"onActivityResult-result:"+result+" uri:"+uri);

        // 2018/11/27 Hardy
        if (uri != null && requestCode == OpenFileWebChromeClient.REQUEST_CAPTURE_PHOTO) {
            String path = FileCacheManager.getInstance().GetTempCameraImageUrl();
//            String fileName = "file_choose" + "_" + System.currentTimeMillis() + ".jpg";
//            Log.logD(TAG,"onActivityResult-result:"+result+" path:"+ path +"----> fileName: "+"");
            ImageUtil.SaveImageToGallery(this, path);
        }

        if(null != mOpenFileWebChromeClient.mFilePathCallback){
            mOpenFileWebChromeClient.mFilePathCallback.onReceiveValue(uri);
            //避免下一次js执行无响应
            mOpenFileWebChromeClient.mFilePathCallback = null;
        }
        if(mOpenFileWebChromeClient.mFilePathCallbacks != null){
            mOpenFileWebChromeClient.mFilePathCallbacks.onReceiveValue(null == uri ? null : new Uri[] {uri});
            //避免下一次js执行无响应
            mOpenFileWebChromeClient.mFilePathCallbacks = null;
        }
    }

    /**
     * 通知页面用户返回
     */
    public void notifyResume() {
        String url = "javascript:notifyResume()";
        if(owv_content != null){
            owv_content.loadUrl(url);
        }
    }

}
