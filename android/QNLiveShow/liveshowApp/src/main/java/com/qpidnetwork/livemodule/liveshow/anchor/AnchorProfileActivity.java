package com.qpidnetwork.livemodule.liveshow.anchor;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.webkit.WebView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.livechat.contact.ContactBean;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechat.contact.OnLCContactUpdateCallback;
import com.qpidnetwork.livemodule.liveshow.BaseWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutFriendsDetailDialog;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.List;

/**
 * Created by Hunter Mun on 2017/10/13.
 */

//public class AnchorProfileActivity extends BaseWebViewActivity {
public class AnchorProfileActivity extends BaseWebViewActivity implements OnLCContactUpdateCallback {


    public static final String WEB_URL_KEY_ENTERROOM = "enterroom";


    private static final String WOMAN_ID = "womanId";
    private static final int CODE_UPDATE_LIVECHAT_UNREAD = 11;

    private ContactManager mContactManager;
    // 是否已经注册监听接口
    private boolean isRegistContactUpdate = false;
    //
    private String womanId;

    /**
     * 打开主播资料页，tab默认定位位置
     */
    public enum TagType {
        Album,
        MyCalendar,
        Profile
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // 2018/11/24 Hardy
        mContactManager = ContactManager.getInstance();
        initWomanId();

        super.onCreate(savedInstanceState);

        //del by Jagger 2018-2-6 samson说不需要了
        //del by Jagger 2018-2-6 samson说不需要了
        //判断显示启动引导页
//        showGuideView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (mContactManager != null) {
            mContactManager.unregisterContactUpdata(this);
        }

        removeUiMessages(CODE_UPDATE_LIVECHAT_UNREAD);
    }

    @Override
    public boolean onShouldOverrideUrlLoading(WebView view, String url) {
        //增加GA统计
        String moduleName = URL2ActivityManager.getInstance().getModuleNameByUrl(url);
        if (!TextUtils.isEmpty(moduleName)) {
            if (moduleName.equals(URL2ActivityManager.KEY_URL_MODULE_NAME_NEW_BOOKING)) {
                //点击预约直播按钮
                onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                        getResources().getString(R.string.Live_EnterBroadcast_Action_RequestBooking),
                        getResources().getString(R.string.Live_EnterBroadcast_Label_RequestBooking));
            } else if (moduleName.equals(URL2ActivityManager.KEY_URL_MODULE_NAME_LIVE_ROOM)) {
                //点击进入直播间
                AnchorLevelType anchorType = URL2ActivityManager.getInstance().getAnchorTypeByUrl(url);
                String roomId = URL2ActivityManager.getInstance().getRoomIdByUrl(url);
                if (anchorType == AnchorLevelType.gold) {
                    if (!TextUtils.isEmpty(roomId)) {
                        //进入豪华私密直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPrivateBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPrivateBroadcast));
                    } else {
                        //进入付费公开直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPublicBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPublicBroadcast));
                    }
                } else if (anchorType == AnchorLevelType.silver) {
                    if (!TextUtils.isEmpty(roomId)) {
                        //进入标准私密直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_PrivateBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_PrivateBroadcast));
                    } else {
                        //进入免费公开直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_PublicBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_PublicBroadcast));
                    }
                }
            }
        }
        return super.onShouldOverrideUrlLoading(view, url);
    }

    /**
     * 普通webview加载网页
     *
     * @param context
     * @param title
     * @param anchorid
     * @param showTitleBarWhenLoadSuc
     * @return
     */
    public static void launchAnchorInfoActivty(Context context, String title, String anchorid, boolean showTitleBarWhenLoadSuc, TagType tagType) {
        ConfigItem configItem = LoginManager.getInstance().getLocalConfigItem();
        Intent intent = null;
        if (configItem != null) {
//            intent = new Intent();
            intent = new Intent(context, AnchorProfileActivity.class);
            intent.putExtra(WEB_TITLE, title);
            intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
            // 2018/11/24 Hardy
            intent.putExtra(WOMAN_ID, anchorid);

            String url = configItem.anchorPage;
            StringBuilder sb = new StringBuilder(url);
            if (url.contains("?")) {
                sb.append("&anchorid=");
            } else {
                sb.append("?anchorid=");
            }
            sb.append(anchorid);

            //修改为根据是否直播中提示
//            int isEnterRoom = IMManager.getInstance().isCurrentInLive() ? 0 : 1;
//            sb.append("&" + WEB_URL_KEY_ENTERROOM + "=");
//            sb.append(String.valueOf(isEnterRoom));
            //增加tab定位字段
            sb.append("&tabtype=");
            sb.append(String.valueOf(tagType.ordinal()));
            url = sb.toString();
            if (!TextUtils.isEmpty(url)) {
                intent.putExtra(WEB_URL, url);
            }
        }
        if (intent != null) {
            context.startActivity(intent);
        }
    }


    //==============    2018/11/24 Hardy 设置LiveChat未读数接口    ======================

    @Override
    protected void onWebPageLoadFinish() {
        super.onWebPageLoadFinish();

        updateUnreadCount();

        // 防止多次注册
        if (!isRegistContactUpdate) {
            isRegistContactUpdate = true;
            mContactManager.registerContactUpdate(this);
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case CODE_UPDATE_LIVECHAT_UNREAD:
                updateUnreadCount();
                break;

            default:
                break;
        }
    }

    private void updateUnreadCount() {
        int count = mContactManager.getWomanUnreadCount(womanId);
        String countStr = count > 0 ? count + "" : "";

        String url = "javascript:notifyLiveAppUnreadCount(";
        url += "'" + countStr + "')";

        Log.i("msg", "updateUnreadCount: " + url + "--- > " + count);

        if (mWebView != null) {
            mWebView.loadUrl(url);
        }
    }

    private void initWomanId() {
        if (getIntent() != null) {
            womanId = getIntent().getStringExtra(WOMAN_ID);
        }
    }

    @Override
    public void onContactUpdate(List<ContactBean> contactList) {
        Message message = Message.obtain();
        message.what = CODE_UPDATE_LIVECHAT_UNREAD;
        sendUiMessage(message);
    }
    //==============    2018/11/24 Hardy 设置LiveChat未读数接口    ======================

    /*********************************  显示主播资料  *******************************/
    @Override
    public void onShowHangoutAnchor(HangoutAnchorInfoItem item) {
        super.onShowHangoutAnchor(item);
        HangOutFriendsDetailDialog.showCheckMailSuccessDialog(this, item);
    }
}
