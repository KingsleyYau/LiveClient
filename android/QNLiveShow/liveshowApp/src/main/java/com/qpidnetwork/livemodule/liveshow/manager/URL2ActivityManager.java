package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.loi.AlphaBarWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.message.ChatTextActivity;
import com.qpidnetwork.livemodule.liveshow.message.MessageContactListActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.Log;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import static com.qpidnetwork.livemodule.liveshow.loi.BaseAlphaBarWebViewActivity.WEB_TITLE;
import static com.qpidnetwork.livemodule.liveshow.loi.BaseAlphaBarWebViewActivity.WEB_TITLE_BAR_SHOW_LOADSUC;
import static com.qpidnetwork.livemodule.liveshow.loi.BaseAlphaBarWebViewActivity.WEB_URL;

/**
 * 以URL拼写规则　决定　走向哪个窗口的管理类
 * Created by Jagger on 2017/9/22.
 */

public class URL2ActivityManager {
    private static String TAG = URL2ActivityManager.class.getSimpleName();

    private static final String KEY_URL_SCHEME = "qpidnetwork";
    private static final String KEY_URL_SCHEME_LIVE = "qpidnetwork-live";       //提供另外一套url外部链接跳转，功能上与KEY_URL_SCHEME一致，目前仅用于检测app是否包含直播模块
    private static final String KEY_URL_AUTHORITY = "app";
    private static final String KEY_URL_PATH = "/open";
    private static final String KEY_URL_SERVICE = "service";
    private static final String KEY_URL_MODULE = "module";
    private static final String KEY_URL_SITE = "site";

    //URL中service的值
    public static final String KEY_URL_SERVICE_NAME_LIVE = "live";

    //URL中module的值
    public static final String KEY_URL_MODULE_NAME_LIVE_LOGIN = "liveLogin";
    public static final String KEY_URL_MODULE_NAME_LIVE_MAIN = "main";
    public static final String KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL = "anchordetail";
    public static final String KEY_URL_MODULE_NAME_LIVE_ROOM = "liveroom";
    public static final String KEY_URL_MODULE_NAME_NEW_BOOKING = "newbooking";
    public static final String KEY_URL_MODULE_NAME_BOOKING_LIST = "bookinglist";
    public static final String KEY_URL_MODULE_NAME_BOOKING_PACKLIST = "backpacklist";
    public static final String KEY_URL_MODULE_NAME_BUY_CREDIT = "buycredit";
    public static final String KEY_URL_MODULE_NAME_MY_LEVEL = "mylevel";
    public static final String KEY_URL_MODULE_NAME_CHAT_LIST = "chatlist";
    public static final String KEY_URL_MODULE_NAME_CHAT = "chat";
    public static final String KEY_URL_MODULE_NAME_GREETMAIL_LIST = "greetmaillist";
    public static final String KEY_URL_MODULE_NAME_MAIL_LIST = "maillist";

    //URL中的KEYS
    public static final String KEY_URL_PARAM_KEY_LISTTYPE = "listtype";

    public static final String KEY_URL_PARAM_KEY_ROOMID = "roomid";
    public static final String KEY_URL_PARAM_KEY_ANCHORID = "anchorid";
    public static final String KEY_URL_PARAM_KEY_ANCHORNAME = "anchorname";
    public static final String KEY_URL_PARAM_KEY_ROOMTYPE = "roomtype";
    public static final String KEY_URL_PARAM_KEY_INVITATIONID = "invitationid";
    public static final String KEY_URL_PARAM_KEY_ANCHORTYPE = "anchor_type";
    public static final String KEY_URL_PARAM_KEY_LIVESHOWID = "liveshowid";
    public static final String KEY_URL_PARAM_KEY_GASCREENNAME = "gaScreenName";

    //自定义key
    public static final String KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL = "anchorAvatar";

    //外部链接携带打开模式及title
    private static final String KEY_URL_PARAM_OPEN_TYPE = "opentype";
    private static final String KEY_URL_PARAM_STYLE_TYPE = "styletype";
    private static final String KEY_URL_PARAM_APP_TITLE = "apptitle";

    //买点外部链接参数
    private static final String KEY_URL_PARAM_ORDER_TYPE = "order_type";
    private static final String KEY_URL_PARAM_CLICK_FROM = "click_from";
    private static final String KEY_URL_PARAM_ORDER_NUMBER = "number";
    private static final String KEY_URL_PARAM_RESUMECB = "resumecb";

    public static URL2ActivityManager getInstance() {
        if (singleton == null) {
            singleton = new URL2ActivityManager();
        }

        return singleton;
    }

    private static URL2ActivityManager singleton;

    private URL2ActivityManager() {
    }

    public boolean URL2Activity(Context context, String url){
        boolean dealResult = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String scheme = uri.getScheme();
            String authority = uri.getAuthority();
            String path = uri.getPath();
            //符合协议
            if((scheme.equals(KEY_URL_SCHEME) || scheme.equals(KEY_URL_SCHEME_LIVE)) && authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)){
                dealResult = true;
                String serivceName = uri.getQueryParameter(KEY_URL_SERVICE);
                //符合服务
                if(serivceName.equals(KEY_URL_SERVICE_NAME_LIVE)){
                    //寻找相应模块
                    String moduleStr = uri.getQueryParameter(KEY_URL_MODULE);

                    //当前主模块
                    if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)){
                        URL4Main(context, uri);
                    }
                    //打开主播详情页
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL)){
                        URL4AnchorProfile(context, uri);
                    }
                    //打开进入直播间过渡页
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_ROOM)){
                        URL4LiveTransition(context, uri);
                    }
                    //打开预约邀请界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_NEW_BOOKING)){
                        URL4ScheduleInvite(context, uri);
                    }
                    //打开预约列表界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_BOOKING_LIST)){
                        URL4BookList(context, uri);
                    }
                    //打开背包列表
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_BOOKING_PACKLIST)){
                        URL4PackageList(context, uri);
                    }
                    //进入买点页面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_BUY_CREDIT)){
                        URL4AddCredit(context, uri);
                    }
                    //进入个人等级界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_MY_LEVEL)){
                        URL4MyLevel(context, uri);
                    }
                    //打开登錄界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_LOGIN)){
                        URL4Login(context);
                    }
                    //打开私信联系人列表
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_CHAT_LIST)){
                        URL4ChatList(context);
                    }
                    //打开私信聊天界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_CHAT)){
                        URL4ChatDetail(context, uri);
                    }
                    //打开意向信列表
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_GREETMAIL_LIST)){
                        URL4GreetMailList(context);
                    }
                    //打开信件列表
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_MAIL_LIST)){
                        URL4MailList(context);
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

    public enum WebViewUrlOpenType{
        Curr_WebView,//当前WebView
        Sys_WebView,//系统浏览器打开
        New_WebView//APP新建WebView
    }

    public WebViewUrlOpenType getOpenTypeByUrl(String url){
        WebViewUrlOpenType openType = WebViewUrlOpenType.Curr_WebView;
        Uri uri = Uri.parse(url);
        String type = uri.getQueryParameter(KEY_URL_PARAM_OPEN_TYPE);
        if(!TextUtils.isEmpty(type)){
            int intType = Integer.valueOf(type);
            if(intType >= 0 && intType < WebViewUrlOpenType.values().length) {
                openType = WebViewUrlOpenType.values()[intType];
            }
        }
        Log.d(TAG,"getOpenTypeByUrl-url:"+url+" openType:"+openType);
        return openType;
    }

    //仅当opentype=2时有效
    public enum WebViewStyleType{
        Normal,//普通
        TRAN_SCROLL_UP_VISIABLE//导航栏背景初始为透明且页面上推渐变至实体
    }

    public WebViewStyleType getStyleTypeByUrl(String url){
        WebViewStyleType styleType = WebViewStyleType.Normal;
        Uri uri = Uri.parse(url);
        String type = uri.getQueryParameter(KEY_URL_PARAM_STYLE_TYPE);
        if(!TextUtils.isEmpty(type)){
            int intType = Integer.valueOf(type);
            if(intType >= 0 && intType < WebViewStyleType.values().length) {
                styleType = WebViewStyleType.values()[intType];
            }
        }
        Log.d(TAG,"getStyleTypeByUrl-url:"+url+" styleType:"+styleType);
        return styleType;
    }

    /**
     * 获取当前使用的服务的服务名字
     * @param url
     * @return
     */
    public String getServiceNameByUrl(String url){
        String serviceName = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            serviceName = uri.getQueryParameter(KEY_URL_SERVICE);
        }
        return serviceName;
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
            moduleName = uri.getQueryParameter(KEY_URL_MODULE);
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

    //---------------------- 以下是生成URL并打开对应界面 ---------------------------

    /**
     * 外部链接打开应用到hot列表url
     * @return
     */
    public static String createServiceEnter(){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_MAIN;

        url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + String.valueOf(1);
        return url;
    }

    /**
     * 生成外部打开主播资料页url
     * @param anchorId
     * @return
     */
    public static String createOutOpenAnchorProfile(String anchorId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL;

        url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        return url;
    }

    /**
     * 主播主动立即私密邀请时，生成Push所带Url
     * @return
     */
    public static String createAnchorInviteUrl(String anchorId, String anchorName, String anchorPhotoUrl, String inviteId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }

        if(!TextUtils.isEmpty(inviteId)){
            url += "&" + KEY_URL_PARAM_KEY_INVITATIONID + "=" + inviteId;
        }

        if(!TextUtils.isEmpty(anchorPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL + "=" + URLEncoder.encode(anchorPhotoUrl);
        }

        //roomType 主播发来立即私密邀请
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(3);

        return url;
    }

    /**
     * 预约邀请到期通知，生成Push所带Url
     * @return
     */
    public static String createBookExpiredUrl(String anchorId, String anchorName, String anchorPhotoUrl, String roomId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }

        if(!TextUtils.isEmpty(roomId)){
            url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=" + roomId;
        }

        if(!TextUtils.isEmpty(anchorPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL + "=" + URLEncoder.encode(anchorPhotoUrl);
        }

        //roomType 预约到期进入直播间
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(1);

        return url;
    }

    /**
     * 节目开播通知url构建
     * @return
     */
    public static String createProgramShowUrl(String anchorId, String anchorName, String anchorPhotoUrl, String liveshowid){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }

        if(!TextUtils.isEmpty(liveshowid)){
            url += "&" + KEY_URL_PARAM_KEY_LIVESHOWID + "=" + liveshowid;
        }

        if(!TextUtils.isEmpty(anchorPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL + "=" + URLEncoder.encode(anchorPhotoUrl);
        }

        //roomType 预约到期进入直播间
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(0);

        return url;
    }

    //----------------------- 以下是跳转 -----------------------------

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
    public int getMainListType(Uri uri){
        HashMap<String, String> params = parseParams(uri);
        int listType = 0;
        if(params.containsKey(KEY_URL_PARAM_KEY_LISTTYPE)){
            listType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_LISTTYPE)) - 1;
        }
        return listType;
    }

    /**
     * 是否Home页当前页
     * @param url
     * @return
     */
    public static boolean isHomeMainPage(String url){
        boolean isHome = false;
        if(!TextUtils.isEmpty(url)) {
            Uri uri = Uri.parse(url);
            String scheme = uri.getScheme();
            String authority = uri.getAuthority();
            String path = uri.getPath();
            //符合协议
            if ((scheme.equals(KEY_URL_SCHEME) || scheme.equals(KEY_URL_SCHEME_LIVE))&& authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)) {
                String serivceName = uri.getQueryParameter(KEY_URL_SERVICE);
                //符合服务
                if (!TextUtils.isEmpty(serivceName) && serivceName.equals(KEY_URL_SERVICE_NAME_LIVE)) {
                    //寻找相应模块
                    String moduleStr = uri.getQueryParameter(KEY_URL_MODULE);
                    if(TextUtils.isEmpty(moduleStr) || moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)){
                        isHome = true;
                    }
                }
            }
        }
        return isHome;
    }

    /**
     * 打开登錄界面
     */
    private void URL4Login(Context context){
        Intent intent = new Intent();
        intent.setClass(context, PeacockActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);

        context.startActivity(intent);

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
    private static void URL4AnchorProfile(Context context, Uri uri){
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
    private static void URL4LiveTransition(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        String roomId = "";
        String anchorId = "";
        String anchorName = "";
        String anchorPhotoUrl = "";
        String invitationId = "";
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
        }
        LiveRoomTransitionActivity.CategoryType categoryType = null;
        switch (roomType){
            case 0: {
                if(TextUtils.isEmpty(liveshowid)) {
                    categoryType = LiveRoomTransitionActivity.CategoryType.Enter_Public_Room;
                }else{
                    categoryType = LiveRoomTransitionActivity.CategoryType.Enter_Program_Public_Room;
                }
            }break;
            case 1: {
                categoryType = LiveRoomTransitionActivity.CategoryType.Schedule_Invite_Enter_Room;
            }break;
            case 2: {
                categoryType = LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room;
            }break;
            case 3: {
                categoryType = LiveRoomTransitionActivity.CategoryType.Anchor_Invite_Enter_Room;
            }break;
        }
        if(categoryType != null){
            if(categoryType == LiveRoomTransitionActivity.CategoryType.Anchor_Invite_Enter_Room){
                context.startActivity(LiveRoomTransitionActivity.getAcceptInviteIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, invitationId));
            }else if(categoryType == LiveRoomTransitionActivity.CategoryType.Enter_Program_Public_Room){
                context.startActivity(LiveRoomTransitionActivity.getProgramShowIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, liveshowid));
            }else{
                context.startActivity(LiveRoomTransitionActivity.getIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, roomId, ""));
            }
        }
    }

    /**
     * 打开预约邀请界面
     * @param context
     * @param uri
     */
    private static void URL4ScheduleInvite(Context context, Uri uri){
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
    private static void URL4BookList(Context context, Uri uri){
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
    private static void URL4PackageList(Context context, Uri uri){
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
    private static void URL4AddCredit(Context context, Uri uri){
        String type = uri.getQueryParameter(KEY_URL_PARAM_ORDER_TYPE);
        String clickFrom = uri.getQueryParameter(KEY_URL_PARAM_CLICK_FROM);
        String number = uri.getQueryParameter(KEY_URL_PARAM_ORDER_NUMBER);
        LiveService.getInstance().onAddCreditClick(new NoMoneyParamsBean(type, clickFrom, number));
    }

    /**
     * 进入我的等级界面
     * @param context
     * @param uri
     */
    private static void URL4MyLevel(Context context, Uri uri){
        String myLevelTitle = context.getResources().getString(R.string.my_level_title);
        context.startActivity(WebViewActivity.getIntent(context,
                myLevelTitle,
                WebViewActivity.UrlIntent.View_Audience_Level,null, true));
    }

    /**
     * 进入联系人列表界面
     * @param context
     */
    private static void URL4ChatList(Context context){
        Intent intent = new Intent(context, MessageContactListActivity.class);
        context.startActivity(intent);
    }

    /**
     * 进入私信聊天界面
     * @param context
     * @param uri
     */
    private static void URL4ChatDetail(Context context, Uri uri){
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
    private static void URL4GreetMailList(Context context){
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
    private static void URL4MailList(Context context){
        if(LoginManager.getInstance().getSynConfig() != null){
            context.startActivity(WebViewActivity.getIntent(context,
                    context.getResources().getString(R.string.live_webview_mail_title),
                    WebViewActivity.UrlIntent.View_Emf_List,
                    null,
                    true));
        }
    }


    /**
     * 新建webview打开链接
     * @param context
     * @param styletype
     * @param title
     * @param url
     */
    private static void openNewWebviewActivityByUrl(Context context, int styletype, String title, String url){
        Log.d(TAG,"openNewWebviewActivityByUrl-styletype:"+styletype+" title:"+title+" url:"+url);
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
    private static void openSystemBrowser(Context context, String url){
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

}
