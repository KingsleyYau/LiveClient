package com.qpidnetwork.anchor.liveshow.personal.shows;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.liveshow.BaseWebViewActivity;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.member.MemberProfileActivity;

/**
 * Created by Hunter Mun on 2018/5/4.
 */

public class ProgramDetailActivity extends BaseWebViewActivity{

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param showLiveId
     * @return
     */
    public static Intent getProgramDetailIntent(Context context, String title, String showLiveId){
        Intent intent = new Intent(context, ProgramDetailActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_TITLE_TYPE, WebTitleType.Normal.ordinal());
        ConfigItem configItem = LoginManager.getInstance().getSynConfig();
        String url = configItem.showDetailPage;
        StringBuilder sb = new StringBuilder(url);
        if(url.contains("?")){
            sb.append("&live_show_id=");
        }else{
            sb.append("?live_show_id=");
        }

        sb.append(showLiveId);

        url = sb.toString();
        if(!TextUtils.isEmpty(url)){
            intent.putExtra(WEB_URL, url);
        }
        return intent;
    }
}
