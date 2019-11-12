package com.qpidnetwork.qnbridgemodule.urlRouter;

import android.text.TextUtils;
import android.util.Base64;

import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.net.URLEncoder;

/**
 * 直播 URL生成器
 * @author Jagger 2019-7-22
 */
public class LiveUrlBuilder {
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
    public static final String KEY_URL_MODULE_NAME_HANGOUT_DIALOG = "hangout_dialog";   //打开hangoutdialog
    public static final String KEY_URL_MODULE_NAME_HANGOUT_TRANSITION = "hangout";   //打开hangout过渡页
    public static final String KEY_URL_MODULE_NAME_SAYHI_LIST = "sayhi_list";   //打开SayHi列表
    public static final String KEY_URL_MODULE_NAME_SENDSAYHI = "sendsayhi";   //打开SayHi编辑界面
    public static final String KEY_URL_MODULE_NAME_SAYHI_DETAIL = "sayhi_detail";   //打开SayHi详情页
    public static final String KEY_URL_MODULE_NAME_MY_CONTACT_LIST = "mycontactlist";   // 2019/8/16  Hardy
    public static final String KEY_URL_MODULE_NAME_GIFT_FLOWER_LIST = "giftflower_list";                    // 2019/10/12  Hardy 鲜花礼品列表页——商店主页下
    public static final String KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE = "giftflower_anchor_store";    // 2019/10/12  Hardy 鲜花礼品列表页——主播下

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
    public static final String KEY_URL_PARAM_KEY_SAYHIID = "sayhiid";
    public static final String KEY_URL_PARAM_KEY_INVITE_MSG_ID = "invitemsg";   // add by Hardy 2019-7-15

    //自定义key
    public static final String KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL = "anchorAvatar";
    public static final String KEY_URL_PARAM_KEY_BUBBLE_FLAG = "bubbleFlag";
    public static final String KEY_URL_PARAM_KEY_STORE_LIST_TYPE = "listtype";

    //外部链接携带打开模式及title
    public static final String KEY_URL_PARAM_OPEN_TYPE = "opentype";
    public static final String KEY_URL_PARAM_STYLE_TYPE = "styletype";
    public static final String KEY_URL_PARAM_APP_TITLE = "apptitle";

    //买点外部链接参数
    public static final String KEY_URL_PARAM_ORDER_TYPE = "order_type";
    public static final String KEY_URL_PARAM_CLICK_FROM = "click_from";
    public static final String KEY_URL_PARAM_ORDER_NUMBER = "number";
    public static final String KEY_URL_PARAM_RESUMECB = "resumecb";

    //弹出对话框参数
    public static final String KEY_URL_PARAM_D_TITLE = "title";
    public static final String KEY_URL_PARAM_D_MSG = "msg";
    public static final String KEY_URL_PARAM_D_YES_TITLE = "yes_title";
    public static final String KEY_URL_PARAM_D_NO_TITLE = "no_title";
    public static final String KEY_URL_PARAM_D_YES_URL = "yes_url";


    //---------------------- 生成对应界面的URL start ---------------------------

    /**
     * 生成基础URL构造
     * @return
     */
    private static String doCreateBaseUrl(){
//        return CoreUrlHelper.getUrlBasePath();
        return CoreUrlHelper.getUrlBasePath(WebSiteConfigManager.WebSiteType.CharmLive);
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
     * 私密直播 one on one Url
     * @return
     */
    public static String createOneOnOneUrl(String anchorId, String anchorName, String anchorPhotoUrl){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }

//        url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=\"\"";
        url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=";

        if(!TextUtils.isEmpty(anchorPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL + "=" + URLEncoder.encode(anchorPhotoUrl);
        }

        //roomType 进入OneOnOne直播间
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(2);

        return url;
    }

    /**
     * 生成冒泡点击url
     * @param anchorId
     * @param anchorName
     * @param anchorPhotoUrl
     * @return
     */
    public static String createOneOnOneUrlFromBubble(String anchorId, String anchorName, String anchorPhotoUrl){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }

//        url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=\"\"";
        url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=";

        if(!TextUtils.isEmpty(anchorPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHOR_PHOTOURL + "=" + URLEncoder.encode(anchorPhotoUrl);
        }

        //roomType 进入OneOnOne直播间
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(2);

        //增加冒泡标志位
        url += "&" + KEY_URL_PARAM_KEY_BUBBLE_FLAG + "=" + "1";

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
     * 构建 MyContactList 列表
     * @return
     */
    public static String createMyContactListUrl(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_MY_CONTACT_LIST;
        return url;
    }

    /**
     * 鲜花礼品列表——商店
     */
    public static String createGiftFlowersListUrl(){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_GIFT_FLOWER_LIST;
        return url;
    }

    /**
     * 鲜花礼品列表——主播下
     * @return
     */
    public static String createGiftFlowersAnchorStoreUrl(String anchorId){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_GIFT_FLOWER_ANCHOR_STORE;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

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
    public static String createLiveChatActivityUrl(String anchorId, String anchorName, String photoUrl, String inviteMsgId){
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
        if(!TextUtils.isEmpty(inviteMsgId)){
            url += "&" + KEY_URL_PARAM_KEY_INVITE_MSG_ID + "=" + Base64.encodeToString(inviteMsgId.getBytes(), Base64.DEFAULT);
        }

        return url;
    }

    public static String createLiveChatActivityUrl(String anchorId, String anchorName, String photoUrl){
        return createLiveChatActivityUrl(anchorId, anchorName, photoUrl, null);
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
     * 构建打开senmail界面(带sayhiid)
     * @param anchorId
     * @param sayHiResponseId
     * @return
     */
    public static String createSendMailActivityUrlFromSayHi(String anchorId, String sayHiResponseId){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_SEND_MAIL;
        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }
        if(!TextUtils.isEmpty(sayHiResponseId)){
            url += "&" + KEY_URL_PARAM_KEY_SAYHIID + "=" + sayHiResponseId;
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

    /**
     * 构建Hangout过渡页 URL
     * @param anchorId
     * @param anchorName
     * @return
     */
    public static String createHangoutTransitionActivity(String anchorId, String anchorName){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_HANGOUT_TRANSITION;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }
        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }
        return url;
    }

    /**
     * 专门处理冒泡点击进入
     * @param anchorId
     * @param anchorName
     * @return
     */
    public static String createHangoutTransitionActivityFromBubble(String anchorId, String anchorName){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_HANGOUT_TRANSITION;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }
        if(!TextUtils.isEmpty(anchorName)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORNAME + "=" + anchorName;
        }

        url += "&" + KEY_URL_PARAM_KEY_BUBBLE_FLAG + "=" + "1";

        return url;
    }

    /**
     * 构建 SayHi 列表 URL
     * @param sayHiListType 2:Response; 其它默认为:All
     * @return
     */
    public static String createSayHiListActivityUrl(String sayHiListType){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_SAYHI_LIST;

        if(!TextUtils.isEmpty(sayHiListType)){
            url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + sayHiListType;
        }
        return url;
    }

    /**
     * 构建 SayHi 编辑页面 URL
     * @param sayHiId
     * @return
     */
    public static String createSayHiDetailActivityUrl(String sayHiId){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_SAYHI_DETAIL;

        if(!TextUtils.isEmpty(sayHiId)){
            url += "&" + KEY_URL_PARAM_KEY_SAYHIID + "=" + sayHiId;
        }
        return url;
    }

    /**
     * 构建鲜花礼品列表URL
     * @return
     */
    public static String createFlowersMainList(String listType){
        String url = doCreateBaseUrl() //以上是基本结构，后面接的是参数
                + "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_GIFT_FLOWER_LIST;

        if(!TextUtils.isEmpty(listType)){
            url += "&" + KEY_URL_PARAM_KEY_STORE_LIST_TYPE + "=" + listType;
        }

        return url;
    }


    //---------------------- 生成对应界面的URL end ---------------------------
}
