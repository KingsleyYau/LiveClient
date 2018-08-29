package com.qpidnetwork.anchor.liveshow.manager;

import android.content.Context;
import android.util.Log;

import com.qpidnetwork.anchor.httprequest.item.ConfigItem;
import com.qpidnetwork.anchor.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.anchor.utils.SystemUtils;

/**
 * APP更新管理器
 * Created by Jagger on 2018/1/3.
 */

public class UpdateManager {
    /**
     * 更新类型
     */
    public enum  UpdateType{
        FORCE,      //强制
        NORMAL,     //普通
        NONE        //不需要更新
    }

    /**
     * 更新信息
     */
    public class UpdateMessage{
        public String downloadAppUrl = "";
        public String forceUpdateMsg = "";
        public String normalUpdateMsg = "";
    }

    //变量
    private Context mContext;
    private UpdateMessage mUpdateMessage;
    private static boolean isCancelNormal = false; //是否取消普通更新

    public static UpdateManager getInstance(Context c) {
        if (singleton == null) {
            singleton = new UpdateManager(c);
            Log.i("Jagger" , "UpdateManager new UpdateManager");
        }

        return singleton;
    }

    private static UpdateManager singleton;

    private UpdateManager(Context c) {
        mContext = c.getApplicationContext();
    }

    /**
     * 检测是否要更新
     * @param configItem
     * @return
     */
    public UpdateType getUpdateType(ConfigItem configItem){
        if(configItem == null){
            return UpdateType.NONE;
        }

        //test
//        configItem.newestVer = 400;

        if(SystemUtils.getVersionCode(mContext) < configItem.minAavilableVer){
            //封装数据
            mUpdateMessage = new UpdateMessage();
            mUpdateMessage.downloadAppUrl = configItem.downloadAppUrl;
            mUpdateMessage.forceUpdateMsg = configItem.minAvailableMsg;

            return UpdateType.FORCE;
        }else if(!isCancelNormal && SystemUtils.getVersionCode(mContext) < configItem.newestVer){
            Log.i("Jagger" , "UpdateManager isCancelNormal:" + isCancelNormal);
            //封装数据
            mUpdateMessage = new UpdateMessage();
            mUpdateMessage.downloadAppUrl = configItem.downloadAppUrl;
            mUpdateMessage.normalUpdateMsg = configItem.newestMsg;

            return UpdateType.NORMAL;
        }else {
            return UpdateType.NONE;
        }

        //test封装数据
//        mUpdateMessage = new UpdateMessage();
//        mUpdateMessage.downloadAppUrl = "";
//        mUpdateMessage.forceUpdateMsg = "更新";
//        return UpdateType.NORMAL;
    }

    /**
     * 更新信息
     * @return null表示没有更新信息
     */
    public UpdateMessage getUpdateMessage(){
        return mUpdateMessage;
    }

    /**
     * 强制更新
     */
    public void doForceUpdate(){
        LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_FORCE_UPDATE, "");
    }

    /**
     * 普通更新
     */
    public void doNormalUpdate(){
        LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_NORMAL_UPDATE, "");
    }

    /**
     * 取消这次使用过程中的更新提示
     */
    public void setNormalUpdateCancel(){
        isCancelNormal = true;
        Log.i("Jagger" , "UpdateManager setNormalUpdateCancel:" + isCancelNormal);
    }

}
