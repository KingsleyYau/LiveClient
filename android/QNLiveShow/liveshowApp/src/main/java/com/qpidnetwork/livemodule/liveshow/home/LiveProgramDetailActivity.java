package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.liveshow.BaseWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;

/**
 * Created by Hunter on 18/4/27.
 */

public class LiveProgramDetailActivity extends BaseWebViewActivity {

    public static final String WEB_URL_KEY_ENTERROOM = "enterroom";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param showLiveId            //节目id
     * @param showTitleBarWhenLoadSuc
     * @return
     */
    public static Intent getProgramInfoIntent(Context context, String title, String showLiveId, boolean showTitleBarWhenLoadSuc){
        ConfigItem configItem = LoginManager.getInstance().getLocalConfigItem();
        Intent intent = new Intent();
        if(configItem != null) {
            intent = new Intent(context, LiveProgramDetailActivity.class);
            intent.putExtra(WEB_TITLE, title);
            intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
            String url = configItem.showDetailPage;
            StringBuilder sb = new StringBuilder(url);
            if (url.contains("?")) {
                sb.append("&live_show_id=");
            } else {
                sb.append("?live_show_id=");
            }

            sb.append(showLiveId);

            //修改为根据是否直播中提示
            //        int isEnterRoom = IMManager.getInstance().isCurrentInLive() ? 0:1;
            //        sb.append("&" + WEB_URL_KEY_ENTERROOM + "=");
            //        sb.append(String.valueOf(isEnterRoom));
            url = sb.toString();
            if (!TextUtils.isEmpty(url)) {
                intent.putExtra(WEB_URL, url);
            }
        }
        return intent;
    }
}
