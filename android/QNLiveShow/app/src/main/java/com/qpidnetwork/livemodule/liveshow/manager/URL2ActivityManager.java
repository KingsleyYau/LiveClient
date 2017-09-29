package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.ad.AD4QNActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.StringUtil;

/**
 * 以URL拼写规则　决定　走向哪个窗口的管理类
 * Created by Jagger on 2017/9/22.
 */

public class URL2ActivityManager {
    private final String KEY_URL_SCHEME = "qpidnetwork";
    private final String KEY_URL_AUTHORITY = "app";
    private final String KEY_URL_PATH = "/open";
    private final String KEY_URL_SERVICE = "service";
    private final String KEY_URL_MODULE = "module";

    //URL中service的值
    private final String KEY_URL_SERVICE_NAME_LIVE = "live";

    //URL中module的值
    private final String KEY_URL_MODULE_NAME_LIVE_QNAD = "qnad";
    private final String KEY_URL_MODULE_NAME_LIVE_MAIN = "main";
    private final String KEY_URL_MODULE_NAME_LIVE_ROOM = "liveroom";
    private final String KEY_URL_MODULE_NAME_ANCHOR_DETAIL = "anchordetail";

    //URL中的KEYS
    private final String KEY_URL_PARAM_KEY_LISTTYPE = "listtype";

    private final String KEY_URL_PARAM_KEY_ROOMID = "roomid";
    private final String KEY_URL_PARAM_KEY_ANCHORID = "anchorid";
    private final String KEY_URL_PARAM_KEY_ROOMTYPE = "roomtype";


    private Context mContext;
    private String mURL = "";
    private boolean mIsAppStart4Me = false; //APP是否由我启动的

    public static URL2ActivityManager getInstance(Context c) {
        if (singleton == null) {
            singleton = new URL2ActivityManager(c);
        }

        return singleton;
    }

    private static URL2ActivityManager singleton;

    private URL2ActivityManager(Context c) {
        mContext = c.getApplicationContext();
    }

    /**
     * 解析URL
     * @return
     */
    public void GotoActivity(String url){
        mURL = url;

//        if(!AppManager.getAppManager().isAppAlive()){
//            mIsAppStart4Me = true;
//            StartApp();
//        }else{
            URL2Activity();
//        }

    }

    /**
     * APP启动完成后调用
     */
    public void OnAppStartUpFinish(){
        if(mIsAppStart4Me){
            mIsAppStart4Me = false;
            URL2Activity();
        }
    }

    private void URL2Activity(){
        if(!TextUtils.isEmpty(mURL)){
            Uri uri = Uri.parse(mURL);
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

                    //打开广告列表
                    if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_QNAD)){
                        URL4LiveAD();
                    }
                    //打开主界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_MAIN)){
                        URL4Main();
                    }
                    //进入直播间
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_LIVE_ROOM)){
                        URL4ROOM(
                                uri.getQueryParameter(KEY_URL_PARAM_KEY_ROOMTYPE) ,
                                uri.getQueryParameter(KEY_URL_PARAM_KEY_ROOMID),
                                uri.getQueryParameter(KEY_URL_PARAM_KEY_ANCHORID)
                                );
                    }
                    //进入主播资料界面
                    else if(moduleStr.equals(KEY_URL_MODULE_NAME_ANCHOR_DETAIL)){

                    }
                }
            }
        }
    }
    //---------------------- 以下是生成URL并打开对应界面 ---------------------------

    /**
     * QN中显示的广告界面
     */
    public void toLiveAD(){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_QNAD;

        Log.i("Jagger" , URL2ActivityManager.class.getSimpleName() + "-->toLiveAD:" + url);

        //
        GotoActivity(url);
    }

    /**
     * 生成　进入直播主界面URL
     * @param listType 1：HOT列表　2：FOLLOWING列表　（“”则为1）
     * @return
     */
    public void toLiveMain(String listType){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_MAIN;

        if(!TextUtils.isEmpty(listType)){
            url += "&" + KEY_URL_PARAM_KEY_LISTTYPE + "=" + listType;
        }

        Log.i("Jagger" , URL2ActivityManager.class.getSimpleName() + "-->toLiveMain:" + url);

        //
        GotoActivity(url);
    }

    /**
     * 进入主播资料界面
     * @param anchorId
     */
    public void toAnchordDetail(String anchorId){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_ANCHOR_DETAIL;

        if(!TextUtils.isEmpty(anchorId)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorId;
        }

        Log.i("Jagger" , URL2ActivityManager.class.getSimpleName() + "-->toAnchordetail:" + url);

        //
        GotoActivity(url);
    }

    /**
     * 生成直播间URL并进入
     * @param roomType 0：公开　，　1：私密
     * @param roomId
     * @param anchorid
     */
    public void toLiveRoom(String roomType , String roomId , String anchorid){
        String url = KEY_URL_SCHEME + "://"
                + KEY_URL_AUTHORITY
                + KEY_URL_PATH + "?"
                + KEY_URL_SERVICE + "=" + KEY_URL_SERVICE_NAME_LIVE //以上是基本结构，后面接的是参数
                + "&" + KEY_URL_MODULE + "=" + KEY_URL_MODULE_NAME_LIVE_ROOM;

        if(!TextUtils.isEmpty(roomType)){
            url += "&" + KEY_URL_PARAM_KEY_ROOMTYPE + "=" + roomType;
        }

        if(!TextUtils.isEmpty(roomId)){
            url += "&" + KEY_URL_PARAM_KEY_ROOMID + "=" + roomId;
        }

        if(!TextUtils.isEmpty(anchorid)){
            url += "&" + KEY_URL_PARAM_KEY_ANCHORID + "=" + anchorid;
        }

        Log.i("Jagger" , URL2ActivityManager.class.getSimpleName() + "-->toLiveRoom:" + url);

        //
        GotoActivity(url);
    }




    //----------------------- 以下是跳转 -----------------------------
    private void StartApp(){

    }

    /**
     * QN首页弹出的广告列表界面
     */
    private void URL4LiveAD(){
        Intent intent = new Intent();
        intent.setClass(mContext, AD4QNActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);

        mContext.startActivity(intent);
    }


    /**
     * 打开主界面
     */
    private void URL4Main(){
        Intent intent = new Intent();
        intent.setClass(mContext, MainFragmentActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);

        mContext.startActivity(intent);

    }

    /**
     * 进入直播间
     * @param roomType 0：公开　，　1：私密
     * @param roomId
     * @param anchorid
     */
    private void URL4ROOM(String roomType , String roomId , String anchorid){
//        if(roomType.equals(LiveRoomType.FreePublicRoom.name())){
//            //进入公共直播间
//            Intent intent = LiveRoomTransitionActivity.getRoomInIntent(mContext,
//                    userId, nickName, photoUrl, "",roomPhotoUrl);
//            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
//
//            mContext.startActivity(intent);
//        }else{
//            //发起私密邀请
//            Intent intent = LiveRoomTransitionActivity.getInviteIntent(mContext,
//                    userId, nickName, photoUrl, "",roomPhotoUrl);
//            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
//
//            mContext.startActivity(intent);
//        }


            Intent intent = LiveRoomTransitionActivity.getURLIntent(mContext, roomType.equals("1")?true:false , roomId , anchorid);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);

            mContext.startActivity(intent);
    }
}
