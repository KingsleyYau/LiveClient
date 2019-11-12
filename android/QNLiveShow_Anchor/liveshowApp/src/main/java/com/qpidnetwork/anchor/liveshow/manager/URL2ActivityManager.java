package com.qpidnetwork.anchor.liveshow.manager;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.BaseWebViewActivity;
import com.qpidnetwork.anchor.liveshow.WebViewActivity;
import com.qpidnetwork.anchor.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.anchor.liveshow.liveroom.HangOutRoomTransActivity;
import com.qpidnetwork.anchor.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.anchor.liveshow.liveroom.ProgramLiveTransitionActivity;
import com.qpidnetwork.anchor.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.anchor.liveshow.personal.scheduleinvite.ScheduleInviteActivity;
import com.qpidnetwork.anchor.utils.Log;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

/**
 * 以URL拼写规则　决定　走向哪个窗口的管理类
 * Created by Jagger on 2017/9/22.
 */

public class URL2ActivityManager {
    private final String TAG = URL2ActivityManager.class.getSimpleName();

    private static final String KEY_URL_SCHEME = "qpidnetwork-anchor";
    private static final String KEY_URL_AUTHORITY = "app";
    private static final String KEY_URL_PATH = "/open";
    private static final String KEY_URL_MODULE = "module";


    //URL中module的值
    public static final String KEY_URL_MODULE_NAME_LIVE_LOGIN = "liveLogin";
    public static final String KEY_URL_MODULE_NAME_LIVE_MAIN = "main";
    public static final String KEY_URL_MODULE_NAME_LIVE_ROOM = "liveroom";
    public static final String KEY_URL_MODULE_NAME_BOOKING_LIST = "bookinglist";

    //URL中的KEYS
    public static final String KEY_URL_PARAM_KEY_LISTTYPE = "listtype";

    public static final String KEY_URL_PARAM_KEY_ROOMID = "roomId";
    public static final String KEY_URL_PARAM_KEY_USERID = "userId";
    public static final String KEY_URL_PARAM_KEY_USERNAME = "username";
    public static final String KEY_URL_PARAM_KEY_USERPHOTOURL = "userPhotoUrl";
    public static final String KEY_URL_PARAM_KEY_ROOMTYPE = "roomtype";
    public static final String KEY_URL_PARAM_KEY_INVITATIONID = "invitationid";
    public static final String KEY_URL_PARAM_KEY_ANCHORTYPE = "anchor_type";
    public static final String KEY_URL_PARAM_KEY_SHOWLIVEID = "liveshowid";

    //公共字段
    private static final String KEY_URL_PARAM_KEY_HTTPPROXY = "httpproxy";
    private static final String KEY_URL_PARAM_KEY_TEST = "test";

    //外部链接携带打开模式及title
    private static final String KEY_URL_PARAM_OPEN_TYPE = "opentype";
    private static final String KEY_URL_PARAM_APP_TITLE = "apptitle";

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
            if(scheme.equals(KEY_URL_SCHEME) && authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)){
                //寻找相应模块
                String moduleStr = uri.getQueryParameter(KEY_URL_MODULE);
                //当前主模块
                if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)){
                    URL4Main(context, uri);
                }
                //打开进入直播间过渡页
                else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_ROOM)){
                    URL4LiveTransition(context, uri);
                }
                //打开预约列表界面
                else if(moduleStr.equals(KEY_URL_MODULE_NAME_BOOKING_LIST)){
                    URL4BookList(context, uri);
                }
                //打开登錄界面
                else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_LOGIN)){
                    URL4Login(context);
                }
                dealResult = true;
            }else{
                //非打开指定模块Url，即非模块类型Url，检测
                dealResult = openNoModuleUrl(context, url);
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
            moduleName = uri.getQueryParameter(KEY_URL_MODULE);
        }
        return moduleName;
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
     * 读取链接中用户信息
     * @param url
     * @return
     */
    public IMUserBaseInfoItem getUserBaseInfo(String url){
        IMUserBaseInfoItem userInfo = new IMUserBaseInfoItem();
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            userInfo.userId = uri.getQueryParameter(KEY_URL_PARAM_KEY_USERID);
            userInfo.nickName = uri.getQueryParameter(KEY_URL_PARAM_KEY_USERNAME);
            userInfo.photoUrl = uri.getQueryParameter(KEY_URL_PARAM_KEY_USERPHOTOURL);
        }
        return userInfo;
    }

    /**
     *
     * @return
     */
    public boolean isHangOutRoom(String url){
        boolean isHangOutRoom = false;
        if(!TextUtils.isEmpty(url)) {
            Uri uri = Uri.parse(url);
            String roomType = uri.getQueryParameter(KEY_URL_PARAM_KEY_ROOMTYPE);
            isHangOutRoom = !TextUtils.isEmpty(roomType) && roomType.equals("4");
        }
        Log.d(TAG,"isHangOutRoom-isHangOutRoom:"+isHangOutRoom);
        return isHangOutRoom;
    }


    /**
     * 读取邀请Id
     * @param url
     * @return
     */
    public String getInvitationIdByUrl(String url){
        String invitationId = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            invitationId = uri.getQueryParameter(KEY_URL_PARAM_KEY_INVITATIONID);
        }
        return invitationId;
    }

    /**
     * 读取httpProxy字段
     * @param url
     * @return
     */
    public String readHttpProxyFlags(String url){
        String httpProxy = "";
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String temp = uri.getQueryParameter(KEY_URL_PARAM_KEY_HTTPPROXY);
            if(!TextUtils.isEmpty(temp)){
                httpProxy = temp;
            }
        }
        return httpProxy;
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
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_MAIN;

        url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + String.valueOf(1);
        return url;
    }

    /**
     * 男士邀请主播进入Hangout直播间时，生成Push所带Url
     * @return
     */
    public static String createHangOutInviteUrl(String userId, String userName, String userPhotoUrl, String inviteId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;
        if(!TextUtils.isEmpty(userId)){
            url += "&" + KEY_URL_PARAM_KEY_USERID + "=" + userId;
        }
        if(!TextUtils.isEmpty(userName)){
            url += "&" + KEY_URL_PARAM_KEY_USERNAME + "=" + userName;
        }
        if(!TextUtils.isEmpty(userPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_USERPHOTOURL+ "=" + URLEncoder.encode(userPhotoUrl);
        }
        if(!TextUtils.isEmpty(inviteId)){
            url += "&" + KEY_URL_PARAM_KEY_INVITATIONID + "=" + inviteId;
        }
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(4);
        return url;
    }


    /**
     * 主播主动立即私密邀请时，生成Push所带Url
     * (9.3.接收用户立即私密邀请通知)
     * @return
     */
    public static String createManInviteUrl(String userId, String userName, String userPhotoUrl, String inviteId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(userId)){
            url += "&" + KEY_URL_PARAM_KEY_USERID + "=" + userId;
        }

        if(!TextUtils.isEmpty(userName)){
            url += "&" + KEY_URL_PARAM_KEY_USERNAME + "=" + userName;
        }

        if(!TextUtils.isEmpty(userPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_USERPHOTOURL+ "=" + URLEncoder.encode(userPhotoUrl);
        }

        if(!TextUtils.isEmpty(inviteId)){
            url += "&" + KEY_URL_PARAM_KEY_INVITATIONID + "=" + inviteId;
        }

        //roomType 主播发来立即私密邀请
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(3);

        return url;
    }

    /**
     * 主播主动私密邀请，生成Push所带Url
     * @return
     */
    public static String createInviteUrl(String userId, String userName, String userPhotoUrl){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(userId)){
            url += "&" + KEY_URL_PARAM_KEY_USERID + "=" + userId;
        }

        if(!TextUtils.isEmpty(userName)){
            url += "&" + KEY_URL_PARAM_KEY_USERNAME + "=" + userName;
        }

        if(!TextUtils.isEmpty(userPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_USERPHOTOURL+ "=" + URLEncoder.encode(userPhotoUrl);
        }

        //roomType 主播私密邀请
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(2);

        return url;
    }

    /**
     * 预约邀请到期通知，生成Push所带Url
     * @return
     */
    public static String createBookExpiredUrl(String userId, String userName, String userPhotoUrl, String roomId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(userId)){
            url += "&" + KEY_URL_PARAM_KEY_USERID + "=" + userId;
        }

        if(!TextUtils.isEmpty(userName)){
            url += "&" + KEY_URL_PARAM_KEY_USERNAME + "=" + userName;
        }

        if(!TextUtils.isEmpty(userPhotoUrl)){
            url += "&" + KEY_URL_PARAM_KEY_USERPHOTOURL + "=" + URLEncoder.encode(userPhotoUrl);
        }

        if(!TextUtils.isEmpty(roomId)){
            url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=" + roomId;
        }

        //roomType 预约到期进入直播间
        url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + String.valueOf(1);

        return url;
    }

    /**
     * 生成节目开播通知url
     * @param showliveid
     * @return
     */
    public static String createProgramStartUrl(String showliveid){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(showliveid)){
            url += "&" + KEY_URL_PARAM_KEY_SHOWLIVEID + "=" + showliveid;
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
            if (scheme.equals(KEY_URL_SCHEME)&& authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)) {
                //寻找相应模块
                String moduleStr = uri.getQueryParameter(KEY_URL_MODULE);
                if(TextUtils.isEmpty(moduleStr) || moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)){
                    isHome = true;
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
        intent.setClass(context, LiveLoginActivity.class);
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
     * 打开进入直播间过渡页
     * @param context
     * @param uri
     */
    private static void URL4LiveTransition(Context context, Uri uri){
        HashMap<String, String> params = parseParams(uri);
        String roomId = "";
        String userId = "";
        String userName = "";
        String invitationId = "";
        String userPhotoUrl = "";
        String showLiveId = "";
        int roomType = 0;
        if(params != null){
            if(params.containsKey(KEY_URL_PARAM_KEY_ROOMID)){
                roomId = params.get(KEY_URL_PARAM_KEY_ROOMID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_USERID)){
                userId = params.get(KEY_URL_PARAM_KEY_USERID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_USERNAME)){
                userName = params.get(KEY_URL_PARAM_KEY_USERNAME);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_USERPHOTOURL)){
                userPhotoUrl = URLDecoder.decode(params.get(KEY_URL_PARAM_KEY_USERPHOTOURL));
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_INVITATIONID)){
                invitationId = params.get(KEY_URL_PARAM_KEY_INVITATIONID);
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_ROOMTYPE)){
                roomType = Integer.valueOf(params.get(KEY_URL_PARAM_KEY_ROOMTYPE));
            }
            if(params.containsKey(KEY_URL_PARAM_KEY_SHOWLIVEID)){
                showLiveId = params.get(KEY_URL_PARAM_KEY_SHOWLIVEID);
            }
        }
        if(!TextUtils.isEmpty(showLiveId)){
            //打开节目过渡直播间
            context.startActivity(ProgramLiveTransitionActivity.getProgramIntent(context, showLiveId));
        }else {
            switch (roomType) {
                case 1: {
                    //预约到期
                    context.startActivity(LiveRoomTransitionActivity.getEnterRoomIntent(context, userId, userName, userPhotoUrl, roomId));
                }
                break;
                case 2: {
                    context.startActivity(LiveRoomTransitionActivity.getInviteIntent(context, userId, userName, userPhotoUrl));
                }
                break;
                case 3: {
                    //用户立即私密邀请
                    context.startActivity(LiveRoomTransitionActivity.getAcceptInviteIntent(context, userId, userName, userPhotoUrl, invitationId));
                }
                break;
                case 4: {
                    //用户邀请进入Hangout直播间
                    context.startActivity(HangOutRoomTransActivity.getAcceptInviteIntent(context, userId, userName, userPhotoUrl, invitationId));
                }break;
            }
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
            Intent intent = new Intent(context, ScheduleInviteActivity.class);
            context.startActivity(intent);
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
    }

    /**
     * 进入充值界面
     * @param context
     * @param uri
     */
    private static void URL4AddCredit(Context context, Uri uri){
        LiveService.getInstance().onAddCreditClick(context);
    }

    /**
     * 读取forTest字段
     * @param url
     * @return
     */
    public static boolean readForTestFlags(String url){
        boolean forTest = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String temp = uri.getQueryParameter(KEY_URL_PARAM_KEY_TEST);
            if(!TextUtils.isEmpty(temp)){
                forTest = Integer.valueOf(temp) == 0?false:true;
            }
        }
        return forTest;
    }


    /**
     * uri转url
     * @param uri
     * @return
     */
    public static String uriToUrl(Uri uri){
        String url = "";
        if(uri != null){
            url = KEY_URL_SCHEME + "://"
                    + KEY_URL_AUTHORITY
                    + KEY_URL_PATH;
            String queryStr = uri.getQuery();
            if(!TextUtils.isEmpty(queryStr)){
                url += "?" + queryStr;
            }
        }
        return url;
    }

    /****************************** 增加支持系统浏览器打开或打开新webview加载Url *****************************************/
    /**
     * 处理非模块url即（Scheme非qpidnetwork-anchor）
     * @param context
     * @param url
     * @return
     */
    private boolean openNoModuleUrl(Context context, String url){
        boolean dealResult = false;
        if(!TextUtils.isEmpty(url)){
            Uri uri = Uri.parse(url);
            String openType = uri.getQueryParameter(KEY_URL_PARAM_OPEN_TYPE);
            if(!TextUtils.isEmpty(openType)){
                int type = Integer.valueOf(openType);
                if(type == 1){
                    //系统默认浏览器打开
                    openSystemBrowser(context, url);
                    dealResult = true;
                }else if(type == 2){
                    //新建webview打开
                    String title = uri.getQueryParameter(KEY_URL_PARAM_APP_TITLE);
                    openNewWebviewActivityByUrl(context, title, url);
                    dealResult = true;
                }
            }
        }
        return dealResult;
    }

    /**
     * 新建webview打开链接
     * @param context
     * @param title
     * @param url
     */
    private void openNewWebviewActivityByUrl(Context context, String title, String url){
        Intent intent = WebViewActivity.getIntent(context, title, url, BaseWebViewActivity.WebTitleType.Normal);
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

}
