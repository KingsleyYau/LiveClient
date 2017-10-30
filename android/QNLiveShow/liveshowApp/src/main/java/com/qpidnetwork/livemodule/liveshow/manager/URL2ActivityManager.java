package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.liveshow.personal.mypackage.MyPackageActivity;
import com.qpidnetwork.livemodule.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.livemodule.liveshow.welcome.PeacockActivity;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Set;

/**
 * 以URL拼写规则　决定　走向哪个窗口的管理类
 * Created by Jagger on 2017/9/22.
 */

public class URL2ActivityManager {
    private static final String KEY_URL_SCHEME = "qpidnetwork";
    private static final String KEY_URL_AUTHORITY = "app";
    private static final String KEY_URL_PATH = "/open";
    private static final String KEY_URL_SERVICE = "service";
    private static final String KEY_URL_MODULE = "module";
    private static final String KEY_URL_SITE = "site";

    //URL中service的值
    public static final String KEY_URL_SERVICE_NAME_LIVE = "live";

    //URL中module的值
    private static final String KEY_URL_MODULE_NAME_LIVE_LOGIN = "liveLogin";
    private static final String KEY_URL_MODULE_NAME_LIVE_MAIN = "main";
    private static final String KEY_URL_MODULE_NAME_LIVE_ANCHOR_DETAIL = "anchordetail";
    private static final String KEY_URL_MODULE_NAME_LIVE_ROOM = "liveroom";
    private static final String KEY_URL_MODULE_NAME_NEW_BOOKING = "newbooking";
    private static final String KEY_URL_MODULE_NAME_BOOKING_LIST = "bookinglist";
    private static final String KEY_URL_MODULE_NAME_BOOKING_PACKLIST = "backpacklist";
    private static final String KEY_URL_MODULE_NAME_BUY_CREDIT = "buycredit";
    private static final String KEY_URL_MODULE_NAME_MY_LEVEL = "mylevel";

    //URL中的KEYS
    private static final String KEY_URL_PARAM_KEY_LISTTYPE = "listtype";

    private static final String KEY_URL_PARAM_KEY_ROOMID = "roomid";
    private static final String KEY_URL_PARAM_KEY_ANCHORID = "anchorid";
    private static final String KEY_URL_PARAM_KEY_ANCHORNAME = "anchorname";
    private static final String KEY_URL_PARAM_KEY_ROOMTYPE = "roomtype";
    private static final String KEY_URL_PARAM_KEY_INVITATIONID = "invitationid";

    public static URL2ActivityManager getInstance() {
        if (singleton == null) {
            singleton = new URL2ActivityManager();
        }

        return singleton;
    }

    private static URL2ActivityManager singleton;

    private URL2ActivityManager() {
    }

    public static void URL2Activity(Context context, String url){
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String scheme = uri.getScheme();
            String authority = uri.getAuthority();
            String path = uri.getPath();
            //符合协议
            if(scheme.equals(KEY_URL_SCHEME) && authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)){
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
                }
            }
        }
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

    //---------------------- 以下是生成URL并打开对应界面 ---------------------------

    /**
     * 主播主动立即私密邀请时，生成Push所带Url
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
     * 主播主动立即私密邀请时，生成Push所带Url
     * @return
     */
    public static String createAnchorInviteUrl(String anchorId, String anchorName, String inviteId){
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

        //roomType 主播发来立即私密邀请
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(3);

        return url;
    }

    /**
     * 预约邀请到期通知，生成Push所带Url
     * @return
     */
    public static String createBookExpiredUrl(String anchorId, String anchorName, String roomId){
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

        //roomType 预约到期进入直播间
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(1);

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
    public static int getMainListType(Uri uri){
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
            if (scheme.equals(KEY_URL_SCHEME) && authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)) {
                String serivceName = uri.getQueryParameter(KEY_URL_SERVICE);
                //符合服务
                if (serivceName.equals(KEY_URL_SERVICE_NAME_LIVE)) {
                    //寻找相应模块
                    String moduleStr = uri.getQueryParameter(KEY_URL_MODULE);
                    if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)){
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
    private static void URL4Login(Context context){
        Intent intent = new Intent();
        intent.setClass(context, PeacockActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);

        context.startActivity(intent);

    }

    /**
     * 打开主界面
     */
    private static void URL4Main(Context context, Uri uri){
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
            AnchorProfileActivity.launchActivity(context, anchorId);
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
        String invitationId = "";
        int roomType = -1;
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
        }
        LiveRoomTransitionActivity.CategoryType categoryType = null;
        switch (roomType){
            case 0: {
                categoryType = LiveRoomTransitionActivity.CategoryType.Enter_Public_Room;
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
                context.startActivity(LiveRoomTransitionActivity.getAcceptInviteIntent(context, categoryType, anchorId, anchorName, "", invitationId));
            }else{
                context.startActivity(LiveRoomTransitionActivity.getIntent(context, categoryType, anchorId, anchorName, "", roomId, ""));
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
                defaultIndex = 1;
            }else if(listType == 2){
                defaultIndex = 0;
            }else if(listType == 3){
                defaultIndex = 2;
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
        context.startActivity(WebViewActivity.getIntent(context, "Add Credit", "http://www.baidu.com"));
    }

    private static void URL4MyLevel(Context context, Uri uri){
        context.startActivity(WebViewActivity.getIntent(context, context.getResources().getString(R.string.my_level_title), "http://www.baidu.com"));
    }

}
