package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;
import android.util.Log;

import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.livemodule.utils.SystemUtils;

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
        public String downloadAppUrl;
        public String forceUpdateMsg;
        public String normalUpdateMsg;
    }

    //变量
    private Context mContext;
    private UpdateMessage mUpdateMessage;

    public static UpdateManager getInstance(Context c) {
        if (singleton == null) {
            singleton = new UpdateManager(c);
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

        if(SystemUtils.getVersionCode(mContext) < configItem.minAavilableVer){
            //封装数据
            mUpdateMessage = new UpdateMessage();
            mUpdateMessage.downloadAppUrl = configItem.downloadAppUrl;
            mUpdateMessage.forceUpdateMsg = configItem.minAvailableMsg;

            return UpdateType.FORCE;
        }else if(SystemUtils.getVersionCode(mContext) < configItem.newestVer){
            //封装数据
            mUpdateMessage = new UpdateMessage();
            mUpdateMessage.downloadAppUrl = configItem.downloadAppUrl;
            mUpdateMessage.normalUpdateMsg = configItem.newestMsg;

            return UpdateType.NORMAL;
        }else {
            return UpdateType.NONE;
        }
    }

    /**
     * 更新信息
     * @return
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

}
