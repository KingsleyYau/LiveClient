package com.qpidnetwork.livemodule.liveshow.manager;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.listener.DialogUIListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.RegisterActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatMainActivity;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.loi.AlphaBarWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.message.ChatTextActivity;
import com.qpidnetwork.livemodule.liveshow.message.MessageContactListActivity;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.personal.MyProfileActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.liveshow.personal.tickets.MyTicketsActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.UnsupportedEncodingException;
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
    public static final String KEY_URL_MODULE_NAME_CHAT_LIST = "chatlist";      //私信联系人列表
    public static final String KEY_URL_MODULE_NAME_CHAT = "chat";               //私信联系人列表
    public static final String KEY_URL_MODULE_NAME_LIVE_CHAT_LIST = "livechatlist";     // 2018/11/17 Hardy
    public static final String KEY_URL_MODULE_NAME_LIVE_CHAT = "livechat";              // 2018/11/21 Hardy
    public static final String KEY_URL_MODULE_NAME_GREETMAIL_LIST = "greetmaillist";
    public static final String KEY_URL_MODULE_NAME_MAIL_LIST = "maillist";
    public static final String KEY_URL_MODULE_NAME_POP_YESNO_DIALOG = "popyesnodialog";
    public static final String KEY_URL_MODULE_NAME_MY_TICKETS = "mytickets";
    public static final String KEY_URL_MODULE_NAME_LOGIN = "login"; //add by Jagger 2018-9-26
    public static final String KEY_URL_MODULE_NAME_MY_PROFILE = "myprofile"; //add by Jagger 2018-9-28
    public static final String KEY_URL_MODULE_NAME_SEND_MAIL = "sendmail"; //写信

    //URL中的KEYS
    public static final String KEY_URL_PARAM_KEY_LISTTYPE = "listtype";
    public static final String KEY_URL_PARAM_KEY_ROOMID = "roomid";
    public static final String KEY_URL_PARAM_KEY_ANCHORID = "anchorid";
    public static final String KEY_URL_PARAM_KEY_ANCHORNAME = "anchorname";
    public static final String KEY_URL_PARAM_KEY_ROOMTYPE = "roomtype";
    public static final String KEY_URL_PARAM_KEY_INVITATIONID = "invitationid";
    public static final String KEY_URL_PARAM_KEY_ANCHORTYPE = "anchor_type";
    public static final String KEY_URL_PARAM_KEY_LIVESHOWID = "liveshowid";
    public static final String KEY_URL_PARAM_KEY_GASCREENNAME = "gascreen";
    public static final String KEY_URL_PARAM_KEY_SELECT_INDEX = "selectIndex";

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

    //弹出对话框参数
    private static final String KEY_URL_PARAM_D_TITLE = "title";
    private static final String KEY_URL_PARAM_D_MSG = "msg";
    private static final String KEY_URL_PARAM_D_YES_TITLE = "yes_title";
    private static final String KEY_URL_PARAM_D_NO_TITLE = "no_title";
    private static final String KEY_URL_PARAM_D_YES_URL = "yes_url";

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

    //---------------------- 生成对应界面的URL start ---------------------------

    /**
     * 生成基础URL构造
     * @return
     */
    private static String doCreateBaseUrl(){
        return CoreUrlHelper.getUrlBasePath(LiveModule.getInstance());
    }

    /**
     * 外部链接打开应用到hot列表url
     * @return
     */
    public static String createServiceEnter(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_MAIN;

        url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + String.valueOf(1);
        return url;
    }

    /**
     * 生成外部打开主播资料页url
     * @param anchorId
     * @return
     */
    public static String createOutOpenAnchorProfile(String anchorId){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL;

        url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        return url;
    }

    /**
     * 主播主动立即私密邀请时，生成Push所带Url
     * @return
     */
    public static String createAnchorInviteUrl(String anchorId, String anchorName, String anchorPhotoUrl, String inviteId){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

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
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

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
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

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

    /**
     * 构建买点URL
     * @param orderType
     * @param clickFrom
     * @param number
     * @return
     */
    public static String createAddCreditUrl(String orderType, String clickFrom, String number){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_BUY_CREDIT;

        if(TextUtils.isEmpty(orderType)){
            orderType = "0";
        }
        url += "&" + KEY_URL_PARAM_ORDER_TYPE + "=" + orderType;

        url += "&" + KEY_URL_PARAM_CLICK_FROM + "=" + clickFrom;

        url += "&" + KEY_URL_PARAM_ORDER_NUMBER + "=" + number;

        return url;
    }

    /**
     * 构建私信联系人列表URL
     * @return
     */
    public static String createMessageListUrl(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_CHAT_LIST;
        return url;
    }

    /**
     * 构建 LiveChatList 列表
     * @return
     */
    public static String createLiveChatListUrl(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_CHAT_LIST;
        return url;
    }

    /**
     * 构建打开LiveChat聊天界面
     * @return
     */
    public static String createLiveChatActivityUrl(String anchorId, String anchorName, String photoUrl){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_CHAT;
        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }
        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }
        if(!TextUtils.isEmpty(photoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL + "=" + photoUrl;
        }
        return url;
    }

    /**
     * 构建打开senmail界面
     * @return
     */
    public static String createSendMailActivityUrl(String anchorId){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_SEND_MAIL;
        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }
        return url;
    }


    /**
     * 构建邮件列表URL
     * @return
     */
    public static String createMailList(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_MAIL_LIST;
        return url;
    }

    /**
     * 构建意向信列表URL
     * @return
     */
    public static String createGreetMailList(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_GREETMAIL_LIST;
        return url;
    }

    /**
     * 构建我的票据URL
     * @param selectIndex
     * @return
     */
    public static String createMyTickets(int selectIndex){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_MY_TICKETS;

        url += "&" + KEY_URL_PARAM_KEY_SELECT_INDEX + "=" + selectIndex;
        return url;
    }

    /**
     * 构建MyBooking URL
     * @param listType 大于0才有效
     * @return
     */
    public static String createScheduleInviteActivity(int listType){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_BOOKING_LIST;

        url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + listType;
        return url;
    }


    /**
     * 构建个人资料URL
     * @return
     */
    public static String createMyProfile(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_MY_PROFILE;

        return url;
    }

    /**
     * 构建MyBackpack URL
     * @param listType
     * @return
     */
    public static String createMyBackpackActivity(int listType){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_BOOKING_PACKLIST;

        url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + listType;
        return url;
    }


    //---------------------- 生成对应界面的URL end ---------------------------

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
    public int getMainListType(Uri uri){
        HashMap<String, String> params = parseParams(uri);
        int listType = 0;
        if(params.containsKey(KEY_URL_PARAM_KEY_LISTTYPE)){
            listType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_LISTTYPE)) - 1;
        }
        return listType;
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

        RegisterActivity.launchRegisterActivity(context, url);
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
                context.startActivity(LiveRoomTransitionActivity.getIntent(context, categoryType, anchorId, anchorName, anchorPhotoUrl, roomId, ""));
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
     * 进入livechat聊天界面
     * @param context
     * @param uri
     */
    private void URL4LiveChatAcitivity(Context context, Uri uri){
        if(uri != null){
            String anchorId = "";
            String anchorName = "";
            String photoUrl = "";
            try {
                anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
                anchorName = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORNAME);
                photoUrl = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL);
            }catch (Exception e){
                e.printStackTrace();
            }
            if(!TextUtils.isEmpty(anchorId)){
//                ChatActivity.launchChatActivity(context, anchorId, anchorName, photoUrl);
                //test Jagger
                LiveChatTalkActivity.launchChatActivity(context, anchorId, anchorName, photoUrl);
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
            try {
                anchorId = uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID);
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
                            || moduleName.equals(KEY_URL_MODULE_NAME_SEND_MAIL)){
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
                            || moduleName.equals(KEY_URL_MODULE_NAME_SEND_MAIL)){
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
                    || moduleName.equals(KEY_URL_MODULE_NAME_LIVE_CHAT)
                    || moduleName.equals(KEY_URL_MODULE_NAME_GREETMAIL_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MAIL_LIST)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MY_PROFILE)
                    || moduleName.equals(KEY_URL_MODULE_NAME_MY_TICKETS)
                    || moduleName.equals(KEY_URL_MODULE_NAME_SEND_MAIL)))){

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
