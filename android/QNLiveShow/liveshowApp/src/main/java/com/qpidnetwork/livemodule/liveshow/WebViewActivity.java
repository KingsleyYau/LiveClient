package com.qpidnetwork.livemodule.liveshow;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Message;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.HttpAuthHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ButtonRaised;

/**
 * Created by Hunter Mun on 2017/9/14.
 */

public class WebViewActivity extends BaseActionBarFragmentActivity implements IAuthorizationListener {

    private static final int LOGIN_CALLBACK = 10001;

    public static final String WEB_URL = "web_url";
    public static final String WEB_TITLE = "web_title";

    private WebView mWebView;
    private String mUrl = "";
    private String mTitle = "";

    //error page
    private View errorPage;
    private ButtonRaised btnErrorRetry;

    private boolean isSessionOutTimeError = false;
    private boolean isLoadError = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        InitView();

        // 创建界面时候读取数据
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(WEB_URL)){
                mUrl = bundle.getString(WEB_URL);
            }

            if(bundle.containsKey(WEB_TITLE)){
                mTitle = bundle.getString(WEB_TITLE);
            }
        }
//		mUrl = "http://demo-mobile.chnlove.com/member/bonus_points";
        if( mUrl != null && mUrl.length() > 0 ) {
            mWebView.loadUrl(mUrl);
        }

        if( mTitle != null && mTitle.length() > 0 ) {
            setTitle(mTitle, getResources().getColor(R.color.text_color_dark));
        }

        LoginManager.getInstance().register(this);
    }

    @Override
    protected void onDestroy() {
        LoginManager.getInstance().unRegister(this);
        super.onDestroy();
    }

    public void InitView() {
        setCustomContentView(R.layout.activity_normal_webview);
        mWebView = (WebView) findViewById(R.id.webView);

//        // 域名
//        String domain = WebSiteManager.getInstance().GetWebSite().getAppSiteHost();
//        // Cookie 认证
//        CookieSyncManager.createInstance(this);
//        CookieManager cookieManager = CookieManager.getInstance();
//        cookieManager.setAcceptCookie(true);
//        cookieManager.removeAllCookie();
//        CookiesItem[] cookieList = RequestJni.GetCookiesItem();
//        if(cookieList != null && cookieList.length > 0){
//            for(CookiesItem item : cookieList){
//                if(item != null){
//                    String sessionString = item.cName + "=" + item.value;
//                    cookieManager.setCookie(item.domain, sessionString);
//                }
//            }
//        }
////		String phpSession = RequestJni.GetCookies(domain.substring(domain.indexOf("http://") + 7, domain.length()));
////		cookieManager.setCookie(domain, phpSession);
//        CookieSyncManager.getInstance().sync();

        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                // TODO Auto-generated method stub
                super.onPageStarted(view, url, favicon);
                showProgressDialog("Loading...");
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                // TODO Auto-generated method stub
                super.onPageFinished(view, url);
                if((!isLoadError)&&(!isSessionOutTimeError)){
                    errorPage.setVisibility(View.GONE);
                }
                hideProgressDialogIgnoreCount();
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if( url.contains("MBCE0003")) {
                    //处理session过期重新登陆
                    isSessionOutTimeError = true;
                    errorPage.setVisibility(View.VISIBLE);
                } else {
                    return super.shouldOverrideUrlLoading(view, url);
                }
                return true;
            }

            @Override
            public void onReceivedHttpAuthRequest(WebView view,
                                                  HttpAuthHandler handler, String host, String realm) {
                if (LiveApplication.isDemo) {
                    handler.proceed("test", "5179");
                } else {
                    handler.cancel();
                }
            }

            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                //普通页面错误
                isLoadError = true;
                errorPage.setVisibility(View.VISIBLE);
            }
        });

        //error page
        errorPage = findViewById(R.id.errorPage);
        btnErrorRetry = (ButtonRaised)findViewById(R.id.btnErrorRetry);
        btnErrorRetry.setButtonTitle(getString(R.string.common_btn_tapRetry));
        btnErrorRetry.setOnClickListener(this);
        btnErrorRetry.requestFocus();

    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnErrorRetry) {
            if (isSessionOutTimeError) {
                showProgressDialog("Loading...");
//                    LoginManager.getInstance().Logout();
//                    LoginManager.getInstance().AutoLogin();
            } else {
                isLoadError = false;
                mWebView.reload();
            }
        } else {
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN ) {
            if( mWebView.canGoBack() ) {
                mWebView.goBack();
            } else {
                finish();
            }
            return false;
        } else {

        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case LOGIN_CALLBACK:{
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //session 过期重新登陆
                    isSessionOutTimeError = false;
                    reloadDestUrl();
                }else{
                    //显示错误页（加载页面错误）
                    hideProgressDialogIgnoreCount();
                    errorPage.setVisibility(View.VISIBLE);
                }
            }break;

            default:
                break;
        }
    }

    /***
     * Session 过期重登录后重新同步Cookie 然后重现加载Url
     */
    private void reloadDestUrl(){
		/*加载男士资料*/
//        String domain = WebSiteManager.getInstance().GetWebSite().getAppSiteHost();
//
//        CookieSyncManager.createInstance(this);
//        CookieManager cookieManager = CookieManager.getInstance();
//        cookieManager.setAcceptCookie(true);
//        cookieManager.removeAllCookie();
//        CookiesItem[] cookieList = RequestJni.GetCookiesItem();
//        if(cookieList != null && cookieList.length > 0){
//            for(CookiesItem item : cookieList){
//                if(item != null){
//                    String sessionString = item.cName + "=" + item.value;
//                    cookieManager.setCookie(item.domain, sessionString);
//                }
//            }
//        }
//
////		String phpSession = RequestJni.GetCookies(domain.substring(domain.indexOf("http://") + 7, domain.length()));
////		cookieManager.setCookie(domain, phpSession); //
//        CookieSyncManager.getInstance().sync();

        mWebView.clearCache(true);

        if( mUrl != null && mUrl.length() > 0 ) {
            mWebView.loadUrl(mUrl);
        }
    }

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param url
     * @return
     */
    public static Intent getIntent(Context context, String title, String url){
        Intent intent = new Intent(context, WebViewActivity.class);
        intent.putExtra(WEB_URL, url);
        intent.putExtra(WEB_TITLE, title);
        return intent;
    }

    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        Message msg = Message.obtain();
        msg.what = LOGIN_CALLBACK;
        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
        msg.obj = response;
        sendUiMessage(msg);
    }

    @Override
    public void onLogout() {
        // TODO Auto-generated method stub

    }

    /**
     * 忽视计数器直接隐藏progressDialog
     */
    public void hideProgressDialogIgnoreCount(){
        try {
            if( mProgressDialogCount > 0 ) {
                mProgressDialogCount = 0;
                if( progressDialog != null ) {
                    progressDialog.dismiss();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
