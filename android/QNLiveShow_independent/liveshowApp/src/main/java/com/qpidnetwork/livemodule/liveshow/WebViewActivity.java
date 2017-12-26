package com.qpidnetwork.livemodule.liveshow;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.os.Bundle;
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
import android.webkit.WebChromeClient;
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

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.RequestJni;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.CookiesItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.model.js.CallbackAppGAEventJSObj;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Created by Hunter Mun on 2017/9/14.
 */

public class WebViewActivity extends BaseWebViewActivity{
    /**
     * url访问的数据类型
     */
    public enum UrlIntent{
        View_Audience_Level,//查看用户个人等级
        View_Audience_Intimacy_With_Anchor,//查看亲密度等级说明
        View_Terms_Of_Use//查看用户协议页面
    }

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param urlIntent
     * @param anchorid
     * @param showTitleBarWhenLoadSuc
     * @return
     */
    public static Intent getIntent(Context context, String title, UrlIntent urlIntent,
                                   String anchorid,boolean showTitleBarWhenLoadSuc){
        Intent intent = new Intent(context, WebViewActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
        String url = null;
        ConfigItem configItem = LoginManager.getInstance().getLocalConfigItem();
        switch (urlIntent){
            case View_Terms_Of_Use:
                url = configItem.userProtocol;
                break;
            case View_Audience_Level:
                url = configItem.userLevel;
                break;
            case View_Audience_Intimacy_With_Anchor:
                url = configItem.intimacy;
                StringBuilder sb = new StringBuilder(url);
                if(url.contains("?")){
                    sb.append("&anchorid=");
                }else{
                    sb.append("?anchorid=");
                }
                sb.append(anchorid);
                url = sb.toString();
                break;
        }
        url = IPConfigUtil.addCommonParamsToH5Url(url);
        System.err.println("WebViewActivity-getIntent-urlIntent:"+urlIntent+" url:"+url);
        if(!TextUtils.isEmpty(url)){
            intent.putExtra(WEB_URL, url);
        }
        return intent;
    }

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param url
     * @param showTitleBarWhenLoadSuc
     * @return
     */
    public static Intent getIntent(Context context, String title, String url, boolean showTitleBarWhenLoadSuc){
        Intent intent = new Intent(context, WebViewActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
        intent.putExtra(WEB_URL, url);
        return intent;
    }
}
