package com.qpidnetwork.livemodule.liveshow.help;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;

/**
 * Description:用户协议页
 * <p>
 * Created by Harry on 2017/5/22.
 */

public class UserTermsActivity extends BaseActionBarFragmentActivity {

    private WebView wv_user_item;
    private final String defaultUserItemUrl = "file:///android_asset/use_item.html";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        initView();
    }

    private void initView(){
        setCustomContentView(R.layout.activity_user_items);
        wv_user_item = (WebView)findViewById(R.id.wv_user_item);
        WebSettings webSettings = wv_user_item.getSettings();
        //The default is "UTF-8".
        webSettings.setDefaultTextEncodingName("UTF-8");
        webSettings.setJavaScriptEnabled(true);
        wv_user_item.setWebViewClient(new WebViewClient(){

            @Override
            public void onPageFinished(WebView view, String url) {
                Log.d(TAG,"onPageFinished");
                super.onPageFinished(view, url);
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                Log.d(TAG,"onPageStarted");
                super.onPageStarted(view, url, favicon);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Log.d(TAG,"shouldOverrideUrlLoading-url:"+url);
                view.loadUrl(url);
                return true;
            }

            @SuppressLint("NewApi")
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Log.d(TAG,"shouldOverrideUrlLoading-url:"+request.getUrl().toString());
                view.loadUrl(request.getUrl().toString());
                return true;
            }
        });
        String url = getIntent().getStringExtra("url");
        wv_user_item.loadUrl(null == url ? defaultUserItemUrl : url);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK) && wv_user_item.canGoBack()) {
            wv_user_item.goBack();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
