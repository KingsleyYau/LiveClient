package com.qpidnetwork.livemodule.liveshow.loi;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;

/**
 * Created by Hunter Mun on 2017/9/14.
 */

public class AlphaBarWebViewActivity extends BaseAlphaBarWebViewActivity{
    /**
     * url访问的数据类型
     */
    public enum UrlIntent{
        View_Loi_List//查看意向信列表
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
        Intent intent = new Intent(context, AlphaBarWebViewActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
        String url = null;
        ConfigItem configItem = LoginManager.getInstance().getLocalConfigItem();
        if(configItem != null) {
            switch (urlIntent) {
                case View_Loi_List:
//                    url = "https://demo.charmlive.com/pman/loi/h5/getLoiDetail?opentype=2&loi_id=JBDJE&styletype=1";
                    url = "http://www.jd.com";
                break;
            }
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
        Intent intent = new Intent(context, AlphaBarWebViewActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
        intent.putExtra(WEB_URL, url);
        return intent;
    }
}
