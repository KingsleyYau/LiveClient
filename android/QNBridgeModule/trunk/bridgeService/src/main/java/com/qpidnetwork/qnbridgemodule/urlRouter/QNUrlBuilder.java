package com.qpidnetwork.qnbridgemodule.urlRouter;

import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.util.CoreUrlHelper;

import java.net.URLEncoder;

/**
 * QN URL生成器
 * @author Jagger 2019-7-22
 */
public class QNUrlBuilder {
    //URL中module的值
    public static final String KEY_URL_MODULE_NAME_LAUNCHMODULE = "launchModule";//自定义，用于处理换站及kickoff等返回主界面
    public static final String KEY_URL_MODULE_NAME_QUICKMATCH = "quickmatch";// "qpidnetwork://app/quickmatch";
    public static final String KEY_URL_MODULE_NAME_EMFINBOX = "emf";// "qpidnetwork://app/emf";
    public static final String KEY_URL_MODULE_NAME_LOVECALL = "lovecall";// "qpidnetwork://app/lovecall";
    public static final String KEY_URL_MODULE_NAME_ADMIRE = "admirer";// "qpidnetwork://app/admirer";
    public static final String KEY_URL_MODULE_NAME_CONTACTS = "contact";// "qpidnetwork://app/contact";
    public static final String KEY_URL_MODULE_NAME_SETTING = "setting";// "qpidnetwork://app/setting";
    public static final String KEY_URL_MODULE_NAME_HELPS = "helps";// "qpidnetwork://app/helps";
    public static final String KEY_URL_MODULE_NAME_OVERVIEW = "overview";// "qpidnetwork://app/overview";
    public static final String KEY_URL_MODULE_NAME_CHATLIST = "chatlist";// "qpidnetwork://app/chatlist";
    public static final String KEY_URL_MODULE_NAME_BUYCREDIT = "buycredit";// "qpidnetwork://app/buycredit";
    public static final String KEY_URL_MODULE_NAME_MYPROFILE = "myprofile";// "qpidnetwork://app/myprofile";
    public static final String KEY_URL_MODULE_NAME_CHATINVITE = "chatinvite";// "qpidnetwork://app/chatinvite";
    public static final String KEY_URL_MODULE_NAME_LADYDETAIL = "ladydetail";// "qpidnetwork://app/ladydetail";
    public static final String KEY_URL_MODULE_NAME_CHATLADY = "chatlady";// "qpidnetwork://app/chatlady";
    public static final String KEY_URL_MODULE_NAME_SENDEMF = "sendemf";// "qpidnetwork://app/sendemf";
    public static final String KEY_URL_MODULE_NAME_CONTACTUS = "contactUs";// "qpidnetwork://app/contactUs";	//add by Jagger 2017-7-31
    public static final String KEY_URL_MODULE_NAME_POP_YESNO_DIALOG = "popyesnodialog";// "qpidnetwork://app/popyesnodialog";	//add by Jagger 2018-8-24
    public static final String KEY_URL_MODULE_NAME_CHAT = "chat";// "qpidnetwork://app/chat";      //add by Jagger 2019-7-22 进入Chat界面，只用于内部

    //本地基于push自定义模块跳转处理
    public static final String KEY_URL_MODULE_NAME_PUSHADVERT = "pushadvert";
    public static final String KEY_URL_MODULE_NAME_CAMSHARE = "camshare";

    //URL中的KEYS
    public static final String KEY_URL_PARAM_KEY_LADYID = "ladyid";

    //本地基于push自定义url keys
    public static final String KEY_URL_PARAM_KEY_URLOPENTYPE = "opentype";
    public static final String KEY_URL_PARAM_KEY_ADVERTURL = "advertUrl";
    public static final String KEY_URL_PARAM_KEY_LADYNAME = "ladyName";
    public static final String KEY_URL_PARAM_KEY_LADY_PHOTO = "photoUrl";

    //直播模块keys
    public static final String KEY_URL_PARAM_KEY_LISTTYPE = "listtype";

    //外部链接携带打开模式及title
    public static final String KEY_URL_PARAM_OPEN_TYPE = "opentype";
    public static final String KEY_URL_PARAM_APP_TITLE = "apptitle";

    //打开模块参数
    public static final String KEY_URL_MODULE_NAME_LIVE_MAIN = "main";

    //买点外部链接参数
    public static final String KEY_URL_PARAM_ORDER_TYPE = "order_type";
    public static final String KEY_URL_PARAM_CLICK_FROM = "click_from";
    public static final String KEY_URL_PARAM_ORDER_NUMBER = "number";

    //弹出对话框参数
    public static final String KEY_URL_PARAM_D_TITLE = "title";
    public static final String KEY_URL_PARAM_D_MSG = "msg";
    public static final String KEY_URL_PARAM_D_YES_TITLE = "yes_title";
    public static final String KEY_URL_PARAM_D_NO_TITLE = "no_title";
    public static final String KEY_URL_PARAM_D_YES_URL = "yes_url";

    //---------------------- 以下是生成URL ---------------------------

    /**
     * 生成基础path
     * @return
     */
    public static String getUrlBasePath(){
        return CoreUrlHelper.getUrlBasePath();
    }

//    /**
//     * 生成push advert notification url
//     * @return
//     */
//    public static String CreatePushAdvertNotificationUrl(AdMainAdvert.OpenType openType, String advertUrl){
//        String url = getUrlBasePath();
//        url += "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_PUSHADVERT;
//        if(openType != null){
//            url += "&" + KEY_URL_PARAM_KEY_URLOPENTYPE + "=" + String.valueOf(openType.ordinal());
//        }
//        if(!TextUtils.isEmpty(advertUrl)){
//            url += "&" + KEY_URL_PARAM_KEY_ADVERTURL + "=" + URLEncoder.encode(advertUrl);
//        }
//        return url;
//    }
    /**
     * 生成push advert notification url
     * @param adMainAdvertOpenTypeIndex 对应AdMainAdvert.OpenType索引
     * @return
     */
    public static String CreatePushAdvertNotificationUrl(int adMainAdvertOpenTypeIndex, String advertUrl){
        String url = getUrlBasePath();
        url += "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_PUSHADVERT;
        if(adMainAdvertOpenTypeIndex != -1){
            url += "&" + KEY_URL_PARAM_KEY_URLOPENTYPE + "=" + String.valueOf(adMainAdvertOpenTypeIndex);
        }
        if(!TextUtils.isEmpty(advertUrl)){
            url += "&" + KEY_URL_PARAM_KEY_ADVERTURL + "=" + URLEncoder.encode(advertUrl);
        }
        return url;
    }

    /**
     * 生成打开module URL
     * @return
     */
    public static String CreateMoudleLaunchUrl(){
        String url = getUrlBasePath();
        url += "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LAUNCHMODULE;
        return url;
    }

    /**
     * 生成Camshare Notification url
     * @param targetId
     * @param targetName
     * @return
     */
    public static String CreateCamshareNotificationUrl(String targetId, String targetName){
        String url = getUrlBasePath();
        url += "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_CAMSHARE;
        if(!TextUtils.isEmpty(targetId)){
            url += "&" + KEY_URL_PARAM_KEY_LADYID + "=" + targetId;
        }
        if(!TextUtils.isEmpty(targetName)){
            url += "&" + KEY_URL_PARAM_KEY_LADYNAME + "=" + targetName;
        }
        return url;
    }

    /**
     * 生成emf push 跳转url
     * @return
     */
    public static String CreateEMFNotificationUrl(){
        return CreateLinkUrl(KEY_URL_MODULE_NAME_EMFINBOX, "", "");
    }

    /**
     * 生成live notification 跳转url
     * @return
     */
    public static String CreateLiveNotificationUrl(){
        return CreateLinkUrl(KEY_URL_MODULE_NAME_CHATLIST, "", "");
    }

    /**
     * 本地拼接url
     * @param moduleName
     * @param ladyId
     * @param source
     * @return
     */
    public static String CreateLinkUrl(String moduleName, String ladyId, String source){
        String url = getUrlBasePath();
        if(!TextUtils.isEmpty(moduleName)){
            url += "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + moduleName;
        }
        if(!TextUtils.isEmpty(source)){
            url += "&" + CoreUrlHelper.KEY_URL_SOURCE + "=" + source;
        }
        if(!TextUtils.isEmpty(ladyId)){
            url += "&" + KEY_URL_PARAM_KEY_LADYID + "=" + ladyId;
        }
        return url;
    }

//    /**
//     * 处理url拼接
//     * @param url
//     * @param openType
//     * @return
//     */
//    public static String packageOpenTypeUrl(String url, AdMainAdvert.OpenType openType){
//        String tempUrl = url;
//        if(!TextUtils.isEmpty(url)){
//            if(openType != null){
//                int type = 0;
//                switch (openType){
//                    case APPBROWER:{
//                        type = 2;
//                    }break;
//                    case SYSTEMBROWER:{
//                        type = 1;
//                    }break;
//                    case HIDE:{
//                        type = 3;
//                    }break;
//                    default:
//                        break;
//                }
//                if(type > 0) {
//                    if (url.contains("?")) {
//                        tempUrl = (url + "&" + KEY_URL_PARAM_OPEN_TYPE + "=" + String.valueOf(type));
//                    } else {
//                        tempUrl = (url + "?" + KEY_URL_PARAM_OPEN_TYPE + "=" + String.valueOf(type));
//                    }
//                }
//            }
//        }
//        return tempUrl;
//    }
    /**
     * 处理url拼接
     * @param url
     * @param adMainAdvertOpenTypeIndex 对应AdMainAdvert.OpenType索引
     * @return
     */
    public static String packageOpenTypeUrl(String url, int adMainAdvertOpenTypeIndex){
        String tempUrl = url;
        if(!TextUtils.isEmpty(url)){
            int type = 0;
            switch (adMainAdvertOpenTypeIndex){
                case 2:{
                    type = 2;
                }break;
                case 1:{
                    type = 1;
                }break;
                case 0:{
                    type = 3;
                }break;
                default:
                    break;
            }
            if(type > 0) {
                if (url.contains("?")) {
                    tempUrl = (url + "&" + KEY_URL_PARAM_OPEN_TYPE + "=" + String.valueOf(type));
                } else {
                    tempUrl = (url + "?" + KEY_URL_PARAM_OPEN_TYPE + "=" + String.valueOf(type));
                }
            }
        }
        return tempUrl;
    }

    /**
     * Chat聊天界面连接
     * @param targetId
     * @param targetName
     * @param photoUrl
     * @return
     */
    public static String CreateChatTalkLink( String targetId,  String targetName,  String photoUrl){
        String url = getUrlBasePath();
        url += "&" + CoreUrlHelper.KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_CHAT;

        if(!TextUtils.isEmpty(targetId)){
            url += "&" + KEY_URL_PARAM_KEY_LADYID + "=" + targetId;
        }
        if(!TextUtils.isEmpty(targetName)){
            url += "&" + KEY_URL_PARAM_KEY_LADYNAME + "=" + targetName;
        }
        if(!TextUtils.isEmpty(photoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_LADY_PHOTO + "=" + photoUrl;
        }
        return url;
    }
}
