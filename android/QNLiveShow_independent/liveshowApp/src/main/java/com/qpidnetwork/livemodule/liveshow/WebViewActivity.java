package com.qpidnetwork.livemodule.liveshow;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;

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
        ConfigItem configItem = LoginManager.getInstance().getSynConfig();
        if(configItem != null) {
            switch (urlIntent) {
                case View_Terms_Of_Use:
                    url = configItem.userProtocol;
                    break;
                case View_Audience_Level:
                    url = configItem.userLevel;
                    break;
                case View_Audience_Intimacy_With_Anchor:
                    url = configItem.intimacy;
                    StringBuilder sb = new StringBuilder(url);
                    if (url.contains("?")) {
                        sb.append("&anchorid=");
                    } else {
                        sb.append("?anchorid=");
                    }
                    sb.append(anchorid);
                    url = sb.toString();
                    break;
            }
            url = IPConfigUtil.addCommonParamsToH5Url(url);
            System.err.println("WebViewActivity-getIntent-urlIntent:" + urlIntent + " url:" + url);
            if (!TextUtils.isEmpty(url)) {
                intent.putExtra(WEB_URL, url);
            }
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
