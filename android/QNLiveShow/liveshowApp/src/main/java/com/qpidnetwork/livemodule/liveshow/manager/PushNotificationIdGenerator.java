package com.qpidnetwork.livemodule.liveshow.manager;

import java.util.HashMap;

/**
 * Created by Hunter Mun on 2017/9/15.
 */

public class PushNotificationIdGenerator {

    //主播邀请通知默认设置
    private static final int NOTIFICATION_ANCHOR_INVITE_BASE_ID = 90000;
    private static final int NOTIFICATION_ANCHOR_INVITE_MAX_COUNT = 10;

    //定时预约通知默认设置
    private static final int NOTIFICATION_SCHEDULE_INVITE_BASE_ID = 100000;
    private static final int NOTIFICATION_SCHEDULE_INVITE_MAX_COUNT = 10;

    //节目开播通知默认设置
    private static final int NOTIFICATION_SHOW_START_BASE_ID = 110000;
    private static final int NOTIFICATION_SHOW_START_MAX_COUNT = 10;

    private HashMap<PushMessageType, Integer> mTypeCurrentIdMap;


    public PushNotificationIdGenerator(){
        mTypeCurrentIdMap = new HashMap<PushMessageType, Integer>();
    }

    /**
     * 生成系统NotificationId
     * @param type
     * @return
     */
    public int generateNotificationId(PushMessageType type){
        int currentNotificationId = 0;
        if(mTypeCurrentIdMap.containsKey(type)){
            currentNotificationId = mTypeCurrentIdMap.get(type);
        }
        switch (type){
            case Anchor_Invite_Notify:{
                currentNotificationId = NOTIFICATION_ANCHOR_INVITE_BASE_ID + ++currentNotificationId%NOTIFICATION_ANCHOR_INVITE_MAX_COUNT;
            }break;
            case Schedule_Invite_Expired:{
                currentNotificationId = NOTIFICATION_SCHEDULE_INVITE_BASE_ID + ++currentNotificationId%NOTIFICATION_SCHEDULE_INVITE_MAX_COUNT;
            }break;
            case Program_Show_Start:{
                currentNotificationId = NOTIFICATION_SHOW_START_BASE_ID + ++currentNotificationId%NOTIFICATION_SHOW_START_MAX_COUNT;
            }break;
        }
        mTypeCurrentIdMap.put(type, currentNotificationId);
        return currentNotificationId;
    }


    public int getNotificationBaseId(PushMessageType type){
        int baseId = -1;
        switch (type){
            case Anchor_Invite_Notify:{
                baseId = NOTIFICATION_ANCHOR_INVITE_BASE_ID;
            }break;
            case Schedule_Invite_Expired:{
                baseId = NOTIFICATION_SCHEDULE_INVITE_BASE_ID;
            }break;
            case Program_Show_Start:{
                baseId = NOTIFICATION_SHOW_START_BASE_ID;
            }break;
        }
        return baseId;
    }

    public int getNotificationMaxCount(PushMessageType type){
        int maxCount = -1;
        switch (type){
            case Anchor_Invite_Notify:{
                maxCount = NOTIFICATION_ANCHOR_INVITE_MAX_COUNT;
            }break;
            case Schedule_Invite_Expired:{
                maxCount = NOTIFICATION_SCHEDULE_INVITE_MAX_COUNT;
            }break;
            case Program_Show_Start:{
                maxCount = NOTIFICATION_SHOW_START_MAX_COUNT;
            }break;
        }
        return maxCount;
    }

}
