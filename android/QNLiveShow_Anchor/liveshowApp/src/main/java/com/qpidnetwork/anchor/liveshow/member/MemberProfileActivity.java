package com.qpidnetwork.anchor.liveshow.member;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;

import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.liveshow.BaseWebViewActivity;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.anchor.utils.Log;

/**
 * Created by Hunter Mun on 2018/3/22.
 */

public class MemberProfileActivity extends BaseWebViewActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public boolean onShouldOverrideUrlLoading(WebView view, String url) {
        return super.onShouldOverrideUrlLoading(view, url);
    }

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param manId
     * @return
     */
    public static Intent getMemberInfoIntent(Context context, String title, String manId, boolean showPrivateButton){
        Intent intent = new Intent(context, MemberProfileActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_TITLE_TYPE, WebTitleType.Overflow.ordinal());
        ConfigItem configItem = LoginManager.getInstance().getSynConfig();
        String url = configItem.manPageUrl;
        StringBuilder sb = new StringBuilder(url);
        if(url.contains("?")){
            sb.append("&manid=");
        }else{
            sb.append("?manid=");
        }
        sb.append(manId);

        int showButton = showPrivateButton?1:0;
        sb.append("&showinvite=");
        sb.append(String.valueOf(showButton));

        url = sb.toString();
        if(!TextUtils.isEmpty(url)){
            intent.putExtra(WEB_URL, url);
        }
        return intent;
    }

    /*************************** JS Callback  *****************************/
    @JavascriptInterface
    public void callbackInvite (String userid, String nickname, String photoUrl){
        //点击邀请回调
        startActivity(LiveRoomTransitionActivity.getInviteIntent(this, userid, nickname, photoUrl));
    }
}
