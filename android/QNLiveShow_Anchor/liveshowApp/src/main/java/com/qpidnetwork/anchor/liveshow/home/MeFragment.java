package com.qpidnetwork.anchor.liveshow.home;

import android.annotation.TargetApi;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;
import android.view.LayoutInflater;
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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseFragment;
import com.qpidnetwork.anchor.httprequest.RequestJni;
import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.httprequest.item.CookiesItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;

/**
 * Created by Hunter Mun on 2018/3/22.
 */

public class MeFragment extends BaseFragment {

    private static final int ON_PAGE_LOAD_FINISH_EVENT = 1;

    //title
    private ImageView iv_commBack;

    //views
    protected LinearLayout ll_webview;
    protected WebView mWebView;
    protected View view_errorpage;
    protected Button btnRetry;
    protected ProgressBar pb_loading;

    //data
    protected String mUrl = "";
    boolean isBlockLoadingNetworkImage = false; //图片懒加载
    protected boolean isLoadError = false;
    private boolean isReload = false; //记录是否重新加载，重新加载成功需清除history

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        TAG = MeFragment.class.getSimpleName();
        View view = View.inflate(getContext(), R.layout.fragment_main_me, null);
        initViews(view);
        return view;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        configWebview();
        initViewData();
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if(isVisibleToUser){
            //viewpager切换
            if(mWebView != null){
                //隐藏错误页
                view_errorpage.setVisibility(View.GONE);
                loadUrl(true, false);
            }
        }
    }

    /**
     * 初始化界面显示
     * @param view
     */
    private void initViews(View view){
        //初始化titlebar
        iv_commBack = (ImageView)view.findViewById(R.id.iv_commBack);
        ((TextView)view.findViewById(R.id.tv_commTitle)).setText(R.string.live_main_me_title);
        TextView rightBtn = (TextView)view.findViewById(R.id.tv_opera);
        rightBtn.setVisibility(View.VISIBLE);
        rightBtn.setText(R.string.live_main_me_right_button_tips);
        iv_commBack.setOnClickListener(this);
        rightBtn.setOnClickListener(this);

        //错误页及加载页
        view_errorpage = view.findViewById(R.id.view_errorpage);
        view_errorpage.setVisibility(View.GONE);
        btnRetry = (Button) view.findViewById(R.id.btnRetry);
        btnRetry.setOnClickListener(this);
        btnRetry.setText(getString(R.string.common_btn_tap_to_retry));
        pb_loading = (ProgressBar) view.findViewById(R.id.pb_loading);

        //初始化webview
        LinearLayout.LayoutParams webviewLp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
        mWebView = new WebView(getActivity().getApplicationContext());
        //add by Jagger 2018-4-14
        //参考:https://my.oschina.net/u/1999055/blog/756281
        //WebView开启软件加速之后会导致花屏，Android 4.0（API级别14）中，硬件加速首次在所有应用程序默认开启，所以只需要关闭硬件加速就可以解决这个问题了。
        mWebView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        ll_webview = (LinearLayout) view.findViewById(R.id.ll_webview);
        ll_webview.addView(mWebView,webviewLp);

    }

    /**
     * 读取外部传入数据
     */
    protected void initViewData(){
        ConfigItem configItem = LoginManager.getInstance().getSynConfig();
        Log.logD(TAG, "me configItem: " + configItem);
        if(configItem != null && !TextUtils.isEmpty(configItem.mePageUrl)){
            mUrl = packUrl(configItem.mePageUrl);
            Log.logD(TAG, "me url: " + mUrl);
            //初始化加载
            loadUrl(false, false);
        }
    }

    /**
     * 加载Url或出错重新加载
     * @param isReload
     * @param isSessionTimeout
     */
    private void loadUrl(boolean isReload, boolean isSessionTimeout){
        Log.d(TAG,"loadUrl-isReload:"+isReload+" isSessionTimeout:"+isSessionTimeout);
        isLoadError = false;
        this.isReload = isReload;
        if(!isReload || isSessionTimeout){
            mWebView.clearCache(true);
            syncCookie();
            if(!TextUtils.isEmpty(mUrl)) {
                mWebView.loadUrl(mUrl);
            }
        }else{
            mWebView.reload();
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.iv_commBack:{
                if( mWebView != null && mWebView.canGoBack() ) {
                    mWebView.goBack();
                }
                //刷新返回按钮状态
                refreshBackButton();
            }break;

            case R.id.tv_opera:{
                new AlertDialog.Builder(getContext())
                        .setMessage(getResources().getString(R.string.live_logout_confirm_tips))
                        .setNegativeButton(getResources().getString(R.string.common_btn_cancel), null)
                        .setPositiveButton(getResources().getString(R.string.common_btn_sure), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                //注销跳转到登录界面
                                LoginManager.getInstance().onKickedOff("");
                            }
                        })
                        .create().show();
            }break;

            case R.id.btnRetry:{
                view_errorpage.setVisibility(View.GONE);
                loadUrl(true, false);
            }break;

            default:
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case ON_PAGE_LOAD_FINISH_EVENT:
                //隐藏进度条
                pb_loading.setVisibility(View.GONE);

                //刷新返回按钮显示
                refreshBackButton();

                //添加延时加载
                if (isBlockLoadingNetworkImage) {
                    if (mWebView != null) {
                        mWebView.getSettings().setBlockNetworkImage(false);
                    }
                    isBlockLoadingNetworkImage = false;
                }

                //reload时清除历史
                if (isReload && null != mWebView) {
                    mWebView.clearHistory();
                }

                /*重定向可能导致多次onPageStarted 但仅一次onPageFinished 导致dialog无法隐藏*/
                if ((!isLoadError)) {
                    view_errorpage.setVisibility(View.GONE);
                    if (null != mWebView) {
                        mWebView.setVisibility(View.VISIBLE);
                    }
                }
                break;

            default:
                break;
        }
    }

    /**
     * 加载网页，网络出错错误处理
     */
    protected void onLoadError() {
        Log.logD(TAG, "webview onLoadError");
        isLoadError = true;
        view_errorpage.setVisibility(View.VISIBLE);
        mWebView.setVisibility(View.GONE);
        //失败隐藏返回键
        refreshBackButton();
    }

    @Override
    public void onDetach() {
        //回收webview
        if(null != mWebView){
            //清除绑定，防止泄露
            //解决5.1以上webview内存泄漏问题
            ViewParent parent = mWebView.getParent();
            if (parent != null) {
                ((ViewGroup) parent).removeView(mWebView);
            }
            mWebView.stopLoading();
            // 退出时调用此方法，移除绑定的服务，否则某些特定系统会报错
            mWebView.getSettings().setJavaScriptEnabled(false);
            mWebView.clearCache(true);
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
        super.onDetach();
    }

    /**
     * 二次处理url添加自定义字段
     * @param url
     * @return
     */
    private String packUrl(String url){
        StringBuilder builder = new StringBuilder(url);
        if(!TextUtils.isEmpty(url)){
            if(url.contains("?")){
                builder.append("&device=30");
            }else{
                builder.append("?device=30");
            }
            //增加appver
            builder.append("&appver=");
            int versionCode = SystemUtils.getVersionCode(getActivity());
            builder.append(String.valueOf(versionCode));
        }
        return builder.toString();
    }

    /**
     * 刷新返回按钮是否显示
     */
    private void refreshBackButton(){
        boolean isShow = false;
        if(mWebView != null && mWebView.canGoBack()&& !isLoadError){
            isShow = true;
        }
        iv_commBack.setVisibility(isShow?View.VISIBLE:View.INVISIBLE);
    }

    /********************************* Webview配置 ***********************************/

    private void configWebview(){
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
        String appCachePath = getActivity().getApplicationContext().getCacheDir().getAbsolutePath();
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
    }

    /**
     * 同步webview cookie
     */
    private void syncCookie(){
        // Cookie 认证
        CookieSyncManager.createInstance(getActivity());
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
    private class MyWebViewClient extends WebViewClient {
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            //这里的url可能由于编码问题，在间接调用到String.format方法时会跑错
            //参考:http://blog.csdn.net/cyanflxy/article/details/46274003
            //因此使用System.out.print而非Log.d
            Log.logD(TAG, "onPageStarted url:"+url);
            pb_loading.setVisibility(View.VISIBLE);
            super.onPageStarted(view, url, favicon);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.logD(TAG, "onPageFinished url:"+url);

            //add by Jagger 2017-12-15
            //4.?的手机 , 通过onReceivedHttpAuthRequest后,回调回来会闪退
            Message msg = new Message();
            msg.what = ON_PAGE_LOAD_FINISH_EVENT;
            sendUiMessage(msg);
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Log.logD(TAG, "shouldOverrideUrlLoading-url:"+url);
            //url重定向以及点击页面中的某些链接(get)会执行该方法
            //复写该方法,使得load url时不会打开系统浏览器而是在mWebView中显示
            //协议拦截-参考文档<<App-Webview交互说明>>
            if(URL2ActivityManager.getInstance().URL2Activity(mContext, url)){
                //被捕捉后，拦截事件
                return true;
            }
            return super.shouldOverrideUrlLoading(view, url);
        }

        @Override
        public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
            Log.logD(TAG, "onReceivedHttpAuthRequest-host:"+host+" realm:"+realm);
            //del by Jagger 2017-12-14 在6.0以下会死先去掉
            handler.proceed("test", "5179");
//            super.onReceivedHttpAuthRequest(view,handler,host,realm);
        }

        @Override
        public void onFormResubmission(WebView view, Message dontResend, Message resend) {
            Log.d(TAG,"onFormResubmission");
            resend.sendToTarget();
            super.onFormResubmission(view, dontResend, resend);
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
//            super.onReceivedError(view,errorCode,description,failingUrl);
            Log.logD(TAG, "onReceivedError-errorCode:"+errorCode+" description:"+description
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
            Log.d(TAG,"onReceivedHttpError");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                super.onReceivedHttpError(view, request, errorResponse);
                Log.logD(TAG, "onReceivedHttpError-errorResponse.mStatusCode:" + errorResponse.getStatusCode());
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
            Log.d(TAG, "onReceivedSslError");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                //                super.onReceivedSslError(view, handler, error);
                handler.proceed();//表示等待证书响应
            }
        }
    }

    /********************************* JS Callback ***********************************/
    @JavascriptInterface
    public void callbackWebAuthExpired (String message){
        //需要严格按照文档生命方法类型、方法名、方法接受的参数，不然前端js回调不能触发
        Log.d(TAG, "callbackWebAuthExpired-message:"+message);
        //session过期通知，注销跳转到登录界面
        LoginManager.getInstance().onKickedOff(mContext.getResources().getString(R.string.session_timeout_kick_off_tips));
    }
}
