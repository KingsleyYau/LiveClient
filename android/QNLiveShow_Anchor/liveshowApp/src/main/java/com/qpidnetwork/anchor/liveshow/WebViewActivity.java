package com.qpidnetwork.anchor.liveshow;

import android.content.Context;
import android.content.Intent;

/**
 * Created by Hunter Mun on 2017/9/14.
 */

public class WebViewActivity extends BaseWebViewActivity{

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param url
     * @param webTitleType
     * @return
     */
    public static Intent getIntent(Context context, String title, String url, WebTitleType webTitleType){
        Intent intent = new Intent(context, WebViewActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_TITLE_TYPE, webTitleType.ordinal());
        intent.putExtra(WEB_URL, url);
        return intent;
    }
}
