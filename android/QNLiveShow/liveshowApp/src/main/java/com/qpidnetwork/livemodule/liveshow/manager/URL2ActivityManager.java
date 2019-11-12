package com.qpidnetwork.livemodule.liveshow.manager;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.text.TextUtils;
import android.util.Base64;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.listener.DialogUIListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginNewActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersMainActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersAnchorShopListActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentPagerAdapter4Top;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatMainActivity;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.HangoutTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutDetailDialogFragment;
import com.qpidnetwork.livemodule.liveshow.loi.AlphaBarWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.message.ChatTextActivity;
import com.qpidnetwork.livemodule.liveshow.message.MessageContactListActivity;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.personal.MyProfileActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mycontact.MyContactListActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.liveshow.personal.tickets.MyTicketsActivity;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiDetailsActivity;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiEditActivity;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiListActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import static com.qpidnetwork.livemodule.liveshow.loi.BaseAlphaBarWebViewActivity.WEB_TITLE;
import static com.qpidnetwork.livemodule.liveshow.loi.BaseAlphaBarWebViewActivity.WEB_TITLE_BAR_SHOW_LOADSUC;
import static com.qpidnetwork.livemodule.liveshow.loi.BaseAlphaBarWebViewActivity.WEB_URL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_BOOKING_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_BOOKING_PACKLIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_BUY_CREDIT;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_CHAT;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_CHAT_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_GIFT_FLOWER_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_GREETMAIL_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_HANGOUT_DIALOG;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_HANGOUT_TRANSITION;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_CHAT;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_CHAT_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_LOGIN;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_MAIN;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LIVE_ROOM;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_LOGIN;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_MAIL_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_MY_CONTACT_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_MY_LEVEL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_MY_PROFILE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_MY_TICKETS;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_NEW_BOOKING;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_POP_YESNO_DIALOG;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_SAYHI_DETAIL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_SAYHI_LIST;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_SENDSAYHI;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_MODULE_NAME_SEND_MAIL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_APP_TITLE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_CLICK_FROM;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_D_MSG;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_D_NO_TITLE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_D_TITLE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_D_YES_TITLE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_D_YES_URL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_ANCHORID;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_ANCHORNAME;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_ANCHORTYPE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_BUBBLE_FLAG;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_GASCREENNAME;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_INVITATIONID;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_INVITE_MSG_ID;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_LISTTYPE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_LIVESHOWID;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_ROOMID;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_ROOMTYPE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_SAYHIID;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_SELECT_INDEX;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_KEY_STORE_LIST_TYPE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_OPEN_TYPE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_ORDER_NUMBER;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_ORDER_TYPE;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_RESUMECB;
import static com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder.KEY_URL_PARAM_STYLE_TYPE;

/**
 * 以URL拼写规则　决定　走向哪个窗口的管理类
 * Created by Jagger on 2017/9/22.
 */

public class URL2ActivityManager {
    private static String TAG = URL2ActivityManager.class.getSimpleName();

    public static URL2ActivityManager getInstance() {
        if (singleton == null) {
            singleton = new URL2ActivityManager();
        }

        return singleton;
    }

    private static URL2ActivityManager singleton;

    private URL2ActivityManager() {
    }

    public boolean URL2Activity(final Context context, String url){
        boolean dealResult = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            //符合协议
            if(CoreUrlHelper.checkIsValidMoudleUrl(url)){
                dealResult = true;
                //寻找相应模块
                String moduleStr = uri.getQueryParameter(CoreUrlHelper.KEY_URL_MODULE);
                if(!TextUtils.isEmpty(moduleStr)) {
                    //当前主模块
                    if (moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)) {
                        URL4Main(context, uri);
                    }
                    //打开主播详情页
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL)) {
                        URL4AnchorProfile(context, uri);
                    }
                    //打开进入直播间过渡页
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_ROOM)) {
                        URL4LiveTransition(context, uri);
                    }
                    //打开预约邀请界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_NEW_BOOKING)) {
                        URL4ScheduleInvite(context, uri);
                    }
                    //打开预约列表界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_BOOKING_LIST)) {
                        URL4BookList(context, uri);
                    }
                    //打开背包列表
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_BOOKING_PACKLIST)) {
                        URL4PackageList(context, uri);
                    }
                    //进入买点页面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_BUY_CREDIT)) {
                        URL4AddCredit(context, uri);
                    }
                    //进入个人等级界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_MY_LEVEL)) {
                        URL4MyLevel(context, uri);
                    }
                    //打开登錄界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_LOGIN) || moduleStr.equals(KEY_URL_MODULE_NAME_LOGIN)) {
                        URL4Login(context);
                    }
                    //打开个人资料
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_MY_PROFILE)) {
                        URL4MyProfile(context);
                    }
                    //打开私信联系人列表
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_CHAT_LIST)) {
                        URL4ChatList(context);
                    }
                    //打开 LiveChat List
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_CHAT_LIST)) {
                        URL4LiveChatList(context);
                    }
                    //打开 LiveChat 聊天界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_CHAT)) {
                        URL4LiveChatAcitivity(context, uri);
                    }
                    //打开 MyContact 聊天界面     2019/8/16 Hardy
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_MY_CONTACT_LIST)) {
                        URL4MyContactList(context);
                    }
                    //打开鲜花礼品列表页——商店主页下     2019/10/12 Hardy
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_GIFT_FLOWER_LIST)) {
                        URL4GiftFlowersList(context, uri);
                    }
                    //打开鲜花礼品列表页——主播主页下     2019/10/12 Hardy
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE)) {
                        URL4GiftFlowersAnchorStoreList(context, uri);
                    }
                    //打开私信聊天界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_CHAT)) {
                        URL4ChatDetail(context, uri);
                    }
                    //打开意向信列表
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_GREETMAIL_LIST)) {
                        URL4GreetMailList(context);
                    }
                    //打开信件列表
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_MAIL_LIST)) {
                        URL4MailList(context);
                    }
                    //打开我的票据界面
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_MY_TICKETS)) {
                        URL4MyTicketsActivity(context, uri);
                    }
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_POP_YESNO_DIALOG)) {
                        if(context instanceof Activity){
                            String title = uri.getQueryParameter(KEY_URL_PARAM_D_TITLE);
                            String msg = uri.getQueryParameter(KEY_URL_PARAM_D_MSG);
                            String yesTitle = uri.getQueryParameter(KEY_URL_PARAM_D_YES_TITLE);
                            String noTitle = uri.getQueryParameter(KEY_URL_PARAM_D_NO_TITLE);
                            String yesUrl = uri.getQueryParameter(KEY_URL_PARAM_D_YES_URL);
                            //url decode
                            if(!TextUtils.isEmpty(yesUrl)) {
                                try {
                                    yesUrl = URLDecoder.decode(yesUrl, "utf-8");
                                } catch (UnsupportedEncodingException e) {
                                    e.printStackTrace();
                                }
                            }
                            final String decodeYesUrl = yesUrl;

                            if(TextUtils.isEmpty(noTitle)){
                                //NoTitle无内容，则只显示YES一个按钮
                                DialogUIUtils.showAlert((Activity)context, title, msg, "", "", yesTitle,"", R.color.dark_gray, 0  , true, true, true, new DialogUIListener() {
                                    @Override
                                    public void onPositive() {
                                        new AppUrlHandler(context).urlHandle(decodeYesUrl);
                                    }

                                    @Override
                                    public void onNegative() {

                                    }
                                }).show();

                            }else{
                                //显示两个按钮
                                DialogUIUtils.showAlert((Activity)context, title, msg, "", "", noTitle, yesTitle, 0 , R.color.dark_gray , false, true, true, new DialogUIListener() {
                                    @Override
                                    public void onPositive() {

                                    }

                                    @Override
                                    public void onNegative() {
                                        new AppUrlHandler(context).urlHandle(decodeYesUrl);
                                    }
                                }).show();
                            }
                        }
                    }
                    else if (moduleStr.equals(KEY_URL_MODULE_NAME_SEND_MAIL)) {
                        URL4SendMail(context, uri);
                    }else if(moduleStr.equals(KEY_URL_MODULE_NAME_HANGOUT_DIALOG)) {
                        URL4ShowHangoutInviteDialog(context, uri);
                    }else if (moduleStr.equals(KEY_URL_MODULE_NAME_HANGOUT_TRANSITION)) {
                        URL4HangoutTransition(context, uri);
                    }else if (moduleStr.equals(KEY_URL_MODULE_NAME_SAYHI_LIST)) {
                        URL4SayHiList(context, uri);
                    }else if (moduleStr.equals(KEY_URL_MODULE_NAME_SENDSAYHI)) {
                        URL4SayHiEdit(context, uri);
                    }else if (moduleStr.equals(KEY_URL_MODULE_NAME_SAYHI_DETAIL)) {
                        URL4SayHiDetail(context, uri);
                    }
                }
            }else{
                //非打开指定模块即scheme非 qpidnetwork qpidnetwork-live
                String openType = uri.getQueryParameter(KEY_URL_PARAM_OPEN_TYPE);
                if(!TextUtils.isEmpty(openType)){
                    int type = Integer.valueOf(openType);
                    if(type == 1){
                        //系统默认浏览器打开
                        dealResult = true;
                        openSystemBrowser(context, url);
                    }else if(type == 2){
                        //新建webview打开
                        dealResult = true;
                        String title = uri.getQueryParameter(KEY_URL_PARAM_APP_TITLE);
                        String styleType = uri.getQueryParameter(KEY_URL_PARAM_STYLE_TYPE);
                        int styletype = TextUtils.isEmpty(styleType) ? 0 : Integer.valueOf(styleType);
                        openNewWebviewActivityByUrl(context,styletype, title, url);
                    }else if(type == 0){
                        //当前webview打开
                        dealResult = false;
                    }
                }
            }
        }
        return dealResult;
    }

    /**
     * 获取模块名字
     * @param url
     * @return
     */
    public String getModuleNameByUrl(String url){
        String moduleName = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            moduleName = uri.getQueryParameter(CoreUrlHelper.KEY_URL_MODULE);
        }
        return moduleName;
    }

    /**
     * 获取主播类型
     * @param url
     * @return
     */
    public AnchorLevelType getAnchorTypeByUrl(String url){
        AnchorLevelType anchorType = AnchorLevelType.Unknown;
        String anchorTypeStr = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            anchorTypeStr = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORTYPE);
        }
        if(!TextUtils.isEmpty(anchorTypeStr)){
            if(Integer.valueOf(anchorTypeStr) == 1){
                anchorType = AnchorLevelType.silver;
            }else if(Integer.valueOf(anchorTypeStr) ==  2){
                anchorType = AnchorLevelType.gold;
            }
        }
        return anchorType;
    }

    /**
     * 读取roomId
     * @param url
     * @return
     */
    public String getRoomIdByUrl(String url){
        String roomId = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            roomId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ROOMID);
        }
        return roomId;
    }

    /**
     * 获取resume调用resume js 调用标志位
     * @param url
     * @return
     */
    public boolean getResumecbFlags(String url){
        boolean resumecbFalgs = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String temp = uri.getQueryParameter(KEY_URL_PARAM_RESUMECB);
            if(!TextUtils.isEmpty(temp)
                    && Integer.valueOf(temp) == 1){
                resumecbFalgs = true;
            }
        }
        return resumecbFalgs;
    }

    /**
     * 获取节目id
     * @param url
     * @return
     */
    public String getShowLiveIdByUrl(String url){
        String showLiveId = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            showLiveId = uri.getQueryParameter(KEY_URL_PARAM_KEY_LIVESHOWID);
        }
        return showLiveId;
    }

    //----------------------- 使用URL跳转 start -----------------------------

    /**
     * 解析Url对象参数列表，同一个key多个时取第一个
     * @param uri
     * @return
     */
    private static HashMap<String, String> parseParams(Uri uri){
        HashMap<String, String> mParamsMap = new HashMap<String, String>();
        if(uri != null) {
            Set<String> keys = uri.getQueryParameterNames();
            for(String key : keys){
                List<String> values = uri.getQueryParameters(key);
                mParamsMap.put(key, values.get(0));
            }
        }
        return mParamsMap;
    }

    /**
     * Main特殊处理（区分直接启动和过渡页面）
     * @param uri
     * @return
     */
    public MainFragmentPagerAdapter4Top.TABS getMainListType(Uri uri){
        HashMap<String, String> params = parseParams(uri);
        MainFragmentPagerAdapter4Top.TABS mainTab = MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_DISCOVER;
        if(params.containsKey(KEY_URL_PARAM_KEY_LISTTYPE)){
            int listType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_LISTTYPE));
            switch (listType){
                case 1:{
                    mainTab = MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_DISCOVER;
                }break;
                case 2:{
                    mainTab = MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_FOLLOW;
                }break;
                case 3:{
                    mainTab = MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_CALENDAR;
                }break;
                case 4:{
                    mainTab = MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_HANGOUT;
                }break;
            }
        }
        return mainTab;
    }

    /**
     * 打开登錄界面
     */
    private void URL4Login(Context context){
        URL4Login(context, "");
    }

    /**
     * 打开登錄界面
     */
    private void URL4Login(Context context, String url){
//        Intent intent = new Intent();
//        intent.setClass(context, PeacockActivity.class);
//        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
//
//        context.startActivity(intent);

        LoginNewActivity.launchRegisterActivity(context, url);
    }

    /**
     * 打开主界面
     */
    private void URL4Main(Context context, Uri uri){
        MainFragmentActivity.launchActivityWithListType(context, getMainListType(uri));
    }

    /**
     * 打开主播资料详情
     * @param context
     * @param uri
     */
    private void URL4AnchorProfile(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        String anchorId = "";
        if(params != null){
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORID)){
                anchorId = params.get(KEY_URL_PARAM_KEY_ANCHORID);
            }
        }
        if(!TextUtils.isEmpty(anchorId)){
            AnchorProfileActivity.launchAnchorInfoActivty(context,
                    context.getResources().getString(R.string.live_webview_anchor_profile_title),
                    anchorId, false, AnchorProfileActivity.TagType.Album);
        }
    }

    /**
     * 打开进入直播间过渡页
     * @param context
     * @param uri
     */
    private void URL4LiveTransition(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        String roomId = "";
        String anchorId = "";
        String anchorName = "";
        String anchorPhotoUrl = "";
        String invitationId = "";
        String bubbleFlag = "";
        int roomType = 0;
        String liveshowid = "";
        if(params != null){
            if(params.containsKey(KEY_URL_PARAM_KEY_ROOMID)){
                roomId = params.get(KEY_URL_PARAM_KEY_ROOMID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORID)){
                anchorId = params.get(KEY_URL_PARAM_KEY_ANCHORID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORNAME)){
                anchorName = params.get(KEY_URL_PARAM_KEY_ANCHORNAME);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_INVITATIONID)){
                invitationId = params.get(KEY_URL_PARAM_KEY_INVITATIONID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ROOMTYPE)){
                roomType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_ROOMTYPE));
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_LIVESHOWID)){
                liveshowid = params.get(KEY_URL_PARAM_KEY_LIVESHOWID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL)){
                anchorPhotoUrl = URLDecoder.decode(params.get(KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL));
            }

            if(params.containsKey(KEY_URL_PARAM_KEY_BUBBLE_FLAG)){
                bubbleFlag = params.get(KEY_URL_PARAM_KEY_BUBBLE_FLAG);
            }
        }
        LiveRoomTransitionActivity.CategoryType categoryType = null;
        if(!TextUtils.isEmpty(roomId)){
            categoryType =  LiveRoomTransitionActivity.CategoryType.Schedule_Invite_Enter_Room;
        }else {
            switch (roomType) {
                case 0: {
                    if (TextUtils.isEmpty(liveshowid)) {
                        categoryType = LiveRoomTransitionActivity.CategoryType.Enter_Public_Room;
                    } else {
                        categoryType = LiveRoomTransitionActivity.CategoryType.Enter_Program_Public_Room;
                    }
                }
                break;
                case 1: {
                    categoryType = LiveRoomTransitionActivity.CategoryType.Schedule_Invite_Enter_Room;
                }
                break;
                case 2: {
                    categoryType = LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room;
                }
                break;
                case 3: {
                    categoryType = LiveRoomTransitionActivity.CategoryType.Anchor_Invite_Enter_Room;
                }
                break;
            }
        }
        if(categoryType != null){
            if(categoryType == LiveRoomTransitionActivity.CategoryType.Anchor_Invite_Enter_Room){
                context.startActivity(LiveRoomTransitionActivity.getAcceptInviteIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, invitationId));
            }else if(categoryType == LiveRoomTransitionActivity.CategoryType.Enter_Program_Public_Room){
                context.startActivity(LiveRoomTransitionActivity.getProgramShowIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, liveshowid));
            }else{
                boolean isBubble = false;
                if(!TextUtils.isEmpty(bubbleFlag)){
                    isBubble = (Integer.valueOf(bubbleFlag) == 1) ? true:false;
                }
                if(isBubble){
                    context.startActivity(LiveRoomTransitionActivity.getIntentFromBubble(context, categoryType, anchorId, anchorName, anchorPhotoUrl, roomId, ""));
                }else{
                    context.startActivity(LiveRoomTransitionActivity.getIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, roomId, ""));
                }
            }
        }
    }

    /**
     * 打开预约邀请界面
     * @param context
     * @param uri
     */
    private void URL4ScheduleInvite(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        String anchorId = "";
        String anchorName = "";
        if(params != null){
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORID)){
                anchorId = params.get(KEY_URL_PARAM_KEY_ANCHORID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORNAME)){
                anchorName = params.get(KEY_URL_PARAM_KEY_ANCHORNAME);
            }
        }
        if(!TextUtils.isEmpty(anchorId)){
            context.startActivity(BookPrivateActivity.getIntent(context, anchorId, anchorName));
        }
    }

    /**
     * 打开预约邀请列表界面
     * @param context
     * @param uri
     */
    private void URL4BookList(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        int listType = 1;
        if(params != null){
            if(params.containsKey(KEY_URL_PARAM_KEY_LISTTYPE)){
                listType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_LISTTYPE));
            }
        }

        if(listType > 0){
            ScheduleInviteActivity.launchScheduleListActivity(context, listType - 1);
        }
    }

    /**
     * 打开背包列表
     * @param context
     * @param uri
     */
    private void URL4PackageList(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        int defaultIndex = 0;
        if(params != null){
            int listType = 1;
            if(params.containsKey(KEY_URL_PARAM_KEY_LISTTYPE)){
                listType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_LISTTYPE));
            }
            if(listType == 1){
                defaultIndex = 2;
            }else if(listType == 2){
                defaultIndex = 1;
            }else if(listType == 3){
                defaultIndex = 3;
            }else if(listType == 4){
                defaultIndex = 0;
            }
        }
        MyPackageActivity.launchMyPackageActivity(context, defaultIndex);
    }

    /**
     * 进入充值界面
     * @param context
     * @param uri
     */
    private void URL4AddCredit(Context context, Uri uri){
        String type = uri.getQueryParameter(KEY_URL_PARAM_ORDER_TYPE);
        String clickFrom = uri.getQueryParameter(KEY_URL_PARAM_CLICK_FROM);
        String number = uri.getQueryParameter(KEY_URL_PARAM_ORDER_NUMBER);
        LiveModule.getInstance().onAddCreditClick(context, new NoMoneyParamsBean(type, clickFrom, number));
    }

    /**
     * 进入我的等级界面
     * @param context
     * @param uri
     */
    private void URL4MyLevel(Context context, Uri uri){
        String myLevelTitle = context.getResources().getString(R.string.my_level_title);
        context.startActivity(WebViewActivity.getIntent(context,
                myLevelTitle,
                WebViewActivity.UrlIntent.View_Audience_Level,null, true));
    }

    /**
     * 进入联系人列表界面
     * @param context
     */
    private void URL4ChatList(Context context){
        Intent intent = new Intent(context, MessageContactListActivity.class);
        context.startActivity(intent);
    }

    /**
     * 进入livechat列表界面
     * @param context
     */
    private void URL4LiveChatList(Context context){
        LiveChatMainActivity.startAct(context);
    }

    /**
     * 进入livechat列表界面
     * @param context
     */
    private void URL4MyContactList(Context context){
        MyContactListActivity.startAct(context);
    }

    /**
     * 鲜花礼品列表——商店下
     */
    private void URL4GiftFlowersList(Context context, Uri uri){
        String listType = uri.getQueryParameter(KEY_URL_PARAM_KEY_STORE_LIST_TYPE);
        if (!TextUtils.isEmpty(listType)) {
            FlowersMainActivity.startAct(context, listType);
        }else{
            FlowersMainActivity.startAct(context);
        }
    }
    /**
     * 鲜花礼品列表——主播下
     */
    private void URL4GiftFlowersAnchorStoreList(Context context,Uri uri){
        String anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
        if (!TextUtils.isEmpty(anchorId)) {
            FlowersAnchorShopListActivity.startAct(context, anchorId, "", "");
        }
    }


    /**
     * 进入livechat聊天界面
     * @param context
     * @param uri
     */
    private void URL4LiveChatAcitivity(Context context, Uri uri){
        if(uri != null){
            String anchorId = "";
            String anchorName = "";
            String photoUrl = "";
            String inviteMsgId = "";
            try {
                anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
                anchorName = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORNAME);
                photoUrl = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL);
                // 2019/7/15 Hardy
                inviteMsgId = new String(Base64.decode(uri.getQueryParameter(KEY_URL_PARAM_KEY_INVITE_MSG_ID).getBytes(), Base64.DEFAULT));

                Log.i("Jagger" , "URL2ActivityManager URL4LiveChatAcitivity inviteMsgId1:" + inviteMsgId);

            }catch (Exception e){
                e.printStackTrace();
                Log.i("Jagger" , "URL2ActivityManager URL4LiveChatAcitivity Exception:" + e.toString());
            }


            if(!TextUtils.isEmpty(anchorId)){
                LiveChatTalkActivity.launchChatActivity(context, anchorId, anchorName, photoUrl, inviteMsgId);
            }
        }
    }

    /**
     * 进入写信界面
     * @param context
     * @param uri
     */
    private void URL4SendMail(Context context, Uri uri){
        if(uri != null){
            String anchorId = "";
            String sayHiId = "";
            try {
                anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
                sayHiId = uri.getQueryParameter(KEY_URL_PARAM_KEY_SAYHIID);
            }catch (Exception e){
                e.printStackTrace();
            }
            ConfigItem configItem = LoginManager.getInstance().getSynConfig();
            if(!TextUtils.isEmpty(anchorId) && configItem != null){
                String url = configItem.sendLetter;
                StringBuilder sb = new StringBuilder(url);
                if (url.contains("?")) {
                    sb.append("&anchorid=");
                } else {
                    sb.append("?anchorid=");
                }
                sb.append(anchorId);
                if(!TextUtils.isEmpty(sayHiId)){
                    sb.append("&sayhiid=");
                    sb.append(sayHiId);
                }
                //增加resume刷新cookie逻辑，解决红米写信，选择照片返回cookie丢失导致自动登录被踢
                sb.append("&resumecb=1");

                context.startActivity(AlphaBarWebViewActivity.getIntent(context,
                        "",
                        sb.toString(),
                        true));
            }
        }
    }

    /**
     * 进入私信聊天界面
     * @param context
     * @param uri
     */
    private void URL4ChatDetail(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        String anchorId = "";
        String anchorName = "";
        if(params != null){
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORID)){
                anchorId = params.get(KEY_URL_PARAM_KEY_ANCHORID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ANCHORNAME)){
                anchorName = params.get(KEY_URL_PARAM_KEY_ANCHORNAME);
            }
        }
        if(!TextUtils.isEmpty(anchorId)){
            ChatTextActivity.launchChatTextActivity(context, anchorId, anchorName);
        }
    }

    /**
     * 进入意向信列表
     * @param context
     */
    private void URL4GreetMailList(Context context){
        if(LoginManager.getInstance().getSynConfig() != null){
            context.startActivity(WebViewActivity.getIntent(context,
                    context.getResources().getString(R.string.live_webview_greet_mail_title),
                    WebViewActivity.UrlIntent.View_Loi_List,
                    null,
                    true));
        }
    }

    /**
     * 打开EMF列表界面
     * @param context
     */
    private void URL4MailList(Context context){
        if(LoginManager.getInstance().getSynConfig() != null){
            context.startActivity(WebViewActivity.getIntent(context,
                    context.getResources().getString(R.string.live_webview_mail_title),
                    WebViewActivity.UrlIntent.View_Emf_List,
                    null,
                    true));
        }
    }

    /**
     * 打开我的票据界面
     * @param context
     */
    private void URL4MyTicketsActivity(Context context, Uri uri) {
        String selectIndexStr = uri.getQueryParameter(KEY_URL_PARAM_KEY_SELECT_INDEX);
        int selectIndex = 0;
        if(!TextUtils.isEmpty(selectIndexStr)){
            selectIndex = Integer.valueOf(selectIndexStr);
        }

        MyTicketsActivity.launchMyTicketsActivity(context, selectIndex);
    }

    /**
     * 进入个人资料界面
     * @param context
     */
    private void URL4MyProfile(Context context){
        MyProfileActivity.lanchAct(context);
    }

    /**
     * 打开hangout邀请dialog
     * @param context
     * @param uri
     */
    private void URL4ShowHangoutInviteDialog(final Context context, Uri uri){
        String anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
        String anchorName = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORNAME);
        //点击，弹出start hangout 提示
        if(context instanceof FragmentActivity) {
            FragmentManager fragmentManager = ((FragmentActivity)context).getSupportFragmentManager();
            HangoutOnlineAnchorItem anchorInfoItem = new HangoutOnlineAnchorItem();
            anchorInfoItem.anchorId = anchorId;
            anchorInfoItem.nickName = anchorName;
            HangOutDetailDialogFragment.showDialog(fragmentManager, anchorInfoItem, new HangOutDetailDialogFragment.OnDialogClickListener() {
                @Override
                public void onStartHangoutClick(final HangoutOnlineAnchorItem anchorItem) {
//                    //生成被邀请的主播列表（这里是目标主播一人）
//                    ArrayList<IMUserBaseInfoItem> anchorList = new ArrayList<>();
//                    anchorList.add(new IMUserBaseInfoItem(anchorItem.anchorId, anchorItem.nickName, anchorItem.avatarImg));
//                    //过渡页
//                    Intent intent = HangoutTransitionActivity.getIntent(
//                            context,
//                            anchorList,
//                            "",
//                            anchorItem.coverImg,
//                            "");
//                    context.startActivity(intent);
                    String url = LiveUrlBuilder.createHangoutTransitionActivity(anchorItem.anchorId, anchorItem.nickName);
                    new AppUrlHandler(context).urlHandle(url);
                }
            });
        }
    }

    /**
     * 打开多人互动过渡页
     * @param context
     * @param uri
     */
    private void URL4HangoutTransition(final Context context, Uri uri){
        String anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
        String anchorName = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORNAME);
        String bubbleFlag = uri.getQueryParameter(KEY_URL_PARAM_KEY_BUBBLE_FLAG);
        if(!TextUtils.isEmpty(anchorId)){
            //生成被邀请的主播列表（这里是目标主播一人）
            ArrayList<IMUserBaseInfoItem> anchorList = new ArrayList<>();
            anchorList.add(new IMUserBaseInfoItem(anchorId, anchorName, ""));
            boolean isBubble = false;
            if(!TextUtils.isEmpty(bubbleFlag)){
                isBubble = (Integer.valueOf(bubbleFlag) == 1)?true:false;
            }
            //过渡页
            Intent intent = HangoutTransitionActivity.getIntent(
                    context,
                    anchorList,
                    "",
                    "",
                    "",
                    isBubble);
            context.startActivity(intent);
        }
    }

    /**
     * 打开SayHi列表页
     * @param context
     * @param uri
     */
    private void URL4SayHiList(final Context context, Uri uri){
        int listType = 1;
        try {
            String tempType = uri.getQueryParameter(KEY_URL_PARAM_KEY_LISTTYPE);
            if(!TextUtils.isEmpty(tempType)){
                listType = Integer.valueOf(tempType);
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        //打开sayhi列表页
        SayHiListActivity.TabType tabType = SayHiListActivity.TabType.ALL;
        if(listType == 2){
            tabType =  SayHiListActivity.TabType.RESPONSE;
        }
        SayHiListActivity.startAct(context, tabType);
    }

    /**
     * 打开SayHi编辑页面
     * @param context
     * @param uri
     */
    private void URL4SayHiEdit(final Context context, Uri uri){
        String anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
        String anchorName = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORNAME);
        //打开sayhi编辑页面
        if(!TextUtils.isEmpty(anchorId) && !TextUtils.isEmpty(anchorName)){
            SayHiEditActivity.startAct(context, anchorId, anchorName);
        }
    }

    /**
     * 打开SayHi详情页面
     * @param context
     * @param uri
     */
    private void URL4SayHiDetail(final Context context, Uri uri){
        String sayHiId = uri.getQueryParameter(KEY_URL_PARAM_KEY_SAYHIID);
        //打开sayhi详情页面
        if(!TextUtils.isEmpty(sayHiId)){
            SayHiDetailsActivity.launch(context, sayHiId);
        }
    }

    //----------------------- 使用URL跳转 end -----------------------------

    /**
     * 新建webview打开链接
     * @param context
     * @param styletype
     * @param title
     * @param url
     */
    private void openNewWebviewActivityByUrl(Context context, int styletype, String title, String url){
        Log.logD(TAG,"openNewWebviewActivityByUrl-styletype:"+styletype+" title:"+title+" url:"+url);
        Intent intent = null;
        if(1 == styletype){
            intent = new Intent(context, AlphaBarWebViewActivity.class);
            intent.putExtra(WEB_TITLE, title);
            intent.putExtra(WEB_URL, url);
            intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, true);
        }else{
            intent = WebViewActivity.getIntent(context, title, url, true);
        }
        context.startActivity(intent);
    }

    /**
     * 打开系统浏览器
     * @param context
     * @param url
     */
    private void openSystemBrowser(Context context, String url){
        Intent intent = new Intent();
        intent.setAction("android.intent.action.VIEW");
        Uri content_url = Uri.parse(url);
        intent.setData(content_url);
        context.startActivity(intent);
    }

    /**
     * 解析url中包含的screenName
     * @param url
     * @return
     */
    public static String parseScreenNameByUrl(String url){
        String screenName = "";
        if(!TextUtils.isEmpty(url)){
            try {
                Uri uri = Uri.parse(url);
                screenName = uri.getQueryParameter(KEY_URL_PARAM_KEY_GASCREENNAME);
            }catch (Exception e){

            }
        }
        return screenName;
    }

    /**
     * 检测模块是否和直播冲突（排除法）
     * @return
     */
    public static boolean doCheckModuleConflict(String url){
        boolean isModuleConflict = false;
        if(!TextUtils.isEmpty(url) && CoreUrlHelper.checkIsValidMoudleUrl(url)) {
            Uri uri = Uri.parse(url);
            //寻找相应模块
            try{
                String moduleName = uri.getQueryParameter(CoreUrlHelper.KEY_URL_MODULE);
                if(!TextUtils.isEmpty(moduleName)){
                    if(moduleName.equals(KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL)
                            || moduleName.equals(KEY_URL_MODULE_NAME_BUY_CREDIT)
                            || moduleName.equals(KEY_URL_MODULE_NAME_CHAT)
                            || moduleName.equals(KEY_URL_MODULE_NAME_NEW_BOOKING)
                            || moduleName.equals(KEY_URL_MODULE_NAME_LIVE_CHAT)
                            || moduleName.equals(KEY_URL_MODULE_NAME_SEND_MAIL)
                            || moduleName.equals(KEY_URL_MODULE_NAME_HANGOUT_DIALOG)
                            || moduleName.equals(KEY_URL_MODULE_NAME_SENDSAYHI)
                            || moduleName.equals(KEY_URL_MODULE_NAME_SAYHI_DETAIL)
                            || moduleName.equals(KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE)){
                        isModuleConflict = false;
                    }else{
                        isModuleConflict = true;
                    }
                }
            }catch (Exception e){

            }
        }
        return isModuleConflict;
    }

    /**
     * 打开模块是否新建页打开(是否需要clearTop)
     * @param url
     * @return
     */
    public static boolean doCheckModuleOpenNewPage(String url){
        boolean isNewPage = false;
        if(!TextUtils.isEmpty(url) && CoreUrlHelper.checkIsValidMoudleUrl(url)) {
            Uri uri = Uri.parse(url);
            //寻找相应模块
            try{
                String moduleName = uri.getQueryParameter(CoreUrlHelper.KEY_URL_MODULE);
                //模块需要登录
                if(!TextUtils.isEmpty(moduleName)){
                    if(moduleName.equals(KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL)
                            || moduleName.equals(KEY_URL_MODULE_NAME_BUY_CREDIT)
                            || moduleName.equals(KEY_URL_MODULE_NAME_CHAT)
                            || moduleName.equals(KEY_URL_MODULE_NAME_NEW_BOOKING)
                            || moduleName.equals(KEY_URL_MODULE_NAME_LIVE_ROOM)
                            || moduleName.equals(KEY_URL_MODULE_NAME_LIVE_CHAT)
                            || moduleName.equals(KEY_URL_MODULE_NAME_SEND_MAIL)
                            || moduleName.equals(KEY_URL_MODULE_NAME_SENDSAYHI)
                            || moduleName.equals(KEY_URL_MODULE_NAME_SAYHI_DETAIL)
                            || moduleName.equals(KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE)){
                        isNewPage = true;
                    }else{
                        isNewPage = false;
                    }
                }
            }catch (Exception e){

            }
        }
        return isNewPage;
    }

    /**
     * 检测某个模块是否需要登录
     * @param url
     * @return  是否需要登录
     */
    public static boolean doCheckNeedLogin(String url){
        boolean isNeedLogin = false;
        if(!TextUtils.isEmpty(url)) {
            Uri uri = Uri.parse(url);
            //寻找相应模块
            String moduleName = uri.getQueryParameter(CoreUrlHelper.KEY_URL_MODULE);

            //模块需要登录
            if(!TextUtils.isEmpty(moduleName)
                    && ((moduleName.equals(KEY_URL_MODULE_NAME_LIVE_ROOM)
                    || moduleName.equals(KEY_URL_MODULE_NAME_NEW_BOOKING)
                    || moduleName.equals(KEY_URL_MODULE_NAME_BOOKING_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_BOOKING_PACKLIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_BUY_CREDIT)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MY_LEVEL)
                    || moduleName.equals(KEY_URL_MODULE_NAME_CHAT_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_CHAT)
                    || moduleName.equals(KEY_URL_MODULE_NAME_LIVE_CHAT_LIST)    // 2018/11/17 Hardy
                    || moduleName.equals(KEY_URL_MODULE_NAME_MY_CONTACT_LIST)    // 2019/8/16 Hardy
                    || moduleName.equals(KEY_URL_MODULE_NAME_GIFT_FLOWER_LIST)    // 2019/10/12 Hardy
                    || moduleName.equals(KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE)    // 2019/10/12 Hardy
                    || moduleName.equals(KEY_URL_MODULE_NAME_LIVE_CHAT)
                    || moduleName.equals(KEY_URL_MODULE_NAME_GREETMAIL_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MAIL_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MY_PROFILE)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MY_TICKETS)
                    || moduleName.equals(KEY_URL_MODULE_NAME_SEND_MAIL)
                    || moduleName.equals(KEY_URL_MODULE_NAME_HANGOUT_TRANSITION)
                    || moduleName.equals(KEY_URL_MODULE_NAME_SAYHI_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_SENDSAYHI)
                    || moduleName.equals(KEY_URL_MODULE_NAME_SAYHI_DETAIL)))){

                    //且未登录
                    if(!doCheckIsLogined()){
                        isNeedLogin = true;
                    }
            }
        }
        return isNeedLogin;
    }

    /**
     * 检查是否已登录，如果没登录，则把URL传给RegisterActivity，它处理完登录逻辑后，会把URL传回此类继续处理
     * @return 是否已登录
     */
    private static boolean doCheckIsLogined(){
        if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined){
            Log.i("Jagger" , "doCheckIsLogined:true");
            return true;
        }else {
            Log.i("Jagger" ,  "doCheckIsLogined:false");
            return false;
        }
    }
}
